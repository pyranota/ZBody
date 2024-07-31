// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

// ------------ Basis ------------- //
const std = @import("std");
const rl = @import("raylib");

// ----------- Modules ------------ //
const debug = @import("debug.zig");
const spawn = @import("spawn.zig");
const ctrl = @import("controls.zig");
const rndr = @import("render.zig");

pub var planetsTexture: rl.RenderTexture2D = undefined;

pub fn drawPlanetsTexture(buffer: rl.RenderTexture2D) rl.RenderTexture2D {
    const scrWidth = ctrl.scrWidth();
    const scrHeight = ctrl.scrHeight();
    planetsTexture = rl.loadRenderTexture(scrWidth, scrHeight);
    rl.beginTextureMode(buffer);
    rl.clearBackground(rl.Color.black);
    rl.beginMode2D(ctrl.camera);
    rndr.render();
    rl.endMode2D();
    rl.endTextureMode();
    return buffer;
}

pub fn drawTexture(buffer: rl.RenderTexture2D) void {
    rl.drawTexturePro(buffer.texture //
    , rl.Rectangle{
        .x = 0 //
        ,
        .y = @floatFromInt(ctrl.scrHeight()) //
        ,
        .width = @floatFromInt(ctrl.scrWidth()) //
        ,
        .height = @floatFromInt(-ctrl.scrHeight()),
    } //std//
    , rl.Rectangle{
        .x = 0 //
        ,
        .y = 0 //
        ,
        .width = @floatFromInt(ctrl.scrWidth()) //
        ,
        .height = @floatFromInt(ctrl.scrHeight()), //
    } //
    , rl.Vector2{ .x = 0, .y = 0 } //
    , 0 //
    , rl.Color.white); //
}
