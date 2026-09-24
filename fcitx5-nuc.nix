# fcitx5 用户侧配置：nixos_nuc 专用。
# fcitx5 由 KWin 的 InputMethod 机制拉起（kwinrc 的 InputMethod[$e]），
# KWin 暴露 zwp_input_method_manager_v1，WezTerm 的 zwp_text_input_v3 才能经 KWin 转发到 fcitx5。
# 因此这里禁用 fcitx5 的 KDE 自动启动（写 Hidden=true），清理已废弃的 kwinrc 写入脚本。
# 其余主机用 fcitx5.nix（systemd user service 自动拉起 + 全局 im-module）。
{ config, lib, pkgs, ... }:

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

  # RIME 输入法方案配置
  home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
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

  # Material Color 主题 symlink（保证候选框主题对任何 fcitx5 版本可见）
  home.activation.createFcitx5ThemeLinks = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
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

  # 禁用 fcitx5 的 KDE 自动启动，改为由 KWin 通过虚拟键盘 / InputMethod 机制管理。
  # KWin 读取 kwinrc 中的 InputMethod[$e]，启动 fcitx5 并暴露 zwp_input_method_manager_v1 协议。
  # 这样 WezTerm 的 zwp_text_input_v3 才能经由 KWin 转发到 fcitx5。
  home.activation.disableFcitx5Autostart = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    AUTOSTART_DIR="$HOME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    if [ -f "$AUTOSTART_DIR/org.fcitx.Fcitx5.desktop" ]; then
      if ! grep -Fq 'Hidden=true' "$AUTOSTART_DIR/org.fcitx.Fcitx5.desktop"; then
        echo -e '[Desktop Entry]\nHidden=true' > "$AUTOSTART_DIR/org.fcitx.Fcitx5.desktop"
      fi
    else
      echo -e '[Desktop Entry]\nHidden=true' > "$AUTOSTART_DIR/org.fcitx.Fcitx5.desktop"
    fi
  '';

  # 清理旧的 kwriteconfig6 错误写入使 kwinrc 的激活脚本（已废弃）
  home.activation.cleanupOldKwinrcFix = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    sed -i '/^InputMethod\\/d' "$HOME/.config/kwinrc" 2>/dev/null || true
  '';
}
