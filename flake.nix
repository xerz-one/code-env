{
  inputs = {
    sysrepo.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "sysrepo";
    };
  };

  outputs =
    {
      sysrepo,
      ...
    }@inputs:
    with sysrepo.lib // import tools/racket.nix { lib = sysrepo.lib; };

    # Generalized definitions
    let
      forAllSystems = genAttrs systems.flakeExposed;

      # mkShell override for Clang
      mkShellClang =
        {
          pkgs,
        }:
        pkgs.mkShell.override { stdenv = pkgs.clangStdenv; };

      # Code environment generator
      #
      # This takes the packages defined at `./tools` and builds a Clang stdenv
      # shell for them
      code-env_gen =
        {
          pkgs,
          ...
        }@args:
        mkShellClang
          {
            inherit pkgs;
          }
          {
            packages = import ./tools args;
          };

      # A small tool to infer a default executable from a derivation, as in
      # https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-run#description
      getExe = drv: drv.meta.mainProgram or (drv.pname or (drv.name |> builtins.match ''(.*)-.*''));

      # Launcher environment generator
      #
      # This can take a pre-existing `mkShell` env and add a launcher to it
      launch-env_gen =
        {
          launcher,
          env,
        }:
        env.overrideAttrs (
          final: prev: {
            nativeBuildInputs = prev.nativeBuildInputs ++ [ launcher ];
            shellHook = ''
              exec ${getExe launcher}
            '';
          }
        );
    in

    # Flake-exposed packages and devshells
    rec {
      packages = forAllSystems (
        system:
        let
          pkgs = import sysrepo { inherit system; };

          racket = racket_8_17_gen { inherit pkgs; };
          vscodium = pkgs.vscodium;
        in
        {
          inherit racket vscodium;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import sysrepo { inherit system; };
          flake = packages.${system};

          code-env = code-env_gen { inherit pkgs flake; };
          vsc-env = launch-env_gen {
            launcher = flake.vscodium;
            env = code-env;
          };
        in
        {
          inherit code-env vsc-env;

          default = vsc-env;
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = import sysrepo { inherit system; };
        in
        inputs.treefmt-nix.lib.mkWrapper pkgs {
          programs.nixfmt.enable = true;
        }
      );
    };
}
