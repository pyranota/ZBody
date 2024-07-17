const std = @import("std");
const engine = @import("./engine.zig");
const tree = @import("./tree.zig");
const Body = @import("body.zig");

pub fn main() !void {
    // var tr = tree.Tree().new();
    // tr.addBody(81, .{ .x = 0, .y = 1 });
    // // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    // std.debug.print("{?}\n", .{tr});
    // var tr = try tree.Tree().init(16);
    // defer tr.deinit();

    // try tr.addBody(1, .{ .x = 1, .y = 9 });
    // try tr.addBody(8, .{ .x = 0, .y = 1 });
    // try tr.addBody(10, .{ .x = 10, .y = 0 });
    // try tr.addBody(81, .{ .x = 9, .y = 11 });
    // try tr.print();
    var e = try engine.Engine().init(256);
    try e.addBody(Body{ .mass = 99, .position = .{ .x = 199, .y = 18 }, .velocity = .{} });
    try e.addBody(Body{ .mass = 9, .position = .{ .x = 99, .y = 8 }, .velocity = .{} });
    try e.addBody(Body{ .mass = 16, .position = .{ .x = 99, .y = 99 }, .velocity = .{} });
    try e.step(0.1);
    // try e.print();
    e.tree.traverse();
    defer e.deinit();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
