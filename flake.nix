{
  description = "NixOS 配置：nixos_nuc（Intel NUC）/ nixos_zn（AMD 桌面机）/ nixos_mbp（MacBookPro14,3）";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/ecaf8a83c40db63582da00410062a799b8c2b308";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      plasma-manager,
      ...
    }:
    let
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };

      # 三台机器共用的模块：系统配置 + home-manager/plasma-manager 接线
      baseModules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.sharedModules = [
            plasma-manager.homeModules.plasma-manager
          ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-bak";
          home-manager.users.zn = import ./home.nix;
        }
      ];

      # 每台机器各自追加：硬件/文件系统模块 + 主机专属设置
      mkHost =
        modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = baseModules ++ modules;
        };
      # 只用于构建「不属于任何子系统」的独立包（当前：T1 触控栏驱动）。
      # 用与系统相同的 nixpkgs，保证模块与 boot.kernelPackages 用的内核版本一致。
      pkgsFor = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      packages.x86_64-linux.apple-ib-drv =
        pkgsFor.linuxPackages_latest.callPackage ./pkgs/apple-ib-drv.nix
          { };

      # 硬件/文件系统文件名：每台机器各自的 nixos-generate-config 产物，
      # 只有主机名对它成立。hardware-configuration.nix 这个名字留给当前所在的机器
      # （nixos_nuc），其余两台用带后缀的名字，避免互相覆盖。
      nixosConfigurations = {
        nixos_nuc = mkHost [
          ./hardware-configuration.nix
          ./hosts/nixos_nuc.nix
        ];
        nixos_zn = mkHost [
          ./hardware-configuration-zn.nix
          ./hosts/nixos_zn.nix
        ];
        nixos_mbp = mkHost [
          ./hardware-configuration-mbp.nix
          ./hosts/nixos_mbp.nix
        ];
      };
    };
}
