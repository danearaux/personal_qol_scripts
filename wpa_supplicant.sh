#!/usr/bin/env bash

# PROPER SYNTAX = "python wpa_supplicant.sh <SSID> <PSK>"

SSID="$1"
if [ -z "$SSID" ]; then
	 echo "Usage: $0 <SSID> <PSK>"
	 exit 1
fi

PSK="$2"
if [ -z "$PSK" ]; then
	 echo "Usage: $0 <SSID> <PSK>"
	 exit 1
fi

wpa_passphrase "$SSID" "$PSK" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null

echo "Adding SSID '$SSID' and PSK "$PSK" to wpa_supplicant.conf."

if [ $? -ne 0 ]; then
	 echo "Failed to write to /etc/wpa_supplicant/wpa_supplicant.conf."
	 exit 1
fi

if ! wpa_supplicant "$SSID" -B -i wlan0 -c <(wpa_passphrase "$SSID" "$PSK") > /dev/null 2>&1; then
	 echo "wpa_supplicant command failed. Please check your network interface and configuration."
	 exit 1
fi

echo "wpa_supplicant started for SSID '$SSID'."

# Start wpa_supplicant with the provided SSID and PSK
sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf

if ! sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf; then
	echo "Failed to start wpa_supplicant."
else
	# If the command was successful, print a success message
	echo" wpa_supplicant started successfully for SSID '$SSID'!"
fi

exit 0


