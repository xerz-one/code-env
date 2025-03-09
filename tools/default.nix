{
  pkgs,
  flake
}:

(with pkgs; [
  # old school
  clang-tools
  pkg-config
  gnumake

  # Rust
  rustc
  cargo
  evcxr

  # Haskell
  ghc
  cabal-install

  # Idris
  idris2

  # OCaml
  ocaml
  ocamlPackages.ocamlbuild
  ocamlPackages.utop

  # Java
  jdk23
  javaPackages.openjfx23
]) ++
(with flake; [
  # Racket
  racket
])
