{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "youruser";
  home.homeDirectory = "/home/youruser";

  # This value determines the Home Manager release that your configuration is
  # compatible with. Don't change this!
  home.stateVersion = "24.11";

  # Session variables for proper keyring integration
  home.sessionVariables = {
    # Ensure GNOME Keyring is used for secrets
    GNOME_KEYRING_CONTROL = "/run/user/1000/keyring";
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
  };

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
    brave
  ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Your Name";
      user.email = "work@example.com";
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

  # Noctalia shell configuration (panel, notifications, lock screen)
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
  };

  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_night";
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

  # Lock screen is now handled by Noctalia

  # Ansible inventory - symlink from repo to ~/ansible/inventory.yml
  home.file."ansible/inventory.yml".source = ../../ansible/inventory.yml;

  # Custom desktop entries for fuzzel launcher
  xdg.dataFile."applications/ssh-launcher.desktop".text = ''
    [Desktop Entry]
    Name=SSH Launcher
    Comment=Connect to SSH hosts
    Exec=kitty -e ssh-launcher
    Icon=utilities-terminal
    Type=Application
    Categories=Network;
    Terminal=false
  '';

  xdg.dataFile."applications/k8s-context.desktop".text = ''
    [Desktop Entry]
    Name=Kubernetes Context
    Comment=Switch Kubernetes contexts
    Exec=kitty -e k8s-context-switcher
    Icon=kubernetes
    Type=Application
    Categories=Network;Development;
    Terminal=false
  '';

  # XDG user directories (Downloads, Documents, etc.)
  # Force overwrite of existing user-dirs.dirs file
  xdg.configFile."user-dirs.dirs".force = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
    videos = "$HOME/Videos";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
