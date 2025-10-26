{ config, pkgs, ... }:

{
  # Development tools and environments
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh # GitHub CLI

    # Programming languages
    nodejs_20
    python3
    rustc
    cargo
    go

    # Build tools
    gnumake
    cmake
    gcc

    # Containers and virtualization
    docker-compose
    docker-desktop

    # Text editors and IDEs
    vscode
    lens
    beekeeper-studio

    # Database tools
    postgresql
    sqlite

    # Network tools
    nmap
    tcpdump
    wireshark

    # Cloud tools
    kubectl
    terraform
    awscli2
    doctl
    argocd
  ];

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Podman (alternative to Docker)
  # virtualisation.podman.enable = true;

  # Development databases
  services.postgresql = {
    enable = false; # Enable on work laptop if needed
    package = pkgs.postgresql_15;
  };
}
