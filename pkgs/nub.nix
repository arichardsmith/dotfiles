{
  stdenv,
  fetchurl,
}: let
  pkgMeta = rec {
    name = "nub";
    version = "0.4.5";
    tarballs = {
      "aarch64-darwin" = {
        url = "https://github.com/nubjs/nub/releases/download/v${version}/nub-darwin-arm64.tar.gz";
        hash = "sha256-c6gMocBJLlFLKzBezEm/h6XyoCmsUTQlSe0HWFm7sxk=";
      };
      "x86_64-linux" = {
        url = "https://github.com/nubjs/nub/releases/download/v${version}/nub-linux-x64.tar.gz";
        hash = "sha256-1f2eIRzt/plIZ6nD35dGMWK59KizO/YEXCxxZIeo1cw=";
      };
    };
  };

  inherit (pkgMeta) version;
in
  stdenv.mkDerivation {
    pname = "nub";
    inherit version;
    src = fetchurl pkgMeta.tarballs.${stdenv.hostPlatform.system};
    sourceRoot = ".";
    passthru = {inherit pkgMeta;};
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      install -m755 bin/nub "$out/bin/nub"
      cp -R runtime "$out/runtime"
      ln -s nub "$out/bin/nubx"
      runHook postInstall
    '';
  }
