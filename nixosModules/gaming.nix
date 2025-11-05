{ config, pkgs, ... }:

{
  # Gaming-specific packages
  environment.systemPackages = with pkgs; [
    # Game launchers
    steam
    lutris

    # Gaming tools
    mangohud
    gamemode

    # Emulation
    # retroarch
  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # GameMode for performance optimization
  programs.gamemode.enable = true;

  # Enable 32-bit libraries for gaming
  hardware.graphics = {
    enable = true;
  };

  # Enable Xbox controller support
  hardware.xone.enable = false; # Set to true if you use Xbox wireless dongle
  hardware.xpadneo.enable = true; # Xbox controller via Bluetooth
}
