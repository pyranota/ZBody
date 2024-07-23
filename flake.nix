{
  description = "Zig Template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
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
          # xorg.libX11
          # mesa
          # alsa-lib
          # xorg.libX11.dev # adding the dev doesn't make a difference as far as I can tell
          # xorg.libXft
          # xorg.libXinerama
          # xorg.xorgproto
          # libGL
          # libGLU
          # binutils
          # stdenv
          # wget
          # stdenv.cc
          # raylib
          # glfw
          # xorg.libX11.dev
          # openssl
          # pkg-config
          # pkg-config
          # libGL
          # xorg.libXft
          # libatomic_ops
          # mesa
          # alsa-lib
          # glibc
          # wayland
          # wayland-protocols
          # libxkbcommon
          # glfw-wayland
          # glfw
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs;
          shellHook = ''onefetch; echo "Type Just to Run"'';

          LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
            xorg.libX11
            xorg.libXi
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "Z-body";
          src = ./.;

          buildInputs = with pkgs; [
            wayland
            glfw
            libGL
            raylib-games
            glfw-wayland
            wayland-protocols
          ] ++ (with xorg; [
            libXrandr
            libXinerama
            libXcursor
            libXi
          ]) ++ buildInputs;

          # packages = with pkgs; [
          #   xorg.libX11
          #   xorg.libX11.dev
          #   xorg.libXi
          #   wayland
          #   glfw-wayland
          #   glfw
          #   libGL
          #   raylib-games
          #   glfw-wayland
          #   wayland-protocols
          # ];


          runtimeDependencies = with pkgs.xorg; [
            libX11
            libXi
          ];

          propagatedBuildInputs = with pkgs.xorg; [
            libX11
            libXi
          ];

          nativeBuildInputs = with pkgs; [
            xorg.libX11
            xorg.libXi
            makeWrapper
          ];

          buildPhase = ''
            mkdir -p $out/.cache/zig/p
            mkdir -p $out/.cache/zig/tmp
            cp -r ${pkgs.callPackage ./deps.nix { }}/* $out/.cache/zig/p
            ${pkgs.zig}/bin/zig build --global-cache-dir $out/.cache/zig
          '';

          # dontUnpack = true; # don't unpack the dependencies
          LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
            xorg.libX11
            xorg.libXi
          ];
          installPhase = ''
            ${pkgs.zig}/bin/zig build --global-cache-dir $out/.cache/zig install --prefix $out
            rm -rf $out/.cache # remove cache
            # wrapProgram $out/bin/Z-body --set LD_LIBRARY_PATH ${pkgs.lib.makeLibraryPath [ pkgs.xorg.libX11 pkgs.xorg.libXi ]}:$LD_LIBRARY_PATH
            wrapProgram $out/bin/Z-body --prefix \
            'exec ${pkgs.nix}/bin/nix shell -c "LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.xorg.libX11 pkgs.xorg.libXi ]}:$LD_LIBRARY_PATH exec $0 $@"'
            '';
        };
      }
    );
}
