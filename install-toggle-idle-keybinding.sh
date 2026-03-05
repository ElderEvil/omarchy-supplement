#!/bin/sh
# Adds SUPER+I keybinding to toggle idle management (screen lock, suspend)

BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"

# Prevent duplicate keybindings
if grep -q "omarchy-toggle-idle" "$BINDINGS_FILE" 2>/dev/null; then
    echo "Toggle idle keybinding already exists in $BINDINGS_FILE"
    exit 0
fi

cat >> "$BINDINGS_FILE" <<EOF

# Toggle idle management (screen lock, suspend, etc.)
bind = SUPER, I, exec, omarchy-toggle-idle
EOF

echo "Added toggle idle keybinding (SUPER + I) to $BINDINGS_FILE"
echo "Press SUPER + I to toggle idle management on/off"
