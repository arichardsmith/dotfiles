{pkgs, ...}: {
  packages = with pkgs; [
    gleam
    erlang
    rebar3
  ];
}
