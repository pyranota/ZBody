// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const std = @import("std");
const rl = @import("raylib");
const draw = @import("drawing.zig");

const isDebugThreads = &@import("debug.zig").isDebugThreads;
var engine = &@import("main.zig").engine;
const camera = &@import("controls.zig").camera;
/// Render and draw bodies in scene.
/// Culling included
pub fn render() void {
    for (engine.bodies.items) |body| {
        var col = body.color;
        if (isDebugThreads.*) {
            var rnd = std.rand.DefaultPrng.init(body.assigned_thread);
            col = rnd.random().int(u32) | 0xff;
        }

        const body_p = rl.Vector2.init(body.position[0], body.position[1]);
        const scr_coords = rl.getWorldToScreen2D(body_p, camera.*);

        if (scr_coords.x > 980 or scr_coords.y > 980 or scr_coords.y < 20 or scr_coords.x < 20)
            continue;
        draw.drawPlanet(body.position[0], body.position[1], body.radius, col);
    }
}
