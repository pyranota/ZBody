const std = @import("std");
pub const c = @import("c.zig");

/// Modules amount
const AMOUNT = c.modules.len;
const types: [AMOUNT]type = blk: {
    var output: [AMOUNT]type = undefined;
    for (&output, c.modules, c.names) |*output_el, mod, name| {
        const name_cased = .{std.ascii.toUpper(name[0])} ++ name[1..];

        output_el.* = struct {
            const State = @field(c, name_cased ++ "State");
            var state: State = undefined;

            pub fn init() void {
                state = @field(c.c, "InitGui" ++ name_cased)();
            }

            pub fn update() void {
                mod.update(&state);
                @field(c.c, "Gui" ++ name_cased)(&state);
            }
        };
    }
    break :blk output;
};

pub fn init() void {
    inline for (types) |ty|
        ty.init();
}

/// Draw UI
/// Should be called after camera mode
pub fn draw() void {
    inline for (types) |ty|
        ty.update();
}
