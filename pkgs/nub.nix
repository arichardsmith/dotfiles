{
  stdenv,
  fetchurl,
}: let
  pkgMeta = rec {
    name = "nub";
    version = "0.2.0";
    tarballs = {
      "aarch64-darwin" = {
        url = "https://github.com/nubjs/nub/releases/download/v${version}/nub-darwin-arm64.tar.gz";
        hash = "sha256-H7eIbYfrx9jzdcnqFLjokzTPJjuvB10zXszqcLtzSx0=";
      };
      "x86_64-linux" = {
        url = "https://github.com/nubjs/nub/releases/download/v${version}/nub-linux-x64.tar.gz";
        hash = "sha256-1v/87TBLN7IEIG72gwImobCnREg4h2/a8NgSaepVCsw=";
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
