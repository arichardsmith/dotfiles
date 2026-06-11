{ stdenv, fetchurl }:
let
  version = "1.17.3";

  sources = {
    "aarch64-darwin" = {
      url = "https://registry.npmjs.org/opencode-darwin-arm64/-/opencode-darwin-arm64-${version}.tgz";
      hash = "sha256-dzMX8SJfiRjYGduvPRElo7PMWFqx6YKz/deIGESiEso=";
    };
    "x86_64-linux" = {
      url = "https://registry.npmjs.org/opencode-linux-x64/-/opencode-linux-x64-${version}.tgz";
      hash = "sha256-HGoziSxZhGoJkEmITKky0NYjNFoewo6YiWIUWARNq2o=";
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
