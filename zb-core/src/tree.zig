const std = @import("std");

pub fn Tree() type {
    return struct {
        const Vec2 = struct {
            x: i32,
            y: i32,

            /// Devide all fields by 2
            pub fn half(self: *const @This()) Vec2 {
                const div: i32 = 2;
                return .{ //
                    // Zig for some reasont cant just self.x / 2
                    .x = @divExact(self.x, div),
                    .y = @divExact(self.y, div),
                };
            }
        };
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
            };
            const Leaf = struct {
                //
                mass: u32,
                position: Vec2,
                /// Split leaf on branch and move body to new leaf
                fn split(self: @This()) Branch {
                    _ = self; // autofix
                    return .{ //
                        .children = .{null} ** 4,
                        .centerOfMass = .{ //
                            .x = 0,
                            .y = 0,
                        },
                        .mass = 0,
                    };
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

        /// Create new QuadTree
        pub fn init() Self {
            return .{ .root = null };
        }

        /// Add Astronomical Body to the System
        pub fn addBody(self: *@This(), mass: u32, position: Vec2) void {
            Tree().visitNode(&self.root, mass, position);
        }

        fn visitNode(node: *?*Node, mass: u32, position: Vec2) void {
            if (node.*) |n| {

                // In *which* *quadrant* do we want to put this node
                const quadrant = which(position);

                // If we have our node being something (not a null) we always need it to be a branch.
                // But it can be a Branch or a Leaf.
                // We dont want it to be a Leaf, so in case it is, we just split it.

                var branch = switch (n.*) {
                    //
                    .branch => |branch| branch,
                    // Split and move current leaf one level below
                    // It will be attached to newly created branch
                    .leaf => |leaf| leaf.split(),
                };

                // Call it recursivly
                Tree().visitNode(
                // Formatter
                &branch.children[quadrant],
                // Why are you
                mass,
                // Not working correctly??
                position.half());
            }
            // Here our journey ends. We found a null node and can use it.
            else {
                node.* = @constCast(&Node{
                    .leaf = .{
                        //
                        .mass = mass,
                        .position = position,
                    },
                });
            }
        }

        fn which(position: Vec2) u2 {
            _ = position; // autofix
            return 0;
        }

        /// Delete all bodies
        pub fn clean() void {
            // TODO
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
    var tr = Tree().init();
    tr.addBody(81, .{ .x = 0, .y = 1 });

    // Expected tree
    var exTr = Tree().init();

    exTr.root = @constCast(&Tree().Node.newLeaf(81, .{ .x = 0, .y = 1 }));

    try tt.expectEqualDeep(exTr, tr);
}
