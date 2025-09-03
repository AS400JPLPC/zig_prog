//----------------------
//---test Sqlite     ---
//----------------------

const std = @import("std");

const zfld = @import("zfield").ZFIELD;
const dcml = @import("decimal").DCMLFX;
pub const dte = @import("datetime").DATE;
pub const dtm = @import("datetime").DTIME;
pub const Idm = @import("datetime").DATE.Idiom;
pub const Tmz = @import("timezones");

const sql3 = @import("sqlite");
const def = @import("defrep");
const builtin = @import("builtin");

const allocREP = std.heap.page_allocator;

//============================================================================================
var stdin = std.fs.File.stdin();
var stdout = std.fs.File.stdout().writerStreaming(&.{});

inline fn Print(comptime format: []const u8, args: anytype) void {
    stdout.interface.print(format, args) catch {};
}
inline fn WriteAll(args: anytype) void {
    stdout.interface.writeAll(args) catch {};
}

fn Pause(msg: []const u8) void {
    Print("\nPause  {s}\r\n", .{msg});
    var buf: [16]u8 = undefined;
    var c: usize = 0;
    while (c == 0) {
        c = stdin.read(&buf) catch unreachable;
    }
}
//============================================================================================

pub fn main() !void {
    WriteAll("\x1b[2J");
    WriteAll("\x1b[3J");

    const db = sql3.open("sqlite", "repdb.db", sql3.Mode.ReadWrite) catch |err| {
        const s = @src();
        @panic(std.fmt.allocPrint(allocREP, "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{}  init({s})\n\r", .{ s.file, s.line, s.column, s.fn_name, err, " repdb.db inconnue " }) catch unreachable);
    };

    // definiton -> defrep
    _ = def.createTable(db);

    Pause("start");
    def.defrep.name.setZfld("Nameextend");
    def.defrep.text.setZfld("text de la zone");
    def.defrep.mnmo.setZfld("name");
    def.defrep.type.setZfld("T");
    def.defrep.width.setDcml("10");
    def.defrep.scal.setDcml("0");
    def.defrep.long.setDcml("10");
    def.defrep.hs = false;

    Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {} {} {} \n", .{ def.defrep.name.string(), def.defrep.text.string(), def.defrep.mnmo.string(), def.defrep.type.string(), def.defrep.width.string(), def.defrep.scal.string(), def.defrep.long.string(), def.defrep.hs, sql3.boolean(def.defrep.hs), sql3.cbool(def.defrep.hs) });

    _ = def.insert(db);
    def.defrep.hs = true;
    _ = def.update(db);

    Pause(" contrôle memeoire");
    db.close();

    def.defrep.clearRecord();

    const dbr = try sql3.open("sqlite", "repdb.db", sql3.Mode.ReadOnly);

    // key name unique
    def.lgqLIKE(dbr, "name", "toto");
    Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{
        def.defrep.name.string(),  def.defrep.text.string(), def.defrep.mnmo.string(), def.defrep.type.string(),
        def.defrep.width.string(), def.defrep.scal.string(), def.defrep.long.string(), def.defrep.hs,
    });
    Print("\r\nnbr rows {d} \n", .{def.rows.items.len});

    // hs value not unique
    def.defrep.hs = true;
    def.lgqLIKE(dbr, "hs", sql3.zbool(def.defrep.hs));
    for (def.rows.items, 0..) |_, n| {
        Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{ def.rows.items[n].name.string(), def.rows.items[n].text.string(), def.rows.items[n].mnmo.string(), def.rows.items[n].type.string(), def.rows.items[n].width.string(), def.rows.items[n].scal.string(), def.rows.items[n].long.string(), def.rows.items[n].hs });
    }

    Print("\r\nnbr rows {d} \n", .{def.rows.items.len});

    // hs value not unique
    def.defrep.hs = false;
    def.lgqLIKE(dbr, "hs", sql3.zbool(def.defrep.hs));
    for (def.rows.items, 0..) |_, n| {
        Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{ def.rows.items[n].name.string(), def.rows.items[n].text.string(), def.rows.items[n].mnmo.string(), def.rows.items[n].type.string(), def.rows.items[n].width.string(), def.rows.items[n].scal.string(), def.rows.items[n].long.string(), def.rows.items[n].hs });
    }
    Print("\r\nnbr rows {d} \n", .{def.rows.items.len});

    // mnmo value unique
    def.lgqLIKE(dbr, "mnmo", "2name");
    Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{
        def.defrep.name.string(),  def.defrep.text.string(), def.defrep.mnmo.string(), def.defrep.type.string(),
        def.defrep.width.string(), def.defrep.scal.string(), def.defrep.long.string(), def.defrep.hs,
    });
    Print("\r\nnbr rows {d} \n", .{def.rows.items.len});

    // page down
    def.defrep.name.setZfld("");
    const nrows = def.pgDown(dbr, def.defrep.name.string(), 10);
    for (def.rows.items, 0..) |_, n| {
        Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{ def.rows.items[n].name.string(), def.rows.items[n].text.string(), def.rows.items[n].mnmo.string(), def.rows.items[n].type.string(), def.rows.items[n].width.string(), def.rows.items[n].scal.string(), def.rows.items[n].long.string(), def.rows.items[n].hs });
    }
    Print("\r\nnbr_items {d} nbr_rows:{d}\n", .{ def.rows.items.len, nrows });

    Pause(" contrôle memeoire");
    def.clearRows();
    Pause(" contrôle memeoire");
    dbr.close();

    const db3 = sql3.open("sqlite", "repdb.db", sql3.Mode.ReadWrite) catch |err| {
        const s = @src();
        @panic(std.fmt.allocPrint(allocREP, "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{}  init({s})\n\r", .{ s.file, s.line, s.column, s.fn_name, err, " repdb.db inconnue " }) catch unreachable);
    };
    _ = def.delete(db3, "Nameextend");
    def.defrep.deinitRecord();
    zfld.deinitZfld();
    dcml.deinitDcml();
    dte.deinitDate();

    Pause("stop");
}
