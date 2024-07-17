const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const alloc = std.heap.page_allocator;

pub fn Tree() type {
    return struct {
        /// Building block of the quad tree.
        /// Node is wether a branch or leaf.
        pub const Node = union(enum) {
            const Branch =
                struct {
                // Queadtree needs to reference subnodes
                children: [4]?*Node,
                // Center of mass in region
                centerOfMass: Vec2,
                // Total mass
                mass: u32,
                /// Width and Height occupied by this branch
                size: u32,
                /// Find out in which quadrant should we put node with given position
                pub fn which(self: @This(), position: Vec2) u2 {
                    const node = Node{ .branch = self };
                    return node.which(position);
                }
            };
            const Leaf = struct {
                //
                mass: u32 = 0,
                position: Vec2 = .{},
                /// Quadrant size
                size: u32,
            };

            // Enum / Union Variants
            leaf: Leaf,
            branch: Branch,
            /// Split leaf on branch and move body to new leaf
            /// Transform leaf to the branch
            /// Also allocate a new leaf
            fn split(self: *@This()) !void {
                // TODO: Not leaf check

                // Allocate
                var node = try ally.create(Node);
                node.* = Node{ .leaf = .{ .size = 0 } };
                var leaf = &node.leaf;

                leaf.* = self.leaf;

                var branch = Branch{
                    // We will push leaf to corresponding child later
                    .children = .{null} ** 4,
                    // Center of mass does not change, since we have only one leaf at the moment
                    // Only the next iteration should modify center of mass
                    .centerOfMass = leaf.position,
                    .mass = leaf.mass,
                    .size = leaf.size,
                };

                self.* = Node{ .branch = branch };

                // TODO: Safetychecks on 0
                if (leaf.size == 1) {
                    return;
                }
                leaf.size /= 2;

                // Ask a new branch where to put leaf
                const quadrant = branch.which(leaf.position);

                // TODO: Move into leaf struct itself
                // Fit leaf's position to new quadrant which is 2 times smaller
                leaf.position = leaf.position.fit(leaf.size);
                // var newNode = ally.alloc(Node, 1);

                // self.position.fit();
                // TODO: Should be This with modified position
                self.branch.children[quadrant] = node;
                // return branch;
            }

            fn newLeaf(mass: u32, position: Vec2) Node {
                return .{
                    .leaf = .{
                        //
                        .mass = mass,
                        .position = position,
                    },
                };
            }

            fn size(self: @This()) u32 {
                return switch (self) {
                    inline else => |case| case.size,
                };
            }

            /// Find out in which quadrant should we put node with given position
            /// Can return error if position is out of bound
            fn which(self: @This(), position: Vec2) u2 {
                const half = self.size() / 2;

                const x: u2 = if (position.x < half) 0 else 1;
                const y: u2 = if (position.y < half) 0 else 1;
                return (x + y * 2);
            }

            /// Show what are spatial coordinates of child
            fn where(self: @This(), quadrant: u2) Vec2 {
                //
                const i = quadrant;
                const s = self.size() / 2;

                // Reference implementation from Venx:
                // UVec3::new(i & 1, (i >> 1) & 1,
                var v = Vec2{ //
                    .x = i & 1,
                    .y = (i >> 1) & 1,
                };
                v.x *= s;
                v.y *= s;
                return v;
            }
        };

        const Self = @This();

        // TODO: Find better allocator
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const ally = arena.allocator();

        root: ?*Node = null,
        /// Must be fraction of 2. e.g.:
        /// 16, 32, 64, 128, 256, 512, 1024,
        /// And not:
        /// 3, 88, 194, 666, 777
        size: u32,

        /// Create new QuadTree
        pub fn init(comptime size: u32) !Self {
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
        pub fn addBody(self: *@This(), mass: u32, position: Vec2) !void {
            if (position.max() >= self.size) {
                return ErrorError.Abc;
            }
            try Tree().visitNode(&self.root, mass, position, self.size);
        }

        fn visitNode(node: *?*Node, mass: u32, position: Vec2, size: u32) !void {
            if (node.*) |n| {
                // There is already node on the given spot
                // TODO: Throw runtime error or warning
                // TODO: refactor
                switch (n.*) {
                    // We dont care if its branch,
                    // Cuz if it is, than there is more than one leaf and we cannot determine if position is actually the same
                    .leaf => |leaf| {
                        if (position.x == leaf.position.x and position.y == leaf.position.y) {
                            return;
                        }
                    },
                    else => {},
                }

                // In *which* *quadrant* do we want to put this node
                const quadrant = n.which(position);

                // If we have our node being something (not a null) we always need it to be a branch.
                // But it can be a Branch or a Leaf.
                // We dont want it to be a Leaf, so in case it is, we just split it.

                switch (n.*) {
                    // Split and move current leaf one level below
                    .leaf => try n.split(),
                    else => {},
                }

                // Call it recursivly
                try Tree().visitNode(
                // Formatter
                // &branch.children[quadrant],
                @constCast(&n.branch.children[quadrant]),
                // Why are you
                mass,
                // Not working correctly??
                position.fit(size / 2),
                //
                size / 2);
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

        /// Convert position and node full size
        fn which(position: Vec2, size: u32) u2 {
            const half = size / 2;
            const x: u2 = if (position.x < half) 0 else 1;
            const y: u2 = if (position.y < half) 0 else 1;
            return (x + y * 2);
        }
        /// Internal index of node converted to normalized vector
        // pub fn get_child_position(i: u32) -> UVec3 {
        //     UVec3::new(i & 1, (i >> 1) & 1, (i >> 2) & 1)
        // }
        // /// Convert position of node in 3d space coordinate to internal child branch index
        // pub fn get_child_index(pos: UVec3, level: usize) -> usize {
        //     let child_size = 1 << level;
        //     let x = if pos.x < child_size { 0 } else { 1 };
        //     let y = if pos.y < child_size { 0 } else { 1 };
        //     let z = if pos.z < child_size { 0 } else { 1 };
        //     (x + y * 2 + z * 4) as usize
        // }

        /// Delete all bodies
        pub fn clean(self: *Self) void {
            // TODO: Memory leak possibility
            self.root = null;
        }

        /// Make a step in simulation
        /// Delta needed to make it smooth
        /// For example if program runs at 60 fps, than delta will be 16ms
        pub fn step(self: Self, delta: f32) void {
            _ = delta; // autofix
            self.traverse(a);
        }

        fn a(e: i32) i32 {
            const b = 1;
            std.debug.print("{}", .{e});
            return e + b;
        }

        pub fn traverse(self: Self) void {
            Self.visitNodeTraverse(@constCast(&self.root), .{}, cb);
        }

        fn cb(node: *Node, position: Vec2) void {
            switch (node.*) {
                .leaf => |leaf| {
                    _ = leaf; // autofix

                    std.debug.print("Leaf Position: {?} \n", .{position});
                },
                .branch => |branch| {
                    _ = branch; // autofix
                    std.debug.print("Branch Position: {?} \n", .{node.branch.mass});
                },
            }
        }

        fn visitNodeTraverse(node: *?*Node, position: Vec2, callback: fn (*Node, Vec2) void) void {
            if (node.*) |n| {
                switch (n.*) {
                    .leaf => |leaf| {
                        var p = position;
                        p.x += leaf.position.x;
                        p.y += leaf.position.y;
                        cb(n, p);
                    },
                    .branch => |branch| {
                        for (branch.children, 0..) |child, quadrant| {
                            var qPosition = n.where(@intCast(quadrant));
                            // std.debug.print("qPos: {?}", .{qPosition});
                            qPosition.x += position.x;
                            qPosition.y += position.y;

                            Self.visitNodeTraverse(@constCast(&child), qPosition, callback);
                        }
                    },
                }
            } else {}
        }
    };
}
// TODO: Move in other module
const ErrorError = error{
    Abc,
};

const tt = std.testing;

test "init tree test" {
    // TODO
}

test "init tree, 2 bodies test" {
    // TODO
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
    // You should get this error: Bad value, size should be a power of two.
    _ = try Tree().init(99);
}

test "add body with same position" {
    var tr = try Tree().init(64);

    try tr.addBody(11, .{ .x = 0, .y = 1 });
    try tr.addBody(12, .{ .x = 8, .y = 8 });
    try tr.addBody(13, .{ .x = 10, .y = 0 });
    try tr.addBody(14, .{ .x = 0, .y = 10 });

    var tr2 = try Tree().init(64);

    try tr2.addBody(11, .{ .x = 0, .y = 1 });
    try tr2.addBody(12, .{ .x = 8, .y = 8 });
    try tr2.addBody(13, .{ .x = 10, .y = 0 });
    try tr2.addBody(14, .{ .x = 0, .y = 10 });
    // Add the same body
    try tr2.addBody(14, .{ .x = 0, .y = 10 });

    try tt.expectEqualDeep(tr, tr2);
}

test "traverse leafs and check positions" {
    var tr = try Tree().init(64);

    try tr.addBody(11, .{ .x = 0, .y = 1 });
    try tr.addBody(12, .{ .x = 8, .y = 8 });
    try tr.addBody(13, .{ .x = 10, .y = 0 });
    try tr.addBody(14, .{ .x = 0, .y = 10 });

    // TODO: Do actual testing
    // Rn just watch the output and compare with values above
    tr.traverse();
}

test "Add node outside the bound" {
    std.debug.print("New test starting\n", .{});
    var tr = try Tree().init(16);

    // Outside of 16
    try tt.expectError(ErrorError.Abc, tr.addBody(11, .{ .x = 0, .y = 22 }));
}
