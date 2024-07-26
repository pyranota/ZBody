//
// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,dxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxo,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,kkkkkkkkkkkkkkkkkkkkkkkkkkxxddxxkkkkkx,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,kkkkkkkkkkkkkkkkkkkkkdl:;,,,,,,,,;:ldd,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,kkkkkkkkkkkkkkkkkkdc,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,kkkkkkkkkkkkdxkkxc,,,lkkkkkkkkkkkkkl,,,OWWWWWWWWN0o,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cWWWk,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,kkkkkkkkkkk:,,xd,,,,,:ooooooooxkkko,,,,0MMMOOOO0WMMX;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMMMk,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,kkkkkkkkkkkkdxd,,,,,,,,,,,,,,ckkkl,,,,,0MMM;,,,,oMMMx,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,cMMMk,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,kkkkkc,,,ckkkk;,,,,,,,,,,,,,ckkkl,,,,,,0MMM;,,,;OMMMo,,,,,,;ldxxxxxdl;,,,,,,,,;ldxxxxOMMMk,,,xxxd,,,,,,oxxx:,,,,,,
// ,,,,,,kkkkk,,,,,xkkd,,,,,,,,,,,,,ckkkl,,,,,,,0MMMWWWWMMMMk,,,,,,0MMMMMMMMMMMO,,,,,:0MMMMMMMMMMMk,,,dMMMk,,,,lMMM0,,,,,,,
// ,,,,,,kkkkkxlclxkkko,,,,,,,,,,,,ckkkc,,,,,,,,0MMMolllokWMM0;,,,kMMMx:;;;:OMMMd,,,cWMMKl;;;;lMMMk,,,,0MMMl,,;WMMN;,,,,,,,
// ,,,,,,kkkkkkkkkkkkkx,,,,,,,,,,,lkkkl,,,,,,,,,0MMM;,,,,,:MMMO,,,XMMW,,,,,,;MMM0,,,XMMN,,,,,,cMMMk,,,,;NMMW:,KMMWc,,,,,,,,
// ,,,,,,kkkkoc;;;:oxkkc,,,,,,,,,lkkkl,,,,,,,,,,0MMM;,,,,,;WMMK,,,XMMW,,,,,,;MMM0,,,XMMN,,,,,,cMMMk,,,,,:WMMXkMMMo,,,,,,,,,
// ,,,,,,kkx;,,,,,,,;xkk:,,,,,,,lkkkl,,,,,,,,,,,0MMM:,,,;lXMMMc,,,kMMMx;;,;:kMMMd,,,lWMMKl;,,,lMMMk,,,,,,oMMMMMMk,,,,,,,,,,
// ,,,,,,kko,,,,,,,,,ckkkl,,,,,okkkkkkkkkkkkk,,,0MMMMMMMMMMM0c,,,,;0MMMMMMMMMMMO,,,,,cKMMMMMMMMMMMk,,,,,,,kMMMMK,,,,,,,,,,,
// ,,,,,,kkx;,,,,,,,,dkkkkxc,,;llllllllllllll,,,oxxxxxxxxdl;,,,,,,,,:oxxxxxxdo;,,,,,,,,;ldxxxxxxxxl,,,,,,,,WMMW;,,,,,,,,,,,
// ,,,,,,kkkxl:,,,;lxkkkkkkkxl:,,,,,,,,,,,,,,:c,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,kMMMo,,,,,,,,,,,,
// ,,,,,,kkkkkkkkkkkkkkkkkkkkkkkdolcccccclodkkx,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,oMMMk,,,,,,,,,,,,,
// ,,,,,,kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkx,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,:WMMK,,,,,,,,,,,,,,
// ,,,,,,ccccccccccccccccccccccccccccccccccccc:,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// .,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'
//

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
const rndr = @import("render.zig");

// ----------- Export ------------ //
pub var engine: core.engine.Engine() = undefined;

// --------- Entry point --------- //
pub fn main() anyerror!void {
    // Z-Body engine initialization
    //--------------------------------------------------------------------------------------
    engine = try core.engine.Engine().init(128);
    defer engine.deinit();

    // Generating starting galaxy
    try engine.generateGalaxy();
    //--------------------------------------------------------------------------------------

    // Window creation
    rl.initWindow(ctrl.screenWidth, ctrl.screenHeight, "Z-body");
    defer rl.closeWindow(); // Close window and OpenGL context

    // We want our simulation to be more precise
    // So we higher FPS a little bit.
    rl.setTargetFPS(80);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        rl.clearBackground(rl.Color.black);

        // Handle camera, time, threading, execution
        try ctrl.handleControls();

        // Make a step in simulation
        try ctrl.simStep();

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();

        // Camera begin
        //--------------------------------------------
        ctrl.camera.begin();

        // Lock camera to specific body
        lock.handleLock();

        // Spawn bodies with Right click
        try spawn.spawnBodyWithVelocity();

        // Show debug information withing simulation world
        try debug.handleDebugWorld();

        // Render and Draw all bodies in scene. (With culling enabled)
        rndr.render();

        ctrl.camera.end();
        //--------------------------------------------

        // UI
        ui.handleHUD();

        // Show debug information in HUD
        try debug.handleDebugHUD();

        rl.endDrawing();
        //----------------------------------------------------------------------------------
    }
}
