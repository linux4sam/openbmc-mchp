/*
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the disclaimer below.
 * 
 * Microchip's name may not be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * DISCLAIMER: THIS SOFTWARE IS PROVIDED BY MICROCHIP "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT ARE
 * DISCLAIMED. IN NO EVENT SHALL MICROCHIP BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include <systemd/sd-bus.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

static int get_pgood(sd_bus *bus, const char *path, const char *interface,
                     const char *property, sd_bus_message *reply, void *userdata, sd_bus_error *ret_error) {
    // Always return 1 (power good)
    return sd_bus_message_append(reply, "i", 1);
}

static const sd_bus_vtable power_vtable[] = {
    SD_BUS_VTABLE_START(0),
    SD_BUS_PROPERTY("pgood", "i", get_pgood, 0, 0),
    SD_BUS_VTABLE_END
};

int main(void) {
    sd_bus *bus = NULL;
    sd_bus_slot *slot = NULL;
    int r;

    // Connect to the system bus
    r = sd_bus_open_system(&bus);
    if (r < 0) {
        fprintf(stderr, "Failed to connect to system bus: %s\n", strerror(-r));
        return 1;
    }

    // Request the service name
    r = sd_bus_request_name(bus, "org.openbmc.control.Power", 0);
    if (r < 0) {
        fprintf(stderr, "Failed to acquire service name: %s\n", strerror(-r));
        sd_bus_unref(bus);
        return 1;
    }

    // Export the dummy object at /org/openbmc/control/power0
    r = sd_bus_add_object_vtable(
        bus,
        &slot,
        "/org/openbmc/control/power0",
        "org.openbmc.control.Power",
        power_vtable,
        NULL
    );
    if (r < 0) {
        fprintf(stderr, "Failed to add object vtable: %s\n", strerror(-r));
        sd_bus_unref(bus);
        return 1;
    }

    printf("Dummy power control D-Bus service running with pgood property.\n");
    // Main loop
    while (1) {
        r = sd_bus_process(bus, NULL);
        if (r < 0) {
            fprintf(stderr, "Failed to process bus: %s\n", strerror(-r));
            break;
        }
        if (r > 0) // we processed a request, try again right away
            continue;
        sd_bus_wait(bus, (uint64_t) -1);
    }

    sd_bus_slot_unref(slot);
    sd_bus_unref(bus);
    return 0;
}