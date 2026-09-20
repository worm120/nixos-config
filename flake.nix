{
  description = "NixOS 配置：nixos_zn（AMD 桌面机）/ nixos_mbp（MacBookPro14,3）";

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

      # 两台机器共用的模块：系统配置 + home-manager/plasma-manager 接线
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
    in
    {
      nixosConfigurations = {
        nixos_zn = mkHost [
          ./hardware-configuration.nix
          ./hosts/nixos_zn.nix
        ];
        nixos_mbp = mkHost [
          ./hardware-configuration-mbp.nix
          ./hosts/nixos_mbp.nix
        ];
      };
    };
}
