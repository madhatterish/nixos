{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "youruser";
  home.homeDirectory = "/home/youruser";

  # This value determines the Home Manager release that your configuration is
  # compatible with. Don't change this!
  home.stateVersion = "24.11";

  # User-specific packages
  home.packages = with pkgs; [
    # CLI utilities
    htop
    ripgrep
    fd
    bat
    eza
    fzf
    jq

    # Development tools
    postman
    dbeaver-bin

    # Browser
    firefox
    google-chrome
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "work@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "eza -la";
      nixos-rebuild-work = "sudo nixos-rebuild switch --flake ~/nixos-config#work-laptop";
      nixos-update = "cd ~/nixos-config && nix flake update && sudo nixos-rebuild switch --flake .#work-laptop";
    };
  };

  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ../../shared/hyprland.conf;
  };

  # Waybar configuration
  # Machine-specific config with work-related shortcuts (Slack, Zoom)
  # Shared style from ../../shared/waybar/style.css
  xdg.configFile."waybar/config".source = ./waybar-config.json;
  xdg.configFile."waybar/style.css".source = ../../shared/waybar/style.css;

  programs.waybar = {
    enable = true;
  };

  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    theme = "Tokyo Night";
    font = {
      name = "FiraCode Nerd Font";
      size = 11;
    };
    settings = {
      background_opacity = "0.95";
      confirm_os_window_close = 0;
    };
  };

  # Rofi configuration
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
