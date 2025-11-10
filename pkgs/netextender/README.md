# NetExtender Package for NixOS

SonicWall NetExtender VPN client packaged for NixOS.

## Installation

Add to your NixOS configuration (e.g., `hosts/work-laptop/configuration.nix`):

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.callPackage ../../pkgs/netextender {})
  ];

  # NetExtender needs PPP for VPN functionality
  programs.ppp.enable = true;

  # Optional: Allow your user to run netextender with sudo without password
  security.sudo.extraRules = [{
    users = [ "psych" ];  # Replace with your username
    commands = [{
      command = "${pkgs.callPackage ../../pkgs/netextender {}}/bin/netextender";
      options = [ "NOPASSWD" ];
    }];
  }];
}
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#work-laptop
```

**Note:** On first build, Nix will download the tarball and tell you the correct SHA256 hash. Update the `sha256` field in `default.nix` with that hash.

## Usage

### Command Line
```bash
sudo netextender -u username -p password -d domain https://vpn.example.com
```

### GUI
```bash
netextender-gui
```

Or launch from your application menu as "NetExtender"

## Troubleshooting

NetExtender requires root privileges for network configuration. Use `sudo` or configure the passwordless sudo rule shown above.
