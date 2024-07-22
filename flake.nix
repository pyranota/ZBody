{
  description = "Zig Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        nativeBuildInputs = with pkgs; [
          zig
          onefetch
        ];
        buildInputs = with pkgs; [
          raylib
            # libxcursor-dev
          xorg.libXcursor
          xorg.libX11
          xorg.libXrandr
          xorg.libXinerama
          xorg.libXi
          xorg.libX11
           mesa
          alsa-lib
          xorg.libX11.dev # adding the dev doesn't make a difference as far as I can tell
          xorg.libXft
          xorg.libXinerama
          xorg.xorgproto
          libGL
          libGLU
          binutils stdenv wget stdenv.cc raylib glfw
          xorg.libX11.dev
          openssl
          pkg-config
          pkg-config
          libGL
          xorg.libXft
          libatomic_ops
          mesa
          alsa-lib
          glibc
          wayland
          wayland-protocols
          libxkbcommon
          glfw-wayland
          glfw

          
        ];
      in {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs; 
          shellHook = ''onefetch; echo "Type Just to Run"'';
          packages = with pkgs; [
            raylib
          ];

        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "Z-body";
          src = ./.;
            packages = with pkgs; [
                rustup
                cmake
                clang
                pkg-config
                wayland
                glfw
          raylib
            # libxcursor-dev
          xorg.libXcursor
          xorg.libX11
          xorg.libXrandr
          xorg.libXinerama
          xorg.libXi
          xorg.libX11
           mesa
          alsa-lib
          xorg.libX11.dev # adding the dev doesn't make a difference as far as I can tell
          xorg.libXft
          xorg.libXinerama
          xorg.xorgproto
          libGL
          libGLU
          binutils stdenv wget stdenv.cc raylib glfw
          xorg.libX11.dev
          openssl
          pkg-config
          pkg-config
          libGL
          xorg.libXft
          libatomic_ops
          mesa
          alsa-lib
          glibc
          wayland
          wayland-protocols
          libxkbcommon
          glfw-wayland
          glfw

          
        ];

          inherit buildInputs;

            LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
              libGL
              xorg.libXrandr
              xorg.libXinerama
              xorg.libXcursor
              xorg.libXi
            ];
          LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";

          shellHook = ''onefetch; echo "ust to Run"'';
          # postPatch = ''
          #     # ln -s ${zb-core} $ZIG_GLOBAL_CACHE_DIR/p
          #     ln -s ${zb-core} $out
          # '';
          postPatch = ''
          '';

          buildPhase = ''
            mkdir -p $out/.cache/zig/p
            mkdir -p $out/.cache/zig/tmp
            cp -r ${pkgs.callPackage ./deps.nix { }}/* $out/.cache/zig/p
            ${pkgs.zig}/bin/zig build --global-cache-dir $out/.cache/zig
          '';

          installPhase = ''
            ${pkgs.zig}/bin/zig build --global-cache-dir $out/.cache/zig install --prefix $out
            rm -rf $out/.cache # remove cache
            # cp $src/zig-out/bin/Z-body $out 
            # mkdir $out/bin
            # mkdir -p $out/bin

            # touch $out/bin/zbody
          '';
        };

        # packages.default = pkgs.stdenv.mkDerivation {
        #   pname = "template";
        #   version = "0.0.0";
        #   src = ./.;

        #   nativeBuildInputs =
        #     nativeBuildInputs
        #     ++ [
        #       pkgs.zig.hook

        #       pkgs.raylib
        #     ];
        #   inherit buildInputs;
        # };
        # packages.default = pkgs.hello;
      }
    );
}
