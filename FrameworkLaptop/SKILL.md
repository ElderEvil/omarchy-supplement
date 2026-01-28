---
name: FrameworkLaptop
description: >
  Framework laptop hardware-specific knowledge, quirks, and troubleshooting.
  Use for expansion card issues, DisplayPort problems, USB-C charging,
  firmware updates, hardware diagnostics, or any Framework-specific hardware questions.
---

# FrameworkLaptop Skill

Hardware-specific knowledge for Framework Laptop systems.

## When This Skill MUST Be Used

**ALWAYS invoke this skill when the user's request involves:**

- Expansion card troubleshooting (DisplayPort, USB-C, storage, etc.)
- Monitor not detected or DisplayPort issues
- USB-C charging or power delivery problems
- Framework-specific hardware diagnostics
- Firmware or BIOS updates
- Expansion card slot configuration
- GPU switching (iGPU vs discrete)
- Framework hardware quirks and known issues

## System Information

### Hardware Specifications

```
Model: Laptop 16 (AMD Ryzen 7040 Series)
Product: 16in Laptop
CPU: AMD Ryzen 7 7840HS (16 cores) @ 5.14 GHz
iGPU: AMD Radeon 780M Graphics (Integrated)
dGPU: AMD Radeon RX 7700S (Discrete) - Navi 33
Display: 2560x1600 @ 165Hz (Built-in)
BIOS Version: 03.05
USB Vendor ID: 32ac (Framework)
```

### Detected Framework Hardware

```
- Laptop 16 Keyboard Module - ANSI (32ac:0012)
- DisplayPort Expansion Card (32ac:0003)
```

### Power System

```
Main Battery: BAT1
AC Adapter: ACAD
USB-C PD Ports: 4 (USBC000:001 through USBC000:004)
```

### GPU Configuration

The Framework 16 has dual GPUs:
- **Integrated**: AMD Radeon 780M (Phoenix1) - PCI device c4:00.0
- **Discrete**: AMD Radeon RX 7700S (Navi 33) - PCI device 03:00.0

Both are active. Check which GPU a display is using:
```bash
# List all displays and their GPU assignments
hyprctl monitors all
cat /sys/class/drm/card*/status
```

## Known Issues and Quirks

### DisplayPort Expansion Card

**Symptom**: External monitor shows "No Signal" or not detected by system.

**Common Causes**:
1. **Expansion card slot matters** - Some slots have better GPU connectivity
   - Far-left slot tends to work most reliably for DisplayPort
   - PCIe lanes are distributed differently across the 6 expansion bays
   - If a monitor isn't working, try moving the card to different slots

2. **USB suspend issues** - DisplayPort cards can enter suspended state
   - Check status: `cat /sys/class/drm/card1-DP-1/status`
   - Check EDID: `cat /sys/class/drm/card1-DP-1/edid | od -A x -t x1z`
   - If no EDID data, monitor isn't communicating with card

3. **Billboard mode fallback** - Card detected but not negotiating DP alternate mode
   - Check with: `lsusb -v | grep -A 5 "DisplayPort Expansion Card"`
   - If showing "Billboard" class, it's in fallback mode (not working)

**Troubleshooting Steps**:
```bash
# 1. Check if monitor is detected
hyprctl monitors all

# 2. Check DisplayPort connection status
find /sys/devices -name "card*-DP-*" -type d 2>/dev/null
cat /sys/class/drm/card*/card*-DP-*/status

# 3. Check for EDID data (monitor communication)
cat /sys/class/drm/card*-DP-*/edid | od -A x -t x1z | head -5

# 4. Physical checks (ask user to try):
# - Verify monitor input source is set to DisplayPort
# - Unplug and replug cable at both ends
# - Remove and reinsert expansion card (must click in)
# - Try expansion card in a different slot (far-left often best)
# - Power cycle monitor (unplug power for 30s)
```

### Expansion Card Slots

Framework 16 has 6 expansion card bays. The slots are NOT equal:
- Some have direct CPU connection
- Some route through chipset
- DisplayPort cards work better in certain positions
- **Far-left position** tends to be most reliable for DisplayPort

To identify which USB bus a card is on:
```bash
lsusb -t
# Look for Framework devices (vendor 32ac)
```

### USB-C Charging

Framework 16 has 4 USB-C ports that support Power Delivery:
```bash
# Check which ports are receiving power
ls -la /sys/class/power_supply/ucsi-source-psy-USBC000:00*/
cat /sys/class/power_supply/ucsi-source-psy-USBC000:001/online
```

### Firmware Updates

Check BIOS version:
```bash
cat /sys/class/dmi/id/bios_version
# Current: 03.05
```

Official firmware: https://frame.work/laptop-16-bios

### Battery Information

```bash
# Check battery status
cat /sys/class/power_supply/BAT1/status
cat /sys/class/power_supply/BAT1/capacity

# Check AC adapter
cat /sys/class/power_supply/ACAD/online
```

## Diagnostic Commands

### Quick Hardware Check

```bash
# Framework-specific system info
fastfetch --pipe | grep -A 20 "Hardware"

# Framework USB devices
lsusb | grep "32ac:"

# Display outputs
hyprctl monitors all
find /sys/class/drm -name "card*-*" -type d

# GPU information
lspci | grep -E "(VGA|Display)"

# Power/battery
ls -la /sys/class/power_supply/
```

### Expansion Card Debugging

```bash
# List all expansion cards (Framework USB devices)
lsusb -v -d 32ac: 2>&1 | grep -E "(idProduct|iProduct|bInterface)"

# Check USB topology to identify slot positions
lsusb -t | grep -B 3 "32ac"

# DisplayPort card specific
cat /sys/class/drm/card*-DP-*/status
cat /sys/class/drm/card*-DP-*/enabled
cat /sys/class/drm/card*-DP-*/modes
```

## Common Tasks

### Configure External Monitor

After monitor is detected (shows in `hyprctl monitors all`):

Edit `~/.config/hypr/monitors.conf`:
```
# Framework 16 internal display
monitor = eDP-2, 2560x1600@165, auto, 1.67

# External monitor (adjust resolution/refresh as needed)
monitor = DP-4, 2560x1440@144, auto, 1

# Fallback
monitor =, preferred, auto, 1.67
```

### Check GPU Usage

```bash
# See which GPU is handling displays
hyprctl monitors all

# AMD GPU stats
radeontop  # If installed

# GPU power state
cat /sys/class/drm/card0/device/power_state
cat /sys/class/drm/card1/device/power_state
```

## Resources

- Framework Community: https://community.frame.work/
- Framework Laptop 16 Docs: https://guides.frame.work/
- Linux Compatibility: https://wiki.archlinux.org/title/Framework_Laptop_16
- BIOS Updates: https://frame.work/laptop-16-bios
- Expansion Card Marketplace: https://frame.work/marketplace/expansion-cards

## Adding More Information

This is a PoC. To add more details:

1. **Edit this file**: `/home/elder/.claude/skills/FrameworkLaptop/SKILL.md`
2. **Add sections** for new hardware quirks you discover
3. **Update hardware info** after firmware updates or hardware changes
4. **Document workarounds** for specific issues you encounter

Run these commands to get fresh system info:
```bash
fastfetch --pipe
lspci
lsusb | grep "32ac:"
cat /sys/class/dmi/id/bios_version
```
