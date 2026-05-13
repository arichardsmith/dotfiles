{lib}: toolchains:
lib.mkMerge (lib.mapAttrsToList (
    name: toolchain:
      if toolchain ? home && toolchain.home ? packages
      then throw "applyDevToolchains: toolchain `${name}` defines `home.packages`. Use `packages = [...]` instead."
      else {
        programs = toolchain.programs or {};
        customPrograms = toolchain.customPrograms or {};
        home = lib.mkMerge [
          (toolchain.home or {})
          {packages = toolchain.packages or [];}
        ];
      }
  )
  toolchains)
