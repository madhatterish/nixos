#!/usr/bin/env bash
# SSH Key Setup Helper
# This script helps you generate and organize SSH keys for different purposes

set -e

echo "=== SSH Key Setup Helper ==="
echo ""

# Ensure .ssh directory exists
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Function to generate a key if it doesn't exist
generate_key() {
    local key_name=$1
    local key_comment=$2
    local key_path="$HOME/.ssh/${key_name}"

    if [ -f "$key_path" ]; then
        echo "✓ Key already exists: $key_name"
    else
        echo "Generating $key_name..."
        ssh-keygen -t ed25519 -f "$key_path" -C "$key_comment"
        chmod 600 "$key_path"
        chmod 644 "${key_path}.pub"
        echo "✓ Generated: $key_name"
    fi
}

# Generate keys for different purposes
echo "Generating SSH keys..."
echo ""

generate_key "infrastructure_ed25519" "Infrastructure servers - $(whoami)@$(hostname)"
generate_key "network_ed25519" "Network equipment - $(whoami)@$(hostname)"
generate_key "github_ed25519" "GitHub - $(whoami)@$(hostname)"

echo ""
echo "=== SSH Keys Generated ==="
echo ""

# Display public keys
echo "Your public keys (add these to your servers):"
echo ""

for key in infrastructure_ed25519 network_ed25519 github_ed25519; do
    if [ -f ~/.ssh/${key}.pub ]; then
        echo "--- $key ---"
        cat ~/.ssh/${key}.pub
        echo ""
    fi
done

echo "=== Next Steps ==="
echo ""
echo "1. Add public keys to your servers:"
echo "   - Infrastructure: Copy infrastructure_ed25519.pub to servers' ~/.ssh/authorized_keys"
echo "   - Network: Add network_ed25519.pub to network device SSH keys"
echo "   - GitHub: Add github_ed25519.pub to https://github.com/settings/keys"
echo ""
echo "2. Add keys to SSH agent (will prompt for passphrase):"
echo "   ssh-add ~/.ssh/infrastructure_ed25519"
echo "   ssh-add ~/.ssh/network_ed25519"
echo "   ssh-add ~/.ssh/github_ed25519"
echo ""
echo "3. Test connections:"
echo "   ssh web01.prod"
echo "   ssh -T git@github.com"
echo ""
echo "4. For Ansible, the keys are already configured in ~/.ssh/config"
echo ""

# Optionally add keys to agent
read -p "Add keys to SSH agent now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    for key in infrastructure_ed25519 network_ed25519 github_ed25519; do
        if [ -f ~/.ssh/${key} ]; then
            echo "Adding $key to agent..."
            ssh-add ~/.ssh/${key}
        fi
    done
    echo ""
    echo "Keys added to agent. You can list them with: ssh-add -l"
fi

echo ""
echo "Done!"
