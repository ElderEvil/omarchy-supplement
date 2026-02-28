#!/bin/bash

set -e

echo "Installing steam-mangohud..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f ~/.local/bin/steam-mangohud ]]; then
    cp "$SCRIPT_DIR/scripts/steam-mangohud.sh" ~/.local/bin/steam-mangohud
    chmod +x ~/.local/bin/steam-mangohud
fi

echo "Done!"
echo ""
echo "Usage:"
echo "  steam-mangohud \"Brotato\"           - Launch game by name"
echo "  steam-mangohud --appid 1942280      - Launch by AppID"
echo "  steam-mangohud --list               - List installed games"
