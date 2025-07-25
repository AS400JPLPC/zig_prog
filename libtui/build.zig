	///-----------------------
	/// build (library)
	/// zig 0.12.0 dev
	///-----------------------

const std = @import("std");


pub fn build(b: *std.Build) void {

	const logger_mod = b.addModule("logger", .{
		.root_source_file =  b.path( "./log/logger.zig" ),
	});
	const logcons_mod = b.addModule("logcons", .{
		.root_source_file =  b.path( "./log/logcons.zig" ),
	});

	const cursed_mod = b.addModule("cursed", .{
		.root_source_file = b.path( "./curse/cursed.zig" ),
	});

	const utils_mod = b.addModule("utils", .{
		.root_source_file = b.path( "./curse/utils.zig" ),
		.imports= &.{
		.{ .name = "cursed", .module = cursed_mod },
		},
	});

	const mvzr_mod = b.addModule("mvzr", .{
		.root_source_file = b.path( "./regex/mvzr.zig" ),
	});

 	const forms_mod = b.addModule("forms", .{
		.root_source_file = b.path( "./curse/forms.zig" ),
		.imports= &.{
		.{ .name = "cursed", .module = cursed_mod },
		.{ .name = "utils",  .module = utils_mod},
		.{ .name = "mvzr",   .module = mvzr_mod },
		},
	});

	const grid_mod = b.addModule("grid", .{
		.root_source_file = b.path( "./curse/grid.zig" ),
		.imports = &.{
		.{ .name = "cursed", .module = cursed_mod},
		.{ .name = "utils",  .module = utils_mod},
		.{ .name = "logcons",  .module = logcons_mod},
		},
	});

	const menu_mod= b.addModule("menu", .{
		.root_source_file = b.path( "./curse/menu.zig" ),
		.imports= &.{
		.{ .name = "cursed", .module = cursed_mod},
		.{ .name = "utils",  .module = utils_mod},
		},
	});



	const callpgm_mod = b.addModule("callpgm", .{
		.root_source_file = b.path( "./calling/callpgm.zig" ),
	});



	const crypto_mod= b.addModule("crypto", .{
		.root_source_file = b.path( "./crypt/crypto.zig" ),
	});



	const zmmap_mod= b.addModule("zmmap", .{
		.root_source_file = b.path( "./mmap/zmmap.zig" ),
		.imports= &.{
		.{ .name = "crypto", .module = crypto_mod},
		.{ .name = "logger", .module = logger_mod},
		},
	});



	
	const library_mod = b.addModule("library", .{
	 .root_source_file = b.path( "library.zig" ),
	 .imports = &.{
	 .{ .name = "cursed", .module = cursed_mod },
	 .{ .name = "utils",  .module = utils_mod },
	 .{ .name = "mvzr",   .module = mvzr_mod },

	 .{ .name = "forms",  .module = forms_mod },
	 .{ .name = "grid",   .module = grid_mod },
	 .{ .name = "menu",   .module = menu_mod },
		
	 .{ .name = "callpgm",.module = callpgm_mod },
	 .{ .name = "zmmap",  .module = zmmap_mod },
	 .{ .name = "crypto", .module = crypto_mod },
		
	 .{ .name = "logger", .module = logger_mod },
	 .{ .name = "logcons",.module = logcons_mod },

	 },
	});




    

	_ = library_mod;


}
