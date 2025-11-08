#!/usr/bin/env bash
# SSH Connection Launcher with fuzzel
# Reads hosts from ~/.ssh/config and ansible inventory

# Collect SSH hosts from ~/.ssh/config
SSH_HOSTS=()
if [ -f ~/.ssh/config ]; then
    SSH_HOSTS+=($(grep "^Host " ~/.ssh/config | grep -v "\*" | awk '{print $2}'))
fi

# Collect hosts from Ansible YAML inventory by parsing host entries directly
if [ -f ~/ansible/inventory.yml ]; then
    # Parse YAML for host definitions (lines with host names ending in :)
    # This matches patterns like "  web01.prod:" or "    db01.prod:"
    YAML_HOSTS=$(grep -E '^\s+[a-zA-Z0-9._-]+:$' ~/ansible/inventory.yml | sed 's/://g' | awk '{print $1}')
    SSH_HOSTS+=($YAML_HOSTS)
fi

if [ -f ~/ansible/hosts ]; then
    ANSIBLE_HOSTS=$(grep -v "^\[" ~/ansible/hosts | grep -v "^#" | grep -v "^$" | awk '{print $1}')
    SSH_HOSTS+=($ANSIBLE_HOSTS)
fi

# Remove duplicates and sort
UNIQUE_HOSTS=($(printf '%s\n' "${SSH_HOSTS[@]}" | sort -u))

# If no hosts found, exit
if [ ${#UNIQUE_HOSTS[@]} -eq 0 ]; then
    notify-send "SSH Launcher" "No hosts found in ~/.ssh/config or ansible inventory"
    exit 1
fi

# Use fuzzel to select a host
SELECTED=$(printf '%s\n' "${UNIQUE_HOSTS[@]}" | fuzzel --dmenu --prompt "SSH to: ")

# Exit if no selection
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Launch kitty with tmux and SSH
kitty -e bash -c "tmux new-session -A -s '$SELECTED' 'ssh $SELECTED'"
