{ sources ? import ./nix/sources.nix
, nixpkgs ? sources.nixpkgs
, pkgs ? import nixpkgs { overlays = [ (import ./nix/overlay.nix) ]; }
}:

pkgs.haskellPackages.shellFor {
  packages = p: [ (import ./. { }) ];
  buildInputs = with pkgs; [
    cabal-install
    ghcid
    hlint
  ];

  # run `hoogle server --local` to get a local hoogle search engine
  # and full hackage docset for browsing
  withHoogle = true;
}
