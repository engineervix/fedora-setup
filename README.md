# Fedora Workstation Setup

An automated setup script for Fedora 42 that configures a complete development environment with various tools, editors, and applications.

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
  - [🎨 Creative & Productivity](#-creative--productivity)
  - [⚙️ System Enhancements](#-system-enhancements)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [What the Script Does](#what-the-script-does)
  - [Initial Setup](#initial-setup)
  - [Development Environment](#development-environment)
  - [Modern CLI Tools](#modern-cli-tools)
  - [Shell Configuration](#shell-configuration)
- [Post-Installation](#post-installation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Features

### 🛠️ Development Tools

- **Languages**: Python (with pyenv), Node.js (with Volta), Go, Rust
- **Package Managers**: Poetry, pipx, npm
- **Version Control**: Git with delta, GitHub CLI, GitLab CLI
- **Containers**: Docker with ctop monitoring
- **Cloud**: AWS CLI, Heroku CLI

### 📝 Editors & IDEs

- **Visual Studio Code** (official Microsoft repository)
- **Zed editor** (modern Rust-based editor)
- **Cursor** (optional)
- **Vim** with essential plugins and configuration

### 🖥️ Terminal & Shell

- **Zsh** as default shell with enhanced configuration
- **Starship** prompt for beautiful, informative shell prompts
- **Modern CLI tools**: eza, bat, ripgrep, fd, fzf, zoxide, btop, procs
- **Nerd Fonts**: JetBrains Mono, Fantasque Sans Mono, Cascadia Code

### 🌐 Browsers

- **Chromium** and **Google Chrome**
- **Brave Browser**

### 💬 Communication

- **Slack** (official RPM)
- **Zoom** (automated download and installation)

### 🎨 Creative & Productivity

- **GIMP**, **Inkscape** for graphics
- **Okular**, **Xournal++** for PDF handling
- **EasyEffects** for audio processing

### ⚙️ System Enhancements

- **RPM Fusion** repositories
- **Flathub** support
- **Terminal opacity** configuration
- **GNOME** button layout customization

## Prerequisites

- Fresh Fedora 42 installation
- Internet connection
- Sudo privileges

## Installation

1. **Download the script**:
   ```bash
   git clone https://github.com/engineervix/fedora-setup.git
   cd fedora-setup
   ```

2. **Make it executable**:
   ```bash
   chmod +x fedora_setup.sh
   ```

3. **Run the setup**:
   ```bash
   ./fedora_setup.sh
   ```

## What the Script Does

### Initial Setup

1. Updates all system packages
2. Installs and configures zsh as the default shell
3. Sets up terminal opacity for better aesthetics
4. Enables RPM Fusion repositories

### Development Environment

1. Installs essential development tools and libraries
2. Sets up Docker with user permissions
3. Configures Node.js with Volta
4. Installs Python development tools (pyenv, Poetry, virtualenvwrapper)
5. Sets up Go and Rust development environments

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

### Shell Configuration

Creates a comprehensive `.zshrc` with:
- Custom aliases for improved productivity
- Useful functions (compression, PDF manipulation, etc.)
- Integration with all installed tools
- Beautiful Starship prompt

## Post-Installation

After running the script:

1. **Reboot your system** for all changes to take effect
2. **Open a new terminal** to start using zsh
3. **Configure your terminal font** to use one of the installed Nerd Fonts
4. **Customize further** based on your specific needs
