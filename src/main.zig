// raylib-zig (c) Nikolas Wipper 2023

// const ztracy = @import("ztracy");
const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const rl = @import("raylib");
const rg = @import("raygui");
const core = @import("zb-core");
const draw = @import("drawing.zig");
const Color = rl.Color;
// Size of a galaxy
const boxSize: u32 = 256;
// Amount of space objects in galaxy
const amount = 5040;
const Vec2 = core.vec2.Vec2;
const Vec2F = core.vec2.Vec2F;
const time = std.time;
const Instant = time.Instant;

var isPause = false;
var isDebugBounds = false;
var isDebugLoD = false;
var isMenuShown = false;
var isTargetModeOn: bool = false;
var isLocked = false;
var isPlanetBeingCreated: bool = false;
var fastMode: bool = false;
pub const screenWidth = 1000;
pub const screenHeight = 1000;
//Player input
var isDebugThreads = false;
var isMultiThreaded = true;
var playerColor = rl.Color{
    .r = 255,
    .g = 0,
    .b = 0,
    .a = 255,
};
var targetBodyId: u32 = undefined;
var targetBody: core.Body = undefined;
var playerMass: f32 = 10;
var playerRadius: f32 = 10;
var planetStartPoint = rl.Vector2{
    .x = 0,
    .y = 0,
};
pub var camera = rl.Camera2D{
    .target = rl.Vector2.init(1000, 1000),
    .offset = rl.Vector2.init(screenWidth / 2, screenHeight / 2),
    .rotation = 0,
    .zoom = 1,
};

const ally = std.heap.page_allocator;
var zoom: f32 = 1;
pub fn main() anyerror!void {
    // Initialization
    var engine = try core.engine.Engine().init(boxSize);
    defer engine.deinit();

    try engine.generateGalaxy();
    //--------------------------------------------------------------------------------------

    rl.initWindow(screenWidth, screenHeight, "Z-body");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(80); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    const boxSizeFloat: f32 = @floatFromInt(boxSize);
    var player = rl.Rectangle{ .x = boxSizeFloat / 2, .y = boxSizeFloat / 2, .width = 40, .height = 40 };

    //HUD initialization
    const menu = rl.Rectangle{
        .x = ((screenWidth / 4) * 2.2),
        .y = (screenHeight / 3), //
        .width = (screenWidth / 2), //
        .height = ((screenHeight / 2.5) * 1.5),
    };
    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        playerMass = draw.playerMass;
        playerRadius = draw.playerRadius;
        playerColor = draw.playerColor;

        // Draw
        //----------------------------------------------------------------------------------

        rl.clearBackground(rl.Color.black);

        //Mouse contrlos
        if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_left) and !isMenuShown and !isLocked) {
            const d = rl.getMouseDelta();
            const sens = 1;
            player.x -= (d.x * sens) / camera.zoom;
            player.y -= (d.y * sens) / camera.zoom;
        }
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_right)) {
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
            planetStartPoint.x = pos.x;
            planetStartPoint.y = pos.y;
            isPlanetBeingCreated = true;
        }
        if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_right)) {
            isPlanetBeingCreated = false;
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);

            const c: u32 = @bitCast(rl.colorToInt(playerColor));
            const x = pos.x;
            const y = pos.y;
            if (x == planetStartPoint.x and y == planetStartPoint.y) {
                try engine.addBody(core.Body{
                    .mass = (playerMass),
                    .position = .{ //
                        planetStartPoint.x, planetStartPoint.y,
                    },
                    .velocity = @splat(0),
                    .radius = (playerRadius),
                    .color = c,
                });
            } else try engine.addBody(core.Body{ //
                .mass = (playerMass),
                .position = .{ //
                    planetStartPoint.x, planetStartPoint.y,
                },
                .velocity = .{ //
                    -((x - planetStartPoint.x) / 1000), -((y - planetStartPoint.y) / 1000),
                },
                .radius = (playerRadius),
                .color = c,
            });
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_f))
            fastMode = true
        else
            fastMode = false;

        // Camera zoom controls
        zoom += rl.getMouseWheelMove() * 0.19 * zoom;
        zoom = rl.math.clamp(zoom, 1e-4, 19.0);

        camera.zoom = rl.math.lerp(camera.zoom, zoom, 0.16);

        // Player movement arrow keys
        if (!isLocked) {
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
        }

        const move_amount = try engine.fitBodies();

        if (move_amount != 0) {
            const x: f32 = @floatFromInt(move_amount);
            const y: f32 = @floatFromInt(move_amount);
            planetStartPoint.x += @floatFromInt(move_amount);
            planetStartPoint.y += @floatFromInt(move_amount);
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

        if (isTargetModeOn) {
            for (engine.bodies.items) |body| {
                const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
                const bodyVec = rl.Vector2{ .x = body.position[0], .y = body.position[1] };
                if (isDebugBounds) {
                    rl.drawCircle(@intFromFloat(pos.x), @intFromFloat(pos.y), 10, Color.white);
                    rl.drawCircle(@intFromFloat(bodyVec.x), @intFromFloat(bodyVec.y), body.radius * 1.25, Color.white);
                }
                if (rl.checkCollisionPointCircle(pos, bodyVec, body.radius * 1.25) and rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left) and !isLocked and isPause) {
                    isLocked = true;
                    targetBodyId = body.id;
                    // std.debug.print("\n{}", .{body.id});
                }
                if (isLocked and targetBodyId == body.id) {
                    targetBody = body;
                    player.x = rl.math.lerp(player.x, targetBody.position[0], 0.4);
                    player.y = rl.math.lerp(player.y, targetBody.position[1], 0.4);
                }
            }
        }

        if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_right)) {
            rl.drawCircleV(planetStartPoint, (playerRadius), playerColor);
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
            rl.drawLineEx(planetStartPoint, pos, 10, Color.red);
        }

        // const start = try Instant.now();
        for (engine.bodies.items) |body| {
            var col = body.color;
            if (isDebugThreads) {
                var rnd = RndGen.init(body.assigned_thread);
                col = rnd.random().int(u32) | 0xff;
            }

            const body_p = rl.Vector2.init(body.position[0], body.position[1]);
            const scr_coords = rl.getWorldToScreen2D(body_p, camera);

            if (scr_coords.x > 980 or scr_coords.y > 980 or scr_coords.y < 20 or scr_coords.x < 20)
                continue;
            draw.drawPlanet(body.position[0], body.position[1], 10, col);
        }

        // const end = try Instant.now();
        // const elapsed1: f64 = @floatFromInt(end.since(start));
        // // std.debug.print("Time to draw: {d:.3}ms\n", .{
        //     elapsed1 / time.ns_per_ms,
        // });

        if (isDebugLoD)
            if (engine.bodies.items.len > 0) {
                const p = engine.bodies.items[0].position;
                try engine.showForceBounds(p, draw.drawBoundForceAndCoM);
            };

        if (isDebugBounds)
            try engine.showBounds(draw.drawBound);

        for (0..amount) |i| {
            _ = i; // autofix
        }

        camera.end();
        //HUD

        rl.beginDrawing();
        // const shader: rl.Shader = rl.loadShader(null, @constCast("./src/bloom.fs"));
        // rl.beginShaderMode(shader);

        rl.drawFPS(10, 10);

        //Body count
        // const string = try std.fmt.allocPrint(
        //     ally,
        //     "Astral bodies in scene: {}",
        //     .{engine.bodies.items.len},
        // );
        // defer ally.free(string);
        // rl.drawText(@ptrCast(string), 3, 40, 20, Color.dark_green);

        // Key listeners
        if (rl.isKeyPressed(rl.KeyboardKey.key_space))
            isPause = !isPause;

        if (rl.isKeyPressed(rl.KeyboardKey.key_h))
            isMenuShown = !isMenuShown;

        if (rl.isKeyPressed(rl.KeyboardKey.key_m))
            if (isMultiThreaded) {
                isMultiThreaded = false;
                engine.fixThreadAmount(1);
            } else {
                isMultiThreaded = true;
                try engine.unfixThreadAmount();
            };

        if (rl.isKeyPressed(rl.KeyboardKey.key_o)) {
            isDebugLoD = !isDebugLoD;
            isDebugBounds = false;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_d)) {
            isDebugBounds = !isDebugBounds;
            isDebugLoD = false;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_l)) {
            if (isPause) {
                if (isTargetModeOn) isLocked = false;
                isTargetModeOn = !isTargetModeOn;
            }
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_k))
            isDebugThreads = !isDebugThreads;

        // Go to center of mass
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

        const threshold_string = try std.fmt.allocPrint(
            ally,
            "Threads used: {d}",
            .{engine.thread_amount},
        );
        defer ally.free(threshold_string);
        rl.drawText(@ptrCast(threshold_string), 3, 60, 20, Color.green);

        const cpos_string = try std.fmt.allocPrint(
            ally,
            "Camera position: {?}",
            .{camera.target},
        );
        defer ally.free(cpos_string);
        rl.drawText(@ptrCast(cpos_string), 3, 100, 20, Color.green);
        // var val: i32 = 15;
        // _ = rg.guiSpinner(rl.Rectangle{ .x = 0, .y = 0, .width = 100, .height = 100 }, "Spinner", &val, 0, 50, true);

        // Camera target follows player
        // camera.target.x = rl.math.lerp(camera.target.x, final_cam_pos.x, 0.2);
        // camera.target.y = rl.math.lerp(camera.target.y, final_cam_pos.y, 0.2);
        camera.target.x = final_cam_pos.x;
        camera.target.y = final_cam_pos.y;
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
            if (fastMode)
                try engine.step(2e1)
            else
                try engine.step(3e-2 / camera.zoom);

        // <<<<<<< HEAD
        // const drawZone = ztracy.ZoneNC(@src(), "Draw bodies Zone", 0x00_ff_ff_00);i

        // for (engine.bodies.items) |body|
        //     drawPlanet(body.position[0], body.position[1], body.radius, body.color);
        // drawZone.End();

        if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_right)) {
            rl.drawCircleV(planetStartPoint, playerRadius, playerColor);
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
            rl.drawLineEx(planetStartPoint, pos, 10, Color.red);
        }
        // if (!isPause) {
        // try engine.showBounds(drawBound);
        // =======
        // const gColor = rl.Color{ .r = playerColor.r, .g = playerColor.g, .b = playerColor.b, .a = 255 };

        // std.debug.print("Time to draw: {d:.3}ms\n", .{
        //     elapsed1 / time.ns_per_ms,
        // });
        // }

        // drawZone.End();

        // if (isDebugLoD)
        //     // >>>>>>> threading
        //     if (engine.bodies.items.len > 0) {
        //         const p = engine.bodies.items[0].position;
        //         try engine.showForceBounds(p, drawBoundForceAndCoM);
        //     };

        // if (isDebugBounds)
        //     try engine.showBounds(drawBound);

        // for (0..amount) |i| {
        //     _ = i; // autofix
        //     // randomPlanet(i);
        //     // rl.drawCircle(@intCast(i), 100, 100, Color.white);
        // }

        camera.end();

        //HUD
        rl.drawText(@ptrCast("h - hide/show hud"), 3, @intFromFloat((screenHeight) - 20), 20, Color.dark_green);

        rl.drawText(@ptrCast("space - pause "), 3, @intFromFloat((screenHeight) - 40), 20, Color.dark_green);

        rl.drawText(@ptrCast("d - debug "), 3, @intFromFloat((screenHeight) - 60), 20, Color.dark_green);

        if (isMenuShown) {
            draw.drawMenu(menu);
            draw.drawMenuText(menu);
            draw.drawColorPicker(menu, 20, 20);
            draw.drawMassInput(menu, 20, 280);
            draw.drawRadiusInput(menu, 20, 360);
        }
        rl.endDrawing();
        //HUD End
        // rl.unloadShader(shader);
    }
}
// <<<<<<< HEAD
// =======

// fn drawBound(position: Vec2, size: u32) void {
//     // Also add padding
//     var padding: u32 = 4;
//     if (size <= padding * 8) {
//         padding = 0;
//     }
//     const col = if (size == boxSize) Color.yellow else Color.yellow;
//     rl.drawRectangleLines( //
//         @intCast(position[0] + padding), //
//         @intCast(position[1] + padding), //
//         @intCast(size - padding * 2), //
//         @intCast(size - padding * 2), //
//         col);
// }

// fn drawBoundForceAndCoM(position: Vec2, size: u32, centerOfMass: ?Vec2F) void {
//     // Also add padding
//     var padding: u32 = 4;
//     if (size <= padding * 8) {
//         padding = 0;
//     }
//     const col = if (centerOfMass != null) Color.brown else Color.dark_green;
//     // std.debug.print("Is null? {?} \n", .{centerOfMass});
//     rl.drawRectangleLines( //
//         @intCast(position[0] + padding), //
//         @intCast(position[1] + padding), //
//         @intCast(size - padding * 2), //
//         @intCast(size - padding * 2), //
//         col);

//     if (centerOfMass) |p| {
//         rl.drawCircle( //
//             @intFromFloat(p[0]), //
//             @intFromFloat(p[1]), //
//             15, Color.pink);
//     }
// }

// fn randomPlanet(seed: u64) void {
//     var rnd = RndGen.init(seed);
//     // var some_random_num = rnd.random().int(i32);
//     var r = rnd.random();
//     const x = rnd.random().intRangeAtMost(i32, -boxSize, boxSize);
//     const y = rnd.random().intRangeAtMost(i32, -boxSize, boxSize);
//     const radius = r.float(f32) * 10;
//     const c = r.int(u32);
//     drawPlanet(x, y, radius, Color.fromInt(c).alpha(1.0));
// }

// fn drawPlanet(x: f32, y: f32, r: f32, col: u32) void {
//     // const pixelSize = 1.0 / @as(f32, @floatFromInt(@max(rl.getScreenWidth(), rl.getScreenHeight())));
//     const min_radius = 1 / camera.zoom;
//     // const min_radius = if (pixelSize > 0) pixelSize else 1.0 / zoom;

//     // Use the maximum of the original radius and the minimum radius
//     const effectiveRadius = @max(r, min_radius);
//     const color = rl.Color.fromInt(col);
//     rl.drawCircle(@intFromFloat(x), @intFromFloat(y), effectiveRadius, color);
//     // rl.drawPixel(@intFromFloat(x), @intFromFloat(y), color);
// }

// //HUD DRAW
// fn drawMenu(rec: rl.Rectangle) void {
//     rl.drawRectangleRec( //
//         rec, Color.black);

//     rl.drawRectangleLinesEx( //
//         rec, 4, Color.dark_green);
// }
// //HUD USERINPUT
// fn drawColorPicker(rec: rl.Rectangle, x: f32, y: f32) void {
//     const PcikerRec = rl.Rectangle{
//         .x = (rec.x) + x,
//         .y = (rec.y) + y,
//         .width = 240,
//         .height = 240,
//     };
//     _ = rg.guiColorPicker(
//         PcikerRec,
//         "",
//         &playerColor,
//     );
// }

// fn drawMassInput(rec: rl.Rectangle, x: f32, y: f32) void {
//     const MassInputRec = rl.Rectangle{
//         .x = (rec.x) + x,
//         .y = (rec.y) + y,
//         .width = 240,
//         .height = 60,
//     };

//     _ = rg.guiValueBox(MassInputRec, "", &playerMass, 1, 10000, true);
// }

// fn drawRadiusInput(rec: rl.Rectangle, x: f32, y: f32) void {
//     const MassInputRec = rl.Rectangle{
//         .x = (rec.x) + x,
//         .y = (rec.y) + y,
//         .width = 240,
//         .height = 60,
//     };

//     _ = rg.guiValueBox(MassInputRec, "", &playerRadius, 1, 10000, true);
// }

// fn drawMenuText(rec: rl.Rectangle) void {
//     rl.drawText(@ptrCast(""), @intFromFloat((rec.x)), @intFromFloat(rec.y), 20, Color.dark_green);
// }
// >>>>>>> galaxy-gen
