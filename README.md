# Fedora Workstation Setup

An automated two-part setup script for Fedora 42 that configures a complete development environment with various tools, editors, and applications. The setup is split to ensure proper shell configuration with a required reboot between parts.

[![ShellCheck](https://github.com/engineervix/fedora-setup/actions/workflows/main.yml/badge.svg)](https://github.com/engineervix/fedora-setup/actions/workflows/main.yml)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Features](#features)
  - [🛠️ Development Tools](#-development-tools)
  - [📝 Editors & IDEs](#-editors--ides)
  - [🖥️ Terminal & Shell](#-terminal--shell)
  - [🌐 Browsers](#-browsers)
  - [💬 Communication](#-communication)
  - [🎵 Media & Entertainment](#-media--entertainment)
  - [🎨 Creative & Productivity](#-creative--productivity)
  - [⚙️ System Enhancements](#-system-enhancements)
  - [🔒 Security & Privacy](#-security--privacy)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [What the Script Does](#what-the-script-does)
  - [Part 1 (`fedora_setup_part1.sh`) - Pre-reboot Setup](#part-1-fedora_setup_part1sh---pre-reboot-setup)
  - [Part 2 (`fedora_setup_part2.sh`) - Main Setup](#part-2-fedora_setup_part2sh---main-setup)
  - [Development Environment](#development-environment)
  - [Modern CLI Tools](#modern-cli-tools)
  - [Shell Configuration](#shell-configuration)
  - [Application Installation](#application-installation)
- [Post-Installation](#post-installation)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Features

### 🛠️ Development Tools

- **Languages**: Python (with pyenv), Node.js (with Volta), Go, Rust
- **Package Managers**: Poetry, pipx, npm
- **Version Control**: Git with delta, GitHub CLI, GitLab CLI, lazygit
- **Containers**: Docker with ctop monitoring
- **Cloud**: AWS CLI, Heroku CLI
- **Go Tools**: gopls language server, golangci-lint
- **Python Environment**: virtualenvwrapper for virtual environment management
- **Development Libraries**: Comprehensive set including bzip2-devel, libffi-devel, openssl-devel, and more

### 📝 Editors & IDEs

- **Visual Studio Code** (official Microsoft repository)
- **Zed editor** (modern Rust-based editor)
- **Cursor** (optional)
- **Vim** with essential plugins and configuration

### 🖥️ Terminal & Shell

- **Zsh** as default shell with enhanced configuration
- **Starship** prompt for beautiful, informative shell prompts
- **Modern CLI tools**: eza, bat, ripgrep, fd, fzf, zoxide, btop, procs
- **Additional utilities**: ncdu, tokei, just, rclone, bandwhich
- **Nerd Fonts**: JetBrains Mono, Fantasque Sans Mono, Cascadia Code
- **Powerline fonts** for enhanced terminal experience

### 🌐 Browsers

- **Chromium** and **Google Chrome**
- **Brave Browser**

### 💬 Communication

- **Slack** (official RPM)
- **Zoom** (automated download and installation)

### 🎵 Media & Entertainment

- **Spotify** (via lpf-spotify-client)
- **VLC media player** with multimedia codecs
- **Audacity** for audio editing
- **Transmission** BitTorrent client
- **yt-dlp** for video downloading

### 🎨 Creative & Productivity

- **GIMP**, **Inkscape** for graphics
- **Okular**, **Xournal++** for PDF handling
- **EasyEffects** for audio processing
- **Meld** for visual file/directory comparison
- **Pandoc** for document conversion
- **Thunar** alternative file manager
- **Additional utilities**: screenkey, stacer, sqlitebrowser

### ⚙️ System Enhancements

- **RPM Fusion** repositories
- **Flathub** support
- **DNS over TLS** configuration with Cloudflare for enhanced security
- **DNF optimizations** (fastest mirror, parallel downloads)
- **Terminal opacity** configuration
- **GNOME** button layout and battery percentage customization
- **Multimedia codec support** (ffmpeg, Intel media drivers)
- **System cleanup** (removes totem, rhythmbox)

### 🔒 Security & Privacy

- **DNS over TLS** with Cloudflare's security-focused DNS servers
- **Encrypted DNS queries** with malware/phishing protection
- **Secure package verification** with proper GPG key management

## Prerequisites

- Fresh Fedora 42 installation
- Internet connection
- Sudo privileges
- Ability to reboot the system after Part 1

## Installation

The setup is split into two parts with a required reboot in between to ensure the shell change to zsh takes full effect.

1. **Download the scripts**:
   ```bash
   git clone https://github.com/engineervix/fedora-setup.git
   cd fedora-setup
   ```

2. **Make scripts executable**:
   ```bash
   chmod +x fedora_setup_part1.sh fedora_setup_part2.sh
   ```

3. **Run Part 1** (Initial setup and zsh installation):
   ```bash
   ./fedora_setup_part1.sh
   ```
   The system will prompt you to reboot after completion.

4. **After reboot, run Part 2** (Main installations and configurations):
   ```bash
   ./fedora_setup_part2.sh
   ```

## What the Script Does

The setup is divided into two parts to ensure proper shell configuration:

### Part 1 (`fedora_setup_part1.sh`) - Pre-reboot Setup

1. Updates all system packages
2. Optimizes DNF with fastest mirror and parallel downloads
3. Sets up custom hostname (interactive)
4. Configures DNS over TLS for enhanced security and privacy
5. **Installs and configures zsh as the default shell**
6. Creates a marker file to track completion
7. Prompts for system reboot

**A reboot is required after Part 1 to ensure the shell change takes full effect.**

### Part 2 (`fedora_setup_part2.sh`) - Main Setup

After reboot, Part 2 continues with:

1. Verifies Part 1 completion and zsh is active
2. Configures terminal opacity for better aesthetics
3. Enables RPM Fusion repositories
4. Installs multimedia codecs and Intel media drivers
5. Removes unnecessary applications (totem, rhythmbox)

### Development Environment

1. Installs essential development tools and libraries
2. Sets up comprehensive build environment (C/C++, development tools)
3. Configures Docker with user permissions
4. Installs Node.js development tools with Volta
5. Sets up Python development environment (pyenv, Poetry, virtualenvwrapper)
6. Configures Go development environment with essential tools
7. Installs Rust development environment
8. Sets up cloud tools (AWS CLI, Heroku CLI)
9. Installs version control enhancements (lazygit, delta)

### Modern CLI Tools

Replaces traditional Unix tools with modern, feature-rich alternatives:

- `ls` → `eza` (with icons and colors)
- `cat` → `bat` (syntax highlighting)
- `find` → `fd` (faster, user-friendly)
- `grep` → `ripgrep` (faster search)
- `du` → `duf` (better disk usage)
- `top` → `btop` (beautiful system monitor)
- `ps` → `procs` (modern process viewer)
- `cd` → `zoxide` (smart directory jumping)

Additional tools: ncdu, tokei, just, rclone, bandwhich

### Shell Configuration

Creates a comprehensive `.zshrc` with:
- Custom aliases for improved productivity
- Useful functions (compression, PDF manipulation, file management, etc.)
- Integration with all installed tools
- Beautiful Starship prompt
- Automatic node_modules/.bin PATH management
- Enhanced completion systems

### Application Installation

Installs a comprehensive suite of applications:
- **Editors**: Visual Studio Code, Zed, Vim with plugins, optional Cursor
- **Media**: VLC, Audacity, Spotify, EasyEffects
- **Graphics**: GIMP, Inkscape
- **Productivity**: Okular, Xournal++, Meld, Pandoc
- **Communication**: Slack, Zoom
- **Development**: Docker, various language tools and IDEs
- **System**: Thunar (I only use the bulk renamer tool 😃), screenkey, stacer, sqlitebrowser
- **Network**: Transmission, yt-dlp, rclone

## Post-Installation

After running both parts of the script:

1. **Open a new terminal** to start using zsh with all features
2. **Configure your terminal font** to use one of the installed Nerd Fonts
3. **Complete Spotify installation** by running `lpf update`
4. **Set up Git, SSH, GnuGPG, AWS-CLI, Heroku CLI**, and other things that need auth 
5. **Follow the Firefox Configuration Steps:**
   - **Enable Hardware Acceleration & WebRender:**
     - Go to `about:config` in Firefox
     - Set `layers.acceleration.force-enabled` → `true`
     - Set `gfx.webrender.all` → `true`
   - **Enable OpenH264 plugin:**
     - Go to `about:addons` and select Plugins
     - Enable the OpenH264 plugin
     - Verify it's working: <https://mozilla.github.io/webrtc-landing/pc_test.html>
   - **Install GNOME Vitals extension:**
     - Visit: https://extensions.gnome.org/extension/1460/vitals/
     - Install the extension in Firefox
6. **Customize further** based on your specific needs

## References

- <https://github.com/devangshekhawat/Fedora-42-Post-Install-Guide>
- <https://www.youtube.com/watch?v=ixa3ezZ9XNY>
- <https://www.hackingthehike.com/fedora42-guide/>
- <https://techstay.tech/posts/things-to-do-after-installing-fedora-42.html>
- <https://gist.github.com/engineervix/ed53aa410a22620013e04baca437abb3>
