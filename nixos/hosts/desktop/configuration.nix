{ config, pkgs, lib, ... }:

let
  steamStart = pkgs.writeShellScript "sunshine-steam-start" ''
    pkill -x steam || true
    sleep 3
  '';
  steamStop = pkgs.writeShellScript "sunshine-steam-stop" ''
    pkill -x steam || true
  '';
in {
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.interfaces.eno1 = {
    wakeOnLan.enable = true;
  };

  time.timeZone = "America/Chicago";

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

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaPersistenced = true;
    # RTX 2070 SUPER / Turing
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "misael";
  };
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "hyprland";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
    XDG_SESSION_TYPE = "wayland";
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  systemd.user.services.sunshine.environment = {
    WAYLAND_DISPLAY = "wayland-1";
    DISPLAY = ":0";
    XDG_RUNTIME_DIR = "/run/user/1000";
    PIPEWIRE_RUNTIME_DIR = "/run/user/1000";
    PULSE_SERVER = "unix:/run/user/1000/pulse/native";
  };

  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    package = pkgs.sunshine.override { cudaSupport = true; };
    settings = {
      encoder = "nvenc";
      capture = "kms";
      min_log_level = 2;
    };
    applications = {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
        DISPLAY = ":0";
        WAYLAND_DISPLAY = "wayland-1";
        XDG_RUNTIME_DIR = "/run/user/1000";
        DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        PULSE_SERVER = "unix:/run/user/1000/pulse/native";
      };
      apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
        {
          name = "Steam Big Picture";
          prep-cmd = [
            {
              do = "sudo -u misael ${steamStart}";
              undo = "sudo -u misael ${steamStop}";
            }
          ];
          detached = [ "sudo -u misael env XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 DISPLAY=:0 PULSE_SERVER=unix:/run/user/1000/pulse/native DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus setsid steam -gamepadui -fullscreen" ];
          image-path = "steam.png";
        }
      ];
    };
  };

  security.polkit.enable = true;

  security.sudo.extraRules = [
    {
      users = [ "misael" ];
      runAs = "misael";
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.misael = {
    isNormalUser = true;
    description = "misael";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "uinput" "input" ];
    packages = with pkgs; [
      neovim
      jujutsu
      zellij
      claude-code
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.misael = import ../../../home-manager/desktop.nix;

  hardware.uinput.enable = true;

  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  programs.firefox.enable = true;
  programs.steam.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (import ../../../home-manager/overlay.nix) ];

  # Prevent suspend so SSH and Sunshine streams aren't dropped on idle
  services.logind.settings.Login = {
    IdleAction = "ignore";
    HandleSuspendKey = "ignore";
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  environment.systemPackages = with pkgs; [
    xorg.xrandr
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
