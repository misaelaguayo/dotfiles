{ pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  home.username = "missileserv";
  home.homeDirectory = "/home/missileserv";

  home.packages = with pkgs; [
    docker-compose
    kubeseal
  ];

  home.sessionVariables.KUBECONFIG = "/home/missileserv/.kube/config";
}
