{
  stdenv,
  fetchurl,
  makeWrapper,
  ripgrep,
  lib,
}: let
  pkgMeta = rec {
    name = "@anthropic-ai/claude-code";
    version = "2.1.181";
    tarballs = {
      "aarch64-darwin" = {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code-darwin-arm64/-/claude-code-darwin-arm64-${version}.tgz";
        hash = "sha256-E3kVzdFVy0k+pnsjwGZAmk7Trulnv70kmVYjLN7Zplg=";
      };
      "x86_64-linux" = {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-${version}.tgz";
        hash = "sha256-Te7M0dwVeJSGgk13kKLM1+cJAyzjTa8JnDb31BfWyOk=";
      };
    };
  };

  inherit (pkgMeta) version;
in
  stdenv.mkDerivation {
    pname = "claude-code";
    inherit version;
    src = fetchurl pkgMeta.tarballs.${stdenv.hostPlatform.system};
    nativeBuildInputs = [makeWrapper];
    passthru = {inherit pkgMeta;};
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -m755 claude $out/bin/.claude-unwrapped
      makeWrapper $out/bin/.claude-unwrapped $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --set USE_BUILTIN_RIPGREP 0 \
        --prefix PATH : ${lib.makeBinPath [ripgrep]}
      runHook postInstall
    '';
  }
