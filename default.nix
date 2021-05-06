{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { overlays = [ (import ./nix/overlay.nix) ]; }
}:

pkgs.haskellPackages.epoxy-harden
