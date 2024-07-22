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

pub fn calcForcesCB(node: *Node, nodePosition: Vec2, args: stepArgs) bool {
    const zone = ztracy.Zone(@src());
    defer zone.End();

    const mass: f32 = switch (node.*) {
        inline else => |case| @floatFromInt(case.mass),
    };

    const size: f32 = @floatFromInt(node.size());

    // Can be position of body within leaf
    // Or center of mass in branch
    const container_position = switch (node.*) {
        .leaf => |leaf| leaf.position,
        .branch => |branch| branch.centerOfMass,
    };
    const accelerationCalcZone = ztracy.ZoneN(@src(), "vector calculation zone");

    const np = vec2.convert(f32, nodePosition);
    // Global position
    const global_position = container_position + np;

    // Direction from our node and target
    const d_vec: Vec2F = global_position - args.bodyPos;

    // Distance
    const vec_zero: Vec2F = @splat(0);
    const d = vec2.distance(f32, vec_zero, d_vec);

    accelerationCalcZone.End();

    // Dont calculate force if target is the same as node
    if (@floor(d) == 0)
        return true;
    if (node.* == Node.leaf or size / d < Threshold) {
        const applyAccel = ztracy.ZoneN(@src(), "Apply accleration zone");
        const accel: Vec2F = @splat((mass) / (d * d * d + Safety));
        args.accel.* += accel * d_vec;
        applyAccel.End();
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
        const m: Vec2F = @splat(@floatFromInt(node.branch.mass));
        node.branch.centerOfMass /= m;
    }
}