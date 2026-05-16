# omarchy-supplement

Supplemental files and configurations for the Omarchy project.

## What's Here

### Supplemental Packages
Run `./install-all.sh` or individual scripts for packages not covered by Omarchy's built-in installer:

- **stow** — dotfile symlink manager
- **diskus** — fast `du` alternative
- **hyperfine** — benchmarking tool
- **tokei** — code statistics
- **mangohud** — Vulkan/OpenGL overlay
- **syncthing** — file synchronization
- **telegram-desktop** — Telegram client
- **bitwarden** — password manager

### Superseded by Omarchy 3.8
These are now built-in — use the official commands instead:

| Former script | Omarchy 3.8 command |
|---|---|
| `install-zen-browser.sh` | `omarchy install browser zen` |
| `install-zed-editor.sh` | `omarchy install editor zed` |

### Waybar Weather Module

Omarchy 3.8 ships a live weather widget in Waybar via `wttr.in`. It shows a day/night-aware weather icon and updates every 60 seconds.

**Config** (`~/.config/waybar/config.jsonc`):
```jsonc
"custom/weather": {
  "exec": "$OMARCHY_PATH/default/waybar/weather.sh",
  "return-type": "json",
  "interval": 60,
  "tooltip": false,
  "on-click": "notify-send -u low \"$(omarchy-weather-status)\""
}
```

**Styling** (`~/.config/waybar/style.css`):
```css
#custom-weather {
  margin-left: 13px;
  margin-right: 13px;
}

#custom-weather.unavailable {
  min-width: 0;
  margin: 0;
  padding: 0;
}
```

Add `"custom/weather"` to any `modules-*` array to place it. Click the icon for a detailed notification.
