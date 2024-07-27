// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const std = @import("std");
const ally = std.heap.c_allocator;
const draw = @import("drawing.zig");
const rl = @import("raylib");

var engine = &@import("main.zig").engine;
const camera = &@import("controls.zig").camera;

pub var isDebugBounds = false;
pub var isDebugLoD = false;
pub var isDebugThreads = false;

/// Handles debug in the simulation world
/// It will draw all elements as well
/// Should be called after `camera.begin()` and before `camera.end()`
/// Also should be called after all bodies rendering
/// Since this is the first entry, it also handles all key mapping and detection.
pub fn handleDebugWorld() !void {
    mapKeys();
    try debugLoD();
    try debugBounds();
}
/// Handles debug in the HUD
/// It will draw all elements as well
/// Should be called after `camera.end()`
pub fn handleDebugHUD() !void {
    try debugValues();
}

/// Debug of what forces acting on a body.
/// Basically showing bounds of branches or leafs
fn debugLoD() !void {
    if (isDebugLoD)
        if (engine.bodies.items.len > 0) {
            const p = engine.bodies.items[0].position;
            try engine.showForceBounds(p, draw.drawBoundForceAndCoM);
        };
}

fn debugBounds() !void {
    if (isDebugBounds)
        try engine.showBounds(draw.drawBound);
}

fn debugValues() !void {
    if (isDebugBounds or isDebugLoD) {
        const string = try std.fmt.allocPrint(
            ally,
            "Bodies in scene: {}",
            .{engine.bodies.items.len},
        );
        defer ally.free(string);
        rl.drawText(@ptrCast(string), 3, 40, 20, rl.Color.dark_green);

        const threshold_string = try std.fmt.allocPrint(
            ally,
            "Threads used: {d}",
            .{engine.thread_amount},
        );
        defer ally.free(threshold_string);
        rl.drawText(@ptrCast(threshold_string), 3, 60, 20, rl.Color.green);
        const position_string = try std.fmt.allocPrint(
            ally,
            "Camera position: {?}",
            .{camera.target},
        );
        defer ally.free(position_string);
        rl.drawText(@ptrCast(position_string), 3, 100, 20, rl.Color.green);
    }

    if (isDebugThreads) {
        rl.drawFPS(10, 10);
        const cpos_string = try std.fmt.allocPrint(
            ally,
            "  Threads used: {?}\n(Press M to toggle) \n  Color is Thread",
            .{engine.thread_amount},
        );
        defer ally.free(cpos_string);
        rl.drawText(@ptrCast(cpos_string), 370, 40, 20, rl.Color.gray);
    }
}

fn mapKeys() void {
    if (rl.isKeyPressed(rl.KeyboardKey.key_o)) {
        isDebugLoD = !isDebugLoD;
        isDebugBounds = false;
    }

    if (rl.isKeyPressed(rl.KeyboardKey.key_d)) {
        isDebugBounds = !isDebugBounds;
        isDebugLoD = false;
    }
    if (rl.isKeyPressed(rl.KeyboardKey.key_k))
        isDebugThreads = !isDebugThreads;
}
