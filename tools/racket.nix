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

  # Racket 9.0 definition
  racket_9_0_gen =
    {
      pkgs,
    }:
    (racket_gen { inherit pkgs; }).overrideAttrs (
      final: prev: {
        version = "9.0";
        src = pkgs.fetchurl {
          url = "https://mirror.racket-lang.org/installers/${final.version}/racket-minimal-${final.version}-src.tgz";
          sha256 = "sha256-LJ3AEqy9mA4Qxg21Bx4eRZfm0SRpgyqApEvqsrYuw/4=";
        };
      }
    );
in
{
  inherit racket_gen racket_9_0_gen;
}
