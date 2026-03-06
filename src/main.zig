pub const ecs = @import("zflecs");
pub const rl = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const tile = @import("./tile/tile.zig");

const TILE_SIZE = 8;
const GRID_HEIGHT = 100;
const GRID_WIDTH = 100;
pub fn main() !void {
    rl.InitWindow(800, 450, "rib");
    defer rl.CloseWindow();
    const world = ecs.init();
    defer _ = ecs.fini(world);

    tile.worldImport(world);
    setupGame(world);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLUE);
        _ = ecs.progress(world, rl.GetFrameTime());
        rl.EndDrawing();
    }
}

fn setupGame(world: *ecs.world_t) void {
    const image = rl.LoadImage("assets/tiles/rock.png");
    const texture = rl.LoadTextureFromImage(image);
    for (0..GRID_WIDTH) |xi| {
        for (0..GRID_HEIGHT) |yi| {
            const testing = ecs.new_id(world);
            _ = ecs.set(world, testing, tile.Position, .{ .x = @intCast(xi * TILE_SIZE), .y = @intCast(yi * TILE_SIZE) });
            _ = ecs.set(
                world,
                testing,
                tile.Visual,
                texture,
            );
        }
    }
}
