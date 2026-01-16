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

  # Create pppusers group for VPN access
  users.groups.pppusers = {};

  # Users
  users.users.unknown = {
    isNormalUser = true;
    description = "unknown";
    extraGroups = [ "networkmanager" "wheel" "docker" "pppusers" ];
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

  # Load PPP and WireGuard kernel modules
  boot.kernelModules = [ "ppp_generic" "ppp_async" "ppp_deflate" "ppp_mppe" "wireguard" ];

  # Enable WireGuard
  networking.wireguard.enable = true;

  # Configure pppd to allow group access and symlinks for NetExtender
  systemd.tmpfiles.rules = [
    "d /etc/ppp 0755 root root -"
    "d /etc/ppp/peers 0750 root pppusers -"
    "d /usr/sbin 0755 root root -"
    "d /sbin 0755 root root -"
    "L+ /usr/sbin/pppd - - - - /run/wrappers/bin/pppd"
    "L+ /sbin/ip - - - - ${pkgs.iproute2}/bin/ip"
    "L+ /sbin/lsmod - - - - ${pkgs.kmod}/bin/lsmod"
  ];

  # Make pppd setuid so it can be run by users
  security.wrappers.pppd = {
    source = "${pkgs.ppp}/bin/pppd";
    owner = "root";
    group = "root";
    setuid = true;
  };

  # Allow NetExtender to run with sudo without password
  security.sudo.extraRules = [{
    users = [ "unknown" ];
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
