const std = @import("std");
const engine = @import("./engine.zig");
const tree = @import("./tree.zig");

pub fn main() !void {
    // var tr = tree.Tree().new();
    // tr.addBody(81, .{ .x = 0, .y = 1 });
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    // std.debug.print("{?}\n", .{tr});
    var tr = tree.Tree().init(16);
    tr.addBody(1, .{ .x = 1, .y = 9 });
    tr.addBody(81, .{ .x = 0, .y = 1 });
    // tr.addBody(81, .{ .x = 8, .y = 8 });
    tr.addBody(81, .{ .x = 9, .y = 9 });
    try tr.print();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
