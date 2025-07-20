#!/usr/bin/env bash

# NOTE: adapted from https://forum.cursor.com/t/tutorial-install-cursor-permanently-when-appimage-install-didnt-work-on-linux/7712/27

# Exit immediately if a command exits with a non-zero status
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Variables
APP_NAME="Cursor"
APP_VERSION="latest"
APP_IMAGE_URL=$(curl -sL "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable" | jq -r '.downloadUrl')
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_FILE_DIR="$HOME/.local/share/applications"
ICON_URL="https://us1.discourse-cdn.com/cursor1/original/2X/f/f7bc157cca4b97c3f0fc83c3c1a7094871a268df.png"
ICON_PATH="$HOME/.local/share/icons/cursor-icon.png"
SERVICE_FILE="$HOME/.config/systemd/user/$APP_NAME-update.service"
TIMER_FILE="$HOME/.config/systemd/user/$APP_NAME-update.timer"

log "Starting $APP_NAME installation..."

# Check if Cursor is already installed
if [[ -f "$INSTALL_DIR/$APP_NAME.AppImage" ]]; then
    warn "Cursor is already installed at $INSTALL_DIR/$APP_NAME.AppImage"
    
    # Check if it's executable and working
    if [[ -x "$INSTALL_DIR/$APP_NAME.AppImage" ]]; then
        info "Existing installation appears to be working."
        
        # Check if systemd timer is also set up
        if [[ -f "$TIMER_FILE" ]] && systemctl --user is-enabled "$APP_NAME-update.timer" &>/dev/null; then
            info "Auto-update timer is also configured."
            info "Installation appears to be complete. Nothing to do!"
            exit 0
        else
            warn "Auto-update timer is not configured. Setting up timer only..."
            SETUP_TIMER_ONLY=true
        fi
    else
        warn "Existing installation may be corrupted (not executable)."
        info "Proceeding with fresh installation..."
    fi
else
    info "No existing Cursor installation found. Proceeding with fresh installation..."
fi

# Step 1: Create necessary directories
log "Creating necessary directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_FILE_DIR"
mkdir -p "$(dirname "$ICON_PATH")"
mkdir -p "$(dirname "$SERVICE_FILE")"

# Step 2: Download Cursor AppImage (skip if only setting up timer)
if [[ "$SETUP_TIMER_ONLY" != "true" ]]; then
    log "Downloading $APP_NAME AppImage..."
    
    if [[ -z "$APP_IMAGE_URL" ]]; then
        error "Could not retrieve Cursor download URL"
        exit 1
    fi
    
    info "Download URL: $APP_IMAGE_URL"
    
    if curl -L "$APP_IMAGE_URL" -o "$INSTALL_DIR/$APP_NAME.AppImage"; then
        log "Cursor AppImage downloaded successfully"
    else
        error "Failed to download Cursor AppImage"
        exit 1
    fi
    
    # Step 3: Make the AppImage executable
    log "Making the AppImage executable..."
    chmod +x "$INSTALL_DIR/$APP_NAME.AppImage"
    
    # Step 4: Download the icon
    log "Downloading $APP_NAME icon..."
    if curl -L "$ICON_URL" -o "$ICON_PATH"; then
        log "Icon downloaded successfully"
    else
        warn "Failed to download icon, but continuing with installation"
    fi
    
    # Step 5: Create a desktop entry
    log "Creating desktop entry..."
    cat > "$DESKTOP_FILE_DIR/$APP_NAME.desktop" <<EOL
[Desktop Entry]
Name=$APP_NAME
Exec=$INSTALL_DIR/$APP_NAME.AppImage --no-sandbox
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOL
    log "Desktop entry created successfully"
else
    info "Skipping AppImage download and desktop entry creation (timer setup only)"
fi

# Step 6: Create update service
log "Creating update service..."
cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=Update $APP_NAME AppImage

[Service]
ExecStart=/usr/bin/env bash -c "curl -L $APP_IMAGE_URL -o $INSTALL_DIR/$APP_NAME.AppImage && chmod +x $INSTALL_DIR/$APP_NAME.AppImage"
EOL

# Step 7: Create timer to run the update service daily
log "Creating update timer..."
cat > "$TIMER_FILE" <<EOL
[Unit]
Description=Daily update check for $APP_NAME AppImage

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOL

# Step 8: Enable and start the timer
log "Enabling and starting update timer..."
if systemctl --user enable --now "$APP_NAME-update.timer"; then
    log "Update timer enabled and started successfully"
else
    error "Failed to enable update timer"
    exit 1
fi

# Step 9: Update desktop database (optional but recommended)
if [[ "$SETUP_TIMER_ONLY" != "true" ]]; then
    log "Updating desktop database..."
    if command -v update-desktop-database &> /dev/null; then
        if update-desktop-database "$DESKTOP_FILE_DIR"; then
            log "Desktop database updated successfully"
        else
            warn "Desktop database update failed, but this is not critical"
        fi
    else
        info "Desktop database update command not found. You may need to do this manually or install desktop-file-utils"
    fi
fi

# Step 10: Verify installation
log "Verifying installation..."
if [[ -x "$INSTALL_DIR/$APP_NAME.AppImage" ]]; then
    log "✓ Cursor AppImage is installed and executable"
else
    error "✗ Cursor AppImage installation verification failed"
    exit 1
fi

if systemctl --user is-active --quiet "$APP_NAME-update.timer"; then
    log "✓ Auto-update timer is running"
else
    warn "✗ Auto-update timer is not running"
fi

# Step 11: Final success message
log "$APP_NAME installation completed successfully! 🎉"
echo
info "You can now:"
info "• Launch Cursor from your application menu"
info "• Run it directly: $INSTALL_DIR/$APP_NAME.AppImage"
info "• Use the 'cursor' command if you have the alias set up in your shell"
echo
info "Auto-update timer status:"
systemctl --user status "$APP_NAME-update.timer" --no-pager --lines=3
echo
log "Installation complete! Enjoy using Cursor! 🚀"
