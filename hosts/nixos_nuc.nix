# 主机 nixos_nuc（本机，Intel NUC）专属配置。
# 与 nixos_zn 保持一致，唯一差别是不启用 Steam；
# 共用配置见 ../configuration.nix，硬件/文件系统见 ../hardware-configuration.nix。
{ ... }:

{
  networking.hostName = "nixos_nuc";
}
