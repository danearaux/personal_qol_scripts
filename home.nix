config, pkgs, ... }:

{
  home.username = "dane";
  home.homeDirectory = "/home/dane";

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    firefox
    alacritty
    hyprpaper
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      input = {
        kb_layout = "us";
        follow_mouse = 1;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "0xff82aaff";
        "col.inactive_border" = "0xff3b4252";
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };
      };

      animations = {
        enabled = true;
      };

      exec-once = [
        "waybar"
        "hyprpaper"
      ];

      bind = [
        "SUPER, D, exec, rofi -show drun"
        "SUPER, Q, killactive,"
        "SUPER, T, exec, alacritty"
        "SUPER, B, exec, firefox"
        "SUPER, Y, exec, yazi"
        "SUPER, W, togglefloating,"
        "SUPER, F, fullscreen,"
        "SUPER, Space, exec, rofi -show run"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 28;
        modules-left = [ "clock" ];
        modules-center = [ "workspaces" ];
        modules-right = [ "battery" "pulseaudio" "network" ];
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 12px;
        color: #ffffff;
      }
      window#waybar {
        background: #1e1e2e;
      }
    '';
  };

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = /usr/share/backgrounds/nixos/nix-wallpaper.png
    wallpaper = ,/usr/share/backgrounds/nixos/nix-wallpaper.png
  '';

  programs.alacritty = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
      };
    };
  };

  programs.home-manager.enable = true;

}