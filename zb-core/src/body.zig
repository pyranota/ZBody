const cstd = @cImport(@cInclude("stdlib.h"));
const vec2 = @import("vec2.zig");
const Vec2 = vec2.Vec2;
const Vec2F = vec2.Vec2F;
mass: f32 = 0,
position: Vec2F = @splat(0),

assigned_thread: usize = 0,
//
velocity: Vec2F = @splat(0),
radius: f32 = 0,
color: u32 = 0xff_00_00,
id: u32 = 0,
