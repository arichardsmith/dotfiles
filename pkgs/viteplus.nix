{
  stdenv,
  fetchurl,
}: let
  pkgMeta = rec {
    name = "viteplus";
    version = "0.2.1";
    tarballs = {
      "aarch64-darwin" = {
        url = "https://registry.npmjs.org/@voidzero-dev/vite-plus-cli-darwin-arm64/-/vite-plus-cli-darwin-arm64-${version}.tgz";
        hash = "sha256-glb6/pWzpkGIk5R/8zBeq9O4hdrk50/nLLX9L0OylVQ=";
      };
      "x86_64-linux" = {
        url = "https://registry.npmjs.org/@voidzero-dev/vite-plus-cli-linux-x64-gnu/-/vite-plus-cli-linux-x64-gnu-${version}.tgz";
        hash = "sha256-w8ByhMw99j9zG/uCUlvwbBlXg8gWtmSA9uEJLTvQsiw=";
      };
    };
  };

  inherit (pkgMeta) version;
in
  stdenv.mkDerivation {
    pname = "viteplus";
    inherit version;
    src = fetchurl pkgMeta.tarballs.${stdenv.hostPlatform.system};
    passthru = {inherit pkgMeta;};
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -m755 vp $out/bin/vp
      runHook postInstall
    '';
  }
