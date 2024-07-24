const std = @import("std");
const Body = @import("body.zig");
const ally = std.heap.page_allocator;

const Objects = std.ArrayList(Body);
/// Returned array should be deallocated manually
pub fn generateGalaxy() !Objects {
    var objects = Objects.init(ally);
    try generateSolarSystem(&objects);
    return objects;
}

/// Returned array should be deallocated manually
fn generateSolarSystem(objects: *Objects) !void {
    try objects.append(.{ //
        .radius = 420,
        .mass = 20000,
        .position = @splat(0),
        .color = 0xff_99_00_ff,
    });
    // try objects.append(.{
    //     //
    //     .radius = 30,
    //     .mass = 2000,
    //     .position = .{ 1500, 0 },
    //     .velocity = .{ 0, 3.6514 },
    //     .color = 0x00_00_aa_ff,
    // });
    // try objects.append(.{ //
    //     .radius = 5,
    //     .mass = 100,
    //     .position = .{ 1700, 0 },
    //     .velocity = .{ 0, 6.3622 },
    //     .color = 0x99_99_99_ff,
    // });

    try objects.append(.{
        //
        .radius = 30,
        .mass = 2000,
        .position = .{ 8500, 0 },
        .velocity = .{ 0, 1.5339 },
        .color = 0x00_00_aa_ff,
    });

    try objects.append(.{ //
        .radius = 5,
        .mass = 100,
        .position = .{ 8700, 0 },
        .velocity = .{ 0, 1.5339 + 2.1622 },
        .color = 0x99_99_99_ff,
    });

    // try objects.append(.{ .mass = 50000, .position = .{ 500, 0 }, .velocity = .{ 0, 4 } });
    // try objects.append(.{ .mass = 50000, .position = .{ 0, 0 }, .velocity = .{ 0, -4 } });
}
