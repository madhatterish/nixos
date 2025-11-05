{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "unaware";
  home.homeDirectory = "/home/unaware";

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

    # Browser
    brave
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "personal@example.com";
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
      nixos-rebuild-home = "sudo nixos-rebuild switch --flake ~/nixos-config#home-laptop";
      nixos-update = "cd ~/nixos-config && nix flake update && sudo nixos-rebuild switch --flake .#home-laptop";
    };
  };

  # Niri configuration
  # Link the KDL config file directly - Niri will use this automatically
  xdg.configFile."niri/config.kdl".source = ../../shared/niri.kdl;

  # Waybar configuration
  # Machine-specific config with home/gaming shortcuts (Discord, Spotify)
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

  # Fuzzel configuration (application launcher)
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "kitty";
        layer = "overlay";
        font = "FiraCode Nerd Font:size=11";
      };
      colors = {
        background = "1a1b26dd";
        text = "c0caf5ff";
        match = "7aa2f7ff";
        selection = "283457ff";
        selection-text = "c0caf5ff";
        border = "33ccffff";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };

  # Swaylock configuration
  xdg.configFile."swaylock/config".source = ../../shared/swaylock.conf;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
