#!/usr/bin/env bash

# Helper script to configure displays when docking station is connected
# This script helps with troubleshooting and manual configuration

set -e

echo "=== Dock Display Configuration Helper ==="
echo ""

# Function to list all connected displays
list_displays() {
    echo "Connected Displays:"
    echo "-------------------"
    wlr-randr | grep -E "^[A-Z]|Enabled|Mode"
    echo ""
}

# Function to show USB devices (to verify dock is detected)
check_usb_dock() {
    echo "USB Display Adapters Detected:"
    echo "-------------------------------"
    lsusb | grep -iE "display|dock|hub" || echo "No DisplayLink/dock devices found via USB"
    echo ""
}

# Function to show kernel modules
check_modules() {
    echo "DisplayLink Kernel Modules:"
    echo "---------------------------"
    lsmod | grep -E "evdi|udl" || echo "DisplayLink modules not loaded"
    echo ""
}

# Function to reload displaylink service
reload_displaylink() {
    echo "Reloading DisplayLink service..."
    sudo systemctl restart displaylink.service 2>/dev/null || echo "DisplayLink service not available"
    echo ""
}

# Main menu
show_menu() {
    echo "Options:"
    echo "1) List all connected displays"
    echo "2) Check USB dock detection"
    echo "3) Check DisplayLink kernel modules"
    echo "4) Reload DisplayLink service"
    echo "5) Show all information"
    echo "6) Enable all displays"
    echo "q) Quit"
    echo ""
}

enable_all_displays() {
    echo "Enabling all detected displays..."
    wlr-randr --on
    echo "Sending power-on signal to Niri..."
    niri msg action power-on-monitors
    echo "Done!"
    echo ""
}

show_all_info() {
    list_displays
    check_usb_dock
    check_modules
}

# Main loop
if [ "$1" == "--auto" ]; then
    # Auto mode - just show info and enable displays
    show_all_info
    enable_all_displays
    exit 0
fi

while true; do
    show_menu
    read -p "Enter choice: " choice
    case $choice in
        1) list_displays ;;
        2) check_usb_dock ;;
        3) check_modules ;;
        4) reload_displaylink ;;
        5) show_all_info ;;
        6) enable_all_displays ;;
        q|Q) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
