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

    const dds = sql3.open("sqlite", "DDS.db", sql3.Mode.ReadOnly) catch |err| {
        const s = @src();
        @panic(std.fmt.allocPrint(allocREP, "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{}  init({s})\n\r",
        .{ s.file, s.line, s.column, s.fn_name, err, " DDS.db inconnue " }) catch unreachable);
    };

 
    db.jrnlog(sql3.Jrn.Begin) catch  unreachable;

    lgqDDS(dds);
    for (rowsdds.items, 0..) |_, n| {
    tdf.defrep.mnmo.setZfld(rowsdds.items[n].repNOM.string());
    tdf.defrep.text.setZfld(rowsdds.items[n].repTEXT.string());
    tdf.defrep.type.setZfld(rowsdds.items[n].repTYP.string());
    tdf.defrep.width.setDcml(rowsdds.items[n].repLEN.string());
    tdf.defrep.scal.setDcml(rowsdds.items[n].repDEC.string());
    tdf.defrep.refname.setZfld(rowsdds.items[n].repNAME.string());
    tdf.defrep.hs = false;
    tdf.defrep.long.setDcml("0");
    tdf.defrep.long.addTo(tdf.defrep.width,tdf.defrep.scal);
    
    _ = tdf.insert(db);

    }
    db.jrnlog(sql3.Jrn.Commit) catch unreachable;
    Pause(" contrôle memeoire");
        
    db.close();

    dds.close();

    Pause("stop");
}

pub const repDDS = struct {
    repNOM: zfld,
    repTEXT: zfld,
    repTYP: zfld,
    repLEN: dcml,
    repDEC: dcml,
    repNAME: zfld,


    // defined structure and set ""
    pub fn initRecord() repDDS {
        const rcd = repDDS{
            .repNOM = zfld.init(6),
            .repTEXT = zfld.init(50),
            .repTYP  = zfld.init(1),
            .repLEN  = dcml.init(4, 0),
            .repDEC  = dcml.init(2, 0),
            .repNAME = zfld.init(25),
        };

        return rcd;
    }

    pub fn deinitRecord(r: *repDDS) void {
        r.repNOM.deinit();
        r.repTEXT.deinit();
        r.repTYP.deinit();
        r.repLEN.deinit();
        r.repDEC.deinit();
        r.repNAME.deinit();
    }

};

// defintion defrep Table pour SQL
const defrepSQL = struct {
     repNOM: sql3.Text, repTEXT: sql3.Text, repTYP: sql3.Text,
     repLEN: sql3.Numeric, repDEC: sql3.Numeric, repNAME: sql3.Text };
     
pub var defdds = repDDS.initRecord();
pub var rowsdds = std.ArrayList(repDDS).initCapacity(allocREP, 0) catch unreachable;
pub fn lgqDDS(ldbr: sql3.Database) void {
    var sqlwrk: []const u8 = undefined;
    sqlwrk = std.fmt.allocPrint(allocREP, "SELECT * FROM REPERTOIR ORDER BY repNAME ASC ;",
    .{}) catch unreachable;

    rowsdds.shrinkAndFree(allocREP, 0);

    const select = ldbr.prepare(
        struct {},
        defrepSQL,
        sqlwrk,
    ) catch |err| {
        const s = @src();
        @panic(std.fmt.allocPrint(allocREP,
         "\n\n\r file:{s} line:{d} column:{d} func:{s}() prepare:{s} err:{}\n\r",
         .{ s.file, s.line, s.column, s.fn_name, sqlwrk, err }) catch unreachable);
    };

    defer select.finalize();
    // Iterate again, full

    select.bind(.{}) catch unreachable;
    defer select.reset();

    while (select.step() catch unreachable) |rcd| {
        defdds.repNOM.setZfld(rcd.repNOM.data);
        defdds.repTEXT.setZfld(rcd.repTEXT.data);
        defdds.repTYP.setZfld(rcd.repTYP.data);
        defdds.repLEN.setDcml(rcd.repLEN.data);
        defdds.repDEC.setDcml(rcd.repDEC.data);
        defdds.repNAME.setZfld(rcd.repNAME.data);
        rowsdds.append(allocREP, defdds) catch |err| {
            const s = @src();
            @panic(std.fmt.allocPrint(allocREP,
             "\n\n\r file:{s} line:{d} column:{d} func:{s}() select:{s} err:{}\n\r",
             .{ s.file, s.line, s.column, s.fn_name, sqlwrk, err }) catch unreachable);
        };
    }
}


