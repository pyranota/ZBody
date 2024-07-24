const vec2 = @import("vec2.zig");
const Vec2 = vec2.Vec2;
const Vec2F = vec2.Vec2F;

// TODO: Write docs
// TODO: Rename to Astronomical object (AstrObj)

id: u32 = 0,
mass: f32 = 10,
radius: f32 = 90,
color: u32 = 0xff_00_00_ff,
assigned_thread: usize = 0,
position: Vec2F = @splat(0),
velocity: Vec2F = @splat(0),
