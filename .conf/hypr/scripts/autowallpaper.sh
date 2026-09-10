#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/"

# Time interval in seconds (e.g., 300 seconds = 5 minutes)
INTERVAL=300

# Initialize awww-daemon if not already running
awww query || awww-daemon &

while true; do
    # Find all images in the directory and pick one at random
    selected_wall=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

    if [ -n "$selected_wall" ]; then
        # Change wallpaper with a smooth transition
        awww img "$selected_wall" \
            --transition-fps 60 \
            --transition-type grow \
            --transition-duration 2
    fi

    sleep "$INTERVAL"
done
