{
  lib,
}:
with lib;

let
  # stdenv override with full Clang and Mold
  ## TODO: check that `llvm.clangUseLLVM` is no longer a pain to work with
  stdenv_gen =
    {
      pkgs,
      llvm,
    }:
    pkgs.overrideCC llvm.stdenv llvm.clangUseLLVM |> pkgs.useMoldLinker;

  # mkShell override
  mkShellClang =
    {
      pkgs,
    }:
    pkgs.mkShell.override { stdenv = pkgs.stdenv; };
in
{
  inherit stdenv_gen mkShellClang code-env_gen;
}
