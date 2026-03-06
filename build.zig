const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "lizard",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host,
        }),
    });

    const raylib = b.dependency("raylib", .{});
    exe.root_module.linkLibrary(raylib.artifact("raylib"));

    const zflecs = b.dependency("zflecs", .{});
    exe.root_module.addImport("zflecs", zflecs.module("root"));
    exe.linkLibrary(zflecs.artifact("flecs"));

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
