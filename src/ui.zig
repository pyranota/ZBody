const rl = @import("raylib");
const ctrl = @import("controls.zig");
const draw = @import("drawing.zig");

pub var isMenuShown = false;
//HUD initialization
const menu = rl.Rectangle{
    .x = ((ctrl.screenWidth / 4) * 2.2),
    .y = (ctrl.screenHeight / 3), //
    .width = (ctrl.screenWidth / 2), //
    .height = ((ctrl.screenHeight / 2.5) * 1.5),
};

pub fn mapKeys() void {
    if (rl.isKeyPressed(rl.KeyboardKey.key_h))
        isMenuShown = !isMenuShown;
}

pub fn drawHUD() void {
    //
    rl.drawText(
    //
    @ptrCast("h - hide/show hud"),
    //
    3, @intFromFloat((ctrl.screenHeight) - 20),
    //
    20, rl.Color.dark_green);

    //
    rl.drawText(
    //
    @ptrCast("space - pause "),
    //
    3,
    //
    @intFromFloat((ctrl.screenHeight) - 40),
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
    @intFromFloat((ctrl.screenHeight) - 60),
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
