// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const core = @import("zb-core");
const rl = @import("raylib");
const ctrl = @import("controls.zig");
const isPause = &ctrl.isPause;
const player = &ctrl.player;
const camera = &ctrl.camera;
const isDebugBounds = &@import("debug.zig").isDebugBounds;

var isTargetModeOn: bool = false;
var targetBodyId: u32 = undefined;
var targetBody: core.Body = undefined;
var engine = &@import("main.zig").engine;
pub var isLocked = false;

/// Allows you to "lock" camera on body and spectate it.
pub fn handleLock() void {
    mapKeys();
    if (isTargetModeOn) {
        for (engine.bodies.items) |body| {
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera.*);
            const bodyVec = rl.Vector2{ .x = body.position[0], .y = body.position[1] };

            // A bit embeded debug here.
            if (isDebugBounds.*) {
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
                player.x = rl.math.lerp(player.x, targetBody.position[0], 0.4);
                player.y = rl.math.lerp(player.y, targetBody.position[1], 0.4);
            }
        }
    }
}

fn mapKeys() void {
    if (rl.isKeyPressed(rl.KeyboardKey.key_l))
        if (isPause.*) {
            if (isTargetModeOn) isLocked = false;
            isTargetModeOn = !isTargetModeOn;
        };
}
