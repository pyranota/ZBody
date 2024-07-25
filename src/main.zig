// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,''''''''''''''''''''''''''''',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,;:ccccccccccccccccccccccccccccc:;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,',:oxkxxxxxxxxxxxxxxxxxxxxdxxxxkxdl;,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,';coxkkkkkkkkkkkkkkkxolc:::::::lool;'',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,';coxkkkkkkkkkkkkxoc::::;;;;;;;::;;;:ccccc:;,,,,,,,,,,,,,,,,,,,,,,,,,,,,',;c:;,,,,,,,,,,,,,,,,,,,,
// ,,';coxkkkkkkxddddoc;;:ldxxxxxxxxoc,,d0XNNNNXX0o:,',,,,,,,,,,,,,,,,,,,,,,,',dXKxc,',,,,,,,,,,,,,,,,,
// ,,';coxkkkkkkxdool;,,,,;:::;:ldkxl;';xXWXxccdXWXk:'',,,,,,,,,,,,,,,,,,,,,,',kWNOl,',,,,,,,,,,,,,,,,,
// ,,';coxkkdllodxxoc,',,,,,',,;oxdl;'';xXNKo,'cONNO:'',,,;:cccc:;,,,,,,,;;:cclOMNkc,;cc:;,',;:cc;,,,,,
// ,,';coxkdl;,;lkxl:,',,,,,',coxxl,,'';xXWWKO0KWW0o;'';dOXNNNNNNKxc,',cx0NNNNNWMXkc,oKNXo,';xKNKl'',,,
// ,,';coxkkdoldxkdc;,',,,,,,:okdl;,',';xXWNklld0XN0c''lXWXOl:cdXWNk;,ckWNOdc:cOMNkc,:xXWOl;cKMKx:'',,,
// ,,';coxkkxxxxxkxl:,',,,',:oxxc,,,,'';xXNKl'',cxNWxc;oNWOo;'':kXM0;;xXM0c,'',xWNkc,':OWX0kkNWx:,,,,,,
// ,,';coxxl:,,;:oddl,',,,,:okdl:,,,,,';xXWXo,,;lkNWx:;oNW0d:,,lONWO;;oKMKo:;,;kWNkc,',o0NWWNN0l'',,,,,
// ,,';codl;'',,,;lxdc;,',cdxkdolllllc,;xXWN0kkOXNNOc''cONNXOkk0NNKd;';dXNX0kkkXMNkc,',;l0MMWOl;'',,,,,
// ,,';codo;'''',:lxkxo:;;cooooooooool;,lkO00000Oxc;,'',:okO0000Odc;,',;:okO00000kd:,',';kWMXo,',,,,,,,
// ,,';coxxoc:;:ldxkkkkxoc:;;,,,,,,;;:::,'',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,:OWXx:'',,,,,,,
// ,,';cokkkkkkkkkkkkkkkkkkxdollllooxxdl;'',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',ckNWk:,,,,,,,,,,
// ,,',:ldddddddddddddddddddddddddddddoc;,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,',cxkxc'',,,,,,,,,
// ,,,,,,;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,''''',,,,,,,,,,,
// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
// ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

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
