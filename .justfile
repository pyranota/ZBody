# Default target
# Compile and run
default: run

# Compile and run
run: pull
    zig build run

# Pull dependencies to latest version
pull:
    zig fetch --save ./zb-core

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

# Clean cache
clean:
    rm -rf zig-out
    rm -rf .zig-cache

# Run all tests in project
test:
    echo TODO
