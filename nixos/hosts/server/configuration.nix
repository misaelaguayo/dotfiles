# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "missileserv"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # query dnsmasq for internet
  networking.nameservers = [ "127.0.0.1" ];

  # disable resolved to prevent conflicts on port 53 for dnsmasq
  services.resolved.enable = false;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  networking.networkmanager.connectionConfig = {
    "no-auto-default" = "wlp0s20f3";
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.missileserv = {
    isNormalUser = true;
    description = "missileserv";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "dialout"
      "video"
      "input"
    ];
    packages = with pkgs; [ claude-code ];
  };

  home-manager.users.missileserv = import ../../../home-manager/server.nix;

  # Enable automatic login for the user.
  services.getty.autologinUser = "missileserv";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    neovim
    iptables
    git
    cmake
    bluez
    wl-clipboard
    mesa
    libGL
    xauth
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # services.syncthing = {
  # openDefaultPorts = true;
  # guiAddress = "0.0.0.0:8384";
  # };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };

  programs.ssh.setXAuthLocation = true;

  # mosh for resilient connections over patchy wifi (UDP, survives roaming/dropouts)
  programs.mosh.enable = true;

  # Automatic system reboot
  services.cron.systemCronJobs = [
    # Schedule a reboot every day at midnight
    "0 0 * * * root ${pkgs.systemd}/bin/systemctl reboot"
  ];

  # Hardware watchdog: if the system fully hangs (e.g. a resource-exhaustion
  # pileup that the midnight cron reboot can't run through), pet /dev/watchdog
  # every ~10s and let it hard-reset the box if nothing pets it for 30s.
  systemd.settings.Manager.RuntimeWatchdogSec = "30s";

  # mDNS setup to allow *.local discovery
  services.avahi = {
    enable = false;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.dnsmasq = {
    enable = true;

    settings = {
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      address = [
        "/missileserv.lan/192.168.0.194"
        "/desktop.lan/192.168.0.190"
      ];

      # listen on localhost and static ip
      listen-address = "127.0.0.1,192.168.0.194";

      # arr stack can starve dns hits
      cache-size = 10000;
      dns-forward-max = 1000;
    };
  };

  services.tailscale = {
    enable = true;
  };

  # Cloudflare API token for Caddy's ACME DNS-01 challenge on misael.sh.
  age.secrets.cloudflare-caddy = {
    file = ../../../secrets/cloudflare-caddy.age;
    owner = "caddy";
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.cloudflare-caddy.path;

  # reverse proxy for accessing programs
  services.caddy = {
    enable = true;
    email = "aguayomisael@gmail.com";

    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-5a5cpFl90pEWt0lUC4ZJQ7g+1//ZvsRhee64Dt9vh5o=";
    };

    extraConfig = ''
      	    home.missileserv.lan {
      	      tls internal
      	      reverse_proxy localhost:8123
      	    }

      	    hermes.missileserv.lan {
      	      tls internal
      	      reverse_proxy desktop.lan:9119
      	    }

      	    # Publicly trusted (Let's Encrypt), so OIDC clients need no custom CA.
      	    # Host resolver is dnsmasq; check TXT propagation against 1.1.1.1.
      	    auth.misael.sh {
      	      tls {
      	        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      	        resolvers 1.1.1.1
      	      }
      	      reverse_proxy 127.0.0.1:30900
      	    }

      	    missileserv missileserv.lan {
      	        tls internal

      	        handle /outpost.goauthentik.io/* {
      	          reverse_proxy 127.0.0.1:30900
      	        }

      	        handle /smokeping* {
      	          forward_auth 127.0.0.1:30900 {
      	            uri /outpost.goauthentik.io/auth/caddy
      	            copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      	          }
      	          reverse_proxy 127.0.0.1:30101
      	        }

      	        handle_path /torrent* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30808
      		    }

      		    handle /radarr* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30878
      		    }

      		    handle /sonarr* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30989
      		    }

      		    handle /chaptarr* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30789
      		    }

      		    handle /prowlarr* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30696
      		    }

      		    handle /kapowarr* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30656
      		    }

      		    # Kavita has its own OIDC login against Authentik, so it
      		    # skips the forward_auth gate (same as home/grafana).
      		    handle /kavita* {
      		      reverse_proxy 127.0.0.1:30500
      		    }

      		    handle_path /prometheus* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30909
      		    }

      		    handle /grafana* {
      		      reverse_proxy 127.0.0.1:30300
      		    }

      		    # Argo CD (k3s). k3s NodePorts only listen on 127.0.0.1, not
      		    # ::1, so k8s upstreams use the IPv4 address, not localhost.
      		    handle /argocd* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30080
      		    }

      		    # Reading tracker (~/Projects/learning). The page uses relative
      		    # API paths, so it needs the trailing slash.
      		    redir /learning /learning/
      		    handle_path /learning/* {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30020
      		    }

      		    # Readeck (k3s). No forward_auth: Readeck signs in via Authentik
      		    # OIDC itself, and its API (browser extension, apps) uses tokens
      		    # that forward_auth would block. Served under its /readeck/ prefix,
      		    # so handle (not handle_path).
      		    redir /readeck /readeck/
      		    handle /readeck/* {
      		      reverse_proxy 127.0.0.1:30800
      		    }

      		    # catch-all: dashboard linking out to everything above. Must stay
      		    # last so it doesn't shadow the more specific handles.
      		    handle {
      		      forward_auth 127.0.0.1:30900 {
      		        uri /outpost.goauthentik.io/auth/caddy
      		        copy_headers X-Authentik-Username X-Authentik-Groups X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
      		      }
      		      reverse_proxy 127.0.0.1:30010
      		    }
      	    }
    '';
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        port = 1883;
        users = {
          zigbee = {
            password = "zigbee";
            acl = [ "readwrite #" ];
          };
        };
      }
    ];
  };

  services.zigbee2mqtt = {
    enable = true;

    settings = {
      serial = {
        port = "/dev/serial/by-id/usb-SONOFF_SONOFF_Dongle_Plus_MG24_92e8b33651a3ef118dc94cbd61ce3355-if00-port0";
        adapter = "ember";
      };

      mqtt = {
        server = "mqtt://localhost:1883";
        user = "zigbee";
        password = "zigbee";
      };

      frontend = {
        enabled = true;
        port = 8099;
      };

      homeassistant = {
        enabled = true;
      };

      permit_join = false;
    };
  };

  # Start docker daemon
  virtualisation.docker.enable = true;

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = "--disable=traefik --kube-proxy-arg=nodeport-addresses=127.0.0.1/32";
  };

  # Wait for nas to be mounted before starting containers which depend on its data
  systemd.services.docker = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
  };

  # Wait for nas to be mounted before starting k3s
  systemd.services.k3s = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    8384
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  networking.firewall.extraCommands = ''
    iptables -I DOCKER-ISOLATION-STAGE-2 1 -p tcp --dport 22 -j ACCEPT
  '';

  fileSystems."/mnt/media" = {
    device = "192.168.0.43:/volume2/Media";
    fsType = "nfs";
    options = [
      "bg"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
