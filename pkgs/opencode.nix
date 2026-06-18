{ stdenv, fetchurl }:
let
  version = "1.17.8";

  sources = {
    "aarch64-darwin" = {
      url = "https://registry.npmjs.org/opencode-darwin-arm64/-/opencode-darwin-arm64-${version}.tgz";
      hash = "sha256-n9mRynW4IdDrIPbmR2m8hui/OTqHbGDheWa+KiPKCtc=";
    };
    "x86_64-linux" = {
      url = "https://registry.npmjs.org/opencode-linux-x64/-/opencode-linux-x64-${version}.tgz";
      hash = "sha256-YZ7Gfd4pklo2HM+TGMd/3isFmheoRB9zBQ6yj52/5hA=";
    };
  };
in stdenv.mkDerivation {
  pname = "opencode";
  inherit version;
  src = fetchurl sources.${stdenv.hostPlatform.system};
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 bin/opencode $out/bin/opencode
    runHook postInstall
  '';
}
