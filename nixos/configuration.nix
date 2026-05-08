# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs
, lib
, config
, pkgs
, ...
}: {
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
      };
    };

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
  networking.nameservers = [ "127.0.0.1"];

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
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" ];
    packages = with pkgs; [ ];
  };

  home-manager.users.missileserv = import "/home/missileserv/.config/home-manager/home.nix";

  # Enable automatic login for the user.
  services.getty.autologinUser = "missileserv";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
  services.openssh.enable = true;

  # Automatic system reboot
  services.cron.systemCronJobs = [
    # Schedule a reboot every day at midnight
    "0 0 * * * root ${pkgs.systemd}/bin/systemctl reboot"
  ];

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
      server = [ "1.1.1.1" "1.0.0.1" ];

      address = "/missileserv.lan/192.168.0.194";

      # listen on localhost and static ip
      listen-address = "127.0.0.1,192.168.0.194";
    };
  };

  services.tailscale = {
    enable = true;
  };

  # reverse proxy for accessing programs
  services.caddy = {
    enable = true;

    extraConfig = ''
	    :8124 {
	      tls internal

	      reverse_proxy localhost:8123
	    }

	    home.missileserv.lan {
	      tls internal
	      reverse_proxy localhost:8123
	    }

	    missileserv.lan {
	        tls internal

	        handle /smokeping* {
	          reverse_proxy localhost:9101
	        }

	        handle_path /torrent* {
		  reverse_proxy localhost:8080
		}

		handle /radarr* {
		  reverse_proxy localhost:7878
		}

		handle /sonarr* {
		  reverse_proxy localhost:8989
		}

		handle /overseerr* {
		  reverse_proxy localhost:5055
		}

		handle /grafana* {
		  reverse_proxy localhost:3000
		}

		handle /auth* {
		  reverse_proxy localhost:9000
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
	adapter="ember";
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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 8384 ];
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
