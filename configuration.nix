# 三台机器共用系统配置。
# 每台机器的硬件/文件系统与主机专属设置放在 hosts/<主机名>.nix，由 flake.nix 组合；
# 本文件里不要出现只对某台机器成立的设置。
{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # 国内镜像加速：USTC 主镜像 → TUNA 备用 → 官方兜底（narinfo 签名仍是 cache.nixos.org-1）
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 10;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    networkmanager.enable = true;
    # mihomo (Clash Meta) 监听 7890(mixed) / 7891(socks)；
    # allow-lan 打开后需要放行这两个端口，局域网其他设备才能使用代理
    firewall = {
      allowedTCPPorts = [
        7890
        7891
      ];
      allowedUDPPorts = [
        7890
        7891
      ];
    };
  };

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_CTYPE = "zh_CN.UTF-8";
      LC_MESSAGES = "zh_CN.UTF-8";
    };

    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons =
          with pkgs.qt6Packages;
          [
            fcitx5-configtool
          ]
          ++ [
            pkgs.fcitx5-rime
            pkgs.fcitx5-material-color
          ];
        # KDE Plasma 6 Wayland：走 im-module 前端（fcitx5 自身的 wayland 前端）。
        # fcitx5 由 home-manager 的 fcitx5.nix 内的 activation（systemd user service）拉起。
        waylandFrontend = true;
      };
    };
  };

  environment = {
    sessionVariables = {
      LANG = "zh_CN.UTF-8";
    };
    # fcitx5 on Wayland: don't set GTK/QT im-module globally, avoid fcitx5 warning
    # XWayland apps can set them individually (see https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland)
    variables = {
      GTK_IM_MODULE = lib.mkForce "";
      QT_IM_MODULE = lib.mkForce "";
      SDL_IM_MODULE = lib.mkForce "";
    };

    systemPackages = with pkgs; [
      bluez
      bluez-tools
      btop
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
      coreutils
      curl
      fastfetch
      flameshot
      gcc
      git
      gnumake
      google-chrome
      inetutils
      net-tools
      pkgs-unstable.neovim
      nodejs_24
      python3
      python3Packages.pip
      unzip
      tmux
      typst
      vim
      wget
      zsh
    ];
  };

  services = {
    xserver.enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    blueman.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
  ];

  users.users = {
    zn = {
      isNormalUser = true;
      description = "zn";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      initialPassword = "zning";
      shell = pkgs.zsh;
    };
    root.initialPassword = "zning";
  };

  programs = {
    zsh.enable = true;

    # atop 模块：自带 atopacctd（进程统计）+ atop.service/atop-rotate.timer（每日轮转历史日志）
    atop.enable = true;
    nix-ld.enable = true;

    firefox = {
      enable = true;
      # 用企业策略下发偏好，避免用户 profile 里再被改回去：
      # 启动时恢复上次的标签页，并关掉“按需恢复”让标签页立即加载
      policies.Preferences = {
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

  system.stateVersion = "25.11";
}
