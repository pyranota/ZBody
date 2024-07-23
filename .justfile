# Default target
# Compile and run
default: run

# Compile and run
run: 
    nixGL zig build run

# Compile and run in release mode
run-fast: 
    nixGL zig build run --release=fast

# -target x86_64-linux
# Compile in release mode
release:
    zig build -Dtarget=x86_64-linux-gnu.2.17

release-win:
    zig build -Doptimize=ReleaseFast -Dtarget=x86_64-windows

release-osx:
    zig build -Doptimize=ReleaseFast -Dtarget=x86_64-macos -framework Cocoa

# Compile project with maven to ./target
build:
    zig build

profile: 
    cd zb-core; zig build -DenableTracy
    nixGL tracy -a 127.0.01 & zb-core/zig-out/bin/zb-bench

build-core: 
    cd zb-core; zig build

build-core-release: 
    cd zb-core; zig build --release=fast
# Benchmark zb-core
bench: build-core-release
    hyperfine zb-core/zig-out/bin/zb-bench

# Clean cache
clean:
    rm -rf zig-out
    rm -rf .zig-cache

# Run all tests in project
test:
    echo TODO
