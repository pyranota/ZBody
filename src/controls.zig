//! This file is controlling time, camera movement and threading
const rl = @import("raylib");
const main = @import("main.zig");

const isLocked = @import("lock.zig").isLocked;
const isMenuShown = @import("ui.zig").isMenuShown;

pub const screenWidth = 1000;
pub const screenHeight = 1000;
// Camera position basically
pub var player = rl.Rectangle{ .x = 0, .y = 0, .width = 40, .height = 40 };
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

pub fn control() void {
    // Mouse controls
    if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_left) and !isMenuShown and !isLocked) {
        const d = rl.getMouseDelta();
        const sens = 1;
        player.x -= (d.x * sens) / camera.zoom;
        player.y -= (d.y * sens) / camera.zoom;
    }
}

/// Handles fitting all bodies in given range and extending borders.
/// Makes it *seemless*
pub fn infiniteSpace() void {

    // Camera zoom controls
    const move_amount = try engine.fitBodies();

    const planetStartPoint = @import("spawn.zig").planetStartPoint;

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

fn lerpCamera() void {
    // NOTE: Lerp is disabled for now
    // camera.target.x = final_cam_pos.x;
    // camera.target.y = final_cam_pos.y;

    const final_cam_pos = rl.Vector2.init(player.x, player.y);
    camera.target.x = rl.math.lerp(camera.target.x, final_cam_pos.x, 0.2);
    camera.target.y = rl.math.lerp(camera.target.y, final_cam_pos.y, 0.2);
}

fn mapKeys() void {

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

pub fn smoothZoom() void {
    zoom += rl.getMouseWheelMove() * 0.19 * zoom;
    zoom = rl.math.clamp(zoom, 1e-4, 19.0);

    camera.zoom = rl.math.lerp(camera.zoom, zoom, 0.16);
}

pub fn arrowKeysMove() void {
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
}
