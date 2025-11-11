{ config, pkgs, lib, ... }:

let
  # Custom Cursor with enhanced FHS environment for extension marketplace
  cursor-fhs-custom = pkgs.cursor.fhs.override {
    # Add additional libraries needed for extensions and marketplace
    extraPkgs = pkgs: with pkgs; [
      # SSL certificates for marketplace
      cacert
      # Additional libraries for extensions
      libsecret
      krb5
    ];
    # Set environment variables for SSL
    extraBwrapArgs = [
      "--setenv SSL_CERT_FILE ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "--setenv GIT_SSL_CAINFO ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
in
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
    cursor-fhs-custom  # Custom Cursor with marketplace support

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
