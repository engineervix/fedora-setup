#!/usr/bin/env bash

# =================================================================================================
# description:  Fedora 42 setup script - Part 1: Initial setup and zsh installation
# author:       Victor Miti <https://github.com/engineervix>
# url:          <https://github.com/engineervix/fedora-setup>
# version:      1.0.0
# license:      MIT
#
# Usage: chmod +x fedora_setup_part1.sh && ./fedora_setup_part1.sh
# =================================================================================================

set -e  # Exit immediately if any command fails

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
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
    echo -e "${CYAN}[INFO] $1${NC}"
}

log "Starting Fedora 42 Developer Setup - Part 1..."

# Speed up dnf
log "Optimizing DNF configuration for faster downloads..."
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=9" | sudo tee -a /etc/dnf/dnf.conf

# Update system
log "Updating system packages..."
sudo dnf update -y

# Set hostname
log "Let's set up a new hostname"
read -rp 'hostname: ' myhostname 
sudo hostnamectl set-hostname "$myhostname"

# Configure DNS over TLS for better privacy
setup_dns() {
    log "Setting up secure DNS with Cloudflare DNS over TLS..."
    
    # Create systemd-resolved configuration directory if it doesn't exist
    sudo mkdir -p '/etc/systemd/resolved.conf.d'
    
    # Create DNS over TLS configuration
    sudo tee '/etc/systemd/resolved.conf.d/99-dns-over-tls.conf' > /dev/null << 'EOF'
[Resolve]
DNS=1.1.1.2#security.cloudflare-dns.com 1.0.0.2#security.cloudflare-dns.com 2606:4700:4700::1112#security.cloudflare-dns.com 2606:4700:4700::1002#security.cloudflare-dns.com
DNSOverTLS=yes
EOF
    
    # Restart systemd-resolved to apply changes
    sudo systemctl restart systemd-resolved
    
    log "DNS over TLS configured with Cloudflare's security-focused DNS servers"
    info "DNS queries will now be encrypted and use malware/phishing protection"
}

# Set up secure DNS
setup_dns

# zsh 
setup_zsh() {
    log "Installing zsh and setting it as default shell..."
    sudo dnf install -y zsh
    
    # Change default shell immediately
    chsh -s "$(which zsh)"
    
    # Create initial .zshrc so tools can append to it
    touch "$HOME/.zshrc"
    
    # Set SHELL for current session so tools detect zsh
    SHELL="$(which zsh)"
    export SHELL
    
    log "zsh is now configured as the default shell"
    info "Development tools will now configure for zsh automatically"
}

# Set up zsh early so other tools can configure for it
setup_zsh

# Create a marker file to indicate part 1 is complete
touch "$HOME/.fedora_setup_part1_complete"

# Create the second part script if it doesn't exist
if [ ! -f "./fedora_setup_part2.sh" ]; then
    warn "Part 2 script not found in current directory!"
    warn "Make sure fedora_setup_part2.sh is in the same directory before rebooting."
fi

log "Part 1 of Fedora setup is complete! 🎉"
echo
info "IMPORTANT: You need to reboot now for the shell change to take effect."
info "After rebooting, run ./fedora_setup_part2.sh to continue the setup."
echo
read -rp "Press Enter to reboot now, or Ctrl+C to reboot manually later..."
sudo reboot