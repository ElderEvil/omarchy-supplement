#!/bin/bash
set -euo pipefail

echo "=== Keyboard Layout Switch & Indicator Setup ==="
echo

CONFIG_DIR="$HOME/.config"
HYPR_INPUT="$CONFIG_DIR/hypr/input.conf"
WAYBAR_CONFIG="$CONFIG_DIR/waybar/config.jsonc"
WAYBAR_STYLE="$CONFIG_DIR/waybar/style.css"

backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.bak.$(date +%s)"
        cp "$file" "$backup"
        echo "✓ Backed up: $backup"
    fi
}

echo "1. Checking Hyprland input configuration..."
if grep -q "kb_layout = us,ua" "$HYPR_INPUT" && \
   grep -q "grp:alt_shift_toggle" "$HYPR_INPUT"; then
    echo "✓ Keyboard layouts already configured (us,ua with Alt+Shift toggle)"
else
    echo "⚠ Keyboard layouts not found, configuring..."
    backup_file "$HYPR_INPUT"
    
    if grep -q "kb_layout =" "$HYPR_INPUT"; then
        sed -i 's/kb_layout = .*/kb_layout = us,ua/' "$HYPR_INPUT"
    else
        sed -i '/input {/a \  kb_layout = us,ua' "$HYPR_INPUT"
    fi
    
    if grep -q "kb_options =" "$HYPR_INPUT"; then
        sed -i 's/kb_options = .*/kb_options = compose:caps ,grp:alt_shift_toggle/' "$HYPR_INPUT"
    else
        sed -i '/kb_layout/a \  kb_options = compose:caps ,grp:alt_shift_toggle' "$HYPR_INPUT"
    fi
    
    echo "✓ Configured keyboard layouts"
fi

echo
echo "2. Checking Waybar language indicator..."
if grep -q '"hyprland/language"' "$WAYBAR_CONFIG"; then
    echo "✓ Language indicator already in waybar config"
else
    echo "⚠ Adding language indicator to waybar..."
    backup_file "$WAYBAR_CONFIG"
    
    sed -i '/"modules-right": \[/,/\]/ {
        /"modules-right": \[/a\    "hyprland/language",
    }' "$WAYBAR_CONFIG"
    
    if ! grep -q '"hyprland/language":' "$WAYBAR_CONFIG"; then
        cat >> "$WAYBAR_CONFIG" <<'EOF'
  "hyprland/language": {
    "format": "{}",
    "format-en": "US",
    "format-ua": "UK-UA"
  },
EOF
    fi
    
    echo "✓ Added language indicator to waybar config"
fi

echo
echo "3. Checking Waybar CSS styling..."
if grep -q "#language {" "$WAYBAR_STYLE"; then
    echo "✓ Language indicator styling already configured"
else
    echo "⚠ Adding language indicator styling..."
    backup_file "$WAYBAR_STYLE"
    
    if grep -q "#bluetooth {" "$WAYBAR_STYLE"; then
        sed -i '/#bluetooth {/i #language {\n  margin-right: 12px;\n}\n' "$WAYBAR_STYLE"
    else
        cat >> "$WAYBAR_STYLE" <<'EOF'

#language {
  margin-right: 12px;
}
EOF
    fi
    
    echo "✓ Added language indicator styling"
fi

echo
echo "4. Restarting services..."
if command -v hyprctl &> /dev/null; then
    hyprctl reload &> /dev/null || true
    echo "✓ Hyprland reloaded"
fi

if command -v omarchy-restart-waybar &> /dev/null; then
    omarchy-restart-waybar &> /dev/null || killall waybar 2>/dev/null || true
    echo "✓ Waybar restarted"
fi

echo
echo "=== Setup Complete ==="
echo
echo "Keyboard Layouts:"
echo "  • US English (default)"
echo "  • Ukrainian (UK-UA)"
echo
echo "Switch layouts: Alt + Shift"
echo "Indicator location: Top-right corner of waybar"
echo
echo "To modify layouts, edit: $HYPR_INPUT"
echo "To modify indicator, edit: $WAYBAR_CONFIG"
