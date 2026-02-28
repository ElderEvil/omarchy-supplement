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
    
     if ! grep -A 5 '"hyprland/language":' "$WAYBAR_CONFIG" | grep -q '"on-click"'; then
          echo "⚠ Adding on-click functionality to language indicator..."
          backup_file "$WAYBAR_CONFIG"
          
          # 3-tier keyboard detection: (1) main: yes device, (2) fcitx5 virtual keyboard,
          # (3) first real keyboard. Needed because some systems (e.g., Framework Laptop
          # with fcitx5) have no keyboard marked main: yes, requiring fallback detection.
          
          # Strategy 1: Look for device marked as main: yes
          KEYBOARD_DEVICE=$(hyprctl devices | sed -n '/^Keyboards:/,/^[A-Z]/p' | awk '
              /^		[a-z]/ { device=$1 }
              /main: yes/ { print device; exit }
          ')
          
          # Strategy 2: Fallback to fcitx5 virtual keyboard if present
          if [ -z "$KEYBOARD_DEVICE" ]; then
              KEYBOARD_DEVICE=$(hyprctl devices | sed -n '/^Keyboards:/,/^[A-Z]/p' | awk '
                  /^		hl-virtual-keyboard-fcitx5/ { print $1; exit }
              ')
          fi
          
          # Strategy 3: Fallback to first real keyboard (exclude system/virtual devices)
          if [ -z "$KEYBOARD_DEVICE" ]; then
              KEYBOARD_DEVICE=$(hyprctl devices | sed -n '/^Keyboards:/,/^[A-Z]/p' | awk '
                  /^		[a-z]/ { 
                      device=$1
                      if (device ~ /video-bus|power-button|system-control|consumer-control|wireless-radio/) {
                          device=""
                      }
                  }
                  /rules:.*l "us,ua"/ && device != "" { 
                      print device
                      exit
                  }
              ')
          fi
          
          if [ -z "$KEYBOARD_DEVICE" ]; then
              echo "✗ ERROR: Could not detect keyboard device"
              echo "  Please check: hyprctl devices"
              echo "  And manually set the device in waybar config"
              exit 1
          fi
         
         sed -i '/"hyprland/language": {/,/},\?$/c\  "hyprland/language": {\n    "format": "{}",\n    "format-en": "US",\n    "format-ua": "UA",\n    "on-click": "hyprctl switchxkblayout '"$KEYBOARD_DEVICE"' next"\n  },' "$WAYBAR_CONFIG"
         
         echo "✓ Added on-click functionality to language indicator"
    else
        echo "✓ Language indicator already has on-click configured"
    fi
else
    echo "⚠ Adding language indicator to waybar..."
    backup_file "$WAYBAR_CONFIG"
    
    awk '
        /"modules-right": \[/ {
            print
            print "    \"hyprland/language\","
            next
        }
        { print }
    ' "$WAYBAR_CONFIG" > "${WAYBAR_CONFIG}.tmp" && mv "${WAYBAR_CONFIG}.tmp" "$WAYBAR_CONFIG"
    
     if ! grep -q '"hyprland/language":' "$WAYBAR_CONFIG"; then
          # 3-tier keyboard detection: (1) main: yes device, (2) fcitx5 virtual keyboard,
          # (3) first real keyboard. Needed because some systems (e.g., Framework Laptop
          # with fcitx5) have no keyboard marked main: yes, requiring fallback detection.
          
          # Strategy 1: Look for device marked as main: yes
          KEYBOARD_DEVICE=$(hyprctl devices | sed -n '/^Keyboards:/,/^[A-Z]/p' | awk '
              /^		[a-z]/ { device=$1 }
              /main: yes/ { print device; exit }
          ')
          
          # Strategy 2: Fallback to fcitx5 virtual keyboard if present
          if [ -z "$KEYBOARD_DEVICE" ]; then
              KEYBOARD_DEVICE=$(hyprctl devices | sed -n '/^Keyboards:/,/^[A-Z]/p' | awk '
                  /^		hl-virtual-keyboard-fcitx5/ { print $1; exit }
              ')
          fi
          
          # Strategy 3: Fallback to first real keyboard (exclude system/virtual devices)
          if [ -z "$KEYBOARD_DEVICE" ]; then
              KEYBOARD_DEVICE=$(hyprctl devices | sed -n '/^Keyboards:/,/^[A-Z]/p' | awk '
                  /^		[a-z]/ { 
                      device=$1
                      if (device ~ /video-bus|power-button|system-control|consumer-control|wireless-radio/) {
                          device=""
                      }
                  }
                  /rules:.*l "us,ua"/ && device != "" { 
                      print device
                      exit
                  }
              ')
          fi
          
          if [ -z "$KEYBOARD_DEVICE" ]; then
              echo "✗ ERROR: Could not detect keyboard device"
              echo "  Please check: hyprctl devices"
              echo "  And manually set the device in waybar config"
              exit 1
          fi
        
        awk -v kb="$KEYBOARD_DEVICE" '
            /^}$/ {
                print "  \"hyprland/language\": {"
                print "    \"format\": \"{}\","
                print "    \"format-en\": \"US\","
                print "    \"format-ua\": \"UA\","
                print "    \"on-click\": \"hyprctl switchxkblayout " kb " next\""
                print "  },"
            }
            { print }
        ' "$WAYBAR_CONFIG" > "${WAYBAR_CONFIG}.tmp" && mv "${WAYBAR_CONFIG}.tmp" "$WAYBAR_CONFIG"
    fi
    
    echo "✓ Added clickable language indicator to waybar config"
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
