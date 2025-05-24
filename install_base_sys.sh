#!/usr/bin/env bash

# Causes an immediate exit upon error.
set -e
echo "Installing your base system! this may take a moment."

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Get the actual user who ran sudo (not root)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    USER_HOME="/home/$SUDO_USER"
elif [ -n "$USER" ] && [ "$USER" != "root" ]; then
    REAL_USER="$USER"
    USER_HOME="/home/$USER"
else
    echo "Error: Cannot determine the real user. Please run with sudo as a regular user."
    exit 1
fi

echo "Detected user: $REAL_USER"

# Update the system and install necessary packages
if ! pacman -Syu --noconfirm; then
    echo "Failed to update the system."
    exit 1
else
    echo "System successfully updated!"
fi

# Fixed package list (removed non-existent packages)
echo "Installing packages..."
if ! pacman -S --noconfirm --needed \
    nftables networkmanager bluez bluez-utils ufw lynis lolcat fastfetch git python \
    swww neovim waybar rofi easyeffects pipewire pipewire-pulse pipewire-alsa \
    pipewire-jack pavucontrol pulseaudio-ctl pulsemixer playerctl xdg-user-dirs \
    xdg-utils xdg-desktop-portal xdg-desktop-portal-gtk harfbuzz snapper \
    btrfs-progs net-tools curl wget unzip zip tar gzip bzip2 xz p7zip lzip lz4 \
    brotli zstd jq exa bat ripgrep fd htop kcalc imagemagick gimp yt-dlp vlc mpv \
    firefox base-devel; then 
    echo "Failed to install some packages. Continuing anyway..."
else
    echo "Packages successfully installed!"
fi

# Try to install optional packages that might not be available
echo "Installing optional packages..."
optional_packages=(discord spotify zoom libreoffice-fresh zathura-ps zathura-pdf-mupdf zathura-djvu zathura-pdf-poppler poppler-utils mupdf-tools)

for pkg in "${optional_packages[@]}"; do
    if pacman -S --noconfirm --needed "$pkg" 2>/dev/null; then
        echo "Package $pkg installed successfully!"
    else
        echo "Package $pkg failed to install (might not be available)"
    fi
done

# Install Rust as the real user
echo "Installing Rust programming language as user $REAL_USER..."
sudo -u "$REAL_USER" bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'

if [ $? -eq 0 ]; then
    echo "Rust installed successfully!"
else
    echo "Failed to install Rust, continuing anyway..."
fi

# Clone and build paru as regular user
echo "Setting up paru AUR helper..."
PARU_DIR="$USER_HOME/paru"

# Remove existing paru directory if it exists
if [ -d "$PARU_DIR" ]; then
    rm -rf "$PARU_DIR"
fi

# Clone paru as regular user
if ! sudo -u "$REAL_USER" git clone https://aur.archlinux.org/paru.git "$PARU_DIR"; then
    echo "Failed to clone paru repository."
    exit 1
else
    echo "paru repository cloned successfully!"
fi

# Build and install paru as regular user
echo "Building paru..."
cd "$PARU_DIR"

# Build paru as regular user
if ! sudo -u "$REAL_USER" makepkg -si --noconfirm; then
    echo "Failed to build and install paru."
    echo "This might be due to missing dependencies or build issues."
    echo "You can manually install paru later."
    PARU_FAILED=1
else
    echo "Paru installed successfully!"
    PARU_FAILED=0
fi

# Go back to original directory
cd - > /dev/null

# Update with paru if it was installed successfully
if [ $PARU_FAILED -eq 0 ]; then
    echo "Updating system with paru..."
    if ! sudo -u "$REAL_USER" paru -Syu --noconfirm; then
        echo "Failed to update packages with paru."
    else
        echo "Packages updated successfully with paru!"
    fi
fi

echo "Cleaning up unnecessary packages and cache..."

# Clean package cache
pacman -Sc --noconfirm || echo "Failed to clean package cache"

# Remove orphaned packages
orphans=$(pacman -Qdtq 2>/dev/null || true)
if [ -n "$orphans" ]; then
    if ! pacman -Rns $orphans --noconfirm; then
        echo "Failed to remove some unnecessary packages."
    else
        echo "Unnecessary packages removed successfully!"
    fi
else
    echo "No unnecessary packages found."
fi

# Clean up paru build directory
if [ -d "$PARU_DIR" ]; then
    rm -rf "$PARU_DIR"
    echo "Cleaned up paru build directory."
fi

echo "Installation script completed!"
echo "Note: Some optional packages might not have been installed if they're not available in the repositories."

if [ $PARU_FAILED -eq 1 ]; then
    echo "Warning: paru installation failed. You may need to install it manually later."
fi
