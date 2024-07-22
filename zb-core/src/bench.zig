const std = @import("std");
const engine = @import("engine.zig");

pub fn main() !void {
    std.debug.print("Hello benchmark!", .{});

    const size = 1024 * 256;

    var e = try engine.Engine().init(size);
    defer e.deinit();

    for (0..40) |x| {
        for (0..40) |y| {
            const p: @Vector(2, f32) = .{ @floatFromInt(size / 2 + x * 150), @floatFromInt(size / 2 + y * 150) };
            try e.addBody(.{ .mass = 40, .position = p, .velocity = @splat(0) });
        }
    }

    for (0..50) |_| {
        try e.step(0.05);
    }
}
