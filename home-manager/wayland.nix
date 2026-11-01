{
  config,
  pkgs,
  lib,
  ...
}:

let
  c = config.lib.stylix.colors;
in
{
  home.packages = with pkgs; [
    hyprpaper
    grim
    slurp
    wl-clipboard
    wlr-randr
    libnotify
    pavucontrol
    playerctl
    cliphist
  ];

  # Hyprland 0.57 dropped hyprland.conf; settings render as hl.<name>(...) calls
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    settings =
      let
        lua = lib.generators.mkLuaInline;
        mod = "SUPER";
        # bind "KEYS" "<lua dispatcher>" [ { flags } ]
        bind = keys: dsp: flags: {
          _args = [
            keys
            (lua dsp)
          ]
          ++ flags;
        };
        dirs = {
          left = "left";
          right = "right";
          up = "up";
          down = "down";
          h = "left";
          l = "right";
          k = "up";
          j = "down";
        };
        dirBinds = prefix: dsp: lib.mapAttrsToList (key: dir: bind "${prefix} + ${key}" (dsp dir) [ ]) dirs;
        workspaceBinds = lib.concatMap (
          i:
          let
            n = toString i;
          in
          [
            (bind "${mod} + ${n}" "hl.dsp.focus({ workspace = ${n} })" [ ])
            (bind "${mod} + SHIFT + ${n}" "hl.dsp.window.move({ workspace = ${n} })" [ ])
          ]
        ) (lib.range 1 9);
        exec = cmd: "hl.dsp.exec_cmd([[${cmd}]])";
        locked = {
          locked = true;
        };
        lockedRepeat = {
          locked = true;
          repeating = true;
        };
        repeat = {
          repeating = true;
        };
        floatRule = name: class: {
          inherit name;
          match.class = class;
          float = true;
        };
      in
      {
        monitor = [
          {
            output = "desc:LG Electronics LG ULTRAGEAR+ 206NTLE9G848";
            mode = "3840x2160@144";
            position = "auto";
            scale = 1;
          }
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
        ];

        env = [
          {
            _args = [
              "XCURSOR_SIZE"
              "24"
            ];
          }
          {
            _args = [
              "HYPRCURSOR_SIZE"
              "24"
            ];
          }
        ];

        on = {
          _args = [
            "hyprland.start"
            (lua ''
              function()
                hl.exec_cmd("hyprpaper")
                hl.exec_cmd("waybar")
                hl.exec_cmd("xhost +local:")
                hl.exec_cmd("wl-paste --watch cliphist store")
              end'')
          ];
        };

        config = {
          general = {
            gaps_in = 5;
            gaps_out = 15;
            border_size = 2;
            "col.active_border" = lib.mkForce {
              colors = [
                "rgba(${c.base0E}ff)"
                "rgba(${c.base0D}ff)"
              ];
              angle = 45;
            };
            "col.inactive_border" = lib.mkForce "rgba(${c.base01}aa)";
            resize_on_border = true;
            layout = "dwindle";
          };

          decoration = {
            rounding = 12;
            active_opacity = 1.0;
            inactive_opacity = 0.93;

            blur = {
              enabled = true;
              size = 8;
              passes = 3;
              new_optimizations = true;
            };

            shadow = {
              enabled = true;
              range = 8;
              render_power = 2;
              color = lib.mkForce "rgba(${c.base00}99)";
            };
          };

          animations.enabled = true;

          input = {
            kb_layout = "us";
            follow_mouse = 1;
            sensitivity = 0;
            accel_profile = "flat";
          };

          binds.workspace_back_and_forth = true;

          dwindle.preserve_split = true;

          misc = {
            force_default_wallpaper = 0;
            disable_hyprland_logo = true;
            vrr = 2;
          };
        };

        curve = [
          {
            _args = [
              "easeOut"
              {
                type = "bezier";
                points = [
                  [
                    0.16
                    1
                  ]
                  [
                    0.3
                    1
                  ]
                ];
              }
            ];
          }
          {
            _args = [
              "easeIn"
              {
                type = "bezier";
                points = [
                  [
                    0.7
                    0
                  ]
                  [
                    0.84
                    0
                  ]
                ];
              }
            ];
          }
          {
            _args = [
              "easeInOut"
              {
                type = "bezier";
                points = [
                  [
                    0.87
                    0
                  ]
                  [
                    0.13
                    1
                  ]
                ];
              }
            ];
          }
        ];

        animation = [
          {
            leaf = "windows";
            enabled = true;
            speed = 5;
            bezier = "easeOut";
            style = "slide";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 4;
            bezier = "easeIn";
            style = "slide";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 5;
            bezier = "easeInOut";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 5;
            bezier = "easeInOut";
            style = "slidevert";
          }
        ];

        bind = [
          (bind "${mod} + RETURN" (exec "ghostty") [ ])
          (bind "${mod} + Q" "hl.dsp.window.close()" [ ])
          (bind "${mod} + R" (exec "rofi -show drun") [ ])
          (bind "${mod} + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'' [ ])
          (bind "${mod} + V" ''hl.dsp.window.float({ action = "toggle" })'' [ ])
          (bind "${mod} + C" (exec "cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy")
            [ ]
          )
          (bind "${mod} + SHIFT + E" "hl.dsp.exit()" [ ])

          # Screenshots
          (bind "Print" (exec ''grim -g "$(slurp)" - | wl-copy'') [ ])
          (bind "${mod} + Print" (exec "grim - | wl-copy") [ ])

          # Resize, repeat while held
          (bind "${mod} + CTRL + h" "hl.dsp.window.resize({ x = -40, y = 0, relative = true })" [ repeat ])
          (bind "${mod} + CTRL + l" "hl.dsp.window.resize({ x = 40, y = 0, relative = true })" [ repeat ])
          (bind "${mod} + CTRL + k" "hl.dsp.window.resize({ x = 0, y = -40, relative = true })" [ repeat ])
          (bind "${mod} + CTRL + j" "hl.dsp.window.resize({ x = 0, y = 40, relative = true })" [ repeat ])

          # Media keys, also work while locked
          (bind "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+") [
            lockedRepeat
          ])
          (bind "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") [ lockedRepeat ])
          (bind "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") [ locked ])
          (bind "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") [ locked ])
          (bind "XF86AudioPlay" (exec "playerctl play-pause") [ locked ])
          (bind "XF86AudioNext" (exec "playerctl next") [ locked ])
          (bind "XF86AudioPrev" (exec "playerctl previous") [ locked ])

          # Super+LMB to move, Super+RMB to resize
          (bind "${mod} + mouse:272" "hl.dsp.window.drag()" [ { mouse = true; } ])
          (bind "${mod} + mouse:273" "hl.dsp.window.resize()" [ { mouse = true; } ])
        ]
        ++ dirBinds mod (dir: ''hl.dsp.focus({ direction = "${dir}" })'')
        ++ dirBinds "${mod} + SHIFT" (dir: ''hl.dsp.window.move({ direction = "${dir}" })'')
        ++ workspaceBinds;

        window_rule = [
          {
            name = "steam-float";
            match = {
              class = "^(steam)$";
              title = "negative:^(Steam)$";
            };
            float = true;
          }
          (floatRule "pavucontrol-float" "^(pavucontrol)$")
          (floatRule "nm-editor-float" "^(nm-connection-editor)$")
          {
            name = "suppress-maximize";
            match.class = ".*";
            suppress_event = "maximize";
          }
        ];
      };
  };

  # colors and font come from Stylix
  services.mako = {
    enable = true;
    settings = {
      border-radius = 8;
      border-size = 2;
      default-timeout = 5000;
      padding = "12";
      margin = "12";
    };
  };

  programs.rofi.enable = true;

  # colors and font come from Stylix
  programs.ghostty = {
    enable = true;
    settings = {
      command = "${config.programs.fish.package}/bin/fish";
      font-thicken = true;
      grapheme-width-method = "unicode";
      unfocused-split-opacity = 0.8;
      window-decoration = true;
      keybind = "ctrl+shift+j=write_scrollback_file:open";
      shell-integration-features = "sudo,ssh-terminfo,ssh-env";
    };
  };

  # the waybar CSS below is hand-written; feed it Stylix's colors instead of
  # letting Stylix replace it with its own stylesheet
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 2;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            default = "○";
            active = "●";
            urgent = "◉";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };

        "hyprland/window" = {
          max-length = 60;
          separate-outputs = true;
        };

        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%A %b %d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = " {usage}%";
          interval = 2;
        };

        memory = {
          format = " {}%";
          interval = 5;
        };

        network = {
          format-ethernet = "󰈀 {ipaddr}";
          format-wifi = " {signalStrength}%";
          format-disconnected = "󰖪";
          tooltip-format = "{ifname}: {ipaddr}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 muted";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
          scroll-step = 5;
        };

        tray = {
          spacing = 8;
          icon-size = 16;
        };
      };
    };

    style = ''
      @define-color base     #${c.base00};
      @define-color surface0 #${c.base01};
      @define-color surface1 #${c.base02};
      @define-color overlay0 #${c.base03};
      @define-color text     #${c.base05};
      @define-color subtext0 #${c.base04};
      @define-color blue     #${c.base0D};
      @define-color sapphire #${c.base0C};
      @define-color green    #${c.base0B};
      @define-color yellow   #${c.base0A};
      @define-color mauve    #${c.base0E};
      @define-color red      #${c.base08};

      * {
        font-family: "${config.stylix.fonts.monospace.name}", monospace;
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
