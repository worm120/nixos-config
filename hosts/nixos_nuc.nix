# 主机 nixos_nuc（本机，Intel NUC）专属配置。
# 共用配置见 ../configuration.nix；硬件/文件系统见 ../hardware-configuration.nix。
{ pkgs, ... }:

{
  networking.hostName = "nixos_nuc";

  # 本机原来在 systemPackages 里显式装了 coreutils，保留
  environment.systemPackages = with pkgs; [
    coreutils
  ];

  # 本机 2026-09 调试时把 PATH 基值写死成系统 bin 目录（保持原状）。
  # 注意：这会覆盖 NixOS 默认拼出来的 PATH；若以后出现命令找不到，
  # 优先怀疑这三行，删掉再 nixos-rebuild switch 试试。
  environment.sessionVariables.PATH = "/run/current-system/sw/bin";
}
