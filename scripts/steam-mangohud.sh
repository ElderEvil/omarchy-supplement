#!/bin/bash
# Steam game launcher with MangoHud overlay
# Usage: steam-mangohud "Game Name"
# Or: steam-mangohud --appid 123456

find_games() {
    for manifest in ~/.local/share/Steam/steamapps/appmanifest_*.acf; do
        appid=$(sed -n 's/.*"appid"[[:space:]]*"\([0-9]*\)".*/\1/p' "$manifest")
        name=$(sed -n 's/.*"name"[[:space:]]*"\([^"]*\)".*/\1/p' "$manifest")
        if [[ -n "$name" ]] && [[ -n "$appid" ]] && [[ "$name" != *"Steam Linux Runtime"* ]]; then
            echo "$appid|$name"
        fi
    done
}

GAME_NAME=""
APPID=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --appid)
            APPID="$2"
            shift 2
            ;;
        -l|--list)
            echo "Installed games:"
            find_games | while IFS='|' read -r id name; do
                printf "%-10s %s\n" "$id" "$name"
            done
            exit 0
            ;;
        *)
            GAME_NAME="$1"
            shift
            ;;
    esac
done

if [[ -z "$APPID" ]] && [[ -n "$GAME_NAME" ]]; then
    APPID=$(find_games | grep -i "$GAME_NAME" | head -1 | cut -d'|' -f1)
fi

if [[ -z "$APPID" ]]; then
    echo "Usage: steam-mangohud \"Game Name\""
    echo "   or: steam-mangohud --appid 123456"
    echo "   or: steam-mangohud --list"
    echo ""
    find_games | while IFS='|' read -r id name; do
        printf "%-10s %s\n" "$id" "$name"
    done
    exit 1
fi

GAME_NAME=$(find_games | grep "^$APPID|" | cut -d'|' -f2-)

echo "Launching game with MangoHud: $GAME_NAME (AppID: $APPID)"
mangohud --dlsym steam -applaunch "$APPID" "$@"
