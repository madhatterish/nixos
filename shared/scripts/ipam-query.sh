#!/usr/bin/env bash
# Simple IPAM query tool for Ansible inventory
# Reads from ~/ansible/inventory.yml or ~/ansible/ipam.yml

IPAM_FILE="$HOME/ansible/ipam.yml"
INVENTORY_FILE="$HOME/ansible/inventory.yml"

# Check which file exists
if [ -f "$IPAM_FILE" ]; then
    SOURCE="$IPAM_FILE"
elif [ -f "$INVENTORY_FILE" ]; then
    SOURCE="$INVENTORY_FILE"
else
    echo "No IPAM or inventory file found at:"
    echo "  $IPAM_FILE"
    echo "  $INVENTORY_FILE"
    exit 1
fi

# If no argument, show all hosts with IPs
if [ $# -eq 0 ]; then
    echo "All hosts in $SOURCE:"
    echo "======================================"
    ansible all -i "$SOURCE" --list-hosts 2>/dev/null | tail -n +2 | while read host; do
        IP=$(ansible "$host" -i "$SOURCE" -m debug -a "var=ansible_host" 2>/dev/null | grep ansible_host | awk '{print $2}' | tr -d '"')
        printf "%-30s %s\n" "$host" "$IP"
    done
    exit 0
fi

# Search for specific host or IP
SEARCH="$1"
echo "Searching for: $SEARCH"
echo "======================================"

# Try as hostname
if ansible "$SEARCH" -i "$SOURCE" --list-hosts &>/dev/null; then
    IP=$(ansible "$SEARCH" -i "$SOURCE" -m debug -a "var=ansible_host" 2>/dev/null | grep ansible_host | awk '{print $2}' | tr -d '"')
    echo "Host: $SEARCH"
    echo "IP: $IP"

    # Show additional vars if available
    ansible "$SEARCH" -i "$SOURCE" -m debug -a "var=hostvars[inventory_hostname]" 2>/dev/null | grep -v "^$SEARCH | SUCCESS"
else
    # Try searching in inventory for IP
    grep -i "$SEARCH" "$SOURCE"
fi
