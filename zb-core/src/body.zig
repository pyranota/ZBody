const std = @import("std");
const vec2 = @import("vec2.zig");
const Vec2 = vec2.Vec2;
const Vec2F = vec2.Vec2F;
var prng = std.rand.DefaultPrng.init(blk: {
    var seed: u64 = undefined;
    std.posix.getrandom(std.mem.asBytes(&seed));
    break :blk seed;
});
const rand = prng.random();
mass: f32 = 0,
position: Vec2F = @splat(0),
//
velocity: Vec2F = @splat(0),
radius: f32 = 0,
color: u32 = 0xff_00_00,
id: u32 = 0,
