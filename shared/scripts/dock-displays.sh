#!/usr/bin/env bash

# Helper script to configure displays when docking station is connected
# This script helps with troubleshooting and manual configuration

set -e

echo "=== Dock Display Configuration Helper ==="
echo ""
echo "NOTE: Not all docks need DisplayLink!"
echo "  - Thunderbolt/USB-C docks with DP Alt Mode: Native driver (no DisplayLink needed)"
echo "  - USB-A docks or older USB-C docks: Usually need DisplayLink"
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
    # Check for DisplayLink devices (vendor ID 17e9)
    if lsusb | grep -q "17e9"; then
        echo "DisplayLink device found:"
        lsusb | grep "17e9"
    else
        echo "No DisplayLink devices detected"
    fi
    echo ""
    echo "USB Hubs (may indicate dock):"
    lsusb | grep -iE "hub" | head -5 || echo "No major USB hubs detected"
    echo ""
}

# Function to show kernel modules
check_modules() {
    echo "DisplayLink Kernel Modules:"
    echo "---------------------------"
    lsmod | grep -E "evdi|udl" || echo "DisplayLink modules not loaded"
    echo ""
}

# Function to reload display configuration
reload_displays() {
    echo "Reloading display configuration..."
    echo "Re-probing DRM devices..."
    # Reload the display by power cycling monitors
    niri msg action power-off-monitors
    sleep 1
    niri msg action power-on-monitors
    echo "Display reload complete!"
    echo ""
}

# Function to check displaylink status
check_displaylink_status() {
    echo "DisplayLink Driver Status:"
    echo "--------------------------"
    if command -v displaylink &> /dev/null; then
        echo "DisplayLink driver is installed"
    else
        echo "DisplayLink driver not found (only needed for USB-based docks)"
    fi
    echo ""
}

# Main menu
show_menu() {
    echo "Options:"
    echo "1) List all connected displays"
    echo "2) Check USB dock detection"
    echo "3) Check DisplayLink kernel modules"
    echo "4) Check DisplayLink driver status"
    echo "5) Reload displays (power cycle)"
    echo "6) Show all information"
    echo "7) Enable all displays"
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
    check_displaylink_status
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
        4) check_displaylink_status ;;
        5) reload_displays ;;
        6) show_all_info ;;
        7) enable_all_displays ;;
        q|Q) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option" ;;
    esac
done
