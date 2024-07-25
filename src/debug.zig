const std = @import("std");
const ally = std.heap.page_allocator;
const draw = @import("drawing.zig");
const rl = @import("raylib");

var engine = &@import("main.zig").engine;
const camera = @import("controls.zig").camera;

pub var isDebugBounds = false;
pub var isDebugLoD = false;
pub var isDebugThreads = false;

fn handleDebug() void {
    debugLoD();
    debugBounds();
}

/// Debug of what forces acting on a body.
/// Basically showing bounds of branches or leafs
fn debugLoD() void {
    if (isDebugLoD)
        if (engine.bodies.items.len > 0) {
            const p = engine.bodies.items[0].position;
            try engine.showForceBounds(p, draw.drawBoundForceAndCoM);
        };
}

fn debugBounds() void {
    if (isDebugBounds)
        try engine.showBounds(draw.drawBound);
}

fn toRename() void {
    const string = try std.fmt.allocPrint(
        ally,
        "Astral bodies in scene: {}",
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

    const cpos_string = try std.fmt.allocPrint(
        ally,
        "Camera position: {?}",
        .{camera.target},
    );
    defer ally.free(cpos_string);
    rl.drawText(@ptrCast(cpos_string), 3, 100, 20, rl.Color.green);
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
