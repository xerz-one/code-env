{
  inputs = {
    sysrepo.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{
    sysrepo,
    ...
  }:
  with sysrepo.lib;

  # Generalized definitions
  let
    forAllSystems = genAttrs systems.flakeExposed;

    # Racket package generator
    #
    # It patches `racket-minimal` to add in assumed dependencies,
    # as well as remove a debug flag that is both wastefully slow and buggy 
    racket_gen = {
      pkgs
    }:
    pkgs.racket-minimal.overrideAttrs (final: prev: {
      # TODO: remove version/src override
      version = "8.16";
      src = pkgs.fetchurl {
        url = "https://mirror.racket-lang.org/installers/8.16/racket-minimal-8.16-src.tgz";
        hash = "sha256-TnJ9t1V0qxHWvsevXl1yoIT6f2YuIAw11bwgB3L1zpY=";
      };
      configureFlags = prev.configureFlags |> remove "--enable-check";
      buildInputs = pkgs.racket.buildInputs;
    });

    # mkShell override for Clang
    mkShellClang = {
      pkgs
    }: pkgs.mkShell.override { stdenv = pkgs.clangStdenv; };

    # just a bit of sugar for mkShell
    env_gen = {
      mkShell,
      packages
    }: mkShell {
      inherit packages; 
    };

    # applied sugar for mkShellClang
    env-clang_gen = {
      pkgs,
      packages
    }: env_gen {
      inherit packages;
      mkShell = mkShellClang { inherit pkgs; };
    };

    # Code environment generator
    #
    # This takes the packages defined at `./tools` and builds a Clang stdenv
    # shell for them
    code-env_gen = {
      pkgs,
      ...
    }@args: env-clang_gen {
      inherit pkgs;
      packages = import ./tools args;
    };

    # VSCod* environment generator
    #
    # This can use a pre-existing `mkShell` env and add VSCod* to it
    vsc-env_gen = {
      vsc,
      env
    }: env.overrideAttrs (final: prev: {
      nativeBuildInputs = prev.nativeBuildInputs ++ [ vsc ];
      shellHook = ''
        exec codium
      '';
    });
  in

  # Flake-exposed packages and devshells
  rec {
    packages = forAllSystems (system:
    let
      pkgs      = import sysrepo  { inherit system; };

      racket    = racket_gen      { inherit pkgs; };
      vscodium  = pkgs.vscodium;
    in
    {
      inherit racket vscodium;
    });

    devShells = forAllSystems (system:
    let
      pkgs      = import sysrepo  { inherit system; };
      flake     = packages.${system};

      code-env  = code-env_gen    { inherit pkgs flake; };
      vsc-env   = vsc-env_gen     { vsc = flake.vscodium; env = code-env; };
    in
    {
      inherit code-env vsc-env;

      default = vsc-env;
    });
  };
}
