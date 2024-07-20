//
pub const Vec2 = struct {
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

    pub fn distance(self: @This(), other: Vec2) u32 {
        _ = self; // autofix
        _ = other; // autofix
        return 1;
    }

    pub fn fit(self: @This(), width: u32) @This() {
        return .{ //
            .x = @rem(self.x, width),
            .y = @rem(self.y, width),
        };
    }

    /// Return largest value.
    pub fn max(self: @This()) u32 {
        if (self.x > self.y) {
            return self.x;
        } else {
            return self.y;
        }
    }
};

pub const Vec2F = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    /// Devide all fields by 2
    pub fn half(self: *const @This()) @This() {
        const div: f32 = 2;
        return .{ //
            // Zig for some reasont cant just self.x / 2
            .x = self.x / div,
            .y = self.y / div,
        };
    }

    pub fn fit(self: @This(), width: f32) @This() {
        return .{ //
            .x = @rem(self.x, width),
            .y = @rem(self.y, width),
        };
    }
};
