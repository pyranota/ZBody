// -------------------------------------------------------- //
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// -------------------------------------------------------- //
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// -------------------------------------------------------- //

// ------------ Basis ------------- //
const core = @import("zb-core");
const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

// ----------- Modules ------------ //
const debug = @import("debug.zig");
const spawn = @import("spawn.zig");
const lock = @import("lock.zig");
const draw = @import("drawing.zig");
const ctrl = @import("controls.zig");
const ui = @import("ui.zig");

// Size of a galaxy
const boxSize: u32 = 256;
const rndr = @import("render.zig");

pub var engine: core.engine.Engine() = undefined;

pub fn main() anyerror!void {
    // Z-Body engine initialization
    //--------------------------------------------------------------------------------------
    engine = try core.engine.Engine().init(boxSize);
    defer engine.deinit();

    // Generating starting galaxy
    // try engine.generateGalaxy();
    try engine.addBody(.{});
    //--------------------------------------------------------------------------------------

    rl.initWindow(ctrl.screenWidth, ctrl.screenHeight, "Z-body");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(80); // Set our game to run at 80 frames-per-second

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        rl.clearBackground(rl.Color.black);

        try ctrl.handleControls();

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();

        try ctrl.simStep();

        // Camera begin
        //--------------------------------------------
        ctrl.camera.begin();

        lock.handleLock();

        try spawn.spawnBodyWithVelocity();

        try debug.handleDebugWorld();

        rndr.render();

        ctrl.camera.end();
        //--------------------------------------------

        ui.handleHUD();

        try debug.handleDebugHUD();

        rl.endDrawing();
        //----------------------------------------------------------------------------------
    }
}
