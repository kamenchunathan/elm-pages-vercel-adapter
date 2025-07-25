{
  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    allowUnfree = true;
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

      in
      {
        packages = {
          devenv-up = self.devShells.${system}.default.config.procfileScript;
        };

        devShells.default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            (
              { pkgs, config, ... }:
              {
                packages = with pkgs; [ nodePackages.vercel ];

                languages = {
                  elm.enable = true;

                  javascript = {
                    enable = true;
                    pnpm.enable = true;
                  };
                };
              }
            )
          ];
        };
      }
    );
}
