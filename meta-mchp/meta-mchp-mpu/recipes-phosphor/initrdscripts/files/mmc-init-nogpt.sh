#!/bin/sh

echo "Non-GPT mmc initialization script start"

kgetopt ()
{
    _cmdline="$(cat /proc/cmdline)"
    _optname="$1"
    _optval="$2"
    for _opt in $_cmdline
    do
        case "$_opt" in
            "${_optname}"=*)
                _optval="${_opt##"${_optname}"=}"
                ;;
            *)
                ;;
        esac
    done
    [ -n "$_optval" ] && echo "$_optval"
}

fslist="proc sys dev run"
rodir=/mnt/rofs
mmcdev="/dev/@MMC_DEV@"
rwfsdev="/dev/disk/by-label/rwfs"

cd /

# We want to make all the directories in $fslist, not one directory named by
# concatonating the names with spaces
#
# shellcheck disable=SC2086
mkdir -p $fslist

mount dev dev -tdevtmpfs
mount sys sys -tsysfs
mount proc proc -tproc
mount tmpfs run -t tmpfs -o mode=755,nodev

# Wait up to 5s for the mmc device to appear. Continue even if the count is
# exceeded. A failure will be caught later like in the mount command.
count=0
while [ $count -lt 5 ]; do
    if [ -e "${mmcdev}" ]; then
        break
    fi
    sleep 1
    count=$((count + 1))
done

udevd --daemon
udevadm trigger --type=devices --action=add
udevadm settle --timeout=10
udevadm control --exit

mkdir -p $rodir
if ! mount /dev/disk/by-label/"$(kgetopt root=LABEL)" $rodir -t ext4 -o ro; then
    /bin/sh
fi

# Determine if a factory reset has been requested
mkdir -p /var/lock
resetval=$(fw_printenv -n rwreset 2>/dev/null)
if gpiopresent=$(gpiofind factory-reset-toggle) ; then
    # gpiopresent contains both the gpiochip and line number as
    # separate words, and gpioget needs to see them as such.
    # shellcheck disable=SC2086
    gpioval=$(gpioget $gpiopresent)
else
    gpioval=""
fi
# Prevent unnecessary resets on first boot
if [ -n "$gpioval" ] && [ -z "$resetval" ]; then
    fw_setenv rwreset "$gpioval"
    resetval=$gpioval
fi
if [ "$resetval" = "true" ] || [ -n "$gpioval" ] && [ "$resetval" != "$gpioval" ]; then
    echo "Factory reset requested."
    if ! mkfs.ext4 -F "${rwfsdev}"; then
        echo "Reformat for factory reset failed."
        /bin/sh
    else
        # gpioval will be an empty string if factory-reset-toggle was not found
        fw_setenv rwreset "$gpioval"
        echo "rwfs has been formatted."
    fi
fi

fsck.ext4 -p "${rwfsdev}"
if ! mount "${rwfsdev}" $rodir/var -t ext4 -o rw; then
    /bin/sh
fi

rm -rf $rodir/var/persist/etc-work/
mkdir -p $rodir/var/persist/etc $rodir/var/persist/etc-work $rodir/var/persist/home/root
mount overlay $rodir/etc -t overlay -o lowerdir=$rodir/etc,upperdir=$rodir/var/persist/etc,workdir=$rodir/var/persist/etc-work

init="$(kgetopt init /sbin/init)"

for f in $fslist; do
    mount --move "$f" "$rodir/$f"
done

exec switch_root $rodir "$init"
