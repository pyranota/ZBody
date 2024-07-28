const std = @import("std");
const rlz = @import("raylib-zig");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});
    // const raylib_dep = b.dependency("raylib-zig", .{ .target = target, .optimize = optimize, .linux_display_backend = .X11 });
    const raylib_dep = b.dependency("raylib-zig", .{ .target = target, .optimize = optimize });

    // const raylib = raylib_dep.module("raylib"); // main raylib module
    // const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

    // const zb_core = b.dependency("zb-core", .{
    //     .target = target,
    //     .optimize = optimize,
    // });
    // load the "speak" module from the package
    // const zb_core_module = zb_core.module("zb-core");
    if (target.query.os_tag == .emscripten) {
        const exe_lib = rlz.emcc.compileForEmscripten(b, "ZBody", "src/main.zig", target, optimize);

        exe_lib.linkLibrary(raylib_artifact);
        // exe_lib.root_module.addImport("raylib", raylib);
        // exe_lib.root_module.addImport("raygui", raygui);
        // exe_lib.root_module.addImport("zb-core", zb_core_module);

        // Note that raylib itself is not actually added to the exe_lib output file, so it also needs to be linked with emscripten.
        const link_step = try rlz.emcc.linkWithEmscripten(b, &[_]*std.Build.Step.Compile{ exe_lib, raylib_artifact });

        b.getInstallStep().dependOn(&link_step.step);
        const run_step = try rlz.emcc.emscriptenRunStep(b);
        run_step.step.dependOn(&link_step.step);
        const run_option = b.step("run", "Run ZBody");
        run_option.dependOn(&run_step.step);
        return;
    }
    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).

    const exe = b.addExecutable(.{
        .name = "Z-body",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // const ztracy = b.dependency("ztracy", .{
    //     .enable_ztracy = true,
    //     .enable_fibers = true,
    // });
    // exe.root_module.addImport("ztracy", ztracy.module("root"));

    // exe.linkLibrary(ztracy.artifact("tracy"));
    // exe.linkLibrary(raylib_artifact);

    // exe.root_module.addImport("raylib", raylib);
    // exe.root_module.addImport("raygui", raygui);
    // exe.root_module.addImport("zb-core", zb_core_module);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    //web exports are completely separate
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // exe_unit_tests.root_module.addImport("raylib", raylib);
    // exe_unit_tests.root_module.addImport("raygui", raygui);
    // exe_unit_tests.root_module.addImport("zb-core", zb_core_module);

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
