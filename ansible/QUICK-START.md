# Ansible Quick Start Guide

## Step 1: Set up SSH keys (First time only)

```bash
# Generate your SSH keys
bash ~/nixos/shared/scripts/setup-ssh-keys.sh

# Copy public key to a server
ssh-copy-id -i ~/.ssh/infrastructure_ed25519.pub admin@10.0.1.10
```

## Step 2: Test connectivity

```bash
# Ping all servers
ansible all -m ping

# Ping only production servers
ansible production -m ping

# Ping a specific server
ansible web01.prod -m ping
```

## Step 3: Run your first playbook

```bash
# Health check all servers
ansible-playbook ~/ansible/playbooks/getting-started.yml

# Check only production servers
ansible-playbook ~/ansible/playbooks/getting-started.yml --limit production
```

## Common Ansible Commands

### Ad-hoc commands (quick one-liners)

```bash
# Get server uptime
ansible all -a "uptime"

# Check disk space
ansible all -a "df -h"

# Check who's logged in
ansible all -a "who"

# Reboot a specific server (careful!)
ansible web01.prod -a "reboot" --become

# Install a package on all servers
ansible all -m apt -a "name=htop state=present" --become
```

### Working with groups

```bash
# List all hosts
ansible all --list-hosts

# List hosts in a group
ansible production --list-hosts

# Run command on specific group
ansible web_servers -a "systemctl status nginx"
```

### Getting information

```bash
# Get all facts about a server
ansible web01.prod -m setup

# Get specific facts (IP addresses)
ansible all -m setup -a "filter=ansible_all_ipv4_addresses"

# Get OS information
ansible all -m setup -a "filter=ansible_distribution*"
```

## Useful Playbooks

### Check server health
```bash
ansible-playbook ~/ansible/playbooks/getting-started.yml
```

### Review Windows updates
```bash
ansible-playbook ~/ansible/playbooks/review-updates.yml
```

### Check for updates (no install)
```bash
ansible-playbook ~/ansible/playbooks/windows-updates.yml --tags check
```

## Tips

1. **Start small**: Test on one server first with `--limit hostname`
2. **Dry run**: Use `--check` to see what would change without actually changing it
3. **Verbose mode**: Add `-v`, `-vv`, or `-vvv` for more details
4. **Ask first**: Use `--step` to confirm each task before running

## SSH Launcher Integration

Press `Mod+S` (Super+S) to:
- See all servers from your inventory
- Quickly SSH to any server
- Automatically open in tmux session

## Common Issues

### "Permission denied"
- Make sure you copied your SSH key: `ssh-copy-id user@server`
- Check SSH key permissions: `chmod 600 ~/.ssh/infrastructure_ed25519`

### "Host unreachable"
- Check the IP in inventory.yml
- Try ping: `ping 10.0.1.10`
- Check firewall on server

### "Authentication failed"
- Verify username in inventory.yml
- Check SSH config: `cat ~/.ssh/config`

## Next Steps

1. ✅ Set up SSH keys
2. ✅ Test with `ansible all -m ping`
3. ✅ Run getting-started playbook
4. 📚 Learn more: https://docs.ansible.com/
5. 🚀 Create your own playbooks for:
   - Active Directory user management
   - Software deployment
   - Configuration management
   - Automated backups

## Getting Help

```bash
# Ansible docs
ansible-doc -l                    # List all modules
ansible-doc apt                   # Help for specific module

# Playbook syntax check
ansible-playbook playbook.yml --syntax-check

# List all tags in a playbook
ansible-playbook playbook.yml --list-tags

# List all tasks in a playbook
ansible-playbook playbook.yml --list-tasks
```
