// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const vec2 = @import("vec2.zig");
const Vec2 = vec2.Vec2;
const Vec2F = vec2.Vec2F;

const TreeError = @import("error.zig").TreeError;
const tree = @import("tree.zig");
const Node = @import("node.zig").Node;
const ztracy = @import("ztracy");

const Threshold = tree.Tree().threshhold;
const Safety = tree.Tree().safety;

pub const stepArgs = struct {
    accel: *Vec2F,
    bodyPos: Vec2F,
    bodyMass: u32,
};

/// Calculate forces for given body
pub fn calcForcesCB(node: *Node, nodePosition: Vec2, args: stepArgs) bool {
    // -------------- Tracy ----------------//
    const zone = ztracy.Zone(@src());
    defer zone.End();
    // -------------------------------------//

    // m2
    const mass: f32 = switch (node.*) {
        inline else => |case| case.mass,
    };

    // Spatial size of branch or leaf
    const size: f32 = @floatFromInt(node.size());

    // Can be position of body within leaf
    // Or center of mass in branch
    const container_position = node.coordinates();

    // Tracy
    const accelerationCalcZone = ztracy.ZoneN(@src(), "vector calculation zone");

    // Node position (f32)
    const np = vec2.convert(f32, nodePosition);
    // Global position
    const global_position = container_position + np;
    // Direction from our node and target
    // No normalisation applied
    const dir: Vec2F = global_position - args.bodyPos;
    // Distance
    const vec_zero: Vec2F = @splat(0);
    const r = vec2.distance(f32, vec_zero, dir);

    // Tracy
    accelerationCalcZone.End();

    // Dont calculate force if target is the same as node
    if (@floor(r) == 0)
        // TODO: May be return false?
        return true;

    if (
    // We reached the buttom of tree
    node.* == Node.leaf
    // We are far enough to treat this branch as a single body
    or size / r < Threshold) {
        // Tracy
        const applyAccel = ztracy.ZoneN(@src(), "Apply accleration zone");

        // F = m1 * m2 / r^2;
        // F = m1 * a;
        // a = F / m1;
        //
        // [ a = m2 / r^2 ]
        //
        //
        //      Padding, we dont want inf accel by dividing by 0. >----<
        const accel: Vec2F = @splat((mass) / (r * r * r + Safety));
        //                                                    ^ Extra r, because we are supposed to multiply by
        //  normalized directional vector, so we multiply by another r.
        //                     >---< Here, that is not normalized vector.
        args.accel.* += accel * dir;

        // Tracy
        applyAccel.End();

        // Drop branch from traversing
        return false;
    }
    return true;
}

// Visalisation thing
pub fn forceBoundsCB(node: *Node, nodePosition: Vec2, args: anytype) bool {
    const targetPos = args.@"0";
    const callb = args.@"1";

    switch (node.*) {
        .branch => |br| {
            // Global position
            const g = vec2.convert(f32, nodePosition) + br.centerOfMass;
            // Distance
            const d: f32 = vec2.distance(f32, g, targetPos);
            // Size
            const s: f32 = @floatFromInt(br.size);

            if (s / d < Threshold) {
                callb(nodePosition, br.size, g);
                return false;
            }
        },
        .leaf => |leaf| callb(nodePosition, leaf.size, null),
    }
    return true;
}
// TODO: Rename to Leaf bounds
// Visalisation thing
pub fn treeBoundsCB(node: *Node, nodePosition: Vec2, callb: anytype) void {
    if (node.* == Node.leaf)
        callb(nodePosition, node.size());
}

pub fn finalizeCB(node: *Node, _: Vec2, _: anytype) void {
    if (node.* == Node.branch) {
        const m: Vec2F = @splat(node.branch.mass);
        node.branch.centerOfMass /= m;
    }
}
