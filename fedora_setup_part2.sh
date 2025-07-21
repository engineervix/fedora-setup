#!/usr/bin/env bash

# =================================================================================================
# description:  Fedora 42 setup script - Part 2: Main setup after reboot
# author:       Victor Miti <https://github.com/engineervix>
# url:          <https://github.com/engineervix/fedora-setup>
# version:      1.0.0
# license:      MIT
#
# Usage: chmod +x fedora_setup_part2.sh && ./fedora_setup_part2.sh
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

# Check if part 1 was completed
if [ ! -f "$HOME/.fedora_setup_part1_complete" ]; then
    error "Part 1 of the setup was not completed!"
    error "Please run ./fedora_setup_part1.sh first, then reboot."
    exit 1
fi

# Check if we're running in zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    warn "You're not running zsh as your default shell yet."
    warn "The shell change may not have taken full effect."
    info "Current shell: $SHELL"
    info "Expected shell: $(which zsh)"
fi

log "Starting Fedora 42 Developer Setup - Part 2..."

# Get the default profile UUID
profile_uuid=$(dconf read /org/gnome/Ptyxis/default-profile-uuid | tr -d "'")

# Set the terminal emulator's opacity (change 0.85 to your desired value)
dconf write "/org/gnome/Ptyxis/Profiles/$profile_uuid/opacity" 0.85
log "Set opacity to 0.85 for profile: $profile_uuid"

# Enable RPM Fusion repositories (you should already have enabled the NVIDIA & Steam one after install, on first boot)
log "Enabling RPM Fusion repositories..."
fedora_version="$(rpm -E %fedora)"
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora_version.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedora_version.noarch.rpm"

# Some UX updates
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Enable Flathub (even though I prefer avoiding flatpaks, some apps might need it)
log "Enabling Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install development and multimedia tools
log "Installing development tools and essential packages..."
sudo dnf group install -y c-development development-tools multimedia vlc -y
sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing -y
sudo dnf upgrade @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
sudo dnf group install -y sound-and-video
sudo dnf install ffmpeg-libs libva libva-utils -y
sudo dnf swap libva-intel-media-driver intel-media-driver --allowerasing -y
sudo dnf install libva-intel-driver -y

# Core development packages
log "Installing core development packages..."
sudo dnf install -y \
    bzip2-devel \
    cmake \
    expat-devel \
    gdbm-devel \
    gstreamer1-devel \
    gstreamer1-plugins-base-devel \
    gtk4-devel \
    libadwaita-devel \
    libffi-devel \
    libpcap-devel \
    libpq-devel \
    libyaml-devel \
    ncurses-devel \
    openssl-devel \
    mkcert \
    pipx \
    python3-devel \
    python3-pip \
    python3-virtualenvwrapper \
    python3-wheel \
    readline-devel \
    readline-devel \
    ruby-devel \
    sqlite-devel \
    tk-devel \
    xz-devel \
    zlib-devel 

# Remove stuff we don't need
log "Removing some things we don't need..."
sudo dnf remove -y \
	totem \
	rhythmbox
    
# Various tools
log "Installing some essential utilities, tools & applications ..."
sudo dnf install -y \
    aspell \
    audacity \
    btop \
    cifs-utils \
    dconf-editor \
    duf \
    easyeffects \
    gh \
    gimp \
    git-delta \
    glab \
    gnome-extensions-app \
    gnome-shell-extension-openweather \
    gnome-shell-extension-pop-shell \
    gnome-tweaks \
    gscan2pdf \
    htop \
    httpie \
    inkscape \
    intel-media-driver \
    just \
    ksshaskpass \
    libappindicator-gtk3 \
    libgtop2-devel \
    libXScrnSaver \
    lm_sensors \
    meld \
    nautilus-python \
    ncdu \
    nss-tools \
    ocrmypdf \
    okular \
    openssh-askpass \
    pandoc \
    pdftk-java \
    perl-Image-ExifTool \
    pngquant \
    procs \
    rclone \
    samba-client \
    screenkey \
    ShellCheck \
    sqlitebrowser \
    stacer \
    Thunar \
    tokei \
    transmission \
    wireplumber \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xiphos \
    xournalpp \
    yq \
    yt-dlp \
    yum-utils
# Run dconf to update the system dconf databases, making the newly installed system-wide extensions available to all users.
sudo dconf update

# OpenH264 is used for H.264/MPEG-4 media playback. Adding this can enhance your web browsing experience
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit -y
sudo dnf copr enable atim/bandwhich -y
sudo dnf install bandwhich -y

# Docker
log "Installing Docker..."
sudo dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
# sudo groupadd docker
sudo usermod -aG docker "$USER"

# ctop
log "Installing ctop..."
CTOP_LATEST_TAG=$(curl -s https://api.github.com/repos/bcicen/ctop/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
log "Installing ctop version: $CTOP_LATEST_TAG"
sudo wget "https://github.com/bcicen/ctop/releases/download/$CTOP_LATEST_TAG/ctop-${CTOP_LATEST_TAG#v}-linux-amd64" -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# Node.js development tools with Volta
log "Installing Volta for Node.js version management..."
if ! command -v volta &> /dev/null; then
    curl https://get.volta.sh | bash
    # Add volta to PATH for current session
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    
    # Install latest Node.js and npm with Volta
    log "Installing Node.js and npm via Volta..."
    volta install node@lts
    volta install npm@latest
fi

log "Installing Node.js development tools..."
# Use volta run to ensure we're using the right node version
volta run npm install -g prettier svgo doctoc mdpdf serve

# Browsers
log "Installing Chromium & Google Chrome..."
# Chrome should be available if you accepted adding additional package repositories on first boot after installing Fedora
sudo dnf install -y chromium google-chrome-stable

log "Installing Brave..."
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install -y brave-browser

# Communication tools
log "Installing communication tools..."

# Slack (using the official RPM)
install_slack() {
    log "Starting Slack installation..."
    
    info "Fetching Slack download URL..."
    local download_url
    download_url=$(curl -sL "https://slack.com/downloads/instructions/linux?ddl=1&build=rpm" | \
        grep -o 'https://downloads.slack-edge.com[^"]*\.rpm' | head -1)
    
    if [ -z "$download_url" ]; then
        error "Could not find Slack download URL"
        return 1
    fi
    
    info "Found download URL: $download_url"
    info "Downloading Slack RPM package..."
    
    if curl -L -o "/tmp/slack.rpm" "$download_url"; then
        log "Slack downloaded successfully"
    else
        error "Failed to download Slack"
        return 1
    fi
    
    info "Installing Slack..."
    if sudo dnf install -y /tmp/slack.rpm; then
        log "Slack installed successfully"
        # Clean up
        rm -f /tmp/slack.rpm
    else
        error "Failed to install Slack"
        rm -f /tmp/slack.rpm
        return 1
    fi
}

install_slack

# Zoom (using official RPM)
install_zoom() {
    log "Installing Zoom via automated download..."
    
    # Create temporary directory for zoom installer
    local temp_dir="/tmp/zoom-installer"
    mkdir -p "$temp_dir"
    cd "$temp_dir" || exit
    
    info "Setting up temporary Node.js environment for Zoom download..."
    
    # Create a minimal package.json
    cat > package.json << 'EOF'
{
  "name": "zoom-downloader",
  "version": "1.0.0",
  "description": "Temporary setup for downloading Zoom",
  "main": "index.js",
  "scripts": {},
  "dependencies": {
    "playwright": "^1.54.1"
  }
}
EOF

    # Create the download script
    cat > zoom-download.js << 'EOF'
const { chromium } = require('playwright');

async function downloadZoomForFedora() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  try {
    // Navigate to Zoom download page
    await page.goto('https://zoom.us/download?os=linux');
    
    // Handle cookie banner
    await page.getByRole('button', { name: 'Decline Cookies' }).click();
    
    // Click to open the Linux distribution dropdown
    await page.getByLabel('Show options').click();
    
    // Select Fedora
    await page.getByText('Fedora').click();
    
    // Start download
    const downloadPromise = page.waitForEvent('download');
    await page.getByRole('link', { name: 'Download Zoom Workplace' }).click();
    
    // Wait for download to start and save with original filename
    const download = await downloadPromise;
    const fileName = download.suggestedFilename();
    await download.saveAs(`./${fileName}`);
    
    console.log(`Download completed: ${fileName}`);
    
  } catch (error) {
    console.error('Download failed:', error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

downloadZoomForFedora();
EOF

    # Install playwright and download chromium using volta
    info "Installing Playwright..."
    if volta run npm install; then
        log "Playwright installed successfully"
    else
        error "Failed to install Playwright"
        cd - && rm -rf "$temp_dir"
        return 1
    fi
    
    info "Installing Chromium browser..."
    if volta run npx playwright install chromium; then
        log "Chromium installed successfully"
    else
        error "Failed to install Chromium"
        cd - && rm -rf "$temp_dir"
        return 1
    fi
    
    info "Downloading Zoom RPM package..."
    if volta run node zoom-download.js; then
        log "Zoom download completed"
    else
        error "Failed to download Zoom"
        cd - && rm -rf "$temp_dir"
        return 1
    fi
    
    # Find the downloaded RPM file
    local rpm_file
    rpm_file=$(find . -name "zoom_*.rpm" | head -1)
    
    if [ -z "$rpm_file" ]; then
        error "Could not find downloaded Zoom RPM file"
        cd - && rm -rf "$temp_dir"
        return 1
    fi
    
    info "Installing Zoom RPM package: $rpm_file"
    if sudo dnf install -y "$rpm_file"; then
        log "Zoom installed successfully"
    else
        error "Failed to install Zoom RPM package"
        cd - && rm -rf "$temp_dir"
        return 1
    fi
    
    # Return to original directory and cleanup
    cd -
    
    info "Cleaning up temporary files and Playwright cache..."
    rm -rf "$temp_dir"
    
    # Clean up Playwright cache (located in ~/.cache/ms-playwright)
    if [ -d "$HOME/.cache/ms-playwright" ]; then
        rm -rf "$HOME/.cache/ms-playwright"
        log "Playwright browser cache cleaned up"
    fi
    
    log "Zoom installation completed successfully"
}

install_zoom

# Terminal and shell improvements
log "Installing terminal and shell improvements..."
sudo dnf install -y \
    bat \
    fd-find \
    fzf \
    ripgrep \
    tmux \
    zoxide

# eza
# Get the latest release tag
LATEST_TAG=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
log "Installing eza version: $LATEST_TAG"

# Download and install binary
wget -O /tmp/eza.tar.gz \
  "https://github.com/eza-community/eza/releases/download/$LATEST_TAG/eza_x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/eza.tar.gz -C /tmp/
sudo cp /tmp/eza /usr/local/bin/
sudo chmod +x /usr/local/bin/eza

# Download completions to a permanent location
COMPLETIONS_DIR="$HOME/.local/share/eza-completions"
mkdir -p "$COMPLETIONS_DIR"
wget -O /tmp/completions.tar.gz \
  "https://github.com/eza-community/eza/releases/download/$LATEST_TAG/completions-${LATEST_TAG#v}.tar.gz"

# Extract completions to a temporary target directory
mkdir -p /tmp/target
tar -xzf /tmp/completions.tar.gz -C /tmp/target/

# Find the actual completions directory (it includes the version number)
COMPLETIONS_EXTRACTED_DIR=$(find /tmp/target -name "completions-*" -type d | head -1)

if [ -n "$COMPLETIONS_EXTRACTED_DIR" ] && [ -d "$COMPLETIONS_EXTRACTED_DIR" ]; then
    # Copy all completion files directly to the completions directory
    cp "$COMPLETIONS_EXTRACTED_DIR"/* "$COMPLETIONS_DIR/"
    log "Completions for eza installed successfully"
else
    warn "Could not find extracted completions directory, skipping completion setup"
fi

# Clean up
rm -rf /tmp/eza* /tmp/completions* /tmp/target/

log "eza $LATEST_TAG installed successfully!"
log "Completions installed to: $COMPLETIONS_DIR"

# Vim
log "Setting up Vim with development plugins..."
sudo dnf install -y vim

# Install vim-plug
log "Installing vim-plug plugin manager..."
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    log "vim-plug installed successfully"
else
    info "vim-plug already installed, skipping..."
fi

# Create .vimrc configuration
log "Creating .vimrc configuration..."
cat > "$HOME/.vimrc" << 'EOF'
" Essential Vim Configuration
set nocompatible
filetype off

" Plugins via vim-plug
call plug#begin('~/.vim/plugged')

" File explorer
Plug 'preservim/nerdtree'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Syntax highlighting and language support
Plug 'sheerun/vim-polyglot'

" Auto-completion
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }

" Color schemes
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

" Useful utilities
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'

call plug#end()

" Basic settings
filetype plugin indent on
syntax enable

" Enable true colors support (required for Catppuccin)
set termguicolors

" Theme - with fallback if catppuccin_mocha isn't installed yet
try
    set background=dark
    colorscheme catppuccin_mocha
    let g:airline_theme='catppuccin_mocha'
catch /^Vim\%((\a\+)\)\=:E185/
    " Fallback to default if catppuccin_mocha not available
    colorscheme default
    let g:airline_theme='dark'
endtry

" General settings
set number
set relativenumber
set cursorline
set showmatch
set incsearch
set hlsearch
set ignorecase
set smartcase
set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set scrolloff=8
set sidescrolloff=8
set wrap
set linebreak
set mouse=a
set clipboard=unnamedplus
set backspace=indent,eol,start
set wildmenu
set wildmode=longest:full,full
set splitbelow
set splitright
set laststatus=2
set encoding=utf-8

" Disable backup files (optional)
set nobackup
set nowritebackup
set noswapfile

" Set leader key for future customization
let mapleader = " "

" Plugin-specific settings
let g:NERDTreeShowHidden=1
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" Auto-commands
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
EOF

# Install vim plugins
log "Installing vim plugins (this may take a few minutes)..."
info "Note: YouCompleteMe will compile in the background - this is normal and may take some time"

# Install plugins in a more controlled way
if vim --not-a-term -c 'PlugInstall --sync | qa!' > /tmp/vim-plug-install.log 2>&1; then
    log "Vim plugins installed successfully"
    
    # Check if YouCompleteMe needs manual compilation (fallback)
    if [ -d "$HOME/.vim/plugged/YouCompleteMe" ] && [ ! -f "$HOME/.vim/plugged/YouCompleteMe/third_party/ycmd/ycm_core.so" ]; then
        log "Compiling YouCompleteMe manually..."
        cd "$HOME/.vim/plugged/YouCompleteMe"
        if python3 install.py > /tmp/ycm-install.log 2>&1; then
            log "YouCompleteMe compiled successfully"
        else
            warn "YouCompleteMe compilation had issues - check /tmp/ycm-install.log"
            warn "You may need to install additional development packages"
        fi
        cd - > /dev/null
    fi
else
    warn "Some vim plugins may not have installed correctly - check /tmp/vim-plug-install.log"
    warn "You can manually run ':PlugInstall' in vim to retry"
fi

log "Vim setup completed! Use ':NERDTree' to open file explorer, ':Files' for fuzzy finding."

# Install Powerline fonts for terminal icons
log "Installing Powerline fonts..."
sudo dnf install -y powerline-fonts

# Install Nerd Fonts (for better terminal icons)
log "Installing Nerd Fonts..."
if [ ! -d "$HOME/.local/share/fonts" ]; then
    mkdir -p "$HOME/.local/share/fonts"
fi

# Download and install JetBrains Mono Nerd Font
if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    wget -O /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
    unzip /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono/
    cp /tmp/JetBrainsMono/*.ttf "$HOME/.local/share/fonts/"
    rm -rf /tmp/JetBrainsMono*
fi

# Download and install Fantasque Sans Mono Nerd Font
if [ ! -f "$HOME/.local/share/fonts/FantasqueSansMono Nerd Font Regular.ttf" ]; then
    log "Installing Fantasque Sans Mono Nerd Font..."
    wget -O /tmp/FantasqueSansMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FantasqueSansMono.zip
    unzip /tmp/FantasqueSansMono.zip -d /tmp/FantasqueSansMono/
    cp /tmp/FantasqueSansMono/*.ttf "$HOME/.local/share/fonts/"
    rm -rf /tmp/FantasqueSansMono*
    log "Fantasque Sans Mono Nerd Font installed successfully"
else
    info "Fantasque Sans Mono Nerd Font already installed, skipping..."
fi

# Download and install Cascadia Code font
if [ ! -f "$HOME/.local/share/fonts/CascadiaCode-Regular.ttf" ]; then
    log "Installing Cascadia Code font family..."
    wget -O /tmp/CascadiaCode.zip https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip
    unzip /tmp/CascadiaCode.zip -d /tmp/CascadiaCode/
    
    # Install both variable fonts (from ttf/) and static fonts (from ttf/static/)
    cp /tmp/CascadiaCode/ttf/*.ttf "$HOME/.local/share/fonts/"
    cp /tmp/CascadiaCode/ttf/static/*.ttf "$HOME/.local/share/fonts/"
    
    rm -rf /tmp/CascadiaCode*
    log "Cascadia Code font family installed successfully (includes Nerd Font and Powerline variants)"
else
    info "Cascadia Code font already installed, skipping..."
fi

# Rebuild font cache after all font installations
log "Rebuilding font cache..."
fc-cache -fv
log "Font cache rebuilt successfully"

# https://starship.rs
sudo dnf copr enable atim/starship -y
sudo dnf install starship -y

# Visual Studio Code (official Microsoft repository)
log "Installing Visual Studio Code..."
if ! command -v code &> /dev/null; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    dnf check-update
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf install -y code
else
    info "VS Code already installed, skipping..."
fi

# Zed editor (using official installation method)
log "Installing Zed editor..."
if ! command -v zed &> /dev/null; then
    curl -f https://zed.dev/install.sh | sh
fi

# Optional: Install Cursor editor
echo
info "Do you want to install Cursor editor? (y/n)"
read -r install_cursor
if [[ "$install_cursor" =~ ^[Yy]$ ]]; then
    log "Installing Cursor editor..."
    CURSOR_INSTALL_URL="https://raw.githubusercontent.com/engineervix/fedora-setup/main/install_cursor.sh"
    
    if curl -fsSL "$CURSOR_INSTALL_URL" | bash; then
        log "Cursor installed successfully"
    else
        error "Failed to install Cursor. You can install it manually later by running:"
        error "curl -fsSL $CURSOR_INSTALL_URL | bash"
    fi
else
    info "Skipping Cursor installation. You can install it later by running:"
    info "curl -fsSL https://raw.githubusercontent.com/engineervix/fedora-setup/main/install_cursor.sh | bash"
fi

# Python development tools
log "Installing pyenv for Python version management..."
if ! command -v pyenv &> /dev/null; then
    curl https://pyenv.run | bash
fi

log "Installing Poetry..."
export PATH="$PATH:$HOME/.local/bin"
pipx ensurepath
pipx install poetry
mkdir -p "$HOME/.zfunc/"
poetry completions bash >> ~/.bash_completion
poetry completions zsh > ~/.zfunc/_poetry
{
    echo ''
    echo '# Poetry'
    echo 'fpath+=~/.zfunc'
    echo 'autoload -Uz compinit && compinit'
} >> "$HOME/.zshrc"

# Set up virtualenvwrapper
log "Configuring virtualenvwrapper..."
mkdir -p "$HOME/.virtualenvs"

# Go
log "Installing Go..."
if ! command -v go &> /dev/null; then
    sudo dnf install golang -y
    {
        echo ''
        echo '=============== Go ==============='
        echo "export GOPATH=\$HOME/go"
        echo "export PATH=\$PATH:\$GOPATH/bin"
    } >> "$HOME/.zshrc"
fi

log "Installing Go development tools..."
go install golang.org/x/tools/gopls@latest
gopath_bin="$(go env GOPATH)/bin"
GOPATH=$HOME/go curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b "$gopath_bin"

# Rust
log "Installing Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# AWS CLI
log "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip /tmp/awscliv2.zip -d /tmp/
    sudo /tmp/aws/install
    rm -rfv /tmp/aws*
fi

# Heroku CLI
log "Installing Heroku CLI..."
if ! command -v heroku &> /dev/null; then
    curl https://cli-assets.heroku.com/install.sh | sh
fi

# zsh configuration
log "Adding enhanced zsh configuration..."

# Backup existing .zshrc if it has content (in case tools added stuff)
if [[ -s "$HOME/.zshrc" ]]; then
    cp -v "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
    info "Backed up existing .zshrc (tools may have added configuration)"
fi

# IMPORTANT: Use >> to append, not > to overwrite
cat >> "$HOME/.zshrc" << 'EOF'

# =============== add custom scripts to PATH ===============
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"

# =============== editor ===============
export VISUAL=vim
export EDITOR="$VISUAL"

# =============== pyenv ===============
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# =============== virtualenvwrapper ===============
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/bin/virtualenvwrapper.sh

# =============== cursor ===============
cursor() {
  # Run the cursor command and suppress background process output completely
  (nohup $HOME/.local/bin/Cursor.AppImage "$@" >/dev/null 2>&1 &)
}

# =============== eza ===============
export FPATH="$HOME/.local/share/eza-completions/zsh:$FPATH"

# =============== Aliases ===============
# General
alias open="xdg-open"
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -lah --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias du='duf'
alias top='btop'
alias ps='procs'
alias cd='z'

# Git (credits: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh)
alias ggpur='ggu'
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
alias gam='git am'
alias gama='git am --abort'
alias gamc='git am --continue'
alias gamscp='git am --show-current-patch'
alias gams='git am --skip'
alias gap='git apply'
alias gapt='git apply --3way'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsn='git bisect new'
alias gbso='git bisect old'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gbl='git blame -w'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'

# Docker (Credits: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/docker/docker.plugin.zsh)
alias dbl='docker build'
alias dcin='docker container inspect'
alias dcls='docker container ls'
alias dclsa='docker container ls -a'
alias dib='docker image build'
alias dii='docker image inspect'
alias dils='docker image ls'
alias dipu='docker image push'
alias dipru='docker image prune -a'
alias dirm='docker image rm'
alias dit='docker image tag'
alias dlo='docker container logs'
alias dnc='docker network create'
alias dncn='docker network connect'
alias dndcn='docker network disconnect'
alias dni='docker network inspect'
alias dnls='docker network ls'
alias dnrm='docker network rm'
alias dpo='docker container port'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpu='docker pull'
alias dr='docker container run'
alias drit='docker container run -it'
alias drm='docker container rm'
alias 'drm!'='docker container rm -f'
alias dst='docker container start'
alias drs='docker container restart'
alias dsta='docker stop $(docker ps -q)'
alias dstp='docker container stop'
alias dsts='docker stats'
alias dtop='docker top'
alias dvi='docker volume inspect'
alias dvls='docker volume ls'
alias dvprune='docker volume prune'
alias dxc='docker container exec'
alias dxcit='docker container exec -it'

# Docker Compose (Credits: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/docker-compose/docker-compose.plugin.zsh)
alias dco="docker compose"
alias dcb="docker compose build"
alias dce="docker compose exec"
alias dcps="docker compose ps"
alias dcrestart="docker compose restart"
alias dcrm="docker compose rm"
alias dcr="docker compose run"
alias dcstop="docker compose stop"
alias dcup="docker compose up"
alias dcupb="docker compose up --build"
alias dcupd="docker compose up -d"
alias dcupdb="docker compose up -d --build"
alias dcdn="docker compose down"
alias dcl="docker compose logs"
alias dclf="docker compose logs -f"
alias dclF="docker compose logs -f --tail 0"
alias dcpull="docker compose pull"
alias dcstart="docker compose start"
alias dck="docker compose kill"

# =============== FZF configuration ===============
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# =============== Zoxide (better cd) ===============
eval "$(zoxide init zsh)"

# =============== Starship prompt ===============
eval "$(starship init zsh)"

# =============== Custom functions ===============
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# check python version in pyproject.toml
py_version() {
    yq '.tool.poetry.dependencies.python' pyproject.toml
}

# Automatically adds local node_modules/.bin to PATH when entering directories
function add_nodemodules_bin() {
    local bin_path="./node_modules/.bin"
    if [[ -d "$bin_path" ]]; then
        if [[ ":$PATH:" != *":$bin_path:"* ]]; then
            export PATH="$PATH:$bin_path"
        fi
    fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd add_nodemodules_bin

# best compression:
# tar cv path/to/dir/ | xz -3e > compressed_file.tar.xz
tar_max() {
  tar --exclude='.DS_Store' \
      --exclude='__MACOSX' \
      --exclude='node_modules' \
      --exclude='__pycache__' \
      --exclude='*.pyc' \
      -cv "$1" | xz -3e > "$2".tar.xz
}

# search for string in files
grep_this() {
  grep --color -inrw . -e "$1"
  printf "\033[0;36m=================================================================\033[0m\n"
  echo "Matches: " $(grep --color -inrw . -e "$1" | wc -l)
  printf "\033[1;36m=================================================================\033[0m\n"
}

# create directory with today's date as dir_name in format YYYY-mmm-dd-day
mkdir_date() {
  mkdir -p $(date '+%Y-%h-%d-%a')
}

# the following function renames files by replacing spaces with underscores
# usage: kill_spaces ext
# where ext is the filetype extension, for example, pdf
kill_spaces() {
  find . -name "**.$1" -type f -print0 | while read -d $'\0' f; do mv -v "$f" "${f// /_}"; done
}

wget_entire_site() {
  wget --continue --mirror --convert-links --adjust-extension --page-requisites --no-parent "$1"
}

# encrypt pdf, allow printing
encrypt_pdf() {
  encrypted_pdf="${1%.pdf}.128.pdf"
  pdftk "$1" output ${encrypted_pdf} owner_pw "$2" allow printing verbose

  # rename the files after encryption
  mv -v "$1" "${1%.pdf}_src.pdf"
  mv -v ${encrypted_pdf} "${encrypted_pdf%.128.pdf}.pdf"
}

# split pdf
split_pdf() {
  split_files="${1%.pdf}_%02d.pdf"
  pdftk "$1" burst output ${split_files} verbose
}

# search a bunch of pdf files in the $(pwd) for selected text
grep_pdf() {
  # find . -name '*.pdf' -exec sh -c 'pdftotext "{}" - | grep --with-filename --label="{}" --color -i "Using the BIV"' \;
  find . -iname '*.pdf' | while read filename
  do
    pdftotext -enc Latin1 "$filename" - | grep --with-filename --label="$filename" --color -i "$1"
  done
}

# ===========================================================================
EOF

# Spotify
sudo dnf install lpf-spotify-client -y

# Clean up
log "Cleaning up..."
sudo dnf autoremove -y
sudo dnf clean all

# Remove the setup marker file
rm -f "$HOME/.fedora_setup_part1_complete"

log "Setup complete! 🎉"
echo
info "Recommended next steps:"
info "1. Open a new terminal to start using zsh with starship"
info "2. Configure your terminal to use JetBrains Mono Nerd Font or Fantasque Sans Mono Nerd Font"
info "3. Run 'lpf update' to complete Spotify installation"
info "4. Customize your development environment further"
echo
info "Enjoy your new Fedora development environment! 🚀"
echo
info "Additional Firefox Configuration Steps:"
info "1. Enable Hardware Acceleration & WebRender:"
info "   - Go to about:config in Firefox"
info "   - Set layers.acceleration.force-enabled → true"
info "   - Set gfx.webrender.all → true"
echo
info "2. Enable OpenH264 plugin:"
info "   - Go to about:addons and select Plugins"
info "   - Enable the OpenH264 plugin"
info "   - Verify it's working: https://mozilla.github.io/webrtc-landing/pc_test.html"
echo
info "3. Install GNOME Vitals extension:"
info "   - Visit: https://extensions.gnome.org/extension/1460/vitals/"
info "   - Install the extension in Firefox"