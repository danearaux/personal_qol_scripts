#!/usr/bin/env bash

# Video Downloader: Alias this script as "vdl" in your terminal configuration.
# Also remember to "sudo chmod +x video_dl.sh" to make it executable.

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    sudo pacman -S --noconfirm yt-dlp
    if [ $? -ne 0 ]; then
        echo "Failed to install yt-dlp. Please check your package manager."
        exit 1
    else
        echo "yt-dlp installed successfully!"
    fi
fi

# Prompt the user for a video URL
printf "URL: "
read -r url

if [ -z "$url" ]; then
    echo "No URL provided. Exiting."
    exit 1
fi

# Download the video using yt-dlp with best quality
if ! yt-dlp -f "bestvideo+bestaudio/best" "$url" > /dev/null 2>&1; then
    echo "Video download failed!"
else
    echo "Video successfully downloaded!"
fi

exit 0
