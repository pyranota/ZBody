// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

//! This file is controlling time, camera movement and threading also controlls execution of program

// Static imports
const rl = @import("raylib");
const main = @import("main.zig");
const Vec2F = @import("zb-core").vec2.Vec2F;
const std = @import("std");
const render = @import("render.zig");

// Dynamic imports
const planetStartPoint = &@import("spawn.zig").planetStartPoint;
const isLocked = &@import("lock.zig").isLocked;
const isMenuShown = &@import("ui.zig").isMenuShown;
const engine = &main.engine;

// Export variables provided by module
pub var isPause: bool = false;
pub var isMultiThreaded = true;
/// If true, modifies delta
pub var fastMode: bool = false;

/// Is camera auto-drag enabled
pub var isAutoDrag: bool = true;
/// Add velocity to camera, to "move along" with visible objects
var cameraDragVelocity: Vec2F = @splat(0);
/// Get velocity of camera, which "moves along" with visible objects
pub fn getCameraDragVelocity() Vec2F {
    return cameraDragVelocity;
}

// Dynamic window sizes
var screenWidth: i32 = 1000;
var screenHeight: i32 = 1000;

pub fn scrWidth() i32 {
    return screenWidth;
}

pub fn scrHeight() i32 {
    return screenHeight;
}

// NOTE: These two variables does not directly change the camera position nor zoom
// Camera will be slowling moving to given parameters in these 2 vars
// If you want to quickly jump to specific coord / zoom, than modify one/both variables here and modify camera as well.
// It will prevent camera from lerping
// Camera position
pub var player = rl.Rectangle{ .x = 1e3, .y = 1e3, .width = 40, .height = 40 };
// pub var observer= rl.Vector2{ .x = 1e3, .y = 1e3};
// Camera zoom
var zoom: f32 = 9e-4;

pub var camera = rl.Camera2D{
    .target = rl.Vector2.init(1000, 1000),
    .offset = rl.Vector2.init(0, 500),
    .rotation = 0,
    .zoom = 2e-4,
};

/// Modify delta
/// Used to slow down or speed up simulation
pub var deltaModifier: f32 = 1;
/// Get pure delta
pub fn getDelta() f32 {
    // Normally delta is dynamic value,
    // But here its hardcoded.
    // It allows us to make simulation precise.
    // If fps drops, simulation slows down.
    return 1e-2;
}

/// Get delta with modifier
pub fn getFinalDelta() f32 {
    return getDelta() * deltaModifier;
}

pub fn simStep() !void {
    if (!isPause)
        try engine.step(getFinalDelta());
}

/// Move camera offset towards pointer location
/// Allows to zoom where pointer in, intead of zooming into center of screen (W.I.P)
fn moveCameraOffset() void {
    camera.offset.x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2;
    camera.offset.y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2;
}

/// Entry point for Controls, handles everything.
/// Should be called before everything
pub fn handleControls() !void {
    moveCameraOffset();
    // Listen for keys
    try mapKeys();

    // Speed up simulation
    modifyDelta();

    // Auto-drag
    dragCamera();

    // Move by grabbing
    moveCameraWithMouse();
    lerpCamera();

    // Zoom
    smoothZoom();

    // Dynamically Extend
    infiniteSpace();
}

/// Modify speed of time
/// It handles slow downs and speed up of simulation
fn modifyDelta() void {
    // If fast mode disabled
    // We speed up simulation if zoom is low
    // And slow down if zoom is high      >---------------<
    deltaModifier = if (fastMode) 3e2 else 1 / camera.zoom;
    //                            ^^^
    // If fast mode is enabled
    // We just multiply delta by constant
}

/// Auto-drag logic
/// Allows to automatically drag camera according to AVG velocity of visible bodies
fn dragCamera() void {

    // Safety checks
    if (!isAutoDrag or isPause or engine.isEmpty()) return;

    var totalMass: Vec2F = @splat(0);
    // Cleanup from previous iterations
    cameraDragVelocity = @splat(0);

    // Iterate over all bodies and find visible one.
    for (engine.bodies.items[1..]) |body| {
        //                   ^^^  Ignore black hole in the middle.

        // Cull
        if (!render.isVisible(body.position, camera))
            continue;

        // Find total mass of all bodies in visible zone
        totalMass += @splat(body.mass);

        // Sum up all velocities multiplied by body mass each
        // This value will be divided by total mass after to find out AVG velocity
        cameraDragVelocity += body.velocity * @as(Vec2F, @splat(body.mass));
    }

    // We dont want to devide by zero.
    //           >-< X and Y are same in mass.
    if (totalMass[0] <= 0) return;

    // Find AVG velocity
    cameraDragVelocity /= totalMass;

    // Apply
    // TODO: We could use oneliner for this...
    // Apply to player first
    player.x += (cameraDragVelocity[0] * getFinalDelta());
    player.y += (cameraDragVelocity[1] * getFinalDelta());

    // And move camera instantly to prevent from lerping
    camera.target.x += (cameraDragVelocity[0] * getFinalDelta());
    camera.target.y += (cameraDragVelocity[1] * getFinalDelta());
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
    const final_cam_pos = rl.Vector2.init(player.x, player.y);

    // Uncomment to disable lerp
    // camera.target.x = final_cam_pos.x;
    // camera.target.y = final_cam_pos.y;
    // return;

    camera.target.x = rl.math.lerp(camera.target.x, final_cam_pos.x, 0.15);
    camera.target.y = rl.math.lerp(camera.target.y, final_cam_pos.y, 0.15);
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

// TODO: Zoom towards the spot mouse is pointing
/// Handles zoom with lerp (linear interpolation)
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
