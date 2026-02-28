#!/bin/bash

# Syncthing Installation and Configuration Script
# This script is idempotent - safe to run multiple times
# It installs syncthing, enables the user service, and displays the device ID

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check and setup systemd user session environment variables
setup_user_session_env() {
    # Check if DBUS_SESSION_BUS_ADDRESS and XDG_RUNTIME_DIR are already set
    if [ -n "$DBUS_SESSION_BUS_ADDRESS" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
        print_success "User session environment variables already set"
        return 0
    fi
    
    print_status "Checking user session environment variables..."
    
    # Try to set XDG_RUNTIME_DIR if not set
    if [ -z "$XDG_RUNTIME_DIR" ]; then
        local uid=$(id -u)
        local runtime_dir="/run/user/$uid"
        
        if [ -d "$runtime_dir" ]; then
            export XDG_RUNTIME_DIR="$runtime_dir"
            print_info "Set XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
        else
            print_error "XDG_RUNTIME_DIR not found at $runtime_dir"
            print_error "This usually means you're not running in a proper user session"
            echo ""
            echo "To fix this, try one of the following:"
            echo "  1. Run this script from a proper login shell (not SSH without session)"
            echo "  2. Log out and log back in to establish a user session"
            echo "  3. If running via SSH, use: ssh -X user@host (with X11 forwarding)"
            echo "  4. Or manually set the variables before running this script:"
            echo "     export XDG_RUNTIME_DIR=\"/run/user/\$(id -u)\""
            echo "     export DBUS_SESSION_BUS_ADDRESS=\"unix:path=\${XDG_RUNTIME_DIR}/bus\""
            return 1
        fi
    fi
    
    # Try to set DBUS_SESSION_BUS_ADDRESS if not set
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
        print_info "Set DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
    fi
    
    # Verify the bus socket exists
    if [ ! -S "${XDG_RUNTIME_DIR}/bus" ]; then
        print_error "D-Bus socket not found at ${XDG_RUNTIME_DIR}/bus"
        print_error "The user session may not be properly initialized"
        echo ""
        echo "To fix this, try:"
        echo "  1. Log out and log back in to establish a proper user session"
        echo "  2. Or run: systemctl --user start dbus"
        return 1
    fi
    
    print_success "User session environment variables configured"
    return 0
}

# Main script
main() {
    print_status "Starting Syncthing installation and configuration..."
    
    # Step 0: Setup user session environment
    if ! setup_user_session_env; then
        print_error "Failed to setup user session environment"
        exit 1
    fi
    
    # Step 1: Check and install syncthing package
    print_status "Checking syncthing package..."
    if pacman -Q syncthing &>/dev/null; then
        print_success "Syncthing is already installed"
    else
        print_status "Installing syncthing..."
        pacman -S --noconfirm syncthing
        print_success "Syncthing installed successfully"
    fi
    
    # Step 2: Create ~/Sync directory if it doesn't exist
    print_status "Checking ~/Sync directory..."
    if [ -d "$HOME/Sync" ]; then
        print_success "~/Sync directory already exists"
    else
        print_status "Creating ~/Sync directory..."
        mkdir -p "$HOME/Sync"
        print_success "~/Sync directory created"
    fi
    
    # Step 3: Enable syncthing user service if not already enabled
    print_status "Checking syncthing user service..."
    if systemctl --user is-enabled syncthing &>/dev/null; then
        print_success "Syncthing service is already enabled"
    else
        print_status "Enabling syncthing user service..."
        systemctl --user enable syncthing
        print_success "Syncthing service enabled"
    fi
    
    # Step 4: Start syncthing user service if not already running
    if systemctl --user is-active syncthing &>/dev/null; then
        print_success "Syncthing service is already running"
    else
        print_status "Starting syncthing user service..."
        systemctl --user start syncthing
        print_success "Syncthing service started"
    fi
    
    # Step 5: Wait for syncthing to initialize
    print_status "Waiting for Syncthing to initialize..."
    sleep 3
    
    # Step 6: Display Device ID
    print_status "Retrieving Device ID..."
    DEVICE_ID=$(syncthing --device-id 2>/dev/null | grep -oP '(?<=ID: )[A-Z0-9\-]+' | head -1)
    
    if [ -n "$DEVICE_ID" ]; then
        print_success "Syncthing configuration complete!"
        echo ""
        echo -e "${GREEN}Device ID:${NC}"
        echo -e "${YELLOW}$DEVICE_ID${NC}"
        echo ""
        echo -e "${GREEN}Web GUI URL:${NC}"
        echo -e "${YELLOW}http://127.0.0.1:8384${NC}"
        echo ""
        print_info "Copy the Device ID above to share with other devices"
        print_info "Open the Web GUI URL in your browser to configure Syncthing"
    else
        print_error "Could not retrieve Device ID. Syncthing may still be initializing."
        print_info "Try running 'syncthing --device-id' manually in a moment"
    fi
    
    echo ""
    print_status "Syncthing installation complete!"
}

# Run main function
main "$@"
