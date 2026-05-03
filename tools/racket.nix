{
  lib,
}:
with lib;

let
  defs = rec {
    # Racket version attrset generator
    racket_ver =
      {
        x,
        y,
        z ? 0,
        w ? 0,
      }@ver:
      ver;

    # Racket version attrset from `racket_version.h` parser
    racket_h_ver =
      h:
      let
        get_value = m: h: match ".*MZSCHEME_VERSION_${m} ([[:digit:]]+).*" h |> last;
        x = get_value "X" h |> toInt;
        y = get_value "Y" h |> toInt;
        z = get_value "Z" h |> toInt;
        w = get_value "W" h |> toInt;
      in
      {
        inherit
          x
          y
          z
          w
          ;
      };

    # Racket version attrset to `racket_version.h` patcher
    #
    # Takes the content of a `racket_version.h` string,
    # assumes that all version definitions are coupled together,
    # then inserts its own definitions and returns the result
    racket_ver_patch =
      {
        x,
        y,
        z ? 0,
        w ? 0,
      }@ver:
      h:
      let
        trimmed = split "\n#define MZSCHEME_VERSION_[X|Y|Z|W]{1}[[:space:]]+[[:digit:]]" h |> flatten;
        start = elemAt 1 trimmed;
        end = last trimmed;
        set_value = m: n: "\nMZSCHEME_VERSION_${m} ${n}";
      in
      concatStrings [
        start
        (set_value "X" x)
        (set_value "Y" y)
        (set_value "Z" z)
        (set_value "W" w)
        end
      ];

    # Racket version string from version attrset generator
    racket_ver_str =
      {
        x,
        y,
        z ? 0,
        w ? 0,
      }@ver:
      "${x}.${y}"
      + (
        if w > 0 then
          ".${z}.${w}"
        else if z > 0 then
          ".${z}"
        else
          ""
      );

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

    /*
      TODO: Git Racket package generator
      racket_git_gen =
        {
          pkgs,
          rev,
          hash,
          ...
        }@args:
        (racket_gen { inherit pkgs; }).overrideAttrs (
          final: prev:
          let
            src = pkgs.fetchFromGitHub {
              inherit rev hash;
              owner = "racket";
              repo = "racket";
            };
            ver = args.ver or (racket_h_ver src + "/src/version/racket_version.h");
            version = racket_ver_str ver;
          in
          {
            inherit src version;
          }
        );
    */

    # Racket release package generator
    racket_release_gen =
      {
        pkgs,
        version,
        hash,
      }:
      (racket_gen { inherit pkgs; }).overrideAttrs (
        final: prev: {
          inherit version;
          src = pkgs.fetchurl {
            inherit hash;
            url = "https://mirror.racket-lang.org/installers/${version}/racket-minimal-${version}-src.tgz";
          };
        }
      );
  };
in
defs
