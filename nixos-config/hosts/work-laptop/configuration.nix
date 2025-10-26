{ config, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix

    # Import shared modules
    ../../nixosModules/common.nix
    ../../nixosModules/desktop.nix
    ../../nixosModules/development.nix
  ];

  # Hostname
  networking.hostName = "work-laptop";

  # Enable PostgreSQL for development
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
  };

  # Users
  users.users.youruser = {
    isNormalUser = true;
    description = "Your Name";
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

    # VPN clients (uncomment if needed)
    # openvpn
    # networkmanager-openvpn
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this!
  system.stateVersion = "24.11"; # Did you read the comment?
}
