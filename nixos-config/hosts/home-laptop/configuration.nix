{ config, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix

    # Import shared modules
    ../../nixosModules/common.nix
    ../../nixosModules/desktop.nix
    ../../nixosModules/gaming.nix
  ];

  # Hostname
  networking.hostName = "home-laptop";

  # Users
  users.users.youruser = {
    isNormalUser = true;
    description = "Your Name";
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

    # Torrenting (optional)
    # qbittorrent
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this!
  system.stateVersion = "24.11"; # Did you read the comment?
}
