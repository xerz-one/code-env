{
  lib,
}:
with lib;

let
  # Racket package generator
  #
  # It patches `racket-minimal` to add in assumed dependencies,
  # as well as remove a debug flag that is both wastefully slow and buggy
  racket_gen =
    {
      pkgs,
    }:
    pkgs.racket-minimal.overrideAttrs (
      final: prev: {
        configureFlags = prev.configureFlags |> remove "--enable-check";
        buildInputs = pkgs.racket.buildInputs ++ [ pkgs.libedit ];
      }
    );

  # Racket 8.17 definition
  racket_8_17_gen =
    {
      pkgs,
    }:
    (racket_gen { inherit pkgs; }).overrideAttrs (
      final: prev: {
        version = "8.17";
        src = pkgs.fetchurl {
          url = "https://mirror.racket-lang.org/installers/8.17/racket-minimal-src.tgz";
          sha256 = "sha256-3HcFqoT51u2jqEup11wWFVIlAFFekp6SAQlG7fDKN9A=";
        };
      }
    );
in
{
  inherit racket_gen racket_8_17_gen;
}
