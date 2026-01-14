# Decorp Alternatives Installation Plan

## Overview
A comprehensive plan to replace corporate services with privacy-focused, open-source alternatives on Arch Linux.

## Service Replacements

| Corporate Service | Alternative | Package | Installation Method | Notes |
|---------------|-------------|----------|------------------|---------|
| Gmail | Proton Mail | `proton-mail-bin` | AUR - Encrypted email, Swiss privacy |
| Google Maps | Organic Maps | `organicmaps` | AUR - Offline maps, OpenStreetMap data |
| Google Drive | Syncthing | `syncthing` | Official Arch repo - P2P file sync |
| Google Photos | Immich | Client/Web access | **Server runs on user's server** |
| ChatGPT Web | Open WebUI | `open-webui` | AUR - Local AI chat interface, separate app |
| Google Search | DuckDuckGo | Browser setting | No installation needed |
| Google Chrome | Zen Browser | `zen-browser-bin` | Already installed, privacy-focused |

## Installation Scripts

### 1. `install-degoogle-alternatives.sh`
```bash
#!/bin/sh

echo "Installing privacy-focused corporate alternatives..."

# Install Proton Mail (email alternative)
yay -S --noconfirm --needed proton-mail-bin

# Install Organic Maps (offline maps alternative)  
yay -S --noconfirm --needed organicmaps

# Install Syncthing (file sync alternative)
yay -S --noconfirm --needed syncthing

# Install Open WebUI (ChatGPT alternative)
yay -S --noconfirm --needed open-webui

# Note: Immich server runs on user's server
# Client access via web browser or mobile app
echo "Immich server access: Use web browser at your server URL or mobile app"
```

### 2. `setup-degoogle-privacy.sh` (configuration script)
```bash
#!/bin/sh

echo "Configuring privacy-focused defaults..."

# Set default browser for privacy
# (Configure in desktop environment settings)

# Configure DuckDuckGo as default search engine
# (Configure in browser settings)

# Set up Syncthing autostart
systemctl --user enable syncthing
systemctl --user start syncthing

# Create desktop shortcuts for alternatives
# (Optional desktop entries)

echo "Privacy setup complete!"
echo "Access points:"
echo "- Proton Mail: Launch from applications menu"
echo "- Organic Maps: Launch from applications menu"  
echo "- Syncthing: http://localhost:8384"
echo "- Open WebUI: http://localhost:3000 (after starting service)"
echo "- Immich: Your server URL in web browser"
```

## Service Details

### Proton Mail
- **Package**: `proton-mail-bin` (AUR, 44 votes)
- **Features**: End-to-end encrypted email, calendar integration
- **Installation**: Desktop app for Proton services
- **Requirements**: Proton account (free tier available)

### Organic Maps
- **Package**: `organicmaps` (AUR, 2 votes, actively maintained)
- **Features**: Offline maps, hiking trails, cycling routes, turn-by-turn navigation
- **Data**: OpenStreetMap (crowd-sourced, privacy-focused)
- **Advantages**: No ads, no tracking, works completely offline

### Syncthing
- **Package**: `syncthing` (Official Arch repository)
- **Features**: P2P file synchronization, no central server
- **Advantages**: Private, encrypted, cross-platform
- **Access**: Web interface at http://localhost:8384

### Immich
- **Server**: Self-hosted (user's server)
- **Client Access**: Web browser or mobile app
- **Features**: Photo management, facial recognition, automatic backup
- **Setup**: No local installation needed for client

### Open WebUI
- **Package**: `open-webui` (AUR, 23 votes, actively maintained)
- **Features**: Local AI chat interface, OpenAI API compatible, supports Ollama
- **Installation**: Web-based application, runs as separate service
- **Access**: http://localhost:3000 (after starting service)
- **Advantages**: Runs locally, no data sent to external services, supports multiple LLMs
- **Setup**: Requires `systemctl --user enable --now open-webui` or manual start
- **Note**: Can be used with local models via Ollama or external API keys

### Additional Privacy Options

#### DNS Configuration
- Consider privacy-focused DNS providers:
  - Cloudflare 1.1.1.1
  - Quad9
  - OpenDNS FamilyShield

#### Browser Privacy (Zen Browser)
- Enhanced Tracking Protection
- Container tabs
- No telemetry (vs Chrome)

## Implementation Steps

1. **Create installation script** for package management
2. **Create configuration script** for privacy settings
3. **Add to main install-all.sh** if desired
4. **Test functionality** of each alternative
5. **Document usage** for each service

## Complexity Assessment

- **Easy**: Proton Mail, Organic Maps, Syncthing
- **Medium**: Open WebUI setup, privacy configuration and defaults
- **Server-side**: Immich (handled by user)

## Dependencies

- **Required**: yay (already used)
- **Optional**: Docker (not needed for client-side setup)
- **System**: Standard Arch Linux system

## Next Steps

1. Create the installation scripts
2. Test individual package installations
3. Create configuration guidance
4. Integrate into main installation flow
5. Provide user documentation

## Considerations

- **Migration**: Data migration from Google services not automated
- **Accounts**: Some services require account creation (Proton)
- **Learning Curve**: Users need to learn new interfaces
- **Network**: Some alternatives work offline (Organic Maps, Syncthing)

## Maintenance

- **Updates**: All packages update via yay/pacman
- **Monitoring**: Syncthing web interface for status
- **Backup**: User responsibility for data backup