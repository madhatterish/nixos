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

  # Display manager - SDDM with graphical login
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Set Hyprland as default session
  services.displayManager.defaultSession = "hyprland";

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

    # Waybar system tray dependencies
    libdbusmenu-gtk3

    # Credential management
    gnome-keyring
    seahorse  # GUI for managing passwords/credentials

    # Backlight control
    brightnessctl
  ];

  # Sound with PipeWire (PulseAudio compatibility for Waybar)
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Network management (required for Waybar network module)
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable dconf (required for some GTK apps)
  programs.dconf.enable = true;

  # GNOME Keyring for credential management (WiFi passwords, etc.)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Backlight control permissions
  programs.light.enable = true;

  # Set default screen backlight brightness on boot
  systemd.services.backlight-default = {
    description = "Set default screen backlight brightness";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-backlight@.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl set 100%";
    };
  };

  # Set default keyboard backlight on boot (always on)
  systemd.services.kbd-backlight-default = {
    description = "Set default keyboard backlight";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-backlight@.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl --device='*kbd_backlight' set 100%";
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    font-awesome
    # Nerd Fonts (new individual package syntax)
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
}
