#!/bin/bash

# Framework 16 power profile switcher
# Automatically switches between performance (docked) and power-saver (undocked)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCK_STATUS="$("$SCRIPT_DIR/framework-dock-status.sh")"

if [[ "$DOCK_STATUS" == "docked" ]]; then
    powerprofilesctl set performance
    notify-send "Docked Mode" "Performance profile activated" -u low
else
    powerprofilesctl set power-saver
    notify-send "Battery Mode" "Power-saver profile activated" -u low
fi
