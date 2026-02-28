#!/bin/bash

# Framework 16 dock detection based on USB-C PD ports
# Returns "docked" if any USB-C port is charging, "undocked" otherwise

docked=false

for port in /sys/class/power_supply/ucsi-source-psy-USBC000:001/online \
            /sys/class/power_supply/ucsi-source-psy-USBC000:002/online \
            /sys/class/power_supply/ucsi-source-psy-USBC000:003/online \
            /sys/class/power_supply/ucsi-source-psy-USBC000:004/online; do
    if [[ -f "$port" ]] && [[ "$(cat "$port" 2>/dev/null)" == "1" ]]; then
        docked=true
        break
    fi
done

if $docked; then
    echo "docked"
else
    echo "undocked"
fi
