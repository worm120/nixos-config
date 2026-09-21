# 主机 nixos_mbp（MacBookPro14,3 / 2017 15"）专属配置。
# 共用配置见 ../configuration.nix；硬件/文件系统见 ../hardware-configuration-mbp.nix
# （其中已 import broadcom-43xx.nix，负责 BCM43602 无线网卡固件）。
# 与 nixos_zn 的差异：主机名不同、不启用 Steam，另加 hermes 需要的 rg / ffmpeg。
{ pkgs, ... }:

{
  networking.hostName = "nixos_mbp";

  # Hermes Agent 的安装器在 NixOS 上无法自己装这两个工具（没有 apt / cargo 路径）：
  # ripgrep = 文件搜索，ffmpeg = TTS 语音消息转码
  environment.systemPackages = with pkgs; [
    ripgrep
    ffmpeg
  ];
}
