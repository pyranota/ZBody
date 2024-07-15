//
x: u32 = 0,
y: u32 = 0,
/// Devide all fields by 2
pub fn half(self: *const @This()) @This() {
    const div: u32 = 2;
    return .{ //
        // Zig for some reasont cant just self.x / 2
        .x = self.x / div,
        .y = self.y / div,
    };
}

pub fn fit(self: @This(), width: u32) @This() {
    return .{ //
        .x = @rem(self.x, width),
        .y = @rem(self.y, width),
    };
}
