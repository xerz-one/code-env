{
  pkgs,
  flake,
}:

(with pkgs; [
  # old school
  clang-tools
  libllvm
  binutils
  xxd
  pkg-config
  gnumake
  cmake

  # Shell
  bashInteractive

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
])
++ (with flake; [
  # Racket
  racket
])
