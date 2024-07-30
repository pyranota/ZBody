// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const rl = @import("raylib");
const ctrl = @import("controls.zig");
const draw = @import("drawing.zig");

pub var isMenuShown = false;
//HUD initialization
const menu = rl.Rectangle{
    // TODO: Make dynamic
    .x = ((1000 / 4) * 2.2),
    .y = (1000 / 3), //
    .width = (1000 / 2), //
    .height = ((1000 / 2.5) * 1.5),
};

pub fn handleHUD() void {
    mapKeys();
    drawHUD();
}

fn mapKeys() void {
    if (rl.isKeyPressed(rl.KeyboardKey.key_h))
        isMenuShown = !isMenuShown;
}

fn drawHUD() void {
    //
    rl.drawText(
    //
    @ptrCast("h - hide/show hud"),
    //
    3, ((ctrl.scrHeight()) - 20),
    //
    20, rl.Color.dark_green);

    //
    rl.drawText(
    //
    @ptrCast("space - pause "),
    //
    3,
    //
    ((ctrl.scrHeight()) - 40),
    //
    20,
    //
    rl.Color.dark_green);

    //
    rl.drawText(
    //
    @ptrCast("d - debug "),
    //
    3,
    //
    ((ctrl.scrHeight()) - 60),
    //
    20,
    //
    rl.Color.dark_green);

    if (isMenuShown) {
        draw.drawMenu(menu);
        draw.drawMenuText(menu);
        draw.drawColorPicker(menu, 20, 20);
        draw.drawMassInput(menu, 20, 280);
        draw.drawRadiusInput(menu, 20, 360);
    }
}
