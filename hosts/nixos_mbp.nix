# 主机 nixos_mbp（MacBookPro14,3 / 2017 15"）专属配置。
# 共用配置见 ../configuration.nix；硬件/文件系统见 ../hardware-configuration-mbp.nix
# （其中已 import broadcom-43xx.nix，负责 BCM43602 无线网卡固件）。
# 与 nixos_zn 的唯一差异：主机名不同，且不启用 Steam（此机无游戏需求）。
{ ... }:

{
  networking.hostName = "nixos_mbp";
}
