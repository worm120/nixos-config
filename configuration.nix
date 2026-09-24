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
    fcitx5 = {
      addons = with pkgs.qt6Packages; [
        fcitx5-configtool
      ] ++ [
        pkgs.fcitx5-rime
        pkgs.fcitx5-material-color
      ];
      # KDE Plasma 6 Wayland: 让 KWin 管理 fcitx5 输入法
      # 此时 GTK_IM_MODULE/QT_IM_MODULE 不由 NixOS 全局设置（由 KWin 通过 text-input 协议转发）
      # WezTerm 使用 zwp_text_input_v3 协议，需要 KWin 暴露 input_method 协议
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

  programs.firefox = {
    enable = true;
    # 启动时自动恢复上次的标签页
    policies = {
      Preferences = {
        "browser.startup.page" = {
          Value = 3;
          Status = "default";
        };
        "browser.sessionstore.restore_on_demand" = {
          Value = false;
          Status = "default";
        };
      };
    };
  };

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # 将系统 bin 目录加入 PATH，确保 coreutils 等标准工具可用
  environment.sessionVariables = {
    PATH = "/run/current-system/sw/bin";
  };

  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    bubblewrap
    coreutils
    curl
    gcc
    gnumake
    inetutils
    net-tools
    git
    google-chrome
    neovim
    nodejs
    atop
    unzip
    vim
    wget
    zsh
    typst
  ];

  system.stateVersion = "25.11";
}
