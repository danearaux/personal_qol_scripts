#!/usr/bin/env python3

import os
from yt_dlp import YoutubeDL

def download_video():
    # Prompt the user for the URL
    url = input("url: ").strip() 
    
    if not url:
        print("No URL provided. Exiting.")
        return
    
    # Configure yt-dlp options
    ydl_opts = {
        'format': 'best[height<=720]',  # Download best quality up to 720p
        'outtmpl': '%(title)s.%(ext)s',  # Output filename template
        'noplaylist': False,  # Set to True if you only want single videos from playlist URLs
    }
    
    try:
        with YoutubeDL(ydl_opts) as ydl:
            # Extract info first to see what we're downloading
            info = ydl.extract_info(url, download=False)
            
            if 'entries' in info:
                # It's a playlist
                print(f"Found playlist: {info.get('title', 'Unknown')}")
                print(f"Number of videos: {len(info['entries'])}")
                
                proceed = input("Do you want to download the entire playlist? (y/n): ").strip().lower()
                if proceed != 'y':
                    print("Download cancelled.")
                    return
            else:
                # It's a single video
                print(f"Found video: {info.get('title', 'Unknown')}")
            
            # Actually download
            print("Starting download...")
            ydl.download([url])
            print("Download completed successfully!")
            
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        print("This could be due to:")
        print("- Invalid URL")
        print("- Network connectivity issues") 
        print("- Video availability restrictions")
        print("- Insufficient disk space")
        print("- Permission issues in the current directory")

if __name__ == "__main__":
    download_video()