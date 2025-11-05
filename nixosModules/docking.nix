{ config, pkgs, lib, ... }:

{
  # DisplayLink support for USB docking stations
  # Many USB docks (Dell, HP, Lenovo, Plugable, etc.) use DisplayLink chipsets
  # Note: DisplayLink is only needed for USB-based docks, not Thunderbolt/USB-C with DP Alt Mode

  # Allow unfree packages for DisplayLink
  nixpkgs.config.allowUnfree = true;

  # Kernel modules for USB display adapters
  boot.kernelModules = [
    "udl"            # USB DisplayLink
    "evdi"           # EVDI module for DisplayLink
  ];

  # Additional kernel parameters for better USB and display support
  boot.kernelParams = [
    "video=HDMI-A-1:D"  # This can help with display detection
  ];

  # Extra kernel modules for USB display devices (EVDI for DisplayLink)
  boot.extraModulePackages = with config.boot.kernelPackages; [
    evdi  # Essential Video Device Linked Interface for DisplayLink
  ];

  # Udev rules for automatic dock detection and setup
  services.udev.extraRules = ''
    # DisplayLink devices - reload driver when connected
    ACTION=="add", SUBSYSTEM=="usb", DRIVER=="udl", \
      RUN+="${pkgs.systemd}/bin/systemctl restart display-manager.service"

    # Generic USB display adapters
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="17e9", \
      TAG+="systemd", ENV{SYSTEMD_WANTS}="displaylink.service"

    # Allow users to access video devices
    KERNEL=="card[0-9]*", SUBSYSTEM=="drm", TAG+="uaccess"

    # Disable USB autosuspend for USB hubs to prevent dock disconnection issues
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", \
      TEST=="power/control", ATTR{power/control}="on"
  '';

  # System packages for monitor management
  environment.systemPackages = with pkgs; [
    # Monitor configuration tools
    wlr-randr        # Wayland display configuration (already in desktop.nix but important)
    wdisplays        # GUI for configuring displays on Wayland

    # USB utilities for debugging
    usbutils         # lsusb command
    pciutils         # lspci command

    # EDID tools for monitor detection debugging
    edid-decode      # Decode EDID data from monitors
    read-edid        # Read EDID data

    # DRM utilities for display debugging
    libdrm

    # Create a wrapper package for the dock-displays script
    (pkgs.writeScriptBin "dock-displays" ''
      #!${pkgs.bash}/bin/bash
      exec ${pkgs.bash}/bin/bash ~/nixos-config/shared/scripts/dock-displays.sh "$@"
    '')
  ];

  # Services for DisplayLink - using systemd to manage the connection
  systemd.services.displaylink-reload = {
    description = "Reload DisplayLink devices";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kmod}/bin/modprobe -r evdi && ${pkgs.kmod}/bin/modprobe evdi";
    };
  };

  # Hardware acceleration support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # Increase the number of file descriptors for better multi-monitor support
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "524288";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];

  # Enable early KMS (Kernel Mode Setting) for better display support
  boot.initrd.kernelModules = [ "i915" "amdgpu" "radeon" ];

  # Systemd service to restart display services when dock is connected
  systemd.user.services.dock-display-setup = {
    description = "Configure displays when dock is connected";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && niri msg action power-on-monitors'";
    };
  };
}
