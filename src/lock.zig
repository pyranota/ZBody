// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

// Static imports
const rl = @import("raylib");
const core = @import("zb-core");
const main = @import("main.zig");
const debug = @import("debug.zig");
const render = @import("render.zig");
const ctrl = @import("controls.zig");

// Dynamic imports (Pointers)
var engine = &main.engine;
const observer = &ctrl.observer;
const camera = &ctrl.camera;
const isPause = &ctrl.isPause;
const isDebugBounds = &debug.isDebugBounds;

// Export variables
pub var isLocked = false;
pub var targetBody: core.Body(f32) = undefined;

// Locally used variables
var targetBodyId: u32 = undefined;
var isTargetModeOn: bool = false;

/// Allows you to "lock" camera on body and spectate it.
pub fn handleLock() void {

    // Listen for key events
    mapKeys();

    // Handle locks
    targetMode();
}

// TODO: Refactor
// TODO: Write comments
fn targetMode() void {
    if (isTargetModeOn) {
        for (engine.bodies.items) |body| {
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), ctrl.camera);
            const bodyVec = rl.Vector2{ .x = body.position[0], .y = body.position[1] };

            // A bit embeded debug here.
            if (isDebugBounds.*) {

                // Cull
                // NOTE: It will actually be a bottleneck in program, if we dont cull it
                if (!render.isVisible(body.position, camera.*))
                    continue;

                rl.drawCircle(@intFromFloat(pos.x), @intFromFloat(pos.y), 10, rl.Color.white);
                rl.drawCircle(@intFromFloat(bodyVec.x), @intFromFloat(bodyVec.y), body.radius * 1.25, rl.Color.white);
            }

            if ( //
            rl.checkCollisionPointCircle(pos, bodyVec, body.radius * 1.25) //
            and rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left) //
            and !isLocked and isPause.* //
            ) {
                isLocked = true;
                targetBodyId = body.id;
                // std.debug.print("\n{}", .{body.id});
            }
            if (isLocked and targetBodyId == body.id) {
                targetBody = body;

                observer.x = targetBody.position[0];
                observer.y = targetBody.position[1];

                ctrl.camera.target.x = targetBody.position[0];
                ctrl.camera.target.y = targetBody.position[1];
            }
        }
    }
}

fn mapKeys() void {
    if (isPause.*)
        if (rl.isKeyPressed(rl.KeyboardKey.key_l)) {
            // TODO: Wtf? You like playin with fire i see
            targetBody = undefined;

            if (isTargetModeOn) isLocked = false;

            // Toggle
            isTargetModeOn = !isTargetModeOn;
        };
}
