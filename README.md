# OpenBMC

[![Build Status](https://jenkins.openbmc.org/buildStatus/icon?job=latest-master)](https://jenkins.openbmc.org/job/latest-master/)

OpenBMC is a Linux distribution for management controllers used in devices such
as servers, top of rack switches or RAID appliances. It uses
[Yocto](https://www.yoctoproject.org/),
[OpenEmbedded](https://www.openembedded.org/wiki/Main_Page),
[systemd](https://www.freedesktop.org/wiki/Software/systemd/), and
[D-Bus](https://www.freedesktop.org/wiki/Software/dbus/) to allow easy
customization for your platform.

## Setting up your OpenBMC project

### 1) Prerequisite

See the
[Yocto documentation](https://docs.yoctoproject.org/ref-manual/system-requirements.html#required-packages-for-the-build-host)
for the latest requirements

#### Ubuntu

```sh
sudo apt install git python3-distutils gcc g++ make file wget \
    gawk diffstat bzip2 cpio chrpath zstd lz4 bzip2
```

#### Fedora

```sh
sudo dnf install git python3 gcc g++ gawk which bzip2 chrpath cpio \
    hostname file diffutils diffstat lz4 wget zstd rpcgen patch
```

### 2) Download the source

```sh
git clone https://github.com/linux4sam/openbmc-mchp.git
cd openbmc-mchp
```

### 3) Target your hardware

Any build requires an environment set up according to your hardware target.
There is a special script in the root of this repository that can be used to
configure the environment as needed. The script is called `setup` and takes the
name of your hardware target as an argument.

The script needs to be sourced while in the top directory of the OpenBMC
repository clone, and, if run without arguments, will display the list of
supported hardware targets, see the following example:

```text
$ . setup <machine> [build_dir]
Target machine must be specified. Use one of:
...
```

Microchip supported machines are:
- sam9x60-curiosity-sd
- sam9x60ek-sd
- sam9x75-curiosity-sd
- sama5d27-som1-ek-sd
- sama5d27-wlsom1-ek-sd
- sama5d29-curiosity-sd
- sama7d65-curiosity-sd
- sama7g5ek-sd

Other supported machines can be found under
[meta-phosphor/docs](https://github.com/openbmc/openbmc/blob/master/meta-phosphor/docs/supported-machines.md).

Once you know the target (e.g. sam9x75-curiosity-sd), source the `setup` script as follows:

```sh
. setup sam9x75-curiosity-sd
```

### 4) Build

```sh
bitbake obmc-phosphor-image
```

Additional details can be found in the [docs](https://github.com/openbmc/docs)
repository.

## OpenBMC Development

The OpenBMC community maintains a set of tutorials new users can go through to
get up to speed on OpenBMC development out
[here](https://github.com/openbmc/docs/blob/master/development/README.md)

## Features of OpenBMC

### Feature List

- Host management: Power, Cooling, LEDs, Inventory, Events, Watchdog
- Full IPMI 2.0 Compliance with DCMI
- Code Update Support for multiple BMC/BIOS images
- Web-based user interface
- REST interfaces
- D-Bus based interfaces
- SSH based SOL
- Remote KVM
- Hardware Simulation
- Automated Testing
- User management
- Virtual media

### Features In Progress

- OpenCompute Redfish Compliance
- Verified Boot

### Features Requested but need help

- OpenBMC performance monitoring

## Finding out more

Dive deeper into OpenBMC by opening the [docs](https://github.com/openbmc/docs)
repository.

Please refer to https://github.com/openbmc/openbmc for general OpenBMC information on build validation and testing, submitting patches, bug reporting, questions and contact.
