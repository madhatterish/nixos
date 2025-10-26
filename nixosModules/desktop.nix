{ config, pkgs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG portal for screen sharing and other desktop integrations
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable polkit for authentication
  security.polkit.enable = true;

  # Display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # Essential desktop packages
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    wlr-randr

    # Screenshot and screen recording
    grim
    slurp

    # Terminal
    kitty

    # File manager
    yazi

    # Application launcher
    rofi

    # Notifications
    dunst

    # Wallpaper
    hyprpaper

    # Status bar
    waybar

    # Screen lock
    swaylock

    # Network management GUI
    networkmanagerapplet

    # Bluetooth GUI
    blueman

    # Audio control
    pavucontrol
  ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable dconf (required for some GTK apps)
  programs.dconf.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    font-awesome
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];
}
