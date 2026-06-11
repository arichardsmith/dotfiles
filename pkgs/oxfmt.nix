{ stdenv, fetchurl, makeWrapper, bun, lib }:
let
  version = "0.54.0";

  mainSrc = fetchurl {
    url = "https://registry.npmjs.org/oxfmt/-/oxfmt-${version}.tgz";
    hash = "sha256-yO42G6bNrQYGr8dG+FKgKGzla/d9xBQ9NDiHQfLziMI=";
  };

  tinypoolSrc = fetchurl {
    url = "https://registry.npmjs.org/tinypool/-/tinypool-2.1.0.tgz";
    hash = "sha256-XORYP2+ZNosLV+JSM8mqqHAZSr6vakBnE4iez/N7tB4=";
  };

  bindings = {
    "aarch64-darwin" = {
      platform = "darwin-arm64";
      src = fetchurl {
        url = "https://registry.npmjs.org/@oxfmt/binding-darwin-arm64/-/binding-darwin-arm64-${version}.tgz";
        hash = "sha256-MXu3dpSLC/sWMmdIwxCuN6/FC9Ock/GjzjXo1bWrPvU=";
      };
    };
    "x86_64-linux" = {
      platform = "linux-x64-gnu";
      src = fetchurl {
        url = "https://registry.npmjs.org/@oxfmt/binding-linux-x64-gnu/-/binding-linux-x64-gnu-${version}.tgz";
        hash = "sha256-rn0Pr8ciPM3DlnWPsddzewizvOTSI4ZYSRdfFZz9Fy4=";
      };
    };
  };
  binding = bindings.${stdenv.hostPlatform.system};
in stdenv.mkDerivation {
  pname = "oxfmt";
  inherit version;
  nativeBuildInputs = [ makeWrapper ];
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
