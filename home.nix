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

  home.packages = [
    pkgs.blender
    pkgs.godot
    pkgs.wechat
    pkgs.wezterm
    pkgs.home-manager
    pkgs.zsh-powerlevel10k
    pkgs.rustup
  ];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = npmPrefix;
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    QT_WAYLAND_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
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
    export PATH="${lib.makeBinPath [ pkgs.nodejs pkgs.git ]}:$NPM_CONFIG_PREFIX/bin:$PATH"

    mkdir -p "$NPM_CONFIG_PREFIX"

    if [ ! -f "${codexPackageJson}" ] || ! grep -Fq '"version": "${codexVersion}"' "${codexPackageJson}"; then
      ${pkgs.nodejs}/bin/npm install -g --no-fund --no-update-notifier "@openai/codex@${codexVersion}"
    ${pkgs.nodejs}/bin/npm install -g --no-fund --no-update-notifier "@anthropic-ai/claude-code@${claudeCodeVersion}"
    ${pkgs.nodejs}/bin/npm install -g --no-fund --no-update-notifier "opencode-ai@${openCodeVersion}"
    fi
  '';

  home.activation.refreshUserFontCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.fontconfig}/bin/fc-cache -f "$HOME/.local/share/fonts/0xProto"
  '';
}
