// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const std = @import("std");
const body = @import("body.zig");
const vec2 = @import("vec2.zig");
const safety = @import("tree.zig").Tree().safety;

/// Returned array should be deallocated manually
pub fn generateGalaxy(comptime Float: type, ally: std.mem.Allocator) !std.ArrayList(body.Body(Float)) {
    const Body = body.Body(Float);
    const Objects = std.ArrayList(Body);
    const Vec2F = vec2.Vec2F(Float);

    const Generator = struct {
        /// Returned array should be deallocated manually
        fn generateSolarSystem(objects: *Objects) !void {
            const mass = 1e9;
            const radius = 5000;

            // Create Sun
            try objects.append(.{ //
                .radius = radius,
                .mass = mass,
                .color = 0x0,
            });

            try objectVisit(objects, .{ //
                .mass = mass,
                .radius = radius,
            }, //
                .{
                // Planets in solar systems
                LevelConfig{
                    .mass = 1e-11,
                    .max_accel = 1e-2,
                    .radius = 1,
                    .amount = 3,
                    .color = 0xe8e9f9ff,
                    .can_be_rotated = true,
                },
                // Sun's
                LevelConfig{
                    .mass = 1e2,
                    .max_accel = 2e-2,
                    .radius = 8,
                    .randomely_distributed = true,
                    .amount = 1500,
                    .color = 0xFFA6D6FF,
                },
            }, 1);
        }

        fn objectVisit(
            objects: *Objects,
            origin: struct {
                //
                mass: f32,
                velocity: Vec2F = @splat(0),
                position: Vec2F = @splat(0),
                radius: f32,
            },
            depth_config: [2]LevelConfig,
            depth: u8,
        ) !void {
            const cfg = depth_config[depth];
            const amount = cfg.amount;
            var rnd = std.rand.DefaultPrng.init(0);

            for (0..amount) |i| {
                const fi: f32 = @floatFromInt(i);
                const coeff = if (cfg.randomely_distributed) rnd.random().float(f32) else 1;
                const min_dist = std.math.clamp(findMinDistance(cfg.max_accel * coeff, origin.mass), 0, 2e6);
                const pos_n_vel = find(fi / @as(f32, @floatFromInt(amount)), min_dist + (fi * 2e1), origin.mass);
                const mass = cfg.mass;
                const radius = cfg.radius;
                const position = pos_n_vel[1] + origin.position;
                const velocity = origin.velocity + if (!cfg.can_be_rotated or i % 2 == 0) pos_n_vel[0] else -pos_n_vel[0];

                try objects.append(.{
                    //
                    .radius = radius,
                    .mass = mass,
                    .position = position,
                    .velocity = velocity,
                    .color = cfg.color,
                });

                if (depth > 0)
                    try objectVisit(objects, .{ //
                        .mass = mass,
                        .velocity = velocity,
                        .position = position,
                        .radius = radius,
                    }, depth_config, depth - 1);
            }
        }

        const LevelConfig = struct { //
            amount: usize = 1,
            randomely_distributed: bool = false,
            mass: f32,
            radius: f32,
            can_be_rotated: bool = false,
            max_accel: f32,
            color: u32 = 0xff_ff_ff_ff,
        };

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

        fn findVelocityScalar(distance: f32, mass2: f32) f32 {
            return @sqrt(mass2 / distance);
        }

        /// Find min distance where acceleration on bodies are in given range
        fn findMinDistance(max_accel: f32, mass2: f32) f32 {
            return @sqrt(mass2 / max_accel);
        }
    };

    const objects = Objects.init(ally);

    // gen.generateSolarSystem(&objects);
    try Generator.generateSolarSystem(@constCast(&objects));

    return objects;
}
