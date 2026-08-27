#!/usr/bin/env bash
set -euo pipefail

echo "=== Omarchy Quattro US/UA keyboard setup ==="

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
INPUT_LUA="$CONFIG_DIR/hypr/input.lua"
BINDINGS_LUA="$CONFIG_DIR/hypr/bindings.lua"

if [[ ! -f "$INPUT_LUA" || ! -f "$BINDINGS_LUA" ]]; then
  echo "ERROR: Omarchy Quattro Lua config was not found."
  echo "Expected: $INPUT_LUA and $BINDINGS_LUA"
  exit 1
fi

backup_file() {
  local file="$1"
  local backup="${file}.bak.$(date +%s)"
  cp -a "$file" "$backup"
  echo "Backed up $file to $backup"
}

input_backed_up=0
bindings_backed_up=0

set_input_value() {
  local key="$1"
  local value="$2"

  if ! grep -Fq "$key = \"$value\"" "$INPUT_LUA"; then
    if (( input_backed_up == 0 )); then
      backup_file "$INPUT_LUA"
      input_backed_up=1
    fi
    sed -i -E "s|^[[:space:]]*${key}[[:space:]]*=.*$|    ${key} = \"${value}\",|" "$INPUT_LUA"
  fi
}

ensure_binding() {
  local binding="$1"

  if ! grep -Fq "$binding" "$BINDINGS_LUA"; then
    if (( bindings_backed_up == 0 )); then
      backup_file "$BINDINGS_LUA"
      bindings_backed_up=1
    fi
    printf '\n%s\n' "$binding" >> "$BINDINGS_LUA"
  fi
}

if ! grep -Eq '^[[:space:]]*kb_layout[[:space:]]*=' "$INPUT_LUA" || \
   ! grep -Eq '^[[:space:]]*kb_options[[:space:]]*=' "$INPUT_LUA"; then
  echo "ERROR: $INPUT_LUA does not contain the expected input block."
  exit 1
fi

set_input_value "kb_layout" "us,ua"
set_input_value "kb_options" "compose:caps,shift:both_capslock_cancel"

# Both release orders are needed for Left Alt + Left Shift.
ensure_binding 'o.bind("ALT + SHIFT + SHIFT_L", "Switch keyboard layout", "hyprctl switchxkblayout all next", { release = true })'
ensure_binding 'o.bind("ALT + SHIFT + ALT_L", "Switch keyboard layout", "hyprctl switchxkblayout all next", { release = true })'

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 || true
fi

echo "US/UA layouts configured in Hyprland Lua."
echo "Switch layouts with Left Alt + Left Shift."
echo "The language indicator is provided by Omarchy's built-in bar plugin."
