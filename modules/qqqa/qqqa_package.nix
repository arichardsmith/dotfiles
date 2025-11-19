{pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "qqqa";
  version = "0.10.0";

  src = pkgs.fetchurl {
    url =
      {
        x86_64-linux = "https://github.com/iagooar/qqqa/releases/download/v${version}/qqqa-v${version}-x86_64-unknown-linux-musl.tar.gz";
        aarch64-linux = "https://github.com/iagooar/qqqa/releases/download/v${version}/qqqa-v${version}-aarch64-unknown-linux-musl.tar.gz";
        aarch64-darwin = "https://github.com/iagooar/qqqa/releases/download/v${version}/qqqa-v${version}-aarch64-apple-darwin.tar.gz";
        x86_64-darwin = "https://github.com/iagooar/qqqa/releases/download/v${version}/qqqa-v${version}-x86_64-apple-darwin.tar.gz";
      }.${
        pkgs.stdenv.hostPlatform.system
      };

    sha256 =
      {
        x86_64-linux = "a6c271049e7d167d96d766836118693cb1b34a785d4c465c1e5de24569085d6c";
        aarch64-linux = "839d6f8f0093e43e4edce91afa7a591ca054940333637a3185c9a9db12a241e2";
        x86_64-darwin = "6c1eabe09bf9ac3ad0ffd56ed82d241941c2f588e3e84bf2c53a89100627dfe9";
        aarch64-darwin = "a463135d2dd4a505656a0f7fbccfe87f6dbb487680ded36ab66ff4821b98e015";
      }.${
        pkgs.stdenv.hostPlatform.system
      };
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp qq $out/bin/
    chmod +x $out/bin/qq
    cp qa $out/bin/
    chmod +x $out/bin/qa
  '';
}
