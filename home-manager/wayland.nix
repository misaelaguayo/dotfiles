{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    ghostty
    hyprpaper
    rofi
    grim
    slurp
    wl-clipboard
    wlr-randr
    libnotify
    pavucontrol
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      "$mod" = "ALT";
      "$terminal" = "ghostty";
      "$menu" = "rofi -show drun";

      exec-once = [
        "hyprpaper"
        "waybar"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      general = {
        gaps_in  = 5;
        gaps_out = 15;
        border_size = 2;
        "col.active_border"   = "rgba(cba6f7ff) rgba(89b4faff) 45deg";
        "col.inactive_border" = "rgba(313244aa)";
        resize_on_border = true;
        layout = "dwindle";
      };

      decoration = {
        rounding         = 12;
        active_opacity   = 1.0;
        inactive_opacity = 0.93;

        blur = {
          enabled           = true;
          size              = 8;
          passes            = 3;
          new_optimizations = true;
        };

        shadow = {
          enabled      = true;
          range        = 8;
          render_power = 2;
          color        = "rgba(1e1e2e99)";
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "easeOut,   0.16, 1,    0.3,  1"
          "easeIn,    0.7,  0,    0.84, 0"
          "easeInOut, 0.87, 0,    0.13, 1"
        ];

        animation = [
          "windows,    1, 5, easeOut,   slide"
          "windowsOut, 1, 4, easeIn,    slide"
          "border,     1, 10, default"
          "fade,       1, 5, easeInOut"
          "workspaces, 1, 5, easeInOut, slidevert"
        ];
      };

      input = {
        kb_layout     = "us";
        follow_mouse  = 1;
        sensitivity   = 0;
        accel_profile = "flat";
      };

      dwindle = {
        pseudotile     = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
      };

      bind = [
        "$mod,       return, exec,          $terminal"
        "$mod,       Q,      killactive"
        "$mod,       R,      exec,          $menu"
        "$mod,       F,      fullscreen"
        "$mod,       V,      togglefloating"
        "$mod SHIFT, E,      exit"

        # Focus
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"

        # Move windows
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Screenshots
        ", Print,     exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, Print, exec, grim - | wl-copy"
      ];

      # Super+LMB to move, Super+RMB to resize
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "float, class:^(steam)$, title:^((?!.*Steam).*)"
        "float, class:^(pavucontrol)$"
        "float, class:^(nm-connection-editor)$"
        "suppressevent maximize, class:.*"
      ];
    };
  };

  services.mako = {
    enable = true;
    settings = {
      background-color = "#1e1e2e";
      text-color       = "#cdd6f4";
      border-color     = "#cba6f7";
      border-radius    = 8;
      border-size      = 2;
      default-timeout  = 5000;
      font             = "Hack Nerd Font 12";
      padding          = "12";
      margin           = "12";
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer    = "top";
        position = "top";
        height   = 36;
        spacing  = 2;

        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [ "pulseaudio" "network" "cpu" "memory" "tray" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            default = "○";
            active  = "●";
            urgent  = "◉";
          };
          on-scroll-up   = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };

        "hyprland/window" = {
          max-length       = 60;
          separate-outputs = true;
        };

        clock = {
          format         = " {:%H:%M}";
          format-alt     = " {:%A %b %d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format   = " {usage}%";
          interval = 2;
        };

        memory = {
          format   = " {}%";
          interval = 5;
        };

        network = {
          format-ethernet     = "󰈀 {ipaddr}";
          format-wifi         = " {signalStrength}%";
          format-disconnected = "󰖪";
          tooltip-format      = "{ifname}: {ipaddr}";
        };

        pulseaudio = {
          format       = "{icon} {volume}%";
          format-muted = "󰖁 muted";
          format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
          on-click     = "pavucontrol";
          scroll-step  = 5;
        };

        tray = {
          spacing   = 8;
          icon-size = 16;
        };
      };
    };

    style = ''
      @define-color base     #1e1e2e;
      @define-color surface0 #313244;
      @define-color surface1 #45475a;
      @define-color overlay0 #6c7086;
      @define-color text     #cdd6f4;
      @define-color subtext0 #a6adc8;
      @define-color blue     #89b4fa;
      @define-color sapphire #74c7ec;
      @define-color green    #a6e3a1;
      @define-color yellow   #f9e2af;
      @define-color mauve    #cba6f7;
      @define-color red      #f38ba8;

      * {
        font-family: "Hack Nerd Font", monospace;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: @base;
        color: @text;
        border-bottom: 2px solid @surface0;
      }

      #workspaces { margin: 4px 4px; }

      #workspaces button {
        padding: 2px 10px;
        color: @overlay0;
        background: transparent;
        border-radius: 6px;
        transition: all 0.15s ease;
      }

      #workspaces button.active {
        color: @blue;
        background: @surface0;
        font-weight: bold;
      }

      #workspaces button.urgent {
        color: @red;
        background: @surface0;
      }

      #workspaces button:hover {
        color: @text;
        background: @surface1;
      }

      #window {
        color: @subtext0;
        padding: 0 8px;
        font-style: italic;
      }

      #clock {
        color: @blue;
        font-weight: bold;
        padding: 0 16px;
      }

      #cpu        { color: @green;    padding: 0 10px; }
      #memory     { color: @yellow;   padding: 0 10px; }
      #network    { color: @sapphire; padding: 0 10px; }
      #pulseaudio { color: @mauve;    padding: 0 10px; }
      #tray       { padding: 0 8px; }

      #tray > .needs-attention {
        background-color: @red;
        border-radius: 4px;
      }
    '';
  };
}
