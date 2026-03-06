const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const TILE_SIZE = 5;
const GRID_HEIGHT = 100;
const GRID_WIDTH = 100;

const ecs = @import("zflecs");

const Position = struct { x: i32, y: i32 };
const Visual = rl.Color;

fn registerComponents(world: *ecs.world_t) void {
    ecs.COMPONENT(world, Position);
    ecs.COMPONENT(world, Visual);
}

fn renderVisuals(positions: []Position, visuals: []Visual) void {
    for (positions, visuals) |p, v| {
        rl.DrawRectangle(p.x, p.y, TILE_SIZE, TILE_SIZE, v);
    }
}

fn progressHues(it: *ecs.iter_t, visuals: []Visual) void {
    for (visuals) |*v| {
        var hsv = rl.ColorToHSV(v.*);
        hsv.x += it.delta_time * 100.0;
        v.* = rl.ColorFromHSV(hsv.x, hsv.y, hsv.z);
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
    _ = ecs.ADD_SYSTEM(world, "progress hues", ecs.OnUpdate, progressHues);
}

fn setupGame(world: *ecs.world_t) void {
    for (0..GRID_WIDTH) |xi| {
        for (0..GRID_HEIGHT) |yi| {
            const testing = ecs.new_id(world);
            _ = ecs.set(world, testing, Position, .{ .x = @intCast(xi * TILE_SIZE), .y = @intCast(yi * TILE_SIZE) });
            const hue = @rem(@as(f32, @floatFromInt(yi)) * @as(f32, @floatFromInt(xi)), 360.0);
            _ = ecs.set(world, testing, Visual, rl.ColorFromHSV(hue, 1.0, 1.0));
        }
    }
}
