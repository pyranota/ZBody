// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const rl = @import("raylib");
const core = @import("zb-core");
const Color = rl.Color;
// Size of a galaxy
const boxSize = 5000;
// Amount of space objects in galaxy
const amount = 5040;

pub fn main() anyerror!void {
    // Initialization
    core.Engine();
    //--------------------------------------------------------------------------------------
    const screenWidth = 1000;
    const screenHeight = 1200;

    rl.initWindow(screenWidth, screenHeight, "Z-body");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var player = rl.Rectangle{ .x = 400, .y = 280, .width = 40, .height = 40 };
    // const raylib_zig = rl.Color.init(247, 164, 29, 255);
    var camera = rl.Camera2D{
        .target = rl.Vector2.init(20, 20),
        .offset = rl.Vector2.init(screenWidth / 2, screenHeight / 2),
        .rotation = 0,
        .zoom = 1,
    };
    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawFPS(10, 10);
        // Camera zoom controls
        camera.zoom += rl.getMouseWheelMove() * 0.09;

        camera.zoom = rl.math.clamp(camera.zoom, 0.1, 19.0);
        // Player movement
        if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
            player.x += 9;
        } else if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
            player.x -= 9;
        }
        // Camera target follows player
        camera.target = rl.Vector2.init(player.x + 20, player.y + 20);
        camera.begin();

        defer camera.end();

        for (0..amount) |i| {
            randomPlanet(i);
            // rl.drawCircle(@intCast(i), 100, 100, Color.white);
        }
    }
}

fn randomPlanet(seed: u64) void {
    var rnd = RndGen.init(seed);
    // var some_random_num = rnd.random().int(i32);
    var r = rnd.random();
    const x = rnd.random().intRangeAtMost(i32, -boxSize, boxSize);
    const y = rnd.random().intRangeAtMost(i32, -boxSize, boxSize);
    const radius = r.float(f32) * 10;
    const c = r.int(u32);
    drawPlanet(x, y, radius, Color.fromInt(c).alpha(1.0));
}

fn drawPlanet(x: i32, y: i32, r: f32, col: Color) void {
    rl.drawCircle(x, y, r, col);
}
