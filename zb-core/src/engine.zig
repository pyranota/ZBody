const tree = @import("tree.zig");
const Body = @import("body.zig");
const std = @import("std");
const Vec2F = @import("./vec2.zig").Vec2F;
const Vec2 = @import("./vec2.zig").Vec2;
const List = std.ArrayList;

pub fn Engine() type {
    return struct { //
        tree: tree.Tree(),
        bodies: List(Body),
        forces: List(Vec2F),

        const Self = @This();

        // TODO: Find better allocator
        const ally = std.heap.page_allocator;

        pub fn init(comptime size: u32) !Self {
            return .{ //
                .tree = try tree.Tree().init(size),
                .bodies = List(Body).init(ally),
                .forces = List(Vec2F).init(ally),
            };
        }

        pub fn deinit(self: *Self) void {
            self.bodies.deinit();
            self.tree.deinit();
            self.forces.deinit();
        }

        pub fn addBody(self: *Self, body: Body) !void {
            try self.bodies.append(body);
            try self.forces.append(.{});
        }

        pub fn print(self: *Self) !void {
            try self.tree.print();
        }

        pub fn showBounds(self: Self, comptime callb: anytype) !void {
            try self.tree.showBounds(callb);
        }

        pub fn step(self: *Self, delta: f32) !void {
            self.tree.clean();
            for (self.bodies.items) |body| {
                try self.tree.addBody(@intFromFloat(body.mass), body.position);
            }

            self.tree.finalize();
            for (self.bodies.items, 0..) |body, i| {
                self.tree.step(delta, .{ //
                    .force = &self.forces.items[i],
                    .bodyPos = body.position,
                    .bodyMass = @intFromFloat(body.mass),
                });
            }
            // _ = delta;

            self.applyForces(1);
        }

        /// Apply forces to velocity
        fn applyForces(self: *Self, delta: f32) void {
            // _ = delta; // autofix
            for (self.forces.items, 0..) |force, i| {
                var body = &self.bodies.items[i];

                // const mass: f32 = @floatFromInt(body.mass);

                std.debug.print("Force: X: {d}, Y: {d}\n", .{ force.x, force.y });

                if (force.x != 0) {
                    const accelerationX: f32 = force.x / body.mass;
                    body.velocity.x += accelerationX * delta;
                    if (body.velocity.x < 0) {
                        body.position.x -= @intFromFloat(-body.velocity.x);
                    } else {
                        body.position.x += @intFromFloat(body.velocity.x);
                    }
                }
                if (force.y != 0) {
                    const accelerationY: f32 = force.y / body.mass;
                    body.velocity.y += accelerationY * delta;
                    if (body.velocity.y < 0) {
                        body.position.y -= @intFromFloat(-body.velocity.y);
                    } else {
                        body.position.y += @intFromFloat(body.velocity.y);
                    }
                }
            }
        }

        /// Apply velocity to position
        fn applyVelocities() void {
            // TODO
        }
    };
}

test "init engine" {
    var engine = try Engine().init(16);
    defer engine.deinit();

    try engine.addBody(.{});
}
