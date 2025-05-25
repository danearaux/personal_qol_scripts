#!/usr/bin/env bash

# This script configures and connects to a Wi-Fi network using wpa_supplicant.

# Usage: ./connect_wifi.sh <SSID> <PSK>
# Example: ./connect_wifi.sh "SSID" "PSK"

set -euo pipefail

WLINT=""

if command -v nmcli &> /dev/null; then
    WLINT=$(nmcli device status | awk '$2 == "wifi" {print $1; exit}')
    if [ -n "$WLINT" ]; then # Check if WLINT is not empty
        printf "Detected wireless interface using nmcli: %s\n" "$WLINT"
    fi
fi

if [ -z "$WLINT" ]; then # Only try this if WLINT is still empty
    # Loop through potential wireless interface paths in /sys/class/net/
    # 'wl*' covers wlanX, wlpXsY, etc.
    for IFACE_PATH in /sys/class/net/wl*; do
        # Check if the path exists and is a directory (interface exists)
        # 'grep -q' quietly checks for 'DEVTYPE=wlan' in the uevent file.
        if [ -d "$IFACE_PATH" ] && grep -q 'DEVTYPE=wlan' "$IFACE_PATH/uevent" 2>/dev/null; then
            WLINT=$(basename "$IFACE_PATH") # Extract just the interface name
            printf "Detected wireless interface using sysfs: %s\n" "$WLINT"
            break # Exit loop once found
        fi
    done
fi

# Attempt 3: Fallback to ip link with broader regex (for older/custom systems)
# This catches common patterns like wlanX, wlpXsY, wwpXsY.
if [ -z "$WLINT" ]; then # Only try this if WLINT is still empty
    WLINT=$(ip link | grep -oP 'wlan[0-9]+|wlp[0-9]+s[0-9]+(?:f[0-9]+)?|wwp[0-9]+s[0-9]+(?:f[0-9]+)?' | head -n 1)
    if [ -n "$WLINT" ]; then
        printf "Detected wireless interface using ip link: %s\n" "$WLINT"
    fi
fi

# Final check for wireless interface
if [ -z "$WLINT" ]; then
    printf "Error: No wireless interface found. Please ensure you have a wireless adapter connected and its drivers are loaded.\n" >&2 # Output to stderr
    exit 1
fi

# --- 2. Argument Validation ---

# Check if SSID is provided
SSID="$1" # Assign first argument to SSID
if [ -z "$SSID" ]; then
    printf "Usage: %s <SSID> <PSK>\n" "$0" >&2
    exit 1
fi

# Check if PSK is provided
PSK="$2" # Assign second argument to PSK
if [ -z "$PSK" ]; then
    printf "Usage: %s <SSID> <PSK>\n" "$0" >&2
    exit 1
fi

# --- 3. Generate wpa_supplicant.conf ---
# wpa_passphrase generates the configuration.
# 'sudo tee' writes it to the file with root permissions.
# '> /dev/null' discards stdout (the generated config) from tee.
printf "Generating wpa_supplicant.conf for SSID '%s'...\n" "$SSID"
wpa_passphrase "$SSID" "$PSK" | sudo tee "/etc/wpa_supplicant/wpa_supplicant.conf" > /dev/null

# Check the exit status of the previous command (tee in this case)
if [ $? -ne 0 ]; then
    printf "Error: Failed to write to /etc/wpa_supplicant/wpa_supplicant.conf. Check permissions or sudo setup.\n" >&2
    exit 1
fi

# Set secure permissions for the config file
sudo chmod 600 "/etc/wpa_supplicant/wpa_supplicant.conf"

# --- 4. Bring Up the Wireless Interface ---

printf "Bringing up interface %s...\n" "$WLINT"
if ! sudo ip link set "$WLINT" up; then
    printf "Error: Failed to bring up the %s interface. Please check its status and your network configuration.\n" "$WLINT" >&2
    exit 1
else
    printf "%s interface is up.\n" "$WLINT"
fi

# --- 5. Start wpa_supplicant Daemon ---
# This command starts wpa_supplicant in the background (-B)
# using the detected interface (-i) and the generated config file (-c).

printf "Starting wpa_supplicant for %s...\n" "$SSID"
# The '|| true' is used here to prevent 'set -e' from exiting if wpa_supplicant
# returns a non-zero status for expected reasons (e.g., already running, but we check below).
# It's better to check its PID later or use systemctl.
sudo wpa_supplicant -B -i "$WLINT" -c "/etc/wpa_supplicant/wpa_supplicant.conf" || true

# Give wpa_supplicant a moment to start
sleep 2

# Check if wpa_supplicant is actually running for this interface
# Use 'pgrep' to find processes by name and filter by interface argument.
if ! pgrep -f "wpa_supplicant -B -i ${WLINT}"; then
    printf "Error: wpa_supplicant failed to start or is not running for %s. Check system logs (e.g., journalctl -u wpa_supplicant or dmesg).\n" "$WLINT" >&2
    exit 1
else
    printf "wpa_supplicant started successfully for %s.\n" "$WLINT"
fi

# --- 6. Obtain an IP Address (via DHCP) ---
# This is crucial for actual network connectivity (browsing, etc.).
# You might need to kill any existing dhclient processes first for a clean start.

printf "Obtaining IP address for %s via DHCP...\n" "$WLINT"
# Kill any old dhclient processes on this interface to prevent conflicts
sudo pkill -f "dhclient.*$WLINT" || true # '|| true' prevents exit if no process found

sudo dhclient "$WLINT"
if [ $? -ne 0 ]; then
    printf "Error: Failed to obtain an IP address for %s. Check network connectivity or DHCP server.\n" "$WLINT" >&2
    exit 1
else
    printf "Successfully obtained IP address for %s.\n" "$WLINT"
    printf "Connected to '%s'!\n" "$SSID"
    # Display current IP address for confirmation
    printf "Current IP address:\n"
    ip -4 addr show "$WLINT" | grep -oP 'inet \K[\d.]+'
fi

printf "Wi-Fi setup complete.\n"
