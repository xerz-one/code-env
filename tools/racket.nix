{
  lib,
}:
with lib;

{
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
}
