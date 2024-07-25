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

const ally = std.heap.page_allocator;
var zoom: f32 = 1;
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

    const boxSizeFloat: f32 = @floatFromInt(boxSize);
    var player = rl.Rectangle{ .x = boxSizeFloat / 2, .y = boxSizeFloat / 2, .width = 40, .height = 40 };

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
        playerMass = draw.playerMass;
        playerRadius = draw.playerRadius;
        playerColor = draw.playerColor;

        // Draw
        //----------------------------------------------------------------------------------

        const buffer: rl.RenderTexture2D = rl.loadRenderTexture(screenWidth, screenHeight);

        rl.beginTextureMode(buffer);

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
                try engine.addBody(core.Body{ .mass = (playerMass), .position = .{ planetStartPoint.x, planetStartPoint.y }, .velocity = @splat(0), .radius = (playerRadius), .color = c });
            } else try engine.addBody(core.Body{ .mass = (playerMass), .position = .{ planetStartPoint.x, planetStartPoint.y }, .velocity = .{ -((x - planetStartPoint.x) / 1000), -((y - planetStartPoint.y) / 1000) }, .radius = (playerRadius), .color = c });
        }

        // Camera zoom controls
        zoom += rl.getMouseWheelMove() * 0.19 * zoom;
        zoom = rl.math.clamp(zoom, 0.002, 19.0);

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

        if (!isPause)
            try engine.step(0.05);

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
                    std.debug.print("\n{}", .{body.id});
                }
                if (isLocked and targetBodyId == body.id) {
                    targetBody = body;
                    player.x = rl.math.lerp(player.x, targetBody.position[0], 0.4);
                    player.y = rl.math.lerp(player.y, targetBody.position[1], 0.4);
                }
            }
        }

        for (engine.bodies.items) |body|
            draw.drawPlanet(body.position[0], body.position[1], body.radius, body.color);

        if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_right)) {
            rl.drawCircleV(planetStartPoint, (playerRadius), playerColor);
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera);
            rl.drawLineEx(planetStartPoint, pos, 10, Color.red);
        }

        const start = try Instant.now();
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

        const end = try Instant.now();
        const elapsed1: f64 = @floatFromInt(end.since(start));
        std.debug.print("Time to draw: {d:.3}ms\n", .{
            elapsed1 / time.ns_per_ms,
        });

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
        rl.endTextureMode();

        rl.beginDrawing();
        // const shader: rl.Shader = rl.loadShader(null, @constCast("./src/bloom.fs"));
        // rl.beginShaderMode(shader);

        const hrec: rl.Rectangle = rl.Rectangle{ .x = 0, .y = screenHeight, .width = screenWidth, .height = -screenHeight };
        const hrrec: rl.Rectangle = rl.Rectangle{ .x = 0, .y = 0, .width = screenWidth, .height = screenHeight };
        const hvec: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 };
        rl.drawTexturePro(buffer.texture, hrec, hrrec, hvec, 0, Color.white);
        // rl.endShaderMode();

        rl.drawFPS(10, 10);

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
        rl.unloadRenderTexture(buffer);
        // rl.unloadShader(shader);
    }
}
