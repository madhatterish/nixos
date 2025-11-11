{ config, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix

    # Import shared modules
    ../../nixosModules/common.nix
    ../../nixosModules/desktop.nix
    ../../nixosModules/development.nix
    ../../nixosModules/netbox.nix
  ];

  # Hostname
  networking.hostName = "work-laptop";

  # Enable PostgreSQL for development (also used by NetBox)
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    # NetBox database is created by netbox.nix module
  };

  # Users
  users.users.youruser = {
    isNormalUser = true;
    description = "sgasparis";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    initialPassword = "changeme";
  };

  # Work-specific packages
  environment.systemPackages = with pkgs; [
    # Communication
    slack
    zoom-us

    # Productivity
    libreoffice

    # VPN clients
    (pkgs.callPackage ../../pkgs/netextender {})
  ];

  # Enable PPP for NetExtender VPN
  services.pppd.enable = true;

  # Allow NetExtender to run with sudo without password
  security.sudo.extraRules = [{
    users = [ "youruser" ];
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
