{ config, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix

    # Import shared modules
    ../../nixosModules/common.nix
    ../../nixosModules/desktop.nix
    ../../nixosModules/gaming.nix
    ../../nixosModules/development.nix
    ../../nixosModules/netbox.nix
  ];

  # Hostname
  networking.hostName = "home-laptop";

  # Users
  users.users.unaware = {
    isNormalUser = true;
    description = "unaware";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    initialPassword = "changeme";
  };

  # Home-specific packages
  environment.systemPackages = with pkgs; [
    # Entertainment
    discord
    spotify

    # Media
    vlc
    gimp

    # VPN clients
    (pkgs.callPackage ../../pkgs/netextender {})

    # Torrenting (optional)
    # qbittorrent
  ];

  # Enable PPP for NetExtender VPN
  services.pppd.enable = true;

  # Allow NetExtender to run with sudo without password
  security.sudo.extraRules = [{
    users = [ "unaware" ];
    commands = [{
      command = "${pkgs.callPackage ../../pkgs/netextender {}}/bin/netextender";
      options = [ "NOPASSWD" ];
    }];
  }];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this!
  system.stateVersion = "24.11"; # Did you read the comment?
}
