//
const std = @import("std");
const math = std.math;
const ztracy = @import("ztracy");
usingnamespace math;

pub const Vec2 = @Vector(2, u32);
pub const Vec2F = @Vector(2, f32);

/// Converts `Vec2` to `Vec2F` and vice versa
pub fn convert(comptime To: type, vector: anytype) @Vector(2, To) {
    const zone = ztracy.Zone(@src());
    defer zone.End();
    var res: @Vector(2, To) = undefined;
    inline for (0..2) |i| res[i] = if (To == u32) @intFromFloat(vector[i]) else @floatFromInt(vector[i]);
    return res;
}
pub fn fit(comptime To: type, self: anytype, width: u32) @Vector(2, To) {
    const w: f32 = @floatFromInt(width);
    // TODO: Use splat and vec % width
    // TODO: Could be faster with bit shifting
    return .{ //
        @rem(self[0], w),
        @rem(self[1], w),
    };
}

/// Converts vectors to given type and compares if new types the same
pub fn isEq(comptime T: type, self: anytype, other: anytype) bool {
    // Convert types if needed
    const tinf1 = @typeInfo(@TypeOf(self));
    const v1 = if (tinf1.Vector.child != T)
        convert(T, self)
    else
        self;

    // Each type being converted individually
    const tinf2 = @typeInfo(@TypeOf(other));
    const v2 = if (tinf2.Vector.child != T)
        convert(T, other)
    else
        other;

    const a1: [2]T = v1;
    const a2: [2]T = v2;

    inline for (a1, a2) |e1, e2|
        if (e1 != e2) return false;

    return true;
}
/// Converts vectors to given type and calcluates the distance
pub fn distance(comptime T: type, self: anytype, other: anytype) T {
    const zone = ztracy.Zone(@src());
    defer zone.End();
    // Convert types if needed
    const tinf1 = @typeInfo(@TypeOf(self));
    const v1 = if (tinf1.Vector.child != T)
        convert(T, self)
    else
        self;

    // Each type being converted individually
    const tinf2 = @typeInfo(@TypeOf(other));
    const v2 = if (tinf2.Vector.child != T)
        convert(T, other)
    else
        other;

    const dx = v2[0] - v1[0];
    const dy = v2[1] - v1[1];
    const dQ = dx * dx + dy * dy;

    const d = math.sqrt(dQ);
    return d;
}

pub fn toArray(comptime To: type, vector: anytype) [2]To {
    const res: [2]To = vector;
    return res;
}
// pub const Vec2 = struct {
//     x: u32 = 0,
//     y: u32 = 0,
//     /// Devide all fields by 2
//     pub fn half(self: *const @This()) @This() {
//         const div: u32 = 2;
//         return .{ //
//             // Zig for some reasont cant just self.x / 2
//             .x = self.x / div,
//             .y = self.y / div,
//         };
//     }

//     pub fn toVec2F(self: @This()) Vec2F {
//         return .{ .x = @floatFromInt(self.x), .y = @floatFromInt(self.y) };
//     }

//     // TODO: Return f32
//     pub fn distance(self: @This(), other: Vec2) u32 {
//         const sx: i32 = @intCast(self.x);
//         const sy: i32 = @intCast(self.y);

//         const ox: i32 = @intCast(other.x);
//         const oy: i32 = @intCast(other.y);

//         const dx = ox - sx;
//         const dy = oy - sy;
//         const dQ: u32 = @intCast(dx * dx + dy * dy);

//         const d = math.sqrt(dQ);
//         return d;
//     }

//     pub fn fit(self: @This(), width: u32) @This() {
//         return .{ //
//             .x = @rem(self.x, width),
//             .y = @rem(self.y, width),
//         };
//     }

//     /// Return largest value.
//     pub fn max(self: @This()) u32 {
//         if (self.x > self.y) {
//             return self.x;
//         } else {
//             return self.y;
//         }
//     }
// };

// pub const Vec2F = struct {
//     x: f32 = 0.0,
//     y: f32 = 0.0,
//     /// Devide all fields by 2
//     pub fn half(self: *const @This()) @This() {
//         const div: f32 = 2;
//         return .{ //
//             // Zig for some reasont cant just self.x / 2
//             .x = self.x / div,
//             .y = self.y / div,
//         };
//     }
//     pub fn distance(self: @This(), other: Vec2F) f32 {
//         const dx = other.x - self.x;
//         const dy = other.y - self.y;
//         const dQ = dx * dx + dy * dy;

//         const d = math.sqrt(dQ);
//         return d;
//     }

//     pub fn fit(self: @This(), width: u32) @This() {
//         const w: f32 = @floatFromInt(width);
//         return .{ //
//             .x = @rem(self.x, w),
//             .y = @rem(self.y, w),
//         };
//     }
//     /// Return largest value.
//     pub fn max(self: @This()) f32 {
//         if (self.x > self.y) {
//             return self.x;
//         } else {
//             return self.y;
//         }
//     }
//     pub fn toVec2(self: @This()) Vec2 {
//         return .{ .x = @intFromFloat(self.x), .y = @intFromFloat(self.y) };
//     }
// };
