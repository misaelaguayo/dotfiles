{ inputs, ... }:
{
  home-manager.sharedModules = [ inputs.rex.homeManagerModules.default ];

  # Keep the rex user service running without a login session
  users.users.missileserv.linger = true;

  home-manager.users.missileserv = {
    programs.rex.enable = true;

    services.rex = {
      enable = true;
      # Plain HTTP can't identify callers; the firewall only opens 7297 on
      # the LAN, which remote devices reach through the router's WireGuard
      extraListen = [ ":7297" ];
      allowAnonymous = true;
    };
  };
}
