{ config, pkgs, ... }:

{
  imports = [ ];

  # Bootloader etc.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  time.timeZone = "America/Phoenix"; # adjust to your TZ

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true; # Simple DM that works with Wayland
  services.xserver.desktopManager.plasma5.enable = false;
  services.xserver.windowManager.hyprland.enable = true;

  # Wayland / Hyprland needs some extras
  programs.hyprland.enable = true;

  users.users.dane = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  services.networkmanager.enable = true;

  # Useful packages system-wide
  environment.systemPackages = with pkgs; [
    git vim wget curl
    waybar rofi foot # common Hyprland companions
  ];

  # Allow unfree packages if needed
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05"; # change to your installed version
}