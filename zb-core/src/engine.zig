const tree = @import("tree.zig");
const Body = @import("body.zig");
const std = @import("std");
const vec2 = @import("vec2.zig");
const Vec2F = vec2.Vec2F;
const Vec2 = vec2.Vec2;
const ztracy = @import("ztracy");
const time = std.time;
const Instant = time.Instant;

const List = std.ArrayList;

pub fn Engine() type {
    return struct { //
        tree: tree.Tree(),
        bodies: List(Body),
        accels: List(Vec2F),

        /// Amount of thread being used in execution
        /// Its dynamic value and changes on runtime
        /// Call `fixThreadAmount` to specify fixed amount
        thread_amount: usize = 32,
        is_fixed: bool = false,

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

        pub fn fixThreadAmount(self: *Self, amount: usize) void {
            self.is_fixed = true;
            self.thread_amount = amount;
        }

        pub fn unfixThreadAmount(self: *Self) void {
            self.is_fixed = false;
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

        /// Returns the smallest power of two that is greater than or equal to the input `x`.
        ///
        /// Parameters:
        /// * `x`: A `u32` value.
        ///
        /// Return Value:
        /// A `u32` value representing the smallest power of two that is greater than or equal to `x`.
        ///
        /// Example:
        /// ```zig
        /// const x: u32 = 17;
        /// const next_pow2 = nextPowerOfTwo(x);
        /// std.debug.print("Next power of two: {}\n", .{next_pow2}); // Output: 32
        /// ```
        ///
        /// Notes:
        /// This function uses a bitwise trick to find the next power of two. It works by setting all the bits to the right of the most significant set bit in `x` to 1, and then adding 1 to the result. This effectively "rounds up" `x` to the next power of two.
        ///
        /// Performance:
        /// This function has a constant time complexity of O(1), making it very efficient for finding the next power of two.
        ///
        /// Limitations:
        /// This function only works for `u32` values. If you need to support larger integers, you'll need to modify the function accordingly.
        fn nextPowerOfTwo(x: i32) u32 {
            const abs_x = if (x < 0) -x else x;
            var u_x: u32 = @intCast(abs_x);
            u_x |= u_x >> 1;
            u_x |= u_x >> 2;
            u_x |= u_x >> 4;
            u_x |= u_x >> 8;
            u_x |= u_x >> 16;
            return u_x + 1;
        }

        /// Run through all nodes and find out if we need to extend the tree
        /// Returns amount in pixels to offset object in order to make size change smooth and sound
        pub fn fitBodies(self: *Self) !u32 {
            var is_move = false;
            var move_amount: u32 = 0;

            for (self.bodies.items) |body| {
                const size: f32 = @floatFromInt(self.tree.size);
                const max = vec2.max(f32, body.position);
                const min = vec2.min(f32, body.position);

                if (max > size)
                    self.tree.size = nextPowerOfTwo(@intFromFloat(max))
                else if (min < 0) {
                    is_move = true;
                    move_amount = ((nextPowerOfTwo(@intFromFloat(min)) / self.tree.size) + 1) * self.tree.size;
                }
            }

            if (is_move) {
                self.moveBodies(move_amount);

                // Could happen that after moving to new position there is something out of bound again
                // We can ignore output, since we know we wont need to move it again
                _ = try self.fitBodies();
            }

            return move_amount;
        }

        /// Move all bodies to right and bottom by given amount
        /// It is usefull when you need to extend your space, but since we are using only positive coordinates, we need to extend the zone
        fn moveBodies(self: *Self, amount: u32) void {
            for (self.bodies.items) |*body|
                body.position += @splat(@floatFromInt(amount));
        }

        pub fn getCenterOfMass(self: Self) ?Vec2F {
            if (self.tree.root) |root|
                return root.coordinates()
            else
                return null;
        }

        pub fn mergeSamePositions(self: *Self) !void {
            // Create a tracing zone to measure the performance of this function
            const zone = ztracy.Zone(@src());
            defer zone.End();
            // Create a hashmap to store the positions and indices of the bodies
            var positions = std.AutoHashMap(Vec2, usize).init(ally);
            var toRemove = std.ArrayList(usize).init(ally);

            // Create an array list to store the indices of the bodies to be removed
            defer positions.deinit();
            defer toRemove.deinit();

            for (self.bodies.items, 0..) |body, i|
                // Check if there is already a body at the same position
                if (positions.get(vec2.convert(u32, body.position))) |index| {
                    // Get the existing body
                    var existing = &self.bodies.items[index];

                    // Calculate the masses of the existing and new bodies
                    const existing_mass: Vec2F = @splat(existing.mass);
                    const to_remove_mass: Vec2F = @splat(body.mass);

                    // Keep it balanced :)
                    existing.velocity = (existing.velocity * existing_mass + body.velocity * to_remove_mass) / (existing_mass + to_remove_mass);
                    existing.mass += body.mass;

                    // Add the index of the new body to the list of bodies to be removed
                    try toRemove.append(i);
                } else

                // If there is no body at the same position, add the new body to the hashmap
                try positions.put(vec2.convert(u32, body.position), i);

            // TODO: Refactor
            // Iterate over the list of bodies to be removed in reverse order
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
            _ = delta; // autofix
            const zone = ztracy.Zone(@src());
            defer zone.End();

            try self.mergeSamePositions();
            try self.addBodiesToTree();
            try self.stepEachTreeBody();

            self.applyAcceleration(20);
        }

        fn addBodiesToTree(self: *Self) !void {
            const zone = ztracy.Zone(@src());
            defer zone.End();
            self.tree.clean();
            // const num_threads: usize = 3; // adjust this to your liking
            for (self.bodies.items) |body| {
                try self.tree.addBody(@intFromFloat(body.mass), body.position);
            }

            self.tree.finalize();
        }

        fn parallelLoop(self: *Self, thread_id: usize, num_elements: usize, num_threads: usize) !void {
            const chunk_size: usize = num_elements / num_threads;
            const remainder: usize = num_elements % num_threads;

            // std.debug.print("Remainder: {}\n", .{remainder});

            const start: usize = thread_id * chunk_size;
            // std.debug.print("Start: {}\n", .{start});

            const end: usize = start + chunk_size + if (num_threads - 1 == thread_id) remainder else 0;
            // std.debug.print("End: {}\n", .{end});

            for (self.bodies.items[start..end], start..) |*body, i| {
                body.assigned_thread = thread_id;
                self.tree.step(0, .{ //
                    .accel = &self.accels.items[i],
                    .bodyPos = body.position,
                    .bodyMass = @intFromFloat(body.mass),
                });
            }
        }

        fn stepEachTreeBody(self: *Self) !void {
            const start = try Instant.now();
            const zone = ztracy.Zone(@src());
            defer zone.End();
            const num_threads: usize = 8; // adjust this to your liking
            // const num_threads: usize = if (self.bodies.items.len < self.thread_amount) 1 else 4; // adjust this to your liking
            if (self.bodies.items.len == 0) {
                return;
            } else if (self.bodies.items.len <= num_threads or num_threads == 1) {
                for (self.bodies.items, 0..) |body, i|
                    self.tree.step(0, .{ //
                        .accel = &self.accels.items[i],
                        .bodyPos = body.position,
                        .bodyMass = @intFromFloat(body.mass),
                    });
                return;
            }

            const num_elements = self.bodies.items.len; // adjust this to your liking
            std.debug.print("New round \n \n Total objects: {}\n", .{num_elements});

            // Create threads
            var threads: [num_threads]std.Thread = undefined;
            for (&threads, 0..) |*thread, i|
                thread.* = try std.Thread.spawn(.{}, parallelLoop, .{
                    self,
                    i,
                    num_elements,
                    num_threads,
                });

            for (threads) |thread|
                thread.join();

            const end = try Instant.now();
            const elapsed1: f64 = @floatFromInt(end.since(start));
            std.debug.print("Time elapsed is: {d:.3}ms\n", .{
                elapsed1 / time.ns_per_ms,
            });
        }

        /// Apply accelerations to velocity
        fn applyAcceleration(self: *Self, delta: f32) void {
            const zone = ztracy.Zone(@src());
            defer zone.End();
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
