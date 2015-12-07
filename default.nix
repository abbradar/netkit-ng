{ nixpkgs ? import <nixpkgs> { } }:

let
  pkgs = nixpkgs.pkgsi686Linux;

  callPackage = pkgs.newScope self;

  build = pkgs.fetchFromGitHub {
    owner = "netkit-ng";
    repo = "netkit-ng-build";
    rev = "0.1.3";
    sha256 = "1zy513i4av89j9cxjgfsqs3sc7dgjvncgl3b3lbpk6ra76h4x82h";
  };

  self = {
    core = callPackage ./core.nix { };

    kernel = callPackage ./kernel.nix {
      inherit build;
    };

    fs = callPackage ./fs.nix {
      inherit build;
    };

    netkit = callPackage ./netkit.nix { };
  };

in self
