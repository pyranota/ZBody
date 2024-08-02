// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const std = @import("std");
const vec2 = @import("vec2.zig");
const TreeError = @import("error.zig").TreeError;
const callbacks = @import("callbacks.zig");

const alloc = std.heap.page_allocator;

/// Building block of the quad tree.
/// Node is wether a branch or leaf.
pub fn Node(comptime Float: type) type {
    const Vec2 = vec2.Vec2;
    const Vec2F = vec2.Vec2F(Float);

    return union(enum) {
        const Branch =
            struct {
            // Queadtree needs to reference subnodes
            children: [4]?*Node(Float),
            /// Center of mass in region
            /// If tree is not finalized, than centerOfMass is nothing but
            /// sum of positions multiplied by their mass each.
            /// In order to get actual center of mass we need to devide it by total mass
            /// We dont do this until tree is structured, because we need to add bodies.
            centerOfMass: Vec2F,
            // Total mass
            mass: f32,
            /// Width and Height occupied by this branch
            size: u32,
            /// Find out in which quadrant should we put node with given position
            pub fn which(self: @This(), position: Vec2) u2 {
                const node = Node(Float){ .branch = self };
                return node.which(position);
            }
        };
        const Leaf = struct {
            //
            mass: f32 = 0,
            /// Represents position of the body within this Leaf
            /// It's coordinates are relative to the leaf
            position: Vec2F = @splat(0),
            /// Quadrant size
            size: u32,
        };

        // Enum / Union Variants
        leaf: Leaf,
        branch: Branch,
        /// Split leaf on branch and move body to new leaf
        /// Transform leaf to the branch
        /// Also allocate a new leaf
        pub fn split(self: *@This(), ally: std.mem.Allocator) !void {
            // TODO: Not leaf check

            // Allocate
            var node = try ally.create(Node(Float));
            node.* = Node(Float){ .leaf = .{ .size = 0 } };
            var leaf = &node.leaf;

            leaf.* = self.leaf;

            const m: Vec2F = @splat(leaf.mass);

            const cm = leaf.position * m;

            var branch = Branch{
                // We will push leaf to corresponding child later
                .children = .{null} ** 4,
                // Center of mass does not change, since we have only one leaf at the moment
                // Only the next iteration should modify center of mass
                .centerOfMass = cm,
                .mass = leaf.mass,
                .size = leaf.size,
            };

            self.* = Node(Float){ .branch = branch };

            // TODO: Safetychecks on 0
            if (leaf.size == 1) {
                return;
            }
            leaf.size /= 2;

            // Ask a new branch where to put leaf
            const quadrant = branch.which(vec2.convert(u32, leaf.position));

            // TODO: Move into leaf struct itself
            // Fit leaf's position to new quadrant which is 2 times smaller
            leaf.position = vec2.fit(f32, leaf.position, leaf.size);
            // var newNode = ally.alloc(Node, 1);

            // self.position.fit();
            // TODO: Should be This with modified position
            self.branch.children[quadrant] = node;
            // return branch;
        }

        pub fn newLeaf(mass: u32, position: Vec2) Node {
            return .{
                .leaf = .{
                    //
                    .mass = mass,
                    .position = position,
                },
            };
        }

        pub fn size(self: @This()) u32 {
            return switch (self) {
                inline else => |case| case.size,
            };
        }

        /// Find out in which quadrant should we put node with given position
        /// Can return error if position is out of bound
        pub fn which(self: @This(), position: Vec2) u2 {
            const half = self.size() / 2;
            // TODO: May be can be done in SIMD
            const x: u2 = if (position[0] < half) 0 else 1;
            const y: u2 = if (position[1] < half) 0 else 1;
            return (x + y * 2);
        }

        /// Type agnostic method.
        /// Returns `position` or `centerOfMass`
        pub fn coordinates(self: @This()) Vec2F {
            return switch (self) {
                .leaf => |leaf| leaf.position,
                .branch => |branch| branch.centerOfMass,
            };
        }

        /// Show what are spatial coordinates of child
        pub fn where(self: @This(), quadrant: u2) Vec2 {
            //
            const i = quadrant;
            const s = self.size() / 2;

            // Reference implementation from Venx:
            // UVec3::new(i & 1, (i >> 1) & 1,
            var v = Vec2{ //
                i & 1,
                (i >> 1) & 1,
            };
            v[0] *= s;
            v[1] *= s;
            return v;
        }
    };
}
