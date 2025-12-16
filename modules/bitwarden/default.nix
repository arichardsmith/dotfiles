{
  config,
  lib,
  ...
}: {
  config = {
    # rbw is an unofficial client, but the implementation sounds better than the official one and sidesteps perl requirements
    # https://github.com/doy/rbw

    programs.rbw = {
    };

    # The file produced by rbw.settings is invalid if we don't set pinentry, and the pinentry package doesn't work on Darwin!
    # We have to resort to manually setting the config like cavemen.

    home.file."Library/Application Support/rbw/config.json" = lib.mkForce {
      text = builtins.toJSON {
        email = config.user.email;
      };
    };
  };
}
