{ config, pkgs, lib, ... }:

{
  # NetBox - IP Address Management (IPAM) and Data Center Infrastructure Management (DCIM)
  # Access at http://localhost:8080 after enabling

  # NetBox service
  services.netbox = {
    enable = true;
    secretKeyFile = "/var/lib/netbox/secret-key";
  };

  # Nginx reverse proxy for NetBox (required for static files)
  services.nginx = {
    enable = true;
    user = "netbox";
    recommendedProxySettings = true;
    clientMaxBodySize = "25m";

    virtualHosts."localhost" = {
      listen = [{
        addr = "127.0.0.1";
        port = 8080;
      }];

      locations = {
        "/" = {
          proxyPass = "http://[::1]:8001";
        };
        "/static/" = {
          alias = "${config.services.netbox.dataDir}/static/";
        };
      };
    };
  };

  # PostgreSQL database for NetBox
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "netbox" ];
    ensureUsers = [{
      name = "netbox";
      ensureDBOwnership = true;
    }];
  };

  # Redis cache for NetBox
  services.redis.servers."netbox" = {
    enable = true;
    port = 6379;
  };

  # Create secret key file if it doesn't exist (must be exactly 50 characters)
  system.activationScripts.netbox-secret = lib.mkIf config.services.netbox.enable ''
    if [ ! -f /var/lib/netbox/secret-key ]; then
      mkdir -p /var/lib/netbox
      ${pkgs.openssl}/bin/openssl rand -hex 25 > /var/lib/netbox/secret-key
      chown netbox:netbox /var/lib/netbox/secret-key
      chmod 600 /var/lib/netbox/secret-key
    fi
  '';
}
