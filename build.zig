const std = @import("std");

pub fn build(b: *std.Build) void {
    // ============================== CONFIGURATION ================================

    const optsTarget   = b.standardTargetOptions (.{});
    const optsOptimize = b.standardOptimizeOption(.{});

    const optsZON = @import("build.zig.zon");

    const exe = b.addExecutable(.{
        .name = @tagName(optsZON.name),
        .version = std.SemanticVersion.parse(optsZON.version) catch null,

        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),

            .target = optsTarget,
            .optimize = optsOptimize,

            .strip = true,
            .sanitize_c = .off
        })
    });

    b.installArtifact(exe);

    // ============================== DEPENDENCIES =================================

    const artifact_run = b.addRunArtifact(exe);
    artifact_run.addPassthruArgs();

    b.step("run", "Run the executable").dependOn(&artifact_run.step);

    // =================================== RUN =====================================

    const tests = b.addTest(.{ .root_module = exe.root_module });

    const artifact_test = b.addRunArtifact(tests);
    b.step("test", "Run tests for the executable").dependOn(&artifact_test.step);
}
