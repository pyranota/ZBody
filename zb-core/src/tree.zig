const std = @import("std");
const Vec2 = @import("vec2.zig");
const pretty = @import("pretty");
const alloc = std.heap.page_allocator;

pub fn Tree() type {
    return struct {
        /// Building block of the quad tree.
        /// Node is wether a branch or leaf.
        const Node = union(enum) {
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
                    const half = self.size / 2;
                    const x: u2 = if (position.x < half) 0 else 1;
                    const y: u2 = if (position.y < half) 0 else 1;
                    return (x + y * 2);
                }
            };
            const Leaf = struct {
                //
                mass: u32 = 0,
                position: Vec2 = .{},
                /// Quadrant size
                size: u32,
                /// Split leaf on branch and move body to new leaf
                fn split(self: @This()) Branch {
                    var branch = Branch{
                        // We will push leaf to corresponding child later
                        .children = .{null} ** 4,
                        // Center of mass does not change, since we have only one leaf at the moment
                        // Only the next iteration should modify center of mass
                        .centerOfMass = self.position,
                        .mass = self.mass,
                        .size = self.size,
                    };

                    // Copy
                    var leaf = self;

                    // TODO: Safetychecks on 0
                    leaf.size /= 2;

                    // Ask a new branch where to put leaf
                    const quadrant = branch.which(self.position);

                    // Fit leaf's position to new quadrant which is 2 times smaller
                    leaf.position = leaf.position.fit(self.size);

                    // self.position.fit();
                    // TODO: Should be This with modified position
                    branch.children[quadrant] = @constCast(&Node{ .leaf = leaf });
                    return branch;
                }
            };

            // One of those:
            leaf: Leaf,
            branch: Branch,

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
            fn which(self: @This(), position: Vec2) u2 {
                const half = switch (self) {
                    inline else => |case| case.size,
                } / 2;

                const x: u2 = if (position.x < half) 0 else 1;
                const y: u2 = if (position.y < half) 0 else 1;
                return (x + y * 2);
            }

            // /// Add body to the system
            // pub fn addBody(self: *Self, mass: u32, position: Vec2) !void {
            //     if (self.root) |root| {
            //         _ = root;
            //         // If leaf -> split
            //     } else {
            //         self.root = Node.newLeaf(mass, position);
            //     }
            // }
        };

        const Self = @This();

        root: ?*Node,
        /// Must be fraction of 2. e.g.:
        /// 16, 32, 64, 128, 256, 512, 1024,
        /// And not:
        /// 3, 88, 194, 666, 777
        size: u32,

        /// Create new QuadTree
        pub fn init(size: u32) Self {
            return .{ .root = null, .size = size };
        }

        pub fn print(self: Self) !void {
            try pretty.print(alloc, self, .{ .max_depth = 0 });
        }

        /// Add Astronomical Body to the System
        pub fn addBody(self: *@This(), mass: u32, position: Vec2) void {
            Tree().visitNode(&self.root, mass, position, self.size);
        }

        fn visitNode(node: *?*Node, mass: u32, position: Vec2, size: u32) void {
            if (node.*) |n| {

                // In *which* *quadrant* do we want to put this node
                const quadrant = n.which(position);
                std.debug.print("QUADRANT: {}", .{quadrant});

                // If we have our node being something (not a null) we always need it to be a branch.
                // But it can be a Branch or a Leaf.
                // We dont want it to be a Leaf, so in case it is, we just split it.

                const branch = switch (n.*) {
                    //
                    .branch => |branch| &branch,
                    // Split and move current leaf one level below
                    // It will be attached to newly created branch
                    .leaf => |leaf| &leaf.split(),
                };

                // TODO: Is this branch to branch reassignment without split costly?
                n.* = .{ .branch = branch.* };

                const child: ?*Node = switch (n.*) {
                    .branch => |br| br.children[quadrant],
                    else => unreachable,
                };
                std.testing.expectEqual(child, branch.children[quadrant]) catch unreachable;
                // Call it recursivly
                Tree().visitNode(
                // Formatter
                // &branch.children[quadrant],
                @constCast(&child),
                // Why are you
                mass,
                // Not working correctly??
                position.fit(size / 2),
                //
                size / 2);
            }
            // Here our journey ends. We found a null node and can use it.
            else {
                std.debug.print("Before: {?} \n", .{node.*});
                node.* = @constCast(&Node{
                    .leaf = .{
                        //
                        .mass = mass,
                        .position = position,
                        .size = size,
                    },
                });
                // std.debug.print("After: {?} \n", .{node.*});
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

        fn traverse(self: Self, callback: fn (i32) i32) void {
            _ = self; // autofix
            _ = callback(99);
            _ = callback(9);

            // TODO
        }
    };
}

const tt = std.testing;

test "init tree test" {
    var tr = Tree().init(16);
    tr.addBody(81, .{ .x = 0, .y = 1 });

    // std.debug.print("{?}\n\n", .{tr});
    try tr.print();

    // Expected tree
    // var exTr = Tree().init();

    // exTr.root = @constCast(&Tree().Node.newLeaf(81, .{ .x = 0, .y = 1 }));

    // try tt.expectEqualDeep(exTr, tr);
}
test "init tree, 2 bodies test" {
    var tr = Tree().init(16);
    tr.addBody(81, .{ .x = 0, .y = 1 });
    tr.addBody(81, .{ .x = 8, .y = 8 });

    // std.debug.print("{?}", .{tr});
    // try pretty.print(alloc, tr, .{});

    // Expected tree
    try tt.expect(false);
    // var exTr = Tree().init();

    // exTr.root = @constCast(&Tree().Node.newLeaf(81, .{ .x = 0, .y = 1 }));

    // try tt.expectEqualDeep(exTr, tr);
}
