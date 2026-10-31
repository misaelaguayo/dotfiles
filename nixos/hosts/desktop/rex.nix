{ inputs, ... }:
{
  home-manager.sharedModules = [ inputs.rex.homeManagerModules.default ];

  users.users.misael.linger = true;

  home-manager.users.misael = {
    programs.rex.enable = true;

    services.rex = {
      enable = true;
      extraListen = [ ":7297" ];
      allowAnonymous = true;
    };
  };
}
