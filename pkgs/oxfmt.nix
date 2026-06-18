{
  stdenv,
  fetchurl,
  makeWrapper,
  bun,
  lib,
}: let
  pkgMeta = rec {
    name = "oxfmt";
    version = "0.55.0";
    tarballs = {
      main = {
        url = "https://registry.npmjs.org/oxfmt/-/oxfmt-${version}.tgz";
        hash = "sha256-bP7wu/EYFIudCdggZnNUfDdMkXF84FZtiOLThFUytmw=";
      };
      darwin = {
        url = "https://registry.npmjs.org/@oxfmt/binding-darwin-arm64/-/binding-darwin-arm64-${version}.tgz";
        hash = "sha256-d+rj8eyRaV64lXTEGadkYh4D512/1pVWZIljbDAdrDc=";
      };
      linux = {
        url = "https://registry.npmjs.org/@oxfmt/binding-linux-x64-gnu/-/binding-linux-x64-gnu-${version}.tgz";
        hash = "sha256-DRKrBD6s7E7Mbv2aDjoTBC+Ii7l0chKiNGN4hhNCxD4=";
      };
    };
    deps = {
      tinypool = rec {
        name = "tinypool";
        version = "2.1.0";
        tarballs = {
          main = {
            url = "https://registry.npmjs.org/tinypool/-/tinypool-${version}.tgz";
            hash = "sha256-XORYP2+ZNosLV+JSM8mqqHAZSr6vakBnE4iez/N7tB4=";
          };
        };
      };
    };
  };

  inherit (pkgMeta) version;
  mainSrc = fetchurl pkgMeta.tarballs.main;
  tinypoolSrc = fetchurl pkgMeta.deps.tinypool.tarballs.main;
  bindings = {
    "aarch64-darwin" = {
      platform = "darwin-arm64";
      src = fetchurl pkgMeta.tarballs.darwin;
    };
    "x86_64-linux" = {
      platform = "linux-x64-gnu";
      src = fetchurl pkgMeta.tarballs.linux;
    };
  };
  binding = bindings.${stdenv.hostPlatform.system};
in
  stdenv.mkDerivation {
    pname = pkgMeta.name;
    inherit version;
    nativeBuildInputs = [makeWrapper];
    passthru = {inherit pkgMeta;};
    buildCommand = ''
      mkdir -p "$out/lib/node_modules/oxfmt"
      tar xzf ${mainSrc} -C "$out/lib/node_modules/oxfmt" --strip-components=1

      mkdir -p "$out/lib/node_modules/tinypool"
      tar xzf ${tinypoolSrc} -C "$out/lib/node_modules/tinypool" --strip-components=1

      mkdir -p "$out/lib/node_modules/@oxfmt/binding-${binding.platform}"
      tar xzf ${binding.src} -C "$out/lib/node_modules/@oxfmt/binding-${binding.platform}" --strip-components=1

      mkdir -p "$out/bin"
      makeWrapper ${bun}/bin/bun "$out/bin/oxfmt" \
        --add-flags "$out/lib/node_modules/oxfmt/bin/oxfmt"
    '';
  }
