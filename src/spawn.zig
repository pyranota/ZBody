// --------------------------------------------------------
// ZBody - Concurrent N-body sim using Barnes-Hut and Zig
// --------------------------------------------------------
// Codeberg: https://codeberg.org/pyranota/Z-body
// Licensed under the MIT License
// --------------------------------------------------------

const rl = @import("raylib");
const draw = @import("drawing.zig");
const ctrl = @import("controls.zig");
const camera = &ctrl.camera;
const main = @import("main.zig");
const core = main.core;
const engine = &main.engine;
//Player input
var playerColor = rl.Color{
    .r = 255,
    .g = 0,
    .b = 0,
    .a = 255,
};
var playerMass: f32 = 10;
var playerRadius: f32 = 10;
pub var planetStartPoint = rl.Vector2{
    .x = 0,
    .y = 0,
};

var isPlanetBeingCreated: bool = false;
pub fn spawnBodyWithVelocity() !void {
    playerMass = draw.playerMass;
    playerRadius = draw.playerRadius;
    playerColor = draw.playerColor;

    if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_right)) {
        const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera.*);
        planetStartPoint.x = pos.x;
        planetStartPoint.y = pos.y;
        isPlanetBeingCreated = true;
    }
    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_right)) {
        isPlanetBeingCreated = false;
        const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera.*);

        const c: u32 = @bitCast(rl.colorToInt(playerColor));
        const x = pos.x;
        const y = pos.y;
        if (x == planetStartPoint.x and y == planetStartPoint.y) {
            try engine.addBody(core.Body{
                .mass = (playerMass),
                .position = .{ //
                    planetStartPoint.x, planetStartPoint.y,
                },
                .velocity = @splat(0),
                .radius = (playerRadius),
                .color = c,
            });
        } else try engine.addBody(core.Body{ //
            .mass = (playerMass),
            .position = .{ //
                planetStartPoint.x, planetStartPoint.y,
            },
            // .velocity = .{ //
            //     -((x - planetStartPoint.x) / 1000), -((y - planetStartPoint.y) / 1000),
            // },
            .radius = (playerRadius),
            .color = c,
        });
    }
    if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_right)) {
        rl.drawCircleV(planetStartPoint, (playerRadius), playerColor);
        const pos = rl.getScreenToWorld2D(rl.getMousePosition(), camera.*);
        rl.drawLineEx(planetStartPoint, pos, 10, rl.Color.red);
    }
}
