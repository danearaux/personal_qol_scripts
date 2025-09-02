{ config, pkgs, ... }:

{
  home.username = "dane";
  home.homeDirectory = "/home/dane";

  programs.zsh.enable = true;
  home.packages = with pkgs; [
    firefox
    kitty
    alacritty
    hyprpaper
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";
      exec-once = [
        "waybar"
        "foot"
        "hyprpaper"
      ];
    };
  };

  programs.waybar.enable = true;
  programs.foot.enable = true;

  # Make home-manager manage itself
  programs.home-manager.enable = true;
}