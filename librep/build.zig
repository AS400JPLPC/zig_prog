	///-----------------------
	/// build (library)
	/// zig 0.15.0 dev
	///-----------------------

const std = @import("std");


pub fn build(b: *std.Build) void {

    // Resolve the 'library' dependency.
    const zenlib_znd = b.dependency("libznd", .{});
    const zenlib_sql = b.dependency("libsql", .{});

    // Building the library
    const librep = b.addModule("librep", .{
        .root_source_file = b.path("./libdefrep.zig"),
    });

    librep.addImport("zfield", zenlib_znd.module("zfield"));
    librep.addImport("decimal", zenlib_znd.module("decimal"));
    librep.addImport("datetime", zenlib_znd.module("datetime"));
    librep.addImport("timezones", zenlib_znd.module("timezones"));
    librep.addImport("sqlite", zenlib_sql.module("sqlite"));



}
