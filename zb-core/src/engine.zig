const tree = @import("tree.zig");
const Body = @import("body.zig");
const std = @import("std");
const List = std.ArrayList;

pub fn Engine() type {
    return struct { //
        tree: tree.Tree(),
        bodies: List(Body),

        const Self = @This();

        // TODO: Find better allocator
        const ally = std.heap.page_allocator;

        pub fn init(size: u32) Self {
            return .{ //
                .tree = tree.Tree().init(size),
                .bodies = List(Body).init(ally),
            };
        }

        pub fn deinit(self: *Self) void {
            self.bodies.deinit();
        }

        pub fn addBody(self: *Self, body: Body) !void {
            try self.bodies.append(body);
        }

        pub fn step(self: *Self, delta: f32) void {
            self.tree.clean();
            for (self.bodies) |body| {
                self.tree.addBody(body.mass, body.position);
            }
            _ = delta; // autofix

        }
    };
}

test "init engine" {
    var engine = Engine().init(10);
    defer engine.deinit();

    try engine.addBody(.{});
}
