const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const TILE_SIZE = 8;
const GRID_HEIGHT = 100;
const GRID_WIDTH = 100;

const ecs = @import("zflecs");

const Position = struct { x: i32, y: i32 };
const Visual = rl.Texture2D;

fn registerComponents(world: *ecs.world_t) void {
    ecs.COMPONENT(world, Position);
    ecs.COMPONENT(world, Visual);
}

fn renderVisuals(positions: []Position, visuals: []Visual) void {
    for (positions, visuals) |p, v| {
        rl.DrawTexture(v, p.x, p.y, rl.WHITE);
    }
}
pub fn main() !void {
    rl.InitWindow(800, 450, "rib");
    defer rl.CloseWindow();

    const world = ecs.init();
    defer _ = ecs.fini(world);

    registerComponents(world);
    registerSystems(world);
    setupGame(world);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLUE);
        _ = ecs.progress(world, rl.GetFrameTime());
        rl.EndDrawing();
    }
}

fn registerSystems(world: *ecs.world_t) void {
    _ = ecs.ADD_SYSTEM(world, "render visuals", ecs.OnUpdate, renderVisuals);
}

fn setupGame(world: *ecs.world_t) void {
    const image = rl.LoadImage("assets/tiles/rock.png");
    const texture = rl.LoadTextureFromImage(image);
    for (0..GRID_WIDTH) |xi| {
        for (0..GRID_HEIGHT) |yi| {
            const testing = ecs.new_id(world);
            _ = ecs.set(world, testing, Position, .{ .x = @intCast(xi * TILE_SIZE), .y = @intCast(yi * TILE_SIZE) });
            _ = ecs.set(
                world,
                testing,
                Visual,
                texture,
            );
        }
    }
}
