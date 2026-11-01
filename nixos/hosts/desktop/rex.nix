{ inputs, ... }:
{
  home-manager.sharedModules = [ inputs.rex.homeManagerModules.default ];

  users.users.misael.linger = true;

  home-manager.users.misael = {
    programs.rex.enable = true;
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };

    services.rex = {
      enable = true;
      extraListen = [ ":7297" ];
      allowAnonymous = true;
    };
  };
}
