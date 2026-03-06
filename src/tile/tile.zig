const rl = @import("root").rl;
const ecs = @import("root").ecs;

pub const Position = struct { x: i32, y: i32 };
pub const Visual = rl.Texture2D;

pub fn worldImport(world: *ecs.world_t) void {
    ecs.COMPONENT(world, Position);
    ecs.COMPONENT(world, Visual);
    _ = ecs.ADD_SYSTEM(world, "render visuals", ecs.OnUpdate, renderVisuals);
}

fn renderVisuals(positions: []Position, visuals: []Visual) void {
    for (positions, visuals) |p, v| {
        rl.DrawTexture(v, p.x, p.y, rl.WHITE);
    }
}
