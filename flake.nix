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
        buildInputs = with pkgs; [
          zig
          onefetch
          raylib
          zsh
          hyperfine
          just
        ] ++ (with xorg;[
          libXcursor
          libX11
          libXrandr
          libXinerama
          libXi
        ]);

      in
      {
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          shellHook = ''onefetch; echo "Type Just to Run"; zsh'';
          packages = with pkgs; [tracy];

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
