# Hermes Agent backed by a local llama.cpp server on the RTX 5070 Ti.
#
# Model: Qwen3.6-35B-A3B (MoE, 3B active, multi-token prediction). It is the
# model in Hermes' own local catalog that fits a 16 GB card + 32 GB RAM: the
# attention/shared weights and KV cache stay on the GPU, and --fit spills only
# as many expert tensors to system RAM as needed, so decode stays fast.
# The 27B dense model scores higher but its 4-bit build (16.5 GB) can't fit in
# VRAM, and spilling dense layers makes it several times slower.

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
  # missileserv's Caddy terminates TLS for this name  and proxies to the backend here
  publicHost = "hermes.missileserv.lan";
  missileservIP = "192.168.0.194";
in
{
  # Prebuilt CUDA packages (llama.cpp with CUDA would otherwise compile locally)
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
      # Downloaded into /var/cache/llama-cpp on first start (~23 GB)
      hf-repo = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_M";
      alias = modelAlias;
      # Skip the vision projector: saves ~1 GB of VRAM for experts/context
      no-mmproj = true;
      ctx-size = contextSize;
      # One user, so give the whole context to a single slot
      parallel = 1;
      jinja = true;
      flash-attn = "on";
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
      # Multi-token prediction using the model's built-in MTP head
      spec-type = "draft-mtp";
      spec-draft-n-max = 2;
      # Qwen's recommended sampling (matches Hermes' catalog entry)
      temp = 1.0;
      top-p = 0.95;
      top-k = 20;
      min-p = 0.0;
    };
  };

  systemd.services.llama-cpp.wantedBy = lib.mkForce [ ];

  home-manager.sharedModules = [ inputs.hermes-agent.homeManagerModules.default ];

  # Keep the hermes-backend user service running without a login session
  users.users.misael.linger = true;

  home-manager.users.misael = { config, ... }: {
    programs.hermes-agent.enable = true;

    services.hermes-agent = {
      enable = true;

      # `hermes serve` for Hermes apps on other devices. Clients use
      # https://${publicHost} (iOS refuses plain http), served by missileserv's
      # Caddy, which proxies to desktop.lan:9119. The LAN bind keeps the login
      # gate on; public_url makes Hermes accept the proxied Host header.
      backend = {
        mode = "serve";
        host = "desktop.lan";
        # The DNS server may not answer yet when the user unit starts at boot
        waitFor = "hostname";
        port = 9119;
      };
      # HERMES_DASHBOARD_BASIC_AUTH_{USERNAME,PASSWORD,SECRET}; kept out of the
      # Nix store and git. Skipped at activation if the file doesn't exist.
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
          # Let missileserv's Caddy pass X-Forwarded-Proto/For
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
