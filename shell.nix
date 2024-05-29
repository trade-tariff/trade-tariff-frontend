with (import <nixpkgs> {});
let
  stdenv = pkgs.stdenv;
  gems = bundlerEnv {
    name = "trade-tariff-frontend";
    ruby = ruby_3_2;
    gemdir = ./.;
    dependencies = attrs.dependencies ++ ["mini_portile2"];
  };
in stdenv.mkDerivation {
  LD_LIBRARY_PATH="${stdenv.cc.cc.lib}/lib/";
  name = "trade-tariff-frontend";
  buildInputs = [
    bundix
    libyaml
    gems
    yarn
    nodejs_21
    ruby_3_2
  ];
  shellInit = ''
    fish
  '';
}
