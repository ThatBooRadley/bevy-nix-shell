{
  description = "Bevy dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };

  outputs = { self, nixpkgs, fenix, ... }:
    let pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in {
      devShells."x86_64-linux".default = pkgs.mkShell {
        buildInputs = [
          (with fenix.packages."x86_64-linux";
            with stable;
            combine [
              rustc
              cargo
              llvm-tools-preview
              targets.x86_64-unknown-linux-gnu.stable.rust-std
              rust-analyzer
              clippy
            ])
          pkgs.pkg-config
          pkgs.alsa-lib
          pkgs.udev
          pkgs.xorg.libXcursor
          pkgs.xorg.libXi
          pkgs.xorg.libXrandr
          pkgs.xorg.libX11
          pkgs.vulkan-loader
          pkgs.libxkbcommon
          pkgs.mold
        ];

        #make sure to add specific target in .cargo/config.toml
        RUSTFLAGS = [
          "-Clink-arg=-fuse-ld=${pkgs.mold}/bin/mold"
          "-Clink-arg=-fuse-ld=lld"
        ];

        shellHook = ''
          export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${
            pkgs.lib.makeLibraryPath [
              pkgs.udev
              pkgs.alsa-lib
              pkgs.vulkan-loader
              pkgs.libxkbcommon
            ]
          }"
          nu'';
      };
    };
}

