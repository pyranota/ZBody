const tree = @import("tree.zig");
const Body = @import("body.zig");
const std = @import("std");
const vec2 = @import("vec2.zig");
const Vec2F = vec2.Vec2F;
const Vec2 = vec2.Vec2;

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
            try self.accels.append(@splat(0));
        }

        pub fn print(self: *Self) !void {
            try self.tree.print();
        }

        pub fn showBounds(self: Self, comptime callb: anytype) !void {
            try self.tree.showBounds(callb);
        }

        pub fn showForceBounds(self: Self, targetPosition: Vec2F, callb: anytype) !void {
            try self.tree.showForceBounds(.{ targetPosition, callb });
        }

        pub fn mergeSamePositions(self: *Self) !void {
            // Store position and index of body
            var positions = std.AutoHashMap(Vec2, usize).init(ally);
            var toRemove = std.ArrayList(usize).init(ally);

            defer positions.deinit();
            defer toRemove.deinit();

            for (self.bodies.items, 0..) |body, i|
                if (positions.get(vec2.convert(u32, body.position))) |index| {
                    var existing = &self.bodies.items[index];

                    const existing_mass: Vec2F = @splat(existing.mass);
                    const to_remove_mass: Vec2F = @splat(body.mass);

                    // Keep it balanced :)
                    existing.velocity = (existing.velocity * existing_mass + body.velocity * to_remove_mass) / (existing_mass + to_remove_mass);
                    existing.mass += body.mass;

                    try toRemove.append(i);
                } else try positions.put(vec2.convert(u32, body.position), i);

            // Iterate from end to beginning. So we dont move nodes from end to wrong position
            if (toRemove.items.len > 0) {
                var i: usize = toRemove.items.len - 1;
                while (i >= 0) {
                    const idx = toRemove.items[i];
                    _ = self.bodies.swapRemove(idx);
                    _ = self.accels.swapRemove(idx);

                    if (i == 0)
                        break
                    else
                        i -= 1;
                }
            }
        }

        pub fn step(self: *Self, delta: f32) !void {
            try self.mergeSamePositions();

            self.tree.clean();

            for (self.bodies.items) |body|
                try self.tree.addBody(@intFromFloat(body.mass), body.position);

            self.tree.finalize();
            for (self.bodies.items, 0..) |body, i|
                self.tree.step(delta, .{ //
                    .accel = &self.accels.items[i],
                    .bodyPos = body.position,
                    .bodyMass = @intFromFloat(body.mass),
                });

            self.applyAcceleration(20);
        }

        /// Apply accelerations to velocity
        fn applyAcceleration(self: *Self, delta: f32) void {
            for (self.accels.items, self.bodies.items) |*accel, *body| {
                const sd: Vec2F = @splat(delta);

                body.velocity += accel.* * sd;
                body.position += body.velocity * sd;

                accel.* = @splat(0);
            }
        }
    };
}

test "init engine" {
    var engine = try Engine().init(16);
    defer engine.deinit();

    try engine.addBody(.{});
}
