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

        # emsdk = (import ./emsdk.nix) {
        #   fetchTarball = fetchTarball;
        #   fetchFromGitHub = pkgs.fetchFromGitHub;
        #   linkFarm = pkgs.linkFarm;
        # };

        wasm_binaries = fetchTarball {
          url = "https://storage.googleapis.com/webassembly/emscripten-releases-builds/linux/fd61bacaf40131f74987e649a135f1dd559aff60/wasm-binaries.tar.xz";
          sha256 = "0l0y3q1khcc7i8jv4zjard5rbf8ghls5j68f9q1w4bn29cjv77hy";
        };

        buildInputs = with pkgs; [
          zig
          onefetch
          raylib
          zsh
          hyperfine
          just
          #
          mesa
          alsa-lib
          libGL
          libGLU
          binutils
          stdenv
          stdenv.cc
          glfw
          openssl
          pkg-config
          libatomic_ops
          mesa
          glibc
          wayland
          wayland-protocols
          libxkbcommon
          glfw-wayland
        ] ++ (with xorg;[
          libXcursor
          libX11
          libXrandr
          libXinerama
          libXi
          # Not needed???
          libXft
        ]);


      in
      {
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          packages = with pkgs; [
            tracy
            zig_0_12
            python3

          ];

          LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
            xorg.libX11
            xorg.libXi
          ];


          # emsdk = pkgs.fetchFromGitHub {
          #   owner = "emscripten-core";
          #   repo = "emsdk";
          #   rev = "cc7ef523f6a0582ef4df574667030fb399a1648b";
          #   hash = "sha256-/xuj+RgOqb3T8eDYTe8DpyJijrnLCrc6J3VvHVlwqxI=";
          # };

          # node = fetchTarball {
          #   url = "https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v18.20.3-linux-x64.tar.xz";
          #   sha256 = "0jd70kj1m60c3mxvgl9miylp2i945wqspf715jc0l9snwpn8jqn3";
          # };


          shellHook = ''
                        # mkdir -p emsdk
                        # cp -r $emsdk/* emsdk

                        # mkdir -p emsdk/node
                        # mkdir -p emsdk/node/18.20.3_64bit
                        # cp -r $node/* emsdk/node/18.20.3_64bit

                        # echo "node-18.20.3-64bit" >> emsdk/node/18.20.3_64bit/.emsdk_version
                        # mkdir -p emsdk/upstream

                        # echo "releases-fd61bacaf40131f74987e649a135f1dd559aff60-64bit" >> emsdk/upstream/.emsdk_version
                        # cp -r $wasm_binaries/* emsdk/upstream

                        # ls emsdk/upstream
                        # ls emsdk/node
                        # ls emsdk/node/18.20.3_64bit
                        # emsdk/emsdk install 3.1.64
                        # emsdk/emsdk activate 3.1.64
                        source "${wasm_binaries}/emscripten/emsdk_env.sh"
            #             onefetch
            #             echo "Type Just for Magic"
            #             zsh
          
          '';
        };

        packages.wasm = pkgs.stdenv.mkDerivation {
          name = "zbody-wasm";
          src = ./.;

          buildInputs = with pkgs; [
            python3
            # wayland
            # glfw
            # libGL
            # raylib-games
            # glfw-wayland
            # wayland-protocols
            zig
          ] ++ (with xorg; [
            # libXrandr
            # libXinerama
            # libXcursor
            # libXi
          ]);


          emsdk = pkgs.fetchFromGitHub {
            owner = "emscripten-core";
            repo = "emsdk";
            rev = "cc7ef523f6a0582ef4df574667030fb399a1648b";
            hash = "sha256-/xuj+RgOqb3T8eDYTe8DpyJijrnLCrc6J3VvHVlwqxI=";
          };

          node = fetchTarball {
            url = "https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v18.20.3-linux-x64.tar.xz";
            sha256 = "0jd70kj1m60c3mxvgl9miylp2i945wqspf715jc0l9snwpn8jqn3";
          };

          wasm_binaries = fetchTarball {
            url = "https://storage.googleapis.com/webassembly/emscripten-releases-builds/linux/fd61bacaf40131f74987e649a135f1dd559aff60/wasm-binaries.tar.xz";
            sha256 = "0l0y3q1khcc7i8jv4zjard5rbf8ghls5j68f9q1w4bn29cjv77hy";
          };


          buildPhase = ''
            mkdir -p $out/emsdk
            cp -r $emsdk/* $out/emsdk

            mkdir -p $out/emsdk/node
            mkdir -p $out/emsdk/node/18.20.3_64bit
            cp -r $node/* $out/emsdk/node/18.20.3_64bit

            echo "node-18.20.3-64bit" >> $out/emsdk/node/18.20.3_64bit/.emsdk_version
            mkdir -p $out/emsdk/upstream

            echo "releases-fd61bacaf40131f74987e649a135f1dd559aff60-64bit" >> $out/emsdk/upstream/.emsdk_version
            cp -r $wasm_binaries/* $out/emsdk/upstream

            ls $out/emsdk/upstream
            ls $out/emsdk/node
            ls $out/emsdk/node/18.20.3_64bit
            $out/emsdk/emsdk install 3.1.64
            $out/emsdk/emsdk activate 3.1.64
            source "$out/emsdk/emsdk_env.sh"

            mkdir -p $out/.cache/zig/p
            mkdir -p $out/.cache/zig/tmp
            cp -r ${pkgs.callPackage ./deps.nix { }}/* $out/.cache/zig/p
            # zig build --global-cache-dir $out/.cache/zig --release=fast -Dtarget=wasm32-emscripten --sysroot $EMSDK/emsdk/upstream/emscripten
            # cp -r zig-out/* $out/
            
            touch $out/file.txt
          '';

          installPhase = ''
            touch $out/fil.txt
            zig build install --prefix $out/zbody --global-cache-dir $out/.cache/zig --release=fast -Dtarget=wasm32-emscripten --sysroot $EMSDK/emsdk/upstream/emscripten 
            # zig build install --prefix $out/zbody --global-cache-dir $out/.cache/zig --release=fast -Dtarget=wasm32-emscripten --sysroot ${pkgs.emscripten}/share/emscripten 
            # zig build install --prefix $out/zbody --global-cache-dir $out/.cache/zig --release=fast 
            # cp -r zig-out/* $out/
          '';

        };

        packages.default = pkgs.stdenv.mkDerivation {
          name = "zbody";
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
