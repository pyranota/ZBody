const tree = @import("tree.zig");
const Body = @import("body.zig");
const std = @import("std");
const Vec2F = @import("./vec2.zig").Vec2F;
const List = std.ArrayList;

pub fn Engine() type {
    return struct { //
        tree: tree.Tree(),
        bodies: List(Body),
        accelerations: List(Vec2F),

        const Self = @This();

        // TODO: Find better allocator
        const ally = std.heap.page_allocator;

        pub fn init(comptime size: u32) !Self {
            return .{ //
                .tree = try tree.Tree().init(size),
                .bodies = List(Body).init(ally),
                .accelerations = List(Vec2F).init(ally),
            };
        }

        pub fn deinit(self: *Self) void {
            self.bodies.deinit();
            self.tree.deinit();
            self.accelerations.deinit();
        }

        pub fn addBody(self: *Self, body: Body) !void {
            try self.bodies.append(body);
        }

        pub fn print(self: *Self) !void {
            try self.tree.print();
        }

        pub fn step(self: *Self, delta: f32) !void {
            self.tree.clean();
            for (self.bodies.items) |body| {
                try self.tree.addBody(body.mass, body.position);
            }
            _ = delta; // autofix

        }
    };
}

test "init engine" {
    var engine = Engine().init(16);
    defer engine.deinit();

    try engine.addBody(.{});
}
