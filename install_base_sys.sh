
#!/usr/bin/env bash

# Causes an immediate exit upon error.
set -e
echo "Installing your base system! this may take a moment."
# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Update the system and install necessary packages
if ! pacman -Syu --noconfirm
then
    echo "Failed to update the system."
    exit 1
else
    echo "System successfully updated!"
fi

# Installing tons of packages.
if ! pacman -S --noconfirm nftables networkmanager bluez bluez-utils ufw lynis lolcat fastfetch git python swww neovim waybar rofi easyeffects pipewire pipewire-pulse pipewire-alsa pipewire-jack pavucontrol pulseaudio-ctl pulsemixer playerctl xdg-user-dirs xdg-utils xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-kde harfbuzz snapper btrfs-progs net-tools curl wget unzip zip tar gzip bzip2 xz p7zip lzip lz4 brotli zstd jq exa bat ripgrep fd-find 7zip libreoffice-fresh zathura-ps zathura-pdf-mupdf zathura-djvu zathura-pdf-poppler zathura-ps poppler-utils mupdf-tools htop kcalc imagemagick gimp yt-dlp discord spotify zoom vlc mpv firefox librewolf hyprcursor 
then 
    echo "Failed to install packages."
    exit 1
else
    echo "Packages successfully installed!"
fi

echo "Installing Rust programming language..."

if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
then
    echo "Failed to download Rust."
    exit 1
else
    echo "Rust installed successfully!"
fi

if ! pacman -S --needed base-devel
then
    echo "Failed to install base-devel."
    exit 1
else
    echo "base-devel and git successfully installed!"
fi

if ! git clone https://aur.archlinux.org/paru.git
then
    echo "Failed to clone paru repository."
    exit 1
else
    echo "paru repository cloned successfully!"
fi

OWNER=$(logname)
if ! chown -R "$OWNER":"$OWNER" paru; then
    echo "Failed to change ownership of paru directory."
    exit 1
else
    echo "Ownership of paru directory changed successfully!"
fi

if ! find paru -type d -exec chmod 755 {} + && find paru -type f -exec chmod 644 {} +
then
    echo "Failed to change permissions of paru directory."
    exit 1
else
    echo "Permissions of paru directory changed successfully!"
fi

if ! cd paru
then
    echo "Failed to change directory to paru."
    exit 1
else
    echo "Changed directory to paru successfully!"
fi

makepkg -si --noconfirm || { echo "Failed to build and install paru."; exit 1; }

if ! paru -Syu --noconfirm
then
    echo "Failed to update packages with paru."
    exit 1
else
    echo "Packages updated successfully with paru!"
fi

echo "Paru and all your packages are successfully updated and installed!"
echo "Cleaning up unnecessary packages and cache..."

orphans=$(pacman -Qdtq || true)
if [ -n "$orphans" ]; then
    if ! pacman -Rns "$orphans" --noconfirm; then
        echo "Failed to remove unnecessary packages."
        exit 1
    else
        echo "Unnecessary packages removed successfully!"
    fi
else
    echo "No unnecessary packages found."
fi

exit 0