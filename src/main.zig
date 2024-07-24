// raylib-zig (c) Nikolas Wipper 2023

// const ztracy = @import("ztracy");
const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const rl = @import("raylib");
const rg = @import("raygui");
const core = @import("zb-core");
const Color = rl.Color;
// Size of a galaxy
const boxSize: u32 = 256;
// Amount of space objects in galaxy
const amount = 5040;
const Vec2 = core.vec2.Vec2;
const Vec2F = core.vec2.Vec2F;

var isPause = false;
var isDebug = false;
var isMenuShown = false;

//RGB

var color = rl.Color{
    .r = 255,
    .g = 0,
    .b = 0,
    .a = 0,
};

const ally = std.heap.page_allocator;
var zoom: f32 = 1;

pub fn main() anyerror!void {
    // const tracy_zone = ztracy.ZoneNC(@src(), "Compute Magic", 0x00_ff_00_00);
    // defer tracy_zone.End();
    // rg.guiColorPicker(, , )
    // Initialization
    var engine = try core.engine.Engine().init(boxSize);
    defer engine.deinit();
    // for (0..50) |x| {
    //     for (0..50) |y| {
    //         const p: Vec2F = .{ @floatFromInt(boxSize / 2 + x * 150), @floatFromInt(boxSize / 2 + y * 150) };
    //         try engine.addBody(.{ .mass = 40, .position = p, .velocity = @splat(0) });
    //     }
    // }

    //--------------------------------------------------------------------------------------
    const screenWidth = 1000;
    const screenHeight = 1000;

    rl.initWindow(screenWidth, screenHeight, "Z-body");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    const boxSizeFloat: f32 = @floatFromInt(boxSize);
    var player = rl.Rectangle{ .x = boxSizeFloat / 2, .y = boxSizeFloat / 2, .width = 40, .height = 40 };
    // const raylib_zig = rl.Color.init(247, 164, 29, 255);
    var camera = rl.Camera2D{
        .target = rl.Vector2.init(1000, 1000),
        .offset = rl.Vector2.init(screenWidth / 2, screenHeight / 2),
        .rotation = 0,
        .zoom = 1,
    };
    //HUD initialization
    const menu = rl.Rectangle{
        .x = ((screenWidth / 4) * 2.2),
        .y = (screenHeight / 3), //
        .width = (screenWidth / 2), //
        .height = ((screenHeight / 2.5) * 1.5),
    };
    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawFPS(10, 10);

        //Mouse contrlos
        if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_left) and !isMenuShown) {
            const d = rl.getMouseDelta();
            const sens = 1;
            player.x -= (d.x * sens) / camera.zoom;
            player.y -= (d.y * sens) / camera.zoom;
        }
        if ((rl.isMouseButtonPressed(rl.MouseButton.mouse_button_right) or rl.isKeyDown(rl.KeyboardKey.key_s)) and !isMenuShown) {
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);

            const x = pos.x;
            const y = pos.y;

            // if (x > 0 and y > 0) {
            try engine.addBody(core.Body{ .mass = 10, .position = .{ x, y }, .velocity = @splat(0) });
            // }
        }
        // Camera zoom controls
        zoom += rl.getMouseWheelMove() * 0.19 * zoom;
        zoom = rl.math.clamp(zoom, 0.002, 19.0);

        camera.zoom = rl.math.lerp(camera.zoom, zoom, 0.16);
        // camera.zoom = zoom;
        // Player movement arrow keys

        if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
            player.x += 9;
        } else if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
            player.x -= 9;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
            player.y -= 9;
        } else if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
            player.y += 9;
        }

        // Key listeners
        if (rl.isKeyPressed(rl.KeyboardKey.key_space)) {
            isPause = !isPause;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_h)) {
            isMenuShown = !isMenuShown;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_d)) {
            isDebug = !isDebug;
        }
        // Go to center of mas
        if (rl.isKeyPressed(rl.KeyboardKey.key_c))
            if (engine.getCenterOfMass()) |p| {
                player.x = p[0];
                player.y = p[1];
                zoom = 1;
            };

        //Body count
        const string = try std.fmt.allocPrint(
            ally,
            "Astral bodies in scene: {}",
            .{engine.bodies.items.len},
        );
        defer ally.free(string);
        rl.drawText(@ptrCast(string), 3, 40, 20, Color.dark_green);
        // var val: i32 = 15;
        // _ = rg.guiSpinner(rl.Rectangle{ .x = 0, .y = 0, .width = 100, .height = 100 }, "Spinner", &val, 0, 50, true);

        const move_amount = try engine.fitBodies();

        if (move_amount != 0) {
            const x: f32 = @floatFromInt(move_amount);
            const y: f32 = @floatFromInt(move_amount);

            player.x += x;
            player.y += y;
            camera.target.x += x;
            camera.target.y += y;
        }

        // Camera target follows player
        const final_cam_pos = rl.Vector2.init(player.x, player.y);
        camera.target.x = rl.math.lerp(camera.target.x, final_cam_pos.x, 0.2);
        camera.target.y = rl.math.lerp(camera.target.y, final_cam_pos.y, 0.2);
        // camera.target.x = rl.math.clamp(camera.target.x, 500, 20000);
        // camera.target.y = rl.math.clamp(camera.target.y, 500, 20000);

        camera.begin();

        // if (engine.bodies.items.len > 2) {
        //     // const p = engine.bodies.items[0].position;
        //     // camera.target = rl.Vector2.init(@floatFromInt(p.x), @floatFromInt(p.y));
        //     const com = engine.tree.root.?.branch.centerOfMass;
        //     std.debug.print("Center of mass: X: {d}, Y: {d}\n\n", .{ com.x, com.y });
        // }
        // // camera.target.x = rl.math.clamp(camera.target.x, 500, 20000);
        // // camera.target.y = rl.math.clamp(camera.target.y, 500, 20000);
        // if (engine.bodies.items.len > 2) {
        //     const com = engine.tree.root.?.branch.centerOfMass;
        //     std.debug.print("Center of mass: X: {d}, Y: {d}\n\n", .{ com.x, com.y });
        //     rl.drawCircle(@intFromFloat(com.x), @intFromFloat(com.y), 50, Color.pink);
        // }

        if (!isPause)
            try engine.step(0.05);

        const gColor = rl.Color{ .r = color.r, .g = color.g, .b = color.b, .a = 255 };

        // const drawZone = ztracy.ZoneNC(@src(), "Draw bodies Zone", 0x00_ff_ff_00);
        for (engine.bodies.items) |body|
            drawPlanet(body.position[0], body.position[1], 10, gColor);

        // drawZone.End();

        if (isDebug) {
            // try engine.showBounds(drawBound);
            if (engine.bodies.items.len > 0) {
                const p = engine.bodies.items[0].position;
                try engine.showForceBounds(p, drawBoundForceAndCoM);
            }
        }

        for (0..amount) |i| {
            _ = i; // autofix
            // randomPlanet(i);
            // rl.drawCircle(@intCast(i), 100, 100, Color.white);
        }

        camera.end();

        //HUD
        rl.drawText(@ptrCast("h - hide/show hud"), 3, @intFromFloat((screenHeight) - 20), 20, Color.dark_green);

        rl.drawText(@ptrCast("space - pause "), 3, @intFromFloat((screenHeight) - 40), 20, Color.dark_green);

        rl.drawText(@ptrCast("d - debug "), 3, @intFromFloat((screenHeight) - 60), 20, Color.dark_green);

        if (isMenuShown) {
            // std.debug.print("Yes", .{});
            drawMenu(menu);
            drawMenuText(menu);
            drawColorPicker(menu, 20, 20);
            std.debug.print("\n{}", .{color});
        }
        //HUD End
    }
}

fn drawBound(position: Vec2, size: u32) void {
    // Also add padding
    var padding: u32 = 4;
    if (size <= padding * 8) {
        padding = 0;
    }
    const col = if (size == boxSize) Color.dark_green else Color.yellow;
    rl.drawRectangleLines( //
        @intCast(position[0] + padding), //
        @intCast(position[1] + padding), //
        @intCast(size - padding * 2), //
        @intCast(size - padding * 2), //
        col);
}

fn drawBoundForceAndCoM(position: Vec2, size: u32, centerOfMass: ?Vec2F) void {
    // Also add padding
    var padding: u32 = 4;
    if (size <= padding * 8) {
        padding = 0;
    }
    const col = if (centerOfMass != null) Color.brown else Color.dark_green;
    // std.debug.print("Is null? {?} \n", .{centerOfMass});
    rl.drawRectangleLines( //
        @intCast(position[0] + padding), //
        @intCast(position[1] + padding), //
        @intCast(size - padding * 2), //
        @intCast(size - padding * 2), //
        col);

    if (centerOfMass) |p| {
        rl.drawCircle( //
            @intFromFloat(p[0]), //
            @intFromFloat(p[1]), //
            15, Color.pink);
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

fn drawPlanet(x: f32, y: f32, r: f32, col: Color) void {
    rl.drawCircle(@intFromFloat(x), @intFromFloat(y), r, col);
}

//HUD DRAW
fn drawMenu(rec: rl.Rectangle) void {
    rl.drawRectangleRec( //
        rec, Color.black);

    rl.drawRectangleLinesEx( //
        rec, 4, Color.dark_green);
}
//SLIDERS
fn drawColorPicker(rec: rl.Rectangle, x: f32, y: f32) void {
    const PcikerRec = rl.Rectangle{
        .x = (rec.x) + x,
        .y = (rec.y) + y,
        .width = 240,
        .height = 240,
    };
    _ = rg.guiColorPicker(
        PcikerRec,
        "",
        &color,
    );
}

fn drawMenuText(rec: rl.Rectangle) void {
    rl.drawText(@ptrCast(""), @intFromFloat((rec.x)), @intFromFloat(rec.y), 20, Color.dark_green);
}
