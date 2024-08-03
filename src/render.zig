// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const std = @import("std");
const rl = @import("raylib");
const draw = @import("drawing.zig");
const core = @import("zb-core");
const Vec2F32 = core.vec2.Vec2F(f32);

const isDebugThreads = &@import("debug.zig").isDebugThreads;
var engine = &@import("main.zig").engine;
const camera = &@import("controls.zig").camera;
/// Render and draw bodies in scene.
/// Culling included
pub fn render() void {
    for (engine.bodies.items) |body| {
        var col = body.color;
        if (isDebugThreads.*) {
            var rnd = std.rand.DefaultPrng.init(body.assigned_thread + 1);
            col = rnd.random().int(u32) | 0xff;
        }

        // body.position could be f64 or larger, but rl has only f32
        const render_pos: Vec2F32 = @floatCast(body.position);

        if (isVisible(render_pos, camera.*))
            draw.drawPlanet(render_pos[0], render_pos[1], body.radius, col);
    }
}

/// Find out if body is visible
/// Also knows as occlusion Culling
pub fn isVisible(body_world_position: Vec2F32, cam: rl.Camera2D) bool {

    // Convert internal Vec2F of zb-core into internal Vector2 of Raylib
    const body_position_raylib_vec2 = rl.Vector2.init(body_world_position[0], body_world_position[1]);

    // Convert world space coordinate of body to coordinates on screen
    const scr_coords = rl.getWorldToScreen2D(body_position_raylib_vec2, cam);

    // f32 version of screen width (default is i32)
    const sw: f32 = @floatFromInt(rl.getScreenWidth());
    // f32 version of screen height (default is i32)
    const sh: f32 = @floatFromInt(rl.getScreenHeight());

    // Screen padding. E.G. Black border size
    const pad = 20;

    return if ( //
    scr_coords.x > sw - pad //
    or scr_coords.y > sh - pad //
    or scr_coords.y < pad //
    or scr_coords.x < pad)
        false
    else
        true;
}
