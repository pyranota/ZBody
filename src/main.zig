// raylib-zig (c) Nikolas Wipper 2023

// const ztracy = @import("ztracy");
const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const rl = @import("raylib");
const rg = @import("raygui");
const core = @import("zb-core");
const draw = @import("drawing.zig");
const ctrl = @import("controls.zig");
// Size of a galaxy
const boxSize: u32 = 256;

var engine: core.engine.Engine() = undefined;

pub fn main() anyerror!void {
    // Z-Body engine initialization
    //--------------------------------------------------------------------------------------
    engine = try core.engine.Engine().init(boxSize);
    defer engine.deinit();

    // Generating starting galaxy
    // try engine.generateGalaxy();
    //--------------------------------------------------------------------------------------

    rl.initWindow(ctrl.screenWidth, ctrl.screenHeight, "Z-body");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(80); // Set our game to run at 80 frames-per-second

    //--------------------------------------------------------------------------------------

    // const boxSizeFloat: f32 = @floatFromInt(boxSize);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        // Draw
        //----------------------------------------------------------------------------------

        rl.clearBackground(rl.Color.black);

        ctrl.camera.begin();

        ctrl.camera.end();

        rl.beginDrawing();

        rl.drawFPS(10, 10);

        // Key listeners

        // Go to center of mass

        //Body count

        // camera.begin();

        if (!ctrl.isPause)
            if (ctrl.fastMode)
                try engine.step(2e1)
            else
                try engine.step(3e-2 / ctrl.camera.zoom);

        // camera.end();

        //HUD
        rl.endDrawing();
    }
}
