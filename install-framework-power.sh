#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Framework 16 power profile switcher..."

mkdir -p ~/.config/omarchy/scripts

cp "$SCRIPT_DIR/scripts/framework-dock-status.sh" ~/.config/omarchy/scripts/
cp "$SCRIPT_DIR/scripts/framework-power-switch.sh" ~/.config/omarchy/scripts/

chmod +x ~/.config/omarchy/scripts/framework-dock-status.sh
chmod +x ~/.config/omarchy/scripts/framework-power-switch.sh

if ! grep -q "framework-power-switch" ~/.config/hypr/bindings.conf 2>/dev/null; then
    echo "" >> ~/.config/hypr/bindings.conf
    echo "# Framework 16 power profile switch (Super + Shift + P)" >> ~/.config/hypr/bindings.conf
    echo "bindd = SUPER SHIFT, P, Power profile, exec, ~/.config/omarchy/scripts/framework-power-switch.sh" >> ~/.config/hypr/bindings.conf
fi

echo "Done! Use Super+Shift+P to manually switch power profiles."
