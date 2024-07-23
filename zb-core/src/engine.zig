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

        pub fn mergeSamePositions(self: *Self) !void {
            const zone = ztracy.Zone(@src());
            defer zone.End();
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
            // TODO: Refactor
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

            // if (self.bodies.items.len < num_threads) {
            //     self.tree.finalize();
            //     return;
            // }

            // const num_elements = self.bodies.items.len; // adjust this to your liking

            // std.debug.print("New round \n \n Total objects: {}\n", .{num_elements});
            // // Create threads
            // var threads: [num_threads]std.Thread = undefined;
            // for (&threads, 0..) |*thread, i| {
            //     // _ = thread; // autofix
            //     thread.* = try std.Thread.spawn(.{}, parallelLoop, .{
            //         self,
            //         i,
            //         num_elements,
            //         num_threads,
            //     });
            //     // try self.parallelLoop(i, num_elements, num_threads);
            // }

            // // // Wait for all threads to finish
            // for (threads) |thread|
            //     thread.join();

            self.tree.finalize();
        }

        fn parallelLoop(self: *Self, thread_id: usize, num_elements: usize, num_threads: usize) !void {
            // const start = thread_id * (num_elements / num_threads);
            // // const end = if (thread_id == num_threads - 1) num_elements else (thread_id + 1) * (num_elements / num_threads);
            // const end = start + (num_elements / num_threads);
            // Dont ask...
            // const ONE: usize = 1;
            // const ZERO: usize = 0;

            const chunk_size: usize = num_elements / num_threads;
            const remainder: usize = num_elements % num_threads;

            // std.debug.print("Remainder: {}\n", .{remainder});

            const start: usize = thread_id * chunk_size;
            // std.debug.print("Start: {}\n", .{start});
            // const re = thread_id < remainder;

            const end: usize = start + chunk_size + if (num_threads - 1 == thread_id) remainder else 0;
            // std.debug.print("End: {}\n", .{end});

            for (self.bodies.items[start..end], start..) |body, i|
                self.tree.step(0, .{ //
                    .accel = &self.accels.items[i],
                    .bodyPos = body.position,
                    .bodyMass = @intFromFloat(body.mass),
                });
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
            for (&threads, 0..) |*thread, i| {
                // _ = thread; // autofix
                thread.* = try std.Thread.spawn(.{}, parallelLoop, .{
                    self,
                    i,
                    num_elements,
                    num_threads,
                });
                // try self.parallelLoop(i, num_elements, num_threads);
            }

            // // Wait for all threads to finish
            for (threads) |thread|
                thread.join();

            // for (self.bodies.items, 0..) |body, i|
            //     self.tree.step(0, .{ //
            //         .accel = &self.accels.items[i],
            //         .bodyPos = body.position,
            //         .bodyMass = @intFromFloat(body.mass),
            //     });
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
