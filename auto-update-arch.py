#!/usr/bin/env python3

import subprocess

def run_command(command):
    """Run a shell command and suppress output, return True if it succeeds."""
    try:
        subprocess.run(command, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def main():
    pacman_success = run_command("sudo pacman -Syu --noconfirm")
    yay_success = run_command("yay -Syu --noconfirm")

    if pacman_success and yay_success:
        print("Update successful!")
    else:
        print("Update failed!")

if __name__ == "__main__":
    main()
