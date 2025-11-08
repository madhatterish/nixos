# Ansible WSUS/Windows Update Management

This directory contains Ansible playbooks and inventory for managing infrastructure, including Windows updates via WSUS.

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
