# 主机 nixos_zn（本机，AMD 桌面机）专属配置。
# 共用配置见 ../configuration.nix；硬件/文件系统见 ../hardware-configuration.nix。
{ pkgs-unstable, ... }:

{
  networking.hostName = "nixos_zn";

  programs.steam = {
    enable = true;
    package = pkgs-unstable.steam;
  };
}
