{ lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 10;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  networking.hostName = "nixos_zn";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "zh_CN.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_CTYPE = "zh_CN.UTF-8";
    LC_MESSAGES = "zh_CN.UTF-8";
  };
  environment.sessionVariables = {
    LANG = "zh_CN.UTF-8";
  };
  # fcitx5 on Wayland: don't set GTK/QT im-module globally, avoid fcitx5 warning
  # XWayland apps can set them individually (see https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland)
  environment.variables = {
    GTK_IM_MODULE = lib.mkForce "";
    QT_IM_MODULE = lib.mkForce "";
    SDL_IM_MODULE = lib.mkForce "";
  };

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
    fcitx5 = {
      addons = with pkgs.qt6Packages; [
        fcitx5-configtool
      ] ++ [
        pkgs.fcitx5-rime
        pkgs.fcitx5-material-color
      ];
      # KDE Plasma 6 Wayland: 传统 im-module 方式（不走 KWin InputMethod 机制，更可靠）
      waylandFrontend = true;
    };
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

  programs.steam = {
    enable = true;
    package = pkgs-unstable.steam;
  };

  programs.firefox = {
    enable = true;
    preferences = {
      "browser.startup.page" = 3;
    };
  };

  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    vscode
    llvm
    xmake
    mpv
    mihomo
    clang
    clang-tools
    lld
    lldb
    bubblewrap
    curl
    fastfetch
    flameshot
    gcc
    git
    gnumake
    google-chrome
    inetutils
    net-tools
    nodejs
    python3
    python3Packages.pip
    unzip
    typst
    vim
    wget
    zsh
  ];

  system.stateVersion = "25.11";
}
