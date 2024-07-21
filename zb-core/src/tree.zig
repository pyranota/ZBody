const std = @import("std");
const vec2 = @import("vec2.zig");
const Vec2 = vec2.Vec2;
const Vec2F = vec2.Vec2F;
const TreeError = @import("error.zig").TreeError;
const callbacks = @import("callbacks.zig");
const Node = @import("node.zig").Node;

const alloc = std.heap.page_allocator;

pub fn Tree() type {
    return struct {
        const Self = @This();

        // TODO: Remove allocators
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const ally = arena.allocator();

        // TODO: Make dynamic and smart
        // TODO: Prevent from being 0 or 1
        pub const threshhold: f32 = 0.9;
        pub const safety: f32 = 1000000000;

        root: ?*Node = null,
        // TODO: Make dynamic?
        /// Must be fraction of 2. e.g.:
        /// 16, 32, 64, 128, 256, 512, 1024,
        /// And not:
        /// 3, 88, 194, 666, 777
        size: u32,
        final: bool = false,

        /// Create new QuadTree
        pub fn init(comptime size: u32) !Self {
            // TODO: Use math.isPowOfTwo
            if (!((size & (size - 1)) == 0)) {
                @compileError("Bad value, size should be a power of two.");
            }
            return .{ .size = size };
        }
        /// Deinit QuadTree
        pub fn deinit(_: @This()) void {
            arena.deinit();
        }

        pub fn print(self: Self) !void {
            try @import("pretty").print(alloc, self, .{ .max_depth = 0 });
        }

        /// Add Astronomical Body to the System
        pub fn addBody(self: *@This(), mass: u32, position: Vec2F) !void {
            const positionF = vec2.convert(u32, position);
            if (@max(positionF[0], positionF[1]) >= self.size)
                return TreeError.PositionOutOfBound;

            try Tree().visitNode(&self.root, mass, position, self.size);
        }

        fn visitNode(node: *?*Node, mass: u32, position: Vec2F, size: u32) !void {
            if (node.*) |n| {

                // If we have our node being something (not a null) we always need it to be a branch.
                // But it can be a Branch or a Leaf.
                // We dont want it to be a Leaf, so in case it is, we just split it.

                if (n.* == Node.leaf)
                    if (vec2.isEq(u32, n.leaf.position, position))
                        // There is already node on the given spot
                        return TreeError.BodyAtGivenPositionAlreadyExist
                    else
                        try n.split();

                // In *which* *quadrant* do we want to put this node
                const quadrant = n.which(vec2.convert(u32, position));

                var br = &n.branch;

                // Call it recursivly
                try Tree().visitNode(
                    // Formatter
                    // &branch.children[quadrant],
                    @constCast(&br.children[quadrant]),
                    // Why are you
                    mass,
                    // Not working correctly??
                    vec2.fit(f32, position, size / 2),
                    //
                    size / 2,
                );
                // Add mass
                // Its actually pretty clever solution.
                // As you can see, we dont want to change branches (modify its mass or/and center of mass)
                // until we know that we place new node.
                // In some cases we dont want to place a node and return an error.
                // In order for this to work we put mass and center of mass modification logic after recursion
                // In other words if `try` statement above will fail, this mass modificatin will not occure and tree wont be modified
                // But if it works correctly we use stacked values to modify needed values in inverted order (from bottom to up).
                br.mass += mass;
                const m: Vec2F = @splat(@floatFromInt(mass));
                br.centerOfMass += position * m;
            }
            // Here our journey ends. We found a null node and can use it.
            else {
                const newNode = try ally.create(Node);
                newNode.* = Node{
                    .leaf = .{
                        //
                        .mass = mass,
                        .position = position,
                        .size = size,
                    },
                };
                node.* = newNode;
            }
        }

        // TODO: Remove
        /// Convert position and node full size
        pub fn which(position: Vec2, size: u32) u2 {
            const half = size / 2;
            const x: u2 = if (position[0] < half) 0 else 1;
            const y: u2 = if (position[1] < half) 0 else 1;
            return (x + y * 2);
        }

        /// Delete all bodies
        pub fn clean(self: *Self) void {
            // TODO: Memory leak possibility
            self.root = null;
        }

        // TODO: Remove delta
        pub fn step(self: Self, delta: f32, args: callbacks.stepArgs) void {
            _ = delta; // autofix
            self.traverse(callbacks.calcForcesCB, args) catch unreachable;
        }

        pub fn finalize(self: *Self) void {
            self.final = true;
            self.traverse(callbacks.finalizeCB, .{}) catch unreachable;
        }

        pub fn showForceBounds(self: Self, args: anytype) !void {
            // TODO: Fix. its crashing if there is just one node
            args.@"1"(@splat(0), self.size, if (self.root) |root| root.branch.centerOfMass else null);
            try self.traverse(callbacks.forceBoundsCB, args);
        }

        pub fn showBounds(self: Self, callb: anytype) !void {
            callb(@splat(0), self.size);
            try self.traverse(callbacks.treeBoundsCB, callb);
        }

        /// Takes callback which optionally returns boolean.
        pub fn traverse(self: Self, callback: anytype, args: anytype) !void {
            if (!self.final)
                return TreeError.NotFinalized;

            Self.visitNodeTraverse(@constCast(&self.root), @splat(0), callback, args);
        }

        fn visitNodeTraverse(node: *?*Node, position: Vec2, comptime callback: anytype, args: anytype) void {
            const info = @typeInfo(@TypeOf(callback));

            if (node.*) |n| {
                if (info.Fn.return_type == void)
                    // TODO: Remove pointer to node from callback
                    callback(n, position, args)
                else if (!callback(n, position, args))
                    return;

                switch (n.*) {
                    .leaf => {},
                    .branch => |branch| for (branch.children, 0..) |child, quadrant| {
                        const qPosition = n.where(@intCast(quadrant)) + position;
                        Self.visitNodeTraverse(@constCast(&child), qPosition, callback, args);
                    },
                }
            }
        }
    };
}

const tt = std.testing;

test "mass" {
    std.debug.print("New test starting\n", .{});
    // TODO
    var tr = try Tree().init(64);

    try tr.addBody(10, .{ 0, 0 });
    try tr.addBody(20, .{ 9, 9 });
    try tr.addBody(50, .{ 19, 12 });
    // try tr.print();
    try tt.expectEqual((10 + 20 + 50), tr.root.?.branch.mass);
    std.debug.print("Actual mass: {?}", .{tr.root.?.branch.mass});
    std.debug.print("Test is finished\n\n\n\n", .{});
}

test "center of mass" {
    var tr = try Tree().init(64);

    try tr.addBody(10, .{ 0, 7 });
    try tr.addBody(20, .{ 9, 15 });
    try tr.addBody(50, .{ 19, 12 });

    tr.finalize();

    try tr.print();
}

test "init tree with wrong size" {
    // Right sizes
    _ = try Tree().init(16);
    _ = try Tree().init(8);
    _ = try Tree().init(64);
    _ = try Tree().init(1024);

    // Wrong size
    // Cant test it, becauze it raises compile time error if size is wrong
    // In order to run tests, we need to compile first
    //
    // Uncomment next line to test if it fails to build

    // _ = try Tree().init(99);

    // You should get this error: Bad value, size should be a power of two.
}

test "add body with same position" {
    var tr = try Tree().init(64);

    try tr.addBody(11, .{ 0, 1 });
    try tr.addBody(12, .{ 8, 8 });
    try tr.addBody(13, .{ 10, 0 });
    try tr.addBody(14, .{ 0, 10 });

    var tr2 = try Tree().init(64);

    try tr2.addBody(11, .{ 0, 1 });
    try tr2.addBody(12, .{ 8, 8 });
    try tr2.addBody(13, .{ 10, 0 });
    try tr2.addBody(14, .{ 0, 10 });
    // Add the same body
    try tt.expectError(TreeError.BodyAtGivenPositionAlreadyExist, tr2.addBody(14, .{ 0, 10 }));

    try tt.expectEqualDeep(tr, tr2);
}

test "traverse leafs and check positions" {
    var tr = try Tree().init(64);

    try tr.addBody(11, .{ 0, 1 });
    try tr.addBody(12, .{ 8, 8 });
    try tr.addBody(13, .{ 10, 0 });
    try tr.addBody(14, .{ 0, 10 });

    tr.finalize();
    // TODO: Do actual testing
    // Rn just watch the output and compare with values above
    try tr.traverse();
}

test "traverse without finalizing" {
    var tr = try Tree().init(64);
    try tt.expectError(TreeError.NotFinalized, tr.traverse());
}

test "Add node outside the bound" {
    std.debug.print("New test starting\n", .{});
    var tr = try Tree().init(16);

    // Outside of 16
    try tt.expectError(TreeError.Abc, tr.addBody(11, .{ 0, 22 }));
}
