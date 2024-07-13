const std = @import("std");

pub fn Tree() type {
    return struct {
        const Vec2 = struct { i32, i32 };
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
                    return .{ .children = .{null} ** 4, .centerOfMass = .{ 0, 0 }, .mass = 0 };
                }
            };

            // One of those:
            leaf: Leaf,
            branch: Branch,

            fn newLeaf(mass: u32, position: Vec2) @This() {
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
        pub fn new() Self {
            return .{ .root = null };
        }

        /// Add body to the system
        pub fn addBody(self: @This(), mass: u32, position: Vec2) void {
            self.visitNode(self.root, mass, position);
        }

        fn visitNode(self: @This(), node: ?*Node, mass: u32, position: Vec2) void {
            if (node) |n| {

                // In *which* *quadrant* do we want to put this node
                const quadrant = self.which(position);

                // If we have our node being something (not a null) we always need it to be a branch.
                // But it can be a Branch or a Leaf.
                // We dont want it to be a Leaf, so in case it is, we just split it.

                const branch = switch (n.*) {
                    //
                    .branch => |branch| branch,
                    // Split and move current leaf one level below
                    // It will be attached to newly created branch
                    .leaf => |leaf| leaf.split(),
                };

                // Call it recursivly
                self.visitNode(
                // Formatter
                branch.children[@as(u32, quadrant)],
                // Why are you
                mass,
                // Not working correctly??
                position);
            }
            // Here our journey ends. We found a null node and can use it.
            else {
                // self.root = Node.newLeaf(mass, position);
                return;
            }
        }

        fn which(self: @This(), position: Vec2) u2 {
            _ = self; // autofix
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
