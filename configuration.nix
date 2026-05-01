{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  networking.hostName = "nixos_nuc";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.blueman.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs.qt6Packages; [
      fcitx5-configtool
    ] ++ [
      pkgs.fcitx5-rime
      pkgs.fcitx5-material-color
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
  ];

  users.users.zn = {
    isNormalUser = true;
    description = "zn";
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "zning";
    shell = pkgs.zsh;
  };

  users.users.root.initialPassword = "zning";

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    bubblewrap
    curl
    inetutils
    net-tools
    firefox
    git
    google-chrome
    nodejs
    unzip
    vim
    wget
    zsh
  ];

  system.stateVersion = "25.11";
}
