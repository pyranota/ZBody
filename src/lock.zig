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
pub var targetBody: core.Body = undefined;
var engine = &@import("main.zig").engine;
pub var isLocked = false;
/// Allows you to "lock" camera on body and spectate it.
pub fn handleLock() void {
    mapKeys();
    if (isTargetModeOn) {
        for (engine.bodies.items) |body| {
            const pos = rl.getScreenToWorld2D(rl.getMousePosition(), ctrl.camera);
            const bodyVec = rl.Vector2{ .x = body.position[0], .y = body.position[1] };

            // A bit embeded debug here.
            if (isDebugBounds.*) {
                const body_p = rl.Vector2.init(body.position[0], body.position[1]);
                const scr_coords = rl.getWorldToScreen2D(body_p, ctrl.camera);

                if (scr_coords.x > 980 or scr_coords.y > 980 or scr_coords.y < 20 or scr_coords.x < 20)
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
                player.x = targetBody.position[0];
                player.y = targetBody.position[1];
                ctrl.camera.target.x = targetBody.position[0];
                ctrl.camera.target.y = targetBody.position[1];
            }
        }
    }
}

fn mapKeys() void {
    if (isPause.*) {
        if (rl.isKeyPressed(rl.KeyboardKey.key_l)) {
            if (isTargetModeOn) isLocked = false;
            isTargetModeOn = !isTargetModeOn;
        }
    } else isTargetModeOn = false;
}
