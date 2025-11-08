# Ansible Infrastructure Management

This directory contains Ansible playbooks and inventory for managing infrastructure, including Windows updates via WSUS.

## SSH Key Setup

### Quick Start

Run the SSH key setup helper:
```bash
bash ~/nixos/shared/scripts/setup-ssh-keys.sh
```

This will generate separate SSH keys for:
- `infrastructure_ed25519` - Linux/Unix servers
- `network_ed25519` - Network equipment (switches, routers)
- `github_ed25519` - Git repositories

### Manual Key Generation

If you prefer to generate keys manually:
```bash
# Infrastructure servers
ssh-keygen -t ed25519 -f ~/.ssh/infrastructure_ed25519 -C "infrastructure-$(hostname)"

# Network equipment
ssh-keygen -t ed25519 -f ~/.ssh/network_ed25519 -C "network-$(hostname)"
```

### Deploy Public Keys to Servers

```bash
# Copy to a specific server
ssh-copy-id -i ~/.ssh/infrastructure_ed25519.pub admin@web01.prod

# Or manually add to ~/.ssh/authorized_keys on the server
cat ~/.ssh/infrastructure_ed25519.pub | ssh admin@server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### Using SSH Keys with Ansible

Your `~/.ssh/config` (managed by home-manager) automatically uses the correct keys:
- `*.prod`, `*.staging` → `infrastructure_ed25519`
- `switch*`, `router*` → `network_ed25519`

You can override per-host in the inventory:
```yaml
hosts:
  special-server:
    ansible_host: 10.0.1.100
    ansible_ssh_private_key_file: ~/.ssh/special_key_ed25519
```

## Prerequisites

### On your NixOS machine:

1. Install required Python packages:
```bash
pip install pywinrm[kerberos]
```

2. Ensure Ansible is installed (already in development.nix)

### On Windows servers:

1. Enable WinRM:
```powershell
# Run as Administrator
Enable-PSRemoting -Force
winrm quickconfig

# Allow HTTPS
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="false"}'

# Create self-signed cert (or use proper cert)
New-SelfSignedCertificate -DnsName "servername" -CertStoreLocation Cert:\LocalMachine\My
```

2. Configure WSUS client (if using WSUS server):
```powershell
# Point to your WSUS server
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUServer" -Value "http://wsus-server:8530"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUStatusServer" -Value "http://wsus-server:8530"
```

## Usage

### Check for available updates (no changes):
```bash
cd ~/ansible
ansible-playbook playbooks/windows-updates.yml --tags check
```

### Download updates (don't install):
```bash
ansible-playbook playbooks/windows-updates.yml --tags download
```

### Interactive review and approval:
```bash
ansible-playbook playbooks/review-updates.yml
```
This will:
1. Show all available updates
2. Ask for your approval before installing
3. Ask if you want to reboot after installation

### Install specific update categories:
```bash
# Only critical and security updates
ansible-playbook playbooks/windows-updates.yml --tags install \
  -e "update_categories=['CriticalUpdates','SecurityUpdates']"

# All updates with auto-reboot
ansible-playbook playbooks/windows-updates.yml --tags install \
  -e "auto_reboot=yes"
```

### Check updates for specific hosts:
```bash
ansible-playbook playbooks/review-updates.yml --limit win-srv01
```

## Update Categories

Available categories:
- `CriticalUpdates` - Critical patches
- `SecurityUpdates` - Security fixes
- `UpdateRollups` - Cumulative updates
- `Updates` - General updates
- `DefinitionUpdates` - Antivirus definitions
- `FeaturePacks` - New features
- `ServicePacks` - Service packs

## Reports

Update reports are saved to `/tmp/HOSTNAME_update_report.json` after installation.

## Workflow

1. **Weekly review**: Run `review-updates.yml` to see what's available
2. **Approve critical**: Install critical/security updates immediately
3. **Schedule others**: Plan maintenance window for other updates
4. **Monitor**: Check reports and WSUS server for compliance

## Inventory

Edit `inventory.yml` to add your Windows servers to the `windows` group.
