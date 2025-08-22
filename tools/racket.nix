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

  # Racket 8.18 definition
  racket_8_18_gen =
    {
      pkgs,
    }:
    (racket_gen { inherit pkgs; }).overrideAttrs (
      final: prev: {
        version = "8.18";
        src = pkgs.fetchurl {
          url = "https://mirror.racket-lang.org/installers/${final.version}/racket-minimal-${final.version}-src.tgz";
          sha256 = "sha256-JLnPg2UlS0O6wwgZLHgu372GNj3xMixOBjt5ftD322Y=";
        };
      }
    );
in
{
  inherit racket_gen racket_8_18_gen;
}
