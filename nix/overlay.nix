final: prev: {
  haskellPackages = prev.haskellPackages.override {
    overrides = hFinal: hPrev: {
      dtb-parse = hFinal.callCabal2nix "dtb-parse"
        (final.fetchFromGitHub {
          owner = "blitz";
          repo = "dtb-parse";
          rev = "31316f71b4d1e80a7d84a58f363c0ed2fec0fd9d";
          sha256 = "sha256-T3oLQUKpSUmMX9CRNytNroZI35TVYp7+DSWqFdk3/nI=";
        })
        { };
      epoxy-harden = hFinal.callCabal2nix "epoxy-harden" ./.. { };
    };
  };
}
