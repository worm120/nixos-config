# fcitx5 用户侧配置：nixos_zn / nixos_mbp 用。
# fcitx5 由 NixOS 的 fcitx5 systemd user service 自动拉起，不使用 KWin 的 InputMethod 机制。
# nixos_nuc 用 fcitx5-nuc.nix（KWin InputMethod 方案），按主机 import 见 home.nix。
{ lib, pkgs, ... }:

{
  # fcitx5 Classic UI 主题外观
  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    # 垂直候选列表
    Vertical Candidate List=False
    # 使用鼠标滚轮翻页
    WheelForPaging=True
    # 字体
    Font="Noto Sans CJK SC 12"
    # 菜单字体
    MenuFont="Sans 10"
    # 托盘字体
    TrayFont="Sans Bold 10"
    # 托盘标签轮廓颜色
    TrayOutlineColor=#000000
    # 托盘标签文本颜色
    TrayTextColor=#ffffff
    # 优先使用文字图标
    PreferTextIcon=False
    # 在图标中显示布局名称
    ShowLayoutNameInIcon=True
    # 使用输入法的语言来显示文字
    UseInputMethodLanguageToDisplayText=True
    # 主题
    Theme=Material-Color-brown
    # 深色主题
    DarkTheme=Material-Color-sakuraPink
    # 跟随系统浅色/深色设置
    UseDarkTheme=False
    # 当被主题和桌面支持时使用系统的重点色
    UseAccentColor=True
    # 在 X11 上针对不同屏幕使用单独的 DPI
    PerScreenDPI=False
    # 固定 Wayland 的字体 DPI
    ForceWaylandDPI=0
    # 在 Wayland 下启用分数缩放
    EnableFractionalScale=True
  '';

  home = {
    file = {
      # RIME 输入法方案配置
      ".local/share/fcitx5/rime/default.custom.yaml".text = ''
        patch:
          schema_list:
            - schema: luna_pinyin_simp
            - schema: luna_pinyin
          menu/page_size: 5
          switcher/hotkeys:
            - Control+grave
          ascii_composer/switch_key:
            Shift_L: commit_code
            Shift_R: commit_code
            Control_L: noop
            Control_R: noop
      '';

      # 预配置 fcitx5 profile，添加 RIME 作为默认中文输入法
      ".config/fcitx5/profile".text = ''
        [Groups/0]
        Name=Default
        Default Layout=us
        DefaultIM=keyboard-us

        [Groups/0/Items/0]
        Name=keyboard-us
        Layout=

        [Groups/0/Items/1]
        Name=rime
        Layout=

        [GroupOrder]
        0=Default
      '';
    };

    activation = {
      # Material Color 主题 symlink（保证候选框主题对任何 fcitx5 版本可见）
      createFcitx5ThemeLinks = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        mkdir -p "$HOME/.local/share/fcitx5/themes"
        for theme in \
          Material-Color-black Material-Color-blue Material-Color-brown \
          Material-Color-deepPurple Material-Color-indigo Material-Color-orange \
          Material-Color-pink Material-Color-red Material-Color-sakuraPink \
          Material-Color-teal
        do
          ln -sfn ${pkgs.fcitx5-material-color}/share/fcitx5/themes/"$theme" \
            "$HOME/.local/share/fcitx5/themes/$theme"
        done
      '';

      # 让 NixOS 的 fcitx5 systemd user service 自动启动（不依赖 KWin InputMethod）
      ensureFcitx5Autostart = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        if [ -f "$HOME/.config/autostart/org.fcitx.Fcitx5.desktop" ]; then
          rm -f "$HOME/.config/autostart/org.fcitx.Fcitx5.desktop"
        fi
      '';

      # 清理之前残留的 kwinrc 错误配置
      cleanupKwinrcInputMethod = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        sed -i '/^\[InputMethod\]/,/^\[/ {
          /^\[InputMethod\]/d
          /^\[/!d
        }' "$HOME/.config/kwinrc" 2>/dev/null || true
        sed -i '/^\[$e\]=/d' "$HOME/.config/kwinrc" 2>/dev/null || true
        sed -i '/^\\x5b$e\\x5d=/d' "$HOME/.config/kwinrc" 2>/dev/null || true
      '';
    };
  };
}
