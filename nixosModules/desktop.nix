{ config, pkgs, ... }:

{
  # Environment variables for Wayland apps
  environment.sessionVariables = {
    # Enable Wayland support for Electron/Chromium apps
    NIXOS_OZONE_WL = "1";
  };

  # Enable Niri
  programs.niri = {
    enable = true;
  };

  # XDG portal for screen sharing and other desktop integrations
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome ];
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
      niri = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
  };

  # Enable polkit for authentication
  security.polkit.enable = true;

  # Display manager - SDDM with graphical login and blurred background
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
    package = pkgs.kdePackages.sddm;

    settings = {
      General = {
        # Use Wayland session
        DisplayServer = "wayland";
        # Set input method
        InputMethod = "";
      };

      Theme = {
        # Theme settings - breeze theme with customizations
        Current = "breeze";
        CursorTheme = "breeze_cursors";
        CursorSize = 24;
        # Enable blur
        EnableHiDPI = true;
      };

      Users = {
        # Hide system users
        MaximumUid = 60000;
        MinimumUid = 1000;
        HideUsers = "";
        HideShells = "/bin/false,/usr/bin/nologin";
        # Show user avatars and remember settings
        RememberLastUser = true;
        RememberLastSession = true;
        # User icon directory
        DefaultAvatar = "";
      };
    };
  };

  # Set Niri as default session
  services.displayManager.defaultSession = "niri";

  # Create custom SDDM theme configuration for blurred background
  environment.etc."sddm.conf.d/theme.conf".text = ''
    [Theme]
    Current=breeze
    CursorTheme=breeze_cursors
    CursorSize=24

    # Background image with blur
    # You can set this to your wallpaper path
    background=/home/unaware/Pictures/Wallpapers/arc.png
    type=image

    # Enable blur effect
    blur=true
  '';

  # SSH launcher script wrapper
  environment.systemPackages = with pkgs; [
    (pkgs.writeScriptBin "ssh-launcher" ''
      #!${pkgs.bash}/bin/bash
      ${builtins.readFile ../shared/scripts/ssh-launcher.sh}
    '')
  ] ++ (with pkgs; [
    # SDDM theme dependencies
    libsForQt5.qt5.qtgraphicaleffects  # Required for blur effects
    libsForQt5.qt5.qtquickcontrols2     # Required for SDDM themes
    libsForQt5.qt5.qtsvg                # SVG support for icons
    kdePackages.breeze                   # Breeze theme with blur

    # Wayland utilities
    wl-clipboard
    wlr-randr

    # Terminal
    kitty

    # File manager
    yazi

    # Application launcher
    fuzzel  # Niri works well with fuzzel (or you can use rofi)

    # Notifications
    dunst
    libnotify  # Provides notify-send command

    # Wallpaper
    swaybg    # Niri compatible wallpaper tool
    waypaper  # GUI wallpaper manager for Wayland (works with swaybg)

    # Status bar
    waybar

    # Screen lock
    swaylock-effects  # Enhanced swaylock with blur and effects
    swayidle          # Idle management daemon
    grim              # Screenshot tool (required for swaylock-effects screenshots)

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

    # Infrastructure & Remote Management
    ansible  # Automation for 100+ servers
    tmux     # Terminal multiplexer for persistent SSH sessions
    remmina  # GUI for RDP/VNC connections

    # Network utilities for IPAM workflows
    ipcalc   # IP subnet calculator
    sipcalc  # Advanced IP calculator
    nmap     # Network scanning and discovery

    # Backlight control
    brightnessctl
  ]);

  # Sound with PipeWire (PulseAudio compatibility for Waybar)
  services.pulseaudio.enable = false;
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

  # Swaybg wallpaper service (user service)
  # Usage: Set wallpaper with: swaybg -i /path/to/wallpaper.jpg -m fill &
  # Or use waypaper GUI to manage wallpapers
  systemd.user.services.swaybg = {
    description = "Wayland wallpaper daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ~/Pictures/Wallpapers/default.jpg -m fill";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  # Swayidle service for automatic screen locking
  # Locks screen after 10 minutes of inactivity, turns off display after 15 minutes
  systemd.user.services.swayidle = {
    description = "Idle manager for Wayland";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    path = [ pkgs.bash ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 600 'bash ~/nixos/shared/scripts/lock-screen.sh' \
          timeout 900 'niri msg action power-off-monitors' \
          resume 'niri msg action power-on-monitors' \
          before-sleep 'bash ~/nixos/shared/scripts/lock-screen.sh'
      '';
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    font-awesome
    # Nerd Fonts (new individual package syntax)
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
}
