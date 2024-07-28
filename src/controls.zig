// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

//! This file is controlling time, camera movement and threading also controlls execution of program
const rl = @import("raylib");
const main = @import("main.zig");
const Vec2F = @import("zb-core").vec2.Vec2F;
const std = @import("std");

const planetStartPoint = &@import("spawn.zig").planetStartPoint;
const isLocked = &@import("lock.zig").isLocked;
const isMenuShown = &@import("ui.zig").isMenuShown;

pub const screenWidth = 1000;
pub const screenHeight = 1000;
// Camera position basically
pub var player = rl.Rectangle{ .x = 1e3, .y = 1e3, .width = 40, .height = 40 };
var zoom: f32 = 1;
var engine = &main.engine;
pub var camera = rl.Camera2D{
    .target = rl.Vector2.init(1000, 1000),
    .offset = rl.Vector2.init(screenWidth / 2, screenHeight / 2),
    .rotation = 0,
    .zoom = 1,
};

pub var isPause: bool = false;
pub var fastMode: bool = false;
var isMultiThreaded = true;

// TODO: Make readonly
pub var cameraDragForce: Vec2F = @splat(0);
pub var cameraDragVelocity: Vec2F = @splat(0);

pub fn simStep() !void {
    if (!isPause)
        if (fastMode)
            try engine.step(2e1)
        else
            // We speed up simulation if zoom is low
            // And slow down if zoom is high
            try engine.step(3e-2 / camera.zoom);
}

/// Entry point for Controls, handles everything.
/// Should be called before everything
pub fn handleControls() !void {
    // Listen for keys
    try mapKeys();

    // Autodrag
    dragCamera(3e-2);

    // Move by grabbing
    moveCameraWithMouse();
    lerpCamera();

    // Zoom
    smoothZoom();

    // Dynamically Extend
    infiniteSpace();
}

/// Auto-drag logic
fn dragCamera(delta: f32) void {
    if (isPause or engine.isEmpty()) return;

    var totalMass: Vec2F = @splat(0);
    cameraDragVelocity = @splat(0);
    for (engine.bodies.items) |body| {
        const body_p = rl.Vector2.init(body.position[0], body.position[1]);
        const scr_coords = rl.getWorldToScreen2D(body_p, camera);

        // Cull
        if (scr_coords.x > 980 or scr_coords.y > 980 or scr_coords.y < 20 or scr_coords.x < 20)
            continue;

        // Find total mass of all bodies in visible zone
        totalMass += @splat(body.mass);
        // std.debug.print("Accel in body: {?}\n", .{accel});

        // Find total force on all bodies in visible zone
        // We store only acceleration and masses of bodies
        // Lets multiply those to get force.
        // ** F = m * a **
        cameraDragVelocity += body.velocity * @as(Vec2F, @splat(body.mass));
        // cameraDragVelocity += body.velocity * ;
    }

    // We dont want to devide by zero
    //            __ < X and Y are same in mass
    if (totalMass[0] <= 0) return;

    // cameraDragVelocity /=@as(Vec2F, @splat(delta));
    cameraDragVelocity /= totalMass;

    // std.debug.print("{?}\n", .{totalMass});

    player.x += (cameraDragVelocity[0] * delta) / camera.zoom;
    player.y += (cameraDragVelocity[1] * delta) / camera.zoom;
    // std.debug.print("Mass: {?}\n Force: {?}\n Accel: {?}\n\n", .{ totalMass, cameraDragForce, cameraDragAccel });
}

fn moveCameraWithMouse() void {
    // Mouse controls
    if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_left) and !isMenuShown.* and !isLocked.*) {
        const d = rl.getMouseDelta();
        const sens = 1;
        player.x -= (d.x * sens) / camera.zoom;
        player.y -= (d.y * sens) / camera.zoom;
    }
}

/// Handles fitting all bodies in given range and extending borders.
/// Makes it *seemless*
/// By default called from `handleControls`, but can be called explicitly
pub fn infiniteSpace() void {

    // Camera zoom controls
    const move_amount = try engine.fitBodies();

    if (move_amount != 0) {
        const x: f32 = @floatFromInt(move_amount);
        const y: f32 = @floatFromInt(move_amount);

        // Also we need to modify planet start point for `spawn.zig`
        planetStartPoint.x += @floatFromInt(move_amount);
        planetStartPoint.y += @floatFromInt(move_amount);
        player.x += x;
        player.y += y;
        camera.target.x += x;
        camera.target.y += y;
    }
}

/// Apply move settings to camera
fn lerpCamera() void {
    // NOTE: Lerp is disabled for now
    // camera.target.x = final_cam_pos.x;
    // camera.target.y = final_cam_pos.y;

    const final_cam_pos = rl.Vector2.init(player.x, player.y);
    camera.target.x = rl.math.lerp(camera.target.x, final_cam_pos.x, 0.12);
    camera.target.y = rl.math.lerp(camera.target.y, final_cam_pos.y, 0.12);
}

fn mapKeys() !void {

    // Pause
    if (rl.isKeyPressed(rl.KeyboardKey.key_space))
        isPause = !isPause;

    // Fast mode
    if (rl.isKeyDown(rl.KeyboardKey.key_f))
        fastMode = true
    else
        fastMode = false;

    // Multithreading enabled
    if (rl.isKeyPressed(rl.KeyboardKey.key_m))
        if (isMultiThreaded) {
            isMultiThreaded = false;
            engine.fixThreadAmount(1);
        } else {
            isMultiThreaded = true;
            try engine.unfixThreadAmount();
        };

    // Go to center of mass
    if (rl.isKeyPressed(rl.KeyboardKey.key_c))
        if (engine.getCenterOfMass()) |p| {
            player.x = p[0];
            player.y = p[1];
            zoom = 1;
        };
}

fn smoothZoom() void {
    zoom += rl.getMouseWheelMove() * 0.19 * zoom;
    zoom = rl.math.clamp(zoom, 1e-4, 19.0);

    camera.zoom = rl.math.lerp(camera.zoom, zoom, 0.16);
}

fn arrowKeysMove() void {
    // Player movement arrow keys
    if (!isLocked) {
        if (rl.isKeyDown(rl.KeyboardKey.key_right))
            player.x += 9
        else if (rl.isKeyDown(rl.KeyboardKey.key_left))
            player.x -= 9;

        if (rl.isKeyDown(rl.KeyboardKey.key_up))
            player.y -= 9
        else if (rl.isKeyDown(rl.KeyboardKey.key_down))
            player.y += 9;
    }
}
