{ config, pkgs, ... }:

{
  # NetBox - IP Address Management (IPAM) and Data Center Infrastructure Management (DCIM)
  # Access at http://localhost:8001 after enabling

  # Uncomment to enable NetBox service
  # services.netbox = {
  #   enable = true;
  #   package = pkgs.netbox;
  #
  #   # Listen on localhost only (use nginx reverse proxy for external access)
  #   listenAddress = "127.0.0.1";
  #   port = 8001;
  #
  #   # Secret key for session encryption (generate with: openssl rand -base64 32)
  #   # Store this securely!
  #   secretKeyFile = "/etc/netbox-secret-key";
  #
  #   # Enable plugins as needed
  #   # plugins = p: with p; [
  #   #   netbox-topology-views
  #   #   netbox-dns
  #   # ];
  # };

  # PostgreSQL is required for NetBox
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "netbox" ];
  #   ensureUsers = [{
  #     name = "netbox";
  #     ensureDBOwnership = true;
  #   }];
  # };

  # Redis is required for NetBox caching
  # services.redis.servers."netbox" = {
  #   enable = true;
  #   port = 6379;
  # };

  # Optional: nginx reverse proxy for NetBox
  # services.nginx = {
  #   enable = true;
  #   virtualHosts."netbox.local" = {
  #     locations."/" = {
  #       proxyPass = "http://127.0.0.1:8001";
  #       proxyWebsockets = true;
  #     };
  #   };
  # };
}
