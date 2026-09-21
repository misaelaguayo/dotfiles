{ pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  home.username = "missileserv";
  home.homeDirectory = "/home/missileserv";

  home.packages = with pkgs; [
    docker-compose
  ];

  # k3s's bundled kubectl ignores ~/.kube/config unless this is set
  home.sessionVariables.KUBECONFIG = "/home/missileserv/.kube/config";
}
