// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

//
const std = @import("std");
const math = std.math;
const ztracy = @import("ztracy");
usingnamespace math;

pub const Vec2 = @Vector(2, u32);
/// Vec2 with 2 f32
pub const Vec2F32 = Vec2F(f32);

/// Return Vec2F struct with given float type.
/// Comptime Error if specified type is not a float.
pub fn Vec2F(comptime Float: type) type {
    const TypeInfo = @typeInfo(Float);

    switch (TypeInfo) {
        .Float => return @Vector(2, Float),
        else => @compileError( //
            "Vec2F should receive only floats, e.g: f32, f64, f80 or f128"),
    }
}

// NOTE: Possibly could be deprecated in favour of @castFromFloat and other builtins
/// Converts `Vec2` to `Vec2F` and vice versa
pub fn convert(comptime T: type, vector: anytype) @Vector(2, T) {
    const zone = ztracy.Zone(@src());
    defer zone.End();

    const ToInfo = @typeInfo(T);
    const FromInfo = @typeInfo(@TypeOf(vector[0]));

    // Detect if we try to convert to same type. e.g: from f32 to f64 or from i32 to i32
    return if (@intFromEnum(ToInfo) == @intFromEnum(FromInfo))
        @compileError(std.fmt.comptimePrint( //
            "Trying to convert to same type:\n\t {s} -> {s} is not allowed", //
            .{ @typeName(@TypeOf(vector[0])), @typeName(T) }))
    else if (T == u32)
        // TODO:  ^^^ Make general Int instead of u32
        // Convert to Int if destination is u32
        @intFromFloat(vector)
    else
        // Convert to Float if destination type is float
        @floatFromInt(vector);
}

pub fn fit(self: anytype, width: u32) @Vector(2, @TypeOf(self[0])) {
    const w: @TypeOf(self[0]) = @floatFromInt(width);
    // TODO: Use splat and vec % width
    // TODO: Could be faster with bit shifting
    return .{ //
        @rem(self[0], w),
        @rem(self[1], w),
    };
}
/// Take Vector and return max element
pub fn max(self: anytype) @TypeOf(self[0]) {
    if (self[0] > self[1])
        return self[0]
    else
        return self[1];
}

/// Take Vector and return min element
pub fn min(self: anytype) @TypeOf(self[0]) {
    if (self[0] < self[1])
        return self[0]
    else
        return self[1];
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
// TODO: Refactor
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
