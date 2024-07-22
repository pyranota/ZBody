{ linkFarm, fetchzip }:

linkFarm "zig-packages" [
 # Raylib
  {
    name = "1220361ce363a465c3f52e7e35ca5f1d9c2f5ed8a9207b79c2edb4396cdf31009c48";
    path = fetchzip {
      url = "https://github.com/Not-Nik/raylib-zig/archive/devel.tar.gz";
      hash = "sha256-Ubpwp6cXKqBJ6LT3kvPWmFuT3x0nDXxL8UDx5IUrYNc=";
    };
  }

  # Dependencies of Raylib
  {
    name = "1220aa75240ee6459499456ef520ab7e8bddffaed8a5055441da457b198fc4e92b26";
    path = fetchzip {
      url = "https://github.com/raysan5/raylib/archive/5767c4cd059e07355ae5588966d0aee97038a86b.tar.gz";
      hash = "sha256-2wKecOJqtM207JIK7ZxhtpXkNa7LnFN86eHRWyfRjlg=";
    };
  }

  {
    name = "122002d98ca255ec706ef8e5497b3723d6c6e163511761d116dac3aee87747d46cf1";
    path = fetchzip {
      url = "https://github.com/raysan5/raygui/archive/4b3d94f5df6a5a2aa86286350f7e20c0ca35f516.tar.gz";
      hash = "sha256-+UVvUOp+6PpnoWy81ZCqD8BR6sxZJhtQNYQfbv6SOy0=";
    };
  }

  # Pretty
  {
    name = "1220309f083656d3e9b487a4c0f79f514b0fbc682dba717c294fb02ec2bfd7080850";
    path = fetchzip {
      url = "https://github.com/timfayz/pretty/archive/main.tar.gz";
      # hash = "sha256-Quno72sDgNODfSAQHN88HsC9Dd37YX341/eIWQyvf0g=";
      hash = "sha256-Y/XDNvjBxT5odP4Gtf/NRwAwWNJnVoffCajQgPGGTQ8=";
    };
  }

  # ZTracy
  {
    name = "1220d02ebfd349a43c7ddf450bc0f548339b502aa4d77dc37e8bf5d6fc8f1b7f871e";
    path = fetchzip {
    url = "https://github.com/7R35C0/ztracy/archive/main.tar.gz";
    hash = "sha256-Quno72sDgNODfSAQHN88HsC9Dd37YX341/eIWQyvf0g=";
    };
  }

  # Dependency for ZTracy
  {
    name = "1220bd21394b50683441ebc101d7d7ac9178d93693b37a34a9124c0024b8d068f8a1";
    path = fetchzip {
    # url = "https://github.com/7R35C0/ztracy/archive/main.tar.gz";
    url = "https://github.com/7R35C0/system-sdk/releases/download/system-sdk-0.1.1/system-sdk-0.1.1.tar.gz";
    hash = "sha256-rn+hP+58rnYJlIKnwfkkjkuKsreTJ+Gr9W2BuRlV1IU=";
    };
  }
        #   .system_sdk = .{
        #     .url = "https://github.com/7R35C0/system-sdk/releases/download/system-sdk-0.1.1/system-sdk-0.1.1.tar.gz",
        #     .hash = "1220bd21394b50683441ebc101d7d7ac9178d93693b37a34a9124c0024b8d068f8a1",
        #     //    .path = "foo",
        #     //    .lazy = false,
        # },
        # .pretty = .{
        #     .url = "https://github.com/timfayz/pretty/archive/main.tar.gz",
        #     .hash = "1220309f083656d3e9b487a4c0f79f514b0fbc682dba717c294fb02ec2bfd7080850",
        # },
        # .ztracy = .{
        #     .url = "https://github.com/7R35C0/ztracy/archive/main.tar.gz",
        #     .hash = "1220d02ebfd349a43c7ddf450bc0f548339b502aa4d77dc37e8bf5d6fc8f1b7f871e",
        # },
        #   raylib = .{
        #     .url = "https://github.com/raysan5/raylib/archive/5767c4cd059e07355ae5588966d0aee97038a86b.tar.gz",
        #     .hash = "1220aa75240ee6459499456ef520ab7e8bddffaed8a5055441da457b198fc4e92b26",
        # },
        # .raygui = .{
        #     .url = "https://github.com/raysan5/raygui/archive/4b3d94f5df6a5a2aa86286350f7e20c0ca35f516.tar.gz",
        #     .hash = "122002d98ca255ec706ef8e5497b3723d6c6e163511761d116dac3aee87747d46cf1",
        # }
]
