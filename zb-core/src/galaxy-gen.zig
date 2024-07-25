const std = @import("std");
const Body = @import("body.zig");
const ally = std.heap.page_allocator;
const vec2 = @import("vec2.zig");
const Vec2F = vec2.Vec2F;
const safety = @import("tree.zig").Tree().safety;

const Objects = std.ArrayList(Body);

var rnd = std.rand.DefaultPrng.init(0);
/// Returned array should be deallocated manually
pub fn generateGalaxy() !Objects {
    var objects = Objects.init(ally);
    try generateSolarSystem(&objects);
    return objects;
}

/// Returned array should be deallocated manually
fn generateSolarSystem(objects: *Objects) !void {
    const mass = 100_000;
    const radius = 1000;
    // const dist = 1500;

    // Create Sun
    try objects.append(.{ //
        .radius = radius,
        .mass = mass,
        .position = @splat(0),
        .color = 0xff_99_00_ff,
    });

    try objectVisit(objects, .{ //
        .mass = mass,
        .velocity = @splat(0),
        .position = @splat(0),
        .radius = radius,
    }, 2);
}

fn objectVisit(
    objects: *Objects,
    origin: struct {
        //
        mass: f32,
        velocity: Vec2F,
        position: Vec2F,
        radius: f32,
    },
    depth: u8,
) !void {
    const min_dist = findMinDistance(0.1, origin.mass);

    if (depth != 2 and depth != 1)
        return;
    const dep: f32 = @floatFromInt(1 + @as(u32, depth - 1) * 18500);
    for (0..10) |i| {
        // const v = rnd.random().float(f32);
        const fi: f32 = @floatFromInt(i);

        const pos_n_vel = find(fi / 10, min_dist * dep + 6e4 + (fi * 5e4), origin.mass);
        const mass = origin.mass / 1000;
        const radius = origin.radius / 2;

        const position = pos_n_vel[1] + origin.position;

        const velocity = origin.velocity + if (i % 2 == 0) pos_n_vel[0] else -pos_n_vel[0];

        try objects.append(.{
            //
            .radius = radius,
            .mass = mass,
            .position = position,
            .velocity = velocity,
            .color = 0xff_ff_ff_ff,
        });

        if (depth > 0)
            try objectVisit(objects, .{ //
                .mass = mass,
                .velocity = velocity,
                .position = position,
                .radius = radius,
            }, depth - 1);

        if (depth == 2)
            return;
    }
}

/// Calculate Velocity and Position of body for given parameters, so body can stay on orbit.
/// Angle between 0 and 1 (0-360)
fn find(angle: f32, distance: f32, mass2: f32) std.meta.Tuple(&.{ Vec2F, Vec2F }) {
    const projection: Vec2F = .{
        @cos(angle * 2 * std.math.pi),
        @sin(angle * 2 * std.math.pi),
    };

    const dist_vec: Vec2F = @splat(distance);
    const position = dist_vec * projection;
    const velocity_scalar: Vec2F = @splat(findVelocityScalar(distance, mass2));

    const velocity = projection * velocity_scalar;
    // Rotate by 90 grads
    const rotated_velocity: Vec2F = .{ -velocity[1], velocity[0] };

    return .{ rotated_velocity, position };
}

// fn findVelocityScalar(distance: f32, mass2: f32) f32 {
//     return @sqrt(mass2 * distance / (distance * distance + safety));
// }
fn findVelocityScalar(distance: f32, mass2: f32) f32 {
    return @sqrt(mass2 / distance);
}

/// Find min distance where acceleration on bodies are in given range
fn findMinDistance(max_accel: f32, mass2: f32) f32 {
    return @sqrt(mass2 / max_accel);
}
