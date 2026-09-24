# T1（iBridge）触控栏驱动 —— 2016/2017 款 MacBookPro13,x / 14,x 的触控栏是 T1 设备
# （USB 05ac:8600），mainline 内核只支持 2018+ 的 T2（8302：见 hid-appletb-kbd / appletbdrm
# 的 modalias），所以只能靠这套 out-of-tree 模块。源码内联在 apple-ib-drv-src/
# （176KB，见其中 README / LICENSE），不走上游 fetch —— 理由见下面的 src 注释。
#
# ⚠️ 启用前提：T1 固件必须已被 macOS 重写回 ESP 的 EFI/APPLE/EMBEDDEDOS/。
#    判据：`lsusb -d 05ac:` = 8600 表示健康；仍是 1281（Apple Mobile Device (Recovery Mode)）
#    表示固件缺失，此时触控栏 / 摄像头 / Touch ID / 环境光全都不工作，任何驱动都无效 ——
#    固件按设备 ECID 签名，只能由 macOS 重写，不能从别的 Mac 拷贝。
#
# 固件恢复后在 hosts/nixos_mbp.nix 里启用（照抄即可，已按内核 7.2.6 编译验证）：
#
#   boot.extraModulePackages = [ (pkgs.linuxPackages_latest.callPackage ../pkgs/apple-ib-drv.nix { }) ];
#   services.udev.packages = [ (pkgs.linuxPackages_latest.callPackage ../pkgs/apple-ib-drv.nix { }) ];
#   # ↑ 同一个 derivation：.ko 给 extraModulePackages，99-ibridge.rules 给 udev
#   boot.kernelModules = [ "apple-ibridge" ];   # 这个模块是 ACPI 驱动（alias acpi:APP7777），
#                                               # 会由 kmod 的 modalias 自动加载，这行是显式兜底
#   boot.extraModprobeConfig = "options apple_ibridge skip_acpi_power=1";  # 防 ASOC.SOCW 硬冻结
#   boot.kernelParams = [ "apple_ib_tb.fnmode=1" ];  # 可选：默认媒体键，按住 Fn 出 F1–F12
#
# 万一启用后开机卡住（该模块加载有已知自锁风险），把这行换成上游 cschaba 的晚加载写法：
#   用 Type=oneshot + after multi-user.target 的 systemd 服务跑 modprobe apple-ibridge，
#   而不是 boot.kernelModules（= /etc/modules-load.d，early boot）。
#
# 验证：`lsusb -d 05ac:` 显示 8600；`ls /dev/video*` 出现；`dmesg | grep -i ibridge`；
#      触控栏亮起（Esc / 亮度 / 媒体键，按住 Fn 出 F1–F12）。
{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation rec {
  pname = "apple-ib-drv";
  version = "0.1-unstable-2026-07-01";
  name = "${pname}-${version}-${kernel.version}";

  # 内联源码，不走 fetchFromGitHub：上游 tarball 只能从 github.com 取，而这台国内网络
  # 直连被墙、代理时好时坏（实测 6–130 KB/s），固定输出（FOD）经常卡死几十分钟。
  # 来源 https://github.com/AJ-dev-i60/t1-touchbar rev 20d65c7b0fe6d05ea9734f869b27384a62de5109，
  # 解包后的 nar hash = sha256-nDTnPfNCAnx0NzKxt/YBt/QGnZZg8e+Z173uaWiKQUw=
  # （想改回 fetchFromGitHub 时直接拿这个 hash）。
  src = ./apple-ib-drv-src;

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    install -D apple-ibridge.ko $out/lib/modules/${kernel.modDirVersion}/extra/apple-ibridge.ko
    install -D apple-touchbar.ko $out/lib/modules/${kernel.modDirVersion}/extra/apple-touchbar.ko
    # iBridge 出厂停在未配置状态：这条规则强制 USB config 1，才会同时露出
    # 触控栏 HID 和摄像头的 UVC 接口。给 services.udev.packages 用。
    install -D -m444 packaging/99-ibridge.rules $out/lib/udev/rules.d/99-ibridge.rules
    runHook postInstall
  '';

  meta = {
    description = "Touch Bar / iBridge driver for 2016-2017 T1 MacBook Pros";
    homepage = "https://github.com/AJ-dev-i60/t1-touchbar";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
