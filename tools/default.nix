{
  pkgs,
  flake,
}:

(with flake; [
  # Racket
  racket

  # old school
  stdenv.cc
  llvm.clang-tools
  llvm.libllvm
])
++ (with pkgs; [
  pkg-config
  gnumake
  cmake
  meson
  ninja
  xxd
  ripgrep
  fq

  # Shell
  bashInteractive

  # Rust
  rustc
  cargo
  evcxr

  # Nix
  nixd

  # Haskell
  ghc
  cabal-install

  # Agda
  agda

  # Idris
  idris2

  # OCaml
  ocaml
  ocamlPackages.ocamlbuild
  ocamlPackages.utop

  # Java
  jdk25
  openjfx25
])
