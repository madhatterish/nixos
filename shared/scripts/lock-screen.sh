#!/usr/bin/env bash
# Lock screen script that uses the current waypaper wallpaper

# Get the current wallpaper from waypaper config
WALLPAPER=$(grep "^wallpaper" ~/.config/waypaper/config.ini | cut -d'=' -f2 | xargs)

# If no wallpaper found, use default
if [ -z "$WALLPAPER" ] || [ ! -f "${WALLPAPER/#\~/$HOME}" ]; then
    WALLPAPER=~/Pictures/Wallpapers/arc.png
fi

# Launch swaylock with the current wallpaper
swaylock -C ~/.config/swaylock/config --image "$WALLPAPER"
