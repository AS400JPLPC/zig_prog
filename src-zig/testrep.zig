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
const tdf = @import("defrep");
//==========================================================================================
var stdin = std.fs.File.stdin();
var stdout = std.fs.File.stdout().writer(&.{});

inline fn Print(comptime format: []const u8, args: anytype) void {
    stdout.interface.print(format, args) catch {};
    stdout.interface.flush() catch {};
}

inline fn WriteAll(args: anytype) void {
    stdout.interface.writeAll(args) catch {};
    stdout.interface.flush() catch {};
}

fn Pause(msg: []const u8) void {
    Print("\nPause  {s}\r\n", .{msg});
    var buf: [16]u8 = undefined;
    var c: usize = 0;
    while (c == 0) {
        c = stdin.read(&buf) catch unreachable;
    }
}
fn Perror(errmsg: []const u8) void {
    Print("\r\n please fix: {s}\n", .{errmsg});
    var buf: [16]u8 = undefined;
    var c: usize = 0;
    while (c == 0) {
        c = stdin.read(&buf) catch unreachable;
    }
}

//============================================================================================
const allocREP = std.heap.page_allocator;

pub fn main() !void {
    WriteAll("\x1b[2J");
    WriteAll("\x1b[3J");



    // configuration PRAGMA SQLITE
    sql3.execPragma("sqlite", "repdb.db");



    // open database SQLITE (folder,name.db) 
    const db = sql3.open("sqlite", "repdb.db", sql3.Mode.ReadWrite) catch |err| {
        const s = @src();
        @panic(std.fmt.allocPrint(allocREP, "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{}  init({s})\n\r",
        .{ s.file, s.line, s.column, s.fn_name, err, " repdb.db inconnue " }) catch unreachable);
    };



    // definiton -> defrep
    _ = tdf.createTable(db);

    tdf.defrep.refname.setZfld("Nameextend");
    tdf.defrep.text.setZfld("text de la zone");
    tdf.defrep.mnmo.setZfld("name");
    tdf.defrep.type.setZfld("T");
    tdf.defrep.width.setDcml("10");
    tdf.defrep.scal.setDcml("0");
    tdf.defrep.long.setDcml("10");
    tdf.defrep.hs = false;

    Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {} {} {} \n", .{ tdf.defrep.refname.string(), tdf.defrep.text.string(),
        tdf.defrep.mnmo.string(), tdf.defrep.type.string(), tdf.defrep.width.string(), tdf.defrep.scal.string(),
        tdf.defrep.long.string(), tdf.defrep.hs, sql3.boolean(tdf.defrep.hs), sql3.cbool(tdf.defrep.hs) });

    // delete row name key unique
    _ = tdf.delete(db, "Nameextend");
    Pause("delete");

    _ = tdf.removeTable(db);
  Pause("removeTable");

    _ = tdf.createTable(db);
  Pause("createTable");
   
    _ = tdf.insert(db);
    Pause("insert");
    
    tdf.defrep.hs = true;
    _ = tdf.update(db);

    tdf.defrep.refname.setZfld("Namedelete");
    _ = tdf.insert(db);
    // delete row name key unique
    _ = tdf.delete(db, "Namedelete");

    tdf.defrep.refname.setZfld("toto");
    tdf.defrep.mnmo.setZfld("name2");
    tdf.defrep.hs = false;
    _ = tdf.insert(db);
    tdf.defrep.refname.setZfld("titi");
    tdf.defrep.mnmo.setZfld("name3");
    tdf.defrep.hs = false;
    _ = tdf.insert(db);
    Pause(" contrôle memeoire");



    db.jrnlog(sql3.Jrn.Begin) catch  unreachable;
    _ = tdf.delete(db, "Namedelete");
    db.jrnlog(sql3.Jrn.Rollback) catch unreachable;

    db.jrnlog(sql3.Jrn.Begin) catch  unreachable;
    tdf.defrep.refname.setZfld("Namexxx");
    const ok = tdf.insert(db);
    if (ok )  db.jrnlog(sql3.Jrn.Commit) catch unreachable else db.jrnlog(sql3.Jrn.Commit) catch unreachable;

    Pause(" contrôle db");
    _ = tdf.delete(db, "Namexxx");

        
    db.close();

    tdf.defrep.clearRecord();

    const dbr = try sql3.open("sqlite", "repdb.db", sql3.Mode.ReadOnly);

    // key name unique
    tdf.lgqQUERY(dbr, "refname", "toto");
    Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{
        tdf.defrep.refname.string(),  tdf.defrep.text.string(), tdf.defrep.mnmo.string(), tdf.defrep.type.string(),
        tdf.defrep.width.string(), tdf.defrep.scal.string(), tdf.defrep.long.string(), tdf.defrep.hs,
    });
    Print("\r\nnbr_items = nbrows {d} \n", .{ tdf.rows.items.len});

    // hs value not unique
    tdf.defrep.hs = true;
    tdf.lgqQUERY(dbr, "hs", sql3.zbool(tdf.defrep.hs));
    for (tdf.rows.items, 0..) |_, n| {
        Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{ tdf.rows.items[n].refname.string(),
            tdf.rows.items[n].text.string(), tdf.rows.items[n].mnmo.string(), tdf.rows.items[n].type.string(),
            tdf.rows.items[n].width.string(), tdf.rows.items[n].scal.string(), tdf.rows.items[n].long.string(),
            tdf.rows.items[n].hs });
    }

    Print("\r\nnbr_items {d} \n", .{ tdf.rows.items.len});

    // hs value not unique
    tdf.defrep.hs = false;
    tdf.lgqQUERY(dbr, "hs", sql3.zbool(tdf.defrep.hs));
    for (tdf.rows.items, 0..) |_, n| {
        Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{ tdf.rows.items[n].refname.string(),
            tdf.rows.items[n].text.string(), tdf.rows.items[n].mnmo.string(), tdf.rows.items[n].type.string(),
            tdf.rows.items[n].width.string(), tdf.rows.items[n].scal.string(), tdf.rows.items[n].long.string(),
            tdf.rows.items[n].hs });
    }
    Print("\r\nnbr_items {d}\n", .{ tdf.rows.items.len});

    // mnmo value unique
    tdf.lgqQUERY(dbr, "mnmo", "name2");
    Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{
        tdf.defrep.refname.string(),  tdf.defrep.text.string(), tdf.defrep.mnmo.string(), tdf.defrep.type.string(),
        tdf.defrep.width.string(), tdf.defrep.scal.string(), tdf.defrep.long.string(), tdf.defrep.hs,
    });
    Print("\r\nnbr_items {d}\n", .{ tdf.rows.items.len});

    // page down
    tdf.defrep.refname.setZfld("");
    tdf.pgDown(dbr, tdf.defrep.refname.string(), 10);
    for (tdf.rows.items, 0..) |_, n| {
        Print("\r\n{s}  {s}  {s}  {s}  {s} {s} {s}  {}  \n", .{
            tdf.rows.items[n].refname.string(), tdf.rows.items[n].text.string(), tdf.rows.items[n].mnmo.string(),
            tdf.rows.items[n].type.string(), tdf.rows.items[n].width.string(), tdf.rows.items[n].scal.string(),
            tdf.rows.items[n].long.string(), tdf.rows.items[n].hs });
    }
    Print("\r\nnbr_items {d}\n", .{ tdf.rows.items.len});

    Pause(" contrôle memeoire");
    tdf.clearRows();
    Pause(" contrôle memeoire");
    dbr.close();


    tdf.defrep.deinitRecord();
    zfld.deinitZfld();
    dcml.deinitDcml();
    dte.deinitDate();

    Pause("stop");
}
