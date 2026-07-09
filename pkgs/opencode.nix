{
  stdenv,
  fetchurl,
}: let
  pkgMeta = rec {
    name = "opencode-ai";
    version = "1.17.18";
    tarballs = {
      "aarch64-darwin" = {
        url = "https://registry.npmjs.org/opencode-darwin-arm64/-/opencode-darwin-arm64-${version}.tgz";
        hash = "sha256-b7Q+LYco+g4qWQ1JxFxjSJ7Nozpu1OcGTDSwaw31CB0=";
      };
      "x86_64-linux" = {
        url = "https://registry.npmjs.org/opencode-linux-x64/-/opencode-linux-x64-${version}.tgz";
        hash = "sha256-vMYMkpqrtesw+K7q3sl1TjMEwRxZZrcIMpBnlDufiTQ=";
      };
    };
  };

  inherit (pkgMeta) version;
in
  stdenv.mkDerivation {
    pname = "opencode";
    inherit version;
    src = fetchurl pkgMeta.tarballs.${stdenv.hostPlatform.system};
    passthru = {inherit pkgMeta;};
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -m755 bin/opencode $out/bin/opencode
      runHook postInstall
    '';
  }
