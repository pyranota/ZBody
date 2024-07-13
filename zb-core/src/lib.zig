const std = @import("std");
const tree = @import("./tree.zig");

pub fn say(what: []const u8) void {
    std.debug.print("{s}\n", .{what});
}

/// NOOOO
pub fn Engine() void {
    std.debug.print(" is starting: brr.. brrr", .{});
}
