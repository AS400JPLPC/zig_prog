const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ===========================================================
    //
    // Resolve the 'library' dependency.
    const zenlib_znd = b.dependency("libznd", .{});
    const zenlib_sql = b.dependency("libsql", .{});

    // Building the library
    const lib_defrep = b.addModule("libdefrep", .{
        .root_source_file = b.path("../libdef/libdefrep.zig"),
    });

    lib_defrep.addImport("zfield", zenlib_znd.module("zfield"));
    lib_defrep.addImport("decimal", zenlib_znd.module("decimal"));
    lib_defrep.addImport("datetime", zenlib_znd.module("datetime"));
    lib_defrep.addImport("timezones", zenlib_znd.module("timezones"));
    lib_defrep.addImport("sqlite", zenlib_sql.module("sqlite"));

    // Building the executable

    const Prog = b.addExecutable(.{
        .name = "Test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("./Test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    Prog.root_module.addImport("zfield", zenlib_znd.module("zfield"));
    Prog.root_module.addImport("decimal", zenlib_znd.module("decimal"));
    Prog.root_module.addImport("datetime", zenlib_znd.module("datetime"));
    Prog.root_module.addImport("timezones", zenlib_znd.module("timezones"));
    Prog.root_module.addImport("sqlite", zenlib_sql.module("sqlite"));
    Prog.root_module.addImport("defrep", lib_defrep);

    b.installArtifact(Prog);
}
