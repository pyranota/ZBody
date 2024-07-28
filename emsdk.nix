{ linkFarm, fetchFromGitHub, fetchTarball }:

linkFarm "emsdk" [

  {
    name = "emsdk";
    path = fetchFromGitHub {
      owner = "emscripten-core";
      repo = "emsdk";
      rev = "cc7ef523f6a0582ef4df574667030fb399a1648b";
      hash = "sha256-/xuj+RgOqb3T8eDYTe8DpyJijrnLCrc6J3VvHVlwqxI=";
    };
  }

  {
    name = "emsdk/node/18.20.3_64bit";
    path = fetchTarball {
      url = "https://storage.googleapis.com/webassembly/emscripten-releases-builds/deps/node-v18.20.3-linux-x64.tar.xz";
      sha256 = "0jd70kj1m60c3mxvgl9miylp2i945wqspf715jc0l9snwpn8jqn3";
    };
  }

  {
    name = "emsdk/upstream";
    path = fetchTarball {
      url = "https://storage.googleapis.com/webassembly/emscripten-releases-builds/linux/fd61bacaf40131f74987e649a135f1dd559aff60/wasm-binaries.tar.xz";
      sha256 = "0l0y3q1khcc7i8jv4zjard5rbf8ghls5j68f9q1w4bn29cjv77hy";
    };
  }
]
