const std = @import("std");

pub fn say(what: []const u8) void {
    std.debug.print("{s}\n", .{what});
}

/// NOOOO
pub fn Engine() void {
    std.debug.print(" is starting: brr.. brrr", .{});
}
