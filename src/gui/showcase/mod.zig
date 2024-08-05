const std = @import("std");
const super = @import("../mod.zig");

pub const im = super.import("./showcase/mod.h");

pub fn update() void {
    im.s.
}

inline fn import(comptime mod_path: []const u8) type {
    return struct {
        pub const c = @cImport({
            @cDefine("GUI_SHOWCASE_IMPLEMENTATION", {});
            @cInclude("./showcase//mod.h");
        });
    };
}
