//
const std = @import("std");
const math = std.math;
usingnamespace math;

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
        const sx: i32 = @intCast(self.x);
        const sy: i32 = @intCast(self.y);

        const ox: i32 = @intCast(other.x);
        const oy: i32 = @intCast(other.y);

        const dx = ox - sx;
        const dy = oy - sy;
        const dQ: u32 = @intCast(dx * dx + dy * dy);

        const d = math.sqrt(dQ);
        return d;
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
