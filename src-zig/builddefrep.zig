    ///-----------------------
    /// build Gencurs
    ///-----------------------

const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    // ===========================================================

    const zenlib_tui = b.dependency("libtui", .{});
    const zenlib_znd = b.dependency("libznd", .{});
    const zenlib_sql = b.dependency("libsql", .{});
    const zenlib_rep = b.dependency("librep", .{});


    
    // Building the executable

    const Prog = b.addExecutable(.{
    .name = "defrep",
    .root_module = b.createModule(.{
        .root_source_file = b.path( "./defrep.zig" ),
        .target = target,
        .optimize = optimize,
        }),
    });

    Prog.root_module.addLibraryPath(.{.cwd_relative = "/usr/lib/"});
    Prog.root_module.linkSystemLibrary("sqlite3",  .{ .preferred_link_mode = .dynamic } );

    
    Prog.root_module.addImport("alloc",  zenlib_tui.module("alloc"));
    Prog.root_module.addImport("cursed", zenlib_tui.module("cursed"));
    Prog.root_module.addImport("utils",  zenlib_tui.module("utils"));
    Prog.root_module.addImport("mvzr",   zenlib_tui.module("mvzr"));
    Prog.root_module.addImport("forms",  zenlib_tui.module("forms"));
    Prog.root_module.addImport("grid" ,  zenlib_tui.module("grid"));
    Prog.root_module.addImport("menu" ,  zenlib_tui.module("menu"));


    Prog.root_module.addImport("zfield",    zenlib_znd.module("zfield"));
    Prog.root_module.addImport("decimal",   zenlib_znd.module("decimal"));
    Prog.root_module.addImport("datetime",  zenlib_znd.module("datetime"));
    Prog.root_module.addImport("timezones", zenlib_znd.module("timezones"));

    Prog.root_module.addImport("sqlite", zenlib_sql.module("sqlite"));
    Prog.root_module.addImport("defrep", zenlib_rep.module("librep"));

    b.installArtifact(Prog);





}
