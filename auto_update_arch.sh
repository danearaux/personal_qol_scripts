#!/usr/bin/env

# Small script to update Yay and Pacman and print it's success or failure in the terminal: (for Arch Linux!)

if sudo pacman -Syu --noconfirm > /dev/null 2>&1 && yay -Syu --noconfirm > /dev/null 2>&1; then
    echo "Update successful!"
else
    echo "Update failed!"
fi
