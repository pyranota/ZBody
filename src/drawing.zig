// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const core = @import("zb-core");
const main = @import("main.zig");
const ctrl = @import("controls.zig");

const Color = rl.Color;
// Size of a galaxy
const boxSize: u32 = 256;
// Amount of space objects in galaxy
const amount = 5040;
const Vec2 = core.vec2.Vec2;
const Vec2F = core.vec2.Vec2F;
const time = std.time;
const Instant = time.Instant;

pub var playerColor = rl.Color{
    .r = 255,
    .g = 0,
    .b = 0,
    .a = 255,
};
var targetBodyId: u32 = undefined;
var targetBody: core.Body = undefined;
pub var playerMass: f32 = 10;
pub var playerRadius: f32 = 10;

pub fn drawBound(position: Vec2, size: u32) void {
    // Also add padding
    var padding: u32 = 4;
    if (size <= padding * 8) {
        padding = 0;
    }
    const col = if (size == boxSize) Color.yellow else Color.yellow;
    rl.drawRectangleLines( //
        @intCast(position[0] + padding), //
        @intCast(position[1] + padding), //
        @intCast(size - padding * 2), //
        @intCast(size - padding * 2), //
        col);
}

pub fn drawBoundForceAndCoM(position: Vec2, size: u32, centerOfMass: ?Vec2F) void {
    // Also add padding
    var padding: u32 = 4;
    if (size <= padding * 8) {
        padding = 0;
    }
    const col = if (centerOfMass != null) Color.brown else Color.dark_green;
    // std.debug.print("Is null? {?} \n", .{centerOfMass});
    rl.drawRectangleLines( //
        @intCast(position[0] + padding), //
        @intCast(position[1] + padding), //
        @intCast(size - padding * 2), //
        @intCast(size - padding * 2), //
        col);

    if (centerOfMass) |p| {
        rl.drawCircle( //
            @intFromFloat(p[0]), //
            @intFromFloat(p[1]), //
            15, Color.pink);
    }
}

pub fn drawPlanet(x: f32, y: f32, r: f32, col: u32) void {
    const min_radius = 1 / ctrl.camera.zoom;
    // Use the maximum of the original radius and the minimum radius
    const effectiveRadius = @max(r, min_radius);
    const color = rl.Color.fromInt(col);
    rl.drawCircle(@intFromFloat(x), @intFromFloat(y), effectiveRadius, color);
}

//HUD DRAW
pub fn drawMenu(rec: rl.Rectangle) void {
    rl.drawRectangleRec( //
        rec, Color.black);

    rl.drawRectangleLinesEx( //
        rec, 4, Color.dark_green);
}
//HUD USERINPUT
pub fn drawColorPicker(rec: rl.Rectangle, x: f32, y: f32) void {
    const PcikerRec = rl.Rectangle{
        .x = (rec.x) + x,
        .y = (rec.y) + y,
        .width = 240,
        .height = 240,
    };
    _ = rg.guiColorPicker(
        PcikerRec,
        "",
        &playerColor,
    );
}

pub fn drawMassInput(rec: rl.Rectangle, x: f32, y: f32) void {
    const MassInputRec = rl.Rectangle{
        .x = (rec.x) + x,
        .y = (rec.y) + y,
        .width = 240,
        .height = 60,
    };

    _ = rg.guiSliderBar(MassInputRec, "", "", &playerMass, 1, 1000000);
}

pub fn drawRadiusInput(rec: rl.Rectangle, x: f32, y: f32) void {
    const MassInputRec = rl.Rectangle{
        .x = (rec.x) + x,
        .y = (rec.y) + y,
        .width = 240,
        .height = 60,
    };

    _ = rg.guiSliderBar(MassInputRec, "", "", &playerRadius, 1, 1000);
}

pub fn drawMenuText(rec: rl.Rectangle) void {
    rl.drawText(@ptrCast(""), @intFromFloat((rec.x)), @intFromFloat(rec.y), 20, Color.dark_green);
}
