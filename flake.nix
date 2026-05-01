{
  description = "NixOS configuration for nixos_nuc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/4e92bbcdb030f3b4782be4751dc08e6b6cb6ccf2";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    plasma-manager,
    ...
  }: {
    nixosConfigurations.nixos_nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
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
    };
  };
}
