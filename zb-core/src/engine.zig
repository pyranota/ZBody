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
        accels: List(Vec2F),

        const Self = @This();

        // TODO: Find better allocator
        const ally = std.heap.page_allocator;

        pub fn init(comptime size: u32) !Self {
            return .{ //
                .tree = try tree.Tree().init(size),
                .bodies = List(Body).init(ally),
                .accels = List(Vec2F).init(ally),
            };
        }

        pub fn deinit(self: *Self) void {
            self.bodies.deinit();
            self.tree.deinit();
            self.accels.deinit();
        }

        pub fn addBody(self: *Self, body: Body) !void {
            try self.bodies.append(body);
            try self.accels.append(.{});
        }

        pub fn print(self: *Self) !void {
            try self.tree.print();
        }

        pub fn showBounds(self: Self, comptime callb: anytype) !void {
            try self.tree.showBounds(callb);
        }

        pub fn showForceBounds(self: Self, targetPosition: Vec2F, callb: anytype) !void {
            std.debug.print("\n \n \n Iteration \n", .{});
            // _ = callb; // autofix
            // _ = targetPosition; // autofix
            // _ = self; // autofix
            // comptime var args = tree.Tree().showForcesArgs{ .targetPosition = .{}, .callb = callb };
            // args.targetPosition = targetPosition;
            try self.tree.showForceBounds(.{ targetPosition, callb });
        }

        pub fn mergeSamePositions(self: *Self) !void {
            // Store position and index of body
            var positions = std.AutoHashMap(Vec2, usize).init(ally);
            defer positions.deinit();
            var toRemove = std.ArrayList(usize).init(ally);
            defer toRemove.deinit();

            for (self.bodies.items, 0..) |body, i| {
                if (positions.get(body.position.toVec2())) |index| {
                    // self.bodies.items[index].mass += body.mass;
                    var oldB = &self.bodies.items[index];

                    const vFinalX = (oldB.velocity.x * oldB.mass + body.velocity.x * body.mass) / (oldB.mass + body.mass);
                    const vFinalY = (oldB.velocity.y * oldB.mass + body.velocity.y * body.mass) / (oldB.mass + body.mass);
                    oldB.mass += body.mass;

                    oldB.velocity.x = vFinalX;
                    oldB.velocity.y = vFinalY;

                    try toRemove.append(i);
                } else {
                    try positions.put(body.position.toVec2(), i);
                }
            }

            // var maxMass: f32 = 0;

            // for (self.bodies.items) |body| {
            //     if (body.mass > maxMass) {
            //         maxMass = body.mass;
            //     }
            // }
            // std.debug.print("Max mass: {d}", .{maxMass});

            // Iterate from end to beginning. So we dont move nodes from end to wrong position
            if (toRemove.items.len > 0) {
                var i: usize = toRemove.items.len - 1;
                std.debug.print("Iintitein: {}\n", .{i});
                while (i >= 0) {
                    const idx = toRemove.items[i];
                    _ = self.bodies.swapRemove(idx);
                    _ = self.accels.swapRemove(idx);

                    if (i == 0) {
                        break;
                    } else {
                        i -= 1;
                    }
                }
            }
        }

        pub fn step(self: *Self, delta: f32) !void {
            try self.mergeSamePositions();

            self.tree.clean();

            for (self.bodies.items) |body| {
                try self.tree.addBody(@intFromFloat(body.mass), body.position);
            }

            self.tree.finalize();
            for (self.bodies.items, 0..) |body, i| {
                self.tree.step(delta, .{ //
                    .force = &self.accels.items[i],
                    .bodyPos = body.position,
                    .bodyMass = @intFromFloat(body.mass),
                });
            }
            // _ = delta;

            self.applyForces(20);
        }

        const G = 1.5;
        /// Apply forces to velocity
        fn applyForces(self: *Self, delta: f32) void {
            // _ = delta; // autofix
            for (self.accels.items, self.bodies.items) |*accel, *body| {

                // const mass: f32 = @floatFromInt(body.mass);

                // std.debug.print("Force: X: {d}, Y: {d}\n", .{ force.x, force.y });

                if (accel.x != 0) {
                    // const accelerationX: f32 = .x / body.mass;
                    const accelerationX = accel.x;
                    body.velocity.x += accelerationX * delta * G;
                }
                if (accel.y != 0) {
                    // const accelerationY: f32 = force.y / body.mass;
                    const accelerationY = accel.y;
                    body.velocity.y += accelerationY * delta * G;
                }
                if (body.velocity.x < 0) {
                    const diff = -body.velocity.x * delta;
                    // u32 should not be less than zero
                    if (diff < body.position.x) {
                        body.position.x -= diff;
                    }
                } else {
                    const diff = body.velocity.x * delta;
                    const s: f32 = @floatFromInt(self.tree.size);
                    if (diff + body.position.x < s) {
                        body.position.x += diff;
                    }
                }
                if (body.velocity.y < 0) {
                    const diff = -body.velocity.y * delta;
                    // u32 should not be less than zero
                    if (diff < body.position.y) {
                        body.position.y -= diff;
                    }
                } else {
                    const diff = body.velocity.y * delta;
                    const s: f32 = @floatFromInt(self.tree.size);
                    if (diff + body.position.y < s) {
                        body.position.y += diff;
                    }
                }

                // body.position.x = std.math.clamp(u32, , )

                accel.* = .{};
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
