{ config, lib, pkgs, ... }:

let
  npmPrefix = "${config.home.homeDirectory}/.npm-global";
  codexVersion = "0.120.0";
  claudeCodeVersion = "latest";
  openCodeVersion = "latest";
  codexPackageJson = "${npmPrefix}/lib/node_modules/@openai/codex/package.json";
in
{
  imports = [
    ./fcitx5.nix
  ];

  home.username = "zn";
  home.homeDirectory = "/home/zn";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;
  programs.plasma = {
    enable = true;
    krunner = {
      position = "top";
      historyBehavior = "enableSuggestions";
    };
    configFile."kdeglobals"."Translations" = {
      Language = "zh_CN";
    };
    configFile."plasma-localerc"."Formats" = {
      LANG = "zh_CN.UTF-8";
    };
    configFile."plasma-localerc"."Translations" = {
      LANGUAGE = "zh_CN";
    };
    fonts = {
      general = {
        family = "0xProto Nerd Font";
        pointSize = 10;
      };
      fixedWidth = {
        family = "0xProto Nerd Font Mono";
        pointSize = 10;
        fixedPitch = true;
      };
      small = {
        family = "0xProto Nerd Font";
        pointSize = 8;
      };
      toolbar = {
        family = "0xProto Nerd Font";
        pointSize = 10;
      };
      menu = {
        family = "0xProto Nerd Font";
        pointSize = 10;
      };
      windowTitle = {
        family = "0xProto Nerd Font";
        pointSize = 10;
      };
    };
  };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh.enable = true;
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      [[ -f ~/config/zsh/local.zsh ]] && source ~/config/zsh/local.zsh
    '';
  };


  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # 26.05 起用 settings（matchBlocks/extraOptions 已弃用）；键名是 OpenSSH 原生指令名
    settings."github.com" = {
      HostName = "github.com";
      User = "git";
      ProxyCommand = "${pkgs.netcat}/bin/nc -X connect -x 127.0.0.1:7890 %h %p";
      ServerAliveInterval = 30;
    };
  };

  # tmux：包在 configuration.nix 的 systemPackages，配置在这里声明式管理
  # （生成 ~/.config/tmux/tmux.conf；剪贴板走 set-clipboard + wezterm OSC52，无需 xclip）
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    mouse = true;
    historyLimit = 50000;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 10;
    aggressiveResize = true;
    sensibleOnTop = true;
    extraConfig = ''
      # 真彩色：wezterm 支持 RGB，直接透传
      set -as terminal-features ",*:RGB"
      set -g set-clipboard on
      set -g focus-events on
      setw -g mode-keys vi

      # 状态栏：底部、左对齐、暗色（贴近 LazyVim 的配色）
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=default,fg=#abb2bf"
      set -g status-left-length 30
      set -g status-left " #[bold]#S "
      set -g status-right "#[fg=#98c379]#{?client_prefix,PREFIX ,}#[fg=#abb2bf]%m-%d %H:%M "
      set -g window-status-current-style "fg=#98c379,bold"
      set -g pane-border-style "fg=#3e4451"
      set -g pane-active-border-style "fg=#98c379"
      set -g message-style "bg=#3e4451,fg=#abb2bf"

      # nvim 里 C-h/j/k/l 留给编辑器本身，不映射成 tmux 窗格跳转
    '';
  };

  systemd.user.services.mihomo = {
    Unit = {
      Description = "Mihomo proxy (Clash Meta)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.mihomo}/bin/mihomo -d /home/zn/.config/clash";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.packages = [
    pkgs.blender
    pkgs.godot
    pkgs.wechat
    pkgs.wezterm
    pkgs.home-manager
    pkgs.zsh-powerlevel10k
    pkgs.rustup
    pkgs.tree-sitter  # nvim-treesitter 编译/安装 parser 需要（:TSInstall 依赖它）
    pkgs.nixd              # Nix LSP（nixd 2.7.0）
    pkgs.nixfmt  # nix 格式化（LazyVim nix extra -> conform.nvim；26.05 起 nixfmt-rfc-style 已合并入 nixfmt）
    pkgs.statix            # nix lint（LazyVim nix extra -> nvim-lint）
  ];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = npmPrefix;
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    QT_WAYLAND_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    https_proxy = "http://127.0.0.1:7890";
    http_proxy = "http://127.0.0.1:7890";
  };

  home.sessionPath = [
    "${npmPrefix}/bin"
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/LLVM-22.1.0-Linux-X64/bin"
  ];

  home.file.".npmrc".text = ''
    prefix=${npmPrefix}
  '';
  home.file.".local/share/fonts/0xProto" = {
    source = ./assets/fonts/0xProto;
    recursive = true;
  };

  home.activation.installNodeGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export HOME="${config.home.homeDirectory}"
    export NPM_CONFIG_PREFIX="${npmPrefix}"
    export PATH="${lib.makeBinPath [ pkgs.nodejs_24 pkgs.git ]}:$NPM_CONFIG_PREFIX/bin:$PATH"

    mkdir -p "$NPM_CONFIG_PREFIX"

    if [ ! -f "${codexPackageJson}" ] || ! grep -Fq '"version": "${codexVersion}"' "${codexPackageJson}"; then
      ${pkgs.nodejs_24}/bin/npm install -g --no-fund --no-update-notifier "@openai/codex@${codexVersion}"
    ${pkgs.nodejs_24}/bin/npm install -g --no-fund --no-update-notifier "@anthropic-ai/claude-code@${claudeCodeVersion}"
    ${pkgs.nodejs_24}/bin/npm install -g --no-fund --no-update-notifier "opencode-ai@${openCodeVersion}"
    fi
  '';

  # Neovim 配置（LazyVim）：nix 管理"来源 + 首次落地"，首次 clone 到 ~/.config/nvim 后
  # 保持为本地可写 git 仓库。更新配置：git -C ~/.config/nvim pull（或直接改文件后 commit）。
  # 目录已存在且 origin 就是该仓库时不做任何事；origin 不是它（例如上游 LazyVim/starter 副本）
  # 则先备份为 nvim.bak-<时间戳> 再 clone。
  home.activation.cloneNvimConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export HOME="${config.home.homeDirectory}"
    nvimConfigDir="$HOME/.config/nvim"
    nvimConfigSsh="git@github.com:worm120/nvimConfig.git"
    nvimConfigHttps="https://github.com/worm120/nvimConfig.git"

    if [ -d "$nvimConfigDir/.git" ] \
      && ${pkgs.git}/bin/git -C "$nvimConfigDir" remote get-url origin 2>/dev/null | grep -qF "worm120/nvimConfig"; then
      : # 已是你的仓库，保持现状
    else
      if [ -e "$nvimConfigDir" ]; then
        mv "$nvimConfigDir" "$nvimConfigDir.bak-$(date +%Y%m%d%H%M%S)"
      fi
      mkdir -p "$HOME/.config"
      # SSH 走 ~/.ssh/config 里声明的 mihomo ProxyCommand（programs.ssh，见本文件上方）；
      # 无可用 SSH key 时退回 https（仓库公开）克隆，再把 origin 改回 SSH 以便 push。
      if ${pkgs.git}/bin/git clone --branch main "$nvimConfigSsh" "$nvimConfigDir"; then
        :
      elif ${pkgs.git}/bin/git -c http.proxy=http://127.0.0.1:7890 clone --branch main "$nvimConfigHttps" "$nvimConfigDir"; then
        ${pkgs.git}/bin/git -C "$nvimConfigDir" remote set-url origin "$nvimConfigSsh"
      else
        echo "[cloneNvimConfig] 警告: nvim 配置 clone 失败，下次 nixos-rebuild switch 会重试" >&2
      fi
    fi
  '';

  home.activation.refreshUserFontCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.fontconfig}/bin/fc-cache -f "$HOME/.local/share/fonts/0xProto"
  '';
}
