# 主机 nixos_mbp（MacBookPro14,3 / 2017 15"）专属配置。
# 共用配置见 ../configuration.nix；硬件/文件系统见 ../hardware-configuration-mbp.nix
# （其中已 import broadcom-43xx.nix，负责 BCM43602 无线网卡固件）。
# 与 nixos_zn 的差异：主机名不同、不启用 Steam，另加 hermes 需要的 ffmpeg。
{ pkgs, ... }:

{
  networking.hostName = "nixos_mbp";

  # T1 触控栏（2017 MacBookPro14,3）—— 默认不启用。
  # 硬件前提未满足：T1 固件（ESP 的 EFI/APPLE/EMBEDDEDOS/）已被整盘安装抹掉，
  # `lsusb -d 05ac:` 现在是 1281（Recovery Mode）而不是 8600，此时驱动无设备可绑，
  # 触控栏 / 摄像头 / Touch ID / 环境光都不会工作。固件只能由 macOS 重写。
  # 驱动已打包并编译验证：../pkgs/apple-ib-drv.nix（启用步骤见该文件顶部注释）。

  # Hermes Agent 的安装器在 NixOS 上无法自己装 ffmpeg（没有 apt / cargo 路径）：
  # ffmpeg = TTS 语音消息转码（ripgrep 已移入共用 configuration.nix）
  environment.systemPackages = with pkgs; [
    ffmpeg
  ];
}
