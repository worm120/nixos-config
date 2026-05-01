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

  # KDE 面板输入法图标（禁用，由 Classic UI 接管候选框）
  xdg.configFile."fcitx5/conf/kimpanel.conf".text = ''
    Enabled=False
  '';

  # 禁用 Wayland 输入法前端，让 Classic UI 渲染候选框
  xdg.configFile."fcitx5/conf/waylandim.conf".text = ''
    Enabled=False
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
}
