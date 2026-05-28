{
  description = "Flutter";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        system,
        pkgs,
        ...
      }: let
        pname = "eko";
        gitRev = inputs.self.shortRev or inputs.self.dirtyShortRev or "dirty";
        mkGenericRelease = import ./nix/mk-generic.nix {inherit pkgs;};
        ekoApp = pkgs.callPackage ./nix/package.nix {
          inherit gitRev;
          inherit pname;
        };
        commonPackages = with pkgs; [
          gcc
          jdk
          ninja
          unzip
          supabase-cli
          sops
          age
        ];
        commonShellHook = ''
          git config core.hooksPath scripts/git-hooks
        '';
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        packages = {
          default = ekoApp;
          tarball = mkGenericRelease {
            inherit pname;
            app = ekoApp;
            version = gitRev;
          };
        };
        devShells = let
          darwinShells = import ./nix/darwin-dev-shells.nix {
            inherit pkgs commonPackages commonShellHook;
          };

          linuxShells = import ./nix/linux-dev-shels.nix {
            inherit pkgs commonPackages commonShellHook;
          };
        in
          darwinShells
          // linuxShells
          // {
            default =
              if pkgs.stdenv.isDarwin
              then darwinShells.darwin
              else linuxShells.linux;
          };
      };
    };
}
