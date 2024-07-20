// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const rl = @import("raylib");
const core = @import("zb-core");
const Color = rl.Color;
// Size of a galaxy
const boxSize: u32 = 1024 * 16;
// Amount of space objects in galaxy
const amount = 5040;
const Vec2 = core.vec2.Vec2;

var isPause = false;

pub fn main() anyerror!void {
    // Initialization
    var engine = try core.engine.Engine().init(boxSize);
    defer engine.deinit();

    //--------------------------------------------------------------------------------------
    const screenWidth = 1000;
    const screenHeight = 1000;

    rl.initWindow(screenWidth, screenHeight, "Z-body");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var player = rl.Rectangle{ .x = 400, .y = 280, .width = 40, .height = 40 };
    // const raylib_zig = rl.Color.init(247, 164, 29, 255);
    var camera = rl.Camera2D{
        .target = rl.Vector2.init(1000, 1000),
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
        if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_left)) {
            const d = rl.getMouseDelta();
            const sens = 1;
            player.x -= (d.x * sens) / camera.zoom;
            player.y -= (d.y * sens) / camera.zoom;
        }
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_right)) {
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);

            const x = pos.x;
            const y = pos.y;

            if (x > 0 and y > 0) {
                try engine.addBody(core.Body{ .mass = 10, .position = .{ .x = @intFromFloat(x), .y = @intFromFloat(y) }, .velocity = .{} });
            }
        }
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_middle)) {
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);

            const x = pos.x;
            const y = pos.y;

            if (x > 0 and y > 0) {
                try engine.addBody(core.Body{ .mass = 100, .position = .{ .x = @intFromFloat(x), .y = @intFromFloat(y) }, .velocity = .{} });
            }
        }
        // Camera zoom controls
        camera.zoom += rl.getMouseWheelMove() * 0.09;
        camera.zoom = rl.math.clamp(camera.zoom, 0.1, 19.0);

        // Player movement
        if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
            player.x += 9;
        } else if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
            player.x -= 9;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_space)) {
            isPause = !isPause;
        } // Camera target follows player
        camera.target = rl.Vector2.init(player.x, player.y);
        camera.target.x = rl.math.clamp(camera.target.x, 500, 20000);
        camera.target.y = rl.math.clamp(camera.target.y, 500, 20000);
        camera.begin();

        defer camera.end();

        if (!isPause) {
            std.debug.print("STEEEPPPPEPEPSSPPSPS\n", .{});
            try engine.step(0.05);
        }

        for (engine.bodies.items, 0..) |body, i| {
            if (i == 0) {
                drawPlanet(body.position.x, body.position.y, 10, Color.red);
            } else {
                drawPlanet(body.position.x, body.position.y, 10, Color.gold);
            }
        }
        // try engine.showBounds(drawBound);

        for (0..amount) |i| {
            _ = i; // autofix
            // randomPlanet(i);
            // rl.drawCircle(@intCast(i), 100, 100, Color.white);
        }
    }
}

fn drawBound(position: Vec2, size: u32) void {
    // Also add padding
    var padding: u32 = 4;
    if (size <= padding) {
        padding = 0;
    }
    rl.drawRectangleLines( //
        @intCast(position.x + padding), //
        @intCast(position.y + padding), //
        @intCast(size - padding * 2), //
        @intCast(size - padding * 2), //
        Color.orange);
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

fn drawPlanet(x: u32, y: u32, r: f32, col: Color) void {
    rl.drawCircle(@intCast(x), @intCast(y), r, col);
}
