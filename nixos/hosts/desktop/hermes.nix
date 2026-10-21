{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  llamaPort = 8080;
  modelAlias = "qwen3.6-35b-a3b";
  contextSize = 131072;
  publicHost = "hermes.missileserv.lan";
  missileservIP = "192.168.0.194";
in
{
  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  };

  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override { cudaSupport = true; };
    settings = {
      host = "127.0.0.1";
      port = llamaPort;
      hf-repo = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_M";
      alias = modelAlias;
      no-mmproj = true;
      ctx-size = contextSize;
      parallel = 1;
      jinja = true;
      flash-attn = "on";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      spec-type = "draft-mtp";
      spec-draft-n-max = 2;
      temp = 1.0;
      top-p = 0.95;
      top-k = 20;
      min-p = 0.0;
    };
  };

  systemd.services.llama-cpp.wantedBy = lib.mkForce [ ];

  home-manager.sharedModules = [ inputs.hermes-agent.homeManagerModules.default ];

  users.users.misael.linger = true;

  home-manager.users.misael = { config, ... }: {
    programs.hermes-agent.enable = true;

    services.hermes-agent = {
      enable = true;

      backend = {
        mode = "serve";
        host = "desktop.lan";
        waitFor = "hostname";
        port = 9119;
      };
      environmentFiles = [ "${config.home.homeDirectory}/.config/hermes/backend.env" ];

      settings = {
        model = {
          provider = "custom";
          base_url = "http://127.0.0.1:${toString llamaPort}/v1";
          default = modelAlias;
          context_length = contextSize;
        };
        dashboard = {
          public_url = "https://${publicHost}";
          trusted_proxies = [ missileservIP ];
        };
      };
      mcpServers = {
        nixos = {
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        };
        angular-cli = {
          command = "npx";
          args = [
            "-y"
            "@angular/cli"
            "mcp"
          ];
        };
      };
    };
  };
}
