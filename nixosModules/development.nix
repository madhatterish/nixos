{ config, pkgs, lib, ... }:

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

    # Text editors and IDEs
    (vscode.fhs)  # FHS-compatible VSCode for extensions with native binaries
    lens
    code-cursor  # Using non-FHS version for better marketplace compatibility

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
  # Note: PostgreSQL service is configured in netbox.nix or host-specific configs as needed
  # The postgresql package above provides client tools (psql, etc.)
}
