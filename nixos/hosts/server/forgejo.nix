{ ... }:
{
  services.forgejo = {
    enable = true;
    settings = {
      server = {
        DOMAIN = "git.missileserv.lan";
        ROOT_URL = "https://git.missileserv.lan/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;
        SSH_DOMAIN = "missileserv.lan";
        SSH_PORT = 22;
      };

      service.DISABLE_REGISTRATION = true;

      repository = {
        ENABLE_PUSH_CREATE_USER = true;
        DEFAULT_PUSH_CREATE_PRIVATE = true;
      };
    };
  };

  services.caddy.virtualHosts."git.missileserv.lan".extraConfig = ''
    tls internal
    reverse_proxy 127.0.0.1:3000
  '';
}
