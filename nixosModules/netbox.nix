{ config, pkgs, lib, ... }:

{
  # NetBox - IP Address Management (IPAM) and Data Center Infrastructure Management (DCIM)
  # Access at http://localhost:8001 after enabling

  # NetBox service
  services.netbox = {
    enable = true;
    package = pkgs.netbox;

    # Listen on localhost only (access via http://localhost:8001)
    listenAddress = "127.0.0.1";
    port = 8001;

    # Secret key - automatically generated and stored
    secretKeyFile = "/var/lib/netbox/secret-key";
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

  # Create secret key file if it doesn't exist
  system.activationScripts.netbox-secret = lib.mkIf config.services.netbox.enable ''
    if [ ! -f /var/lib/netbox/secret-key ]; then
      mkdir -p /var/lib/netbox
      ${pkgs.openssl}/bin/openssl rand -base64 32 > /var/lib/netbox/secret-key
      chown netbox:netbox /var/lib/netbox/secret-key
      chmod 600 /var/lib/netbox/secret-key
    fi
  '';
}
