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
const builtin = @import("builtin");


const allocREP = std.heap.page_allocator;

//============================================================================================
var stdin = std.fs.File.stdin();
var stdout = std.fs.File.stdout().writerStreaming(&.{});


inline fn Print( comptime format: []const u8, args: anytype) void {
    stdout.interface.print(format, args) catch  {} ;
}
inline fn WriteAll( args: anytype) void {
    stdout.interface.writeAll(args) catch {} ;
}

fn Pause(msg : [] const u8 ) void{

    Print("\nPause  {s}\r\n",.{msg});
    var buf: [16]u8 = undefined;
    var c  : usize = 0;
    while (c == 0) {
        c = stdin.read(&buf) catch unreachable;
    }
}
//============================================================================================


pub const repertoir = struct {
  name      : zfld ,
  text      : zfld ,
  mnmo      : zfld ,
  type      : zfld ,
  width     : dcml ,
  scal      : dcml ,
  long      : dcml ,
  hs        : bool,
  

   // defined structure and set ""
    pub fn initRecord() repertoir {
        const rcd = repertoir {
            .name   = zfld.init(15) ,
            .text   = zfld.init(30) ,
            .mnmo   = zfld.init(6) ,
            .type   = zfld.init(1) ,
            .width  = dcml.init(4,0) ,
            .scal   = dcml.init(2,0) ,
            .long   = dcml.init(4,0) ,
            .hs     = false,
        };
        
        return rcd;      
    }

    pub fn deinitRecord( r : *repertoir) void {
        r.name.deinit();
        r.name.deinit();
        r.text.deinit();
        r.mnmo.deinit();
        r.type.deinit();
        r.width.deinit();
        r.scal.deinit();
        r.long.deinit();
        r.hs = false;
    }


};

// defintion defrep Table pour SQL
    const defrepSQL = struct {
        name: sql3.Text,
        text: sql3.Text,
        mnmo: sql3.Text,
        type: sql3.Text,
        width: sql3.Numeric,
        scal: sql3.Numeric,
        long: sql3.Numeric,
        hs: sql3.Bool
    };

        
const tblrep: sql3.Database = undefined;
pub   var defrep  = repertoir.initRecord();

pub const defrepList :  std.ArrayList(defrepSQL) = std.ArrayList(defrepSQL).initCapacity(allocREP,0) catch unreachable;


pub fn isTable(db : sql3.Database)  !void {
// To work in extended digital (DCML) put the TEXT fields and BOOL
    if (! try db.istable("defrep")) {

        // Pause("isTable");
        try db.exec(
        \\ CREATE TABLE "defrep" (
	    \\ "name"   VARCHAR(15) NOT NULL UNIQUE,
	    \\ "text"   VARCHAR(30) NOT NULL,
	    \\ "mnmo"   VARCHAR(6) NOT NULL,
	    \\ "type"   VARCAHR(1) NOT NULL,
	    \\ "width"  NUMERIC(4,0) NOT NULL,
	    \\ "scal"   NUMERIC(2,0) NOT NULL,
	    \\ "long"   NUMERIC(4,0) NOT NULL,
	    \\ "hs"     BOOL CHECK("hs" IN (0, 1)),
	    \\ PRIMARY KEY("name"))
	    , .{});
	}
}

pub fn insert(db : sql3.Database)  !void {
   if (try db.istable("defrep")) {
        const insertSQL = try db.prepare(
            defrepSQL,
            void,
        \\INSERT INTO defrep (name,text,mnmo,type,width,scal,long,hs)
        \\VALUES(:name, :text, :mnmo, :type, :width, :scal, :long,:hs)
        ,);
        defer insertSQL.finalize();   

        try insertSQL.exec(.{
            .name  = sql3.text(defrep.name.string()),
            .text  = sql3.text(defrep.text.string()),
            .mnmo  = sql3.text(defrep.mnmo.string()),
            .type  = sql3.text(defrep.type.string()),
            .width = sql3.numeric(defrep.width.string()),
            .scal  = sql3.numeric(defrep.scal.string()),
            .long  = sql3.numeric(defrep.long.string()),
            .hs    = sql3.boolean(defrep.hs),
             });
    }
    
}

pub fn update(db : sql3.Database)  !void {
        const updateSQL : []const u8 = std.fmt.allocPrint(allocREP,
            \\UPDATE defrep SET
            \\text = '{s}', mnmo = '{s}', type = '{s}',
            \\width = {s}, scal = {s}, long = {s}, hs = {d} 
            \\WHERE name='{s}'
            ,   .{
                    defrep.text.string(), defrep.mnmo.string(), defrep.type.string(), 
                    defrep.width.string(), defrep.scal.string(), defrep.long.string(), sql3.cbool(defrep.hs),
                    defrep.name.string()
                ,})
                catch {@panic("init Update invalide");};
        defer allocREP.free(updateSQL);
        Pause(updateSQL);
        try db.exec(updateSQL,.{});
}

// logique LIKE
pub fn lgqLIKE(ldbr : sql3.Database, like : []const u8 )  !void{
    var sqlwrk : []const u8 = undefined;
    if ( std.mem.eql( u8, like ,""))
     sqlwrk = std.fmt. allocPrint(allocREP,"SELECT * FROM defrep ORDER BY name ASC",.{}) catch unreachable
    else  sqlwrk = std.fmt. allocPrint(allocREP,"SELECT * FROM defrep WHERE mnmo LIKE %{s}% ORDER BY name ASC",
                .{like}) catch unreachable;
                
    defer allocREP.free(sqlwrk);
    
         const select = try ldbr.prepare(
            struct {},
            defrepSQL,
            sqlwrk,
        );
        defer select.finalize();
       // Iterate again, full

        try select.bind(.{});
        defer select.reset();

        while (try select.step()) |rcd| {
            std.log.info(
                \\name:{s}
                \\text:{s}
                \\mnmo:{s}
                \\type:{s}
                \\width:{s}
                \\scal:{s}
                \\long:{s}
                \\hs:{}
                , .{rcd.name.data, rcd.text.data, rcd.mnmo.data, rcd.type.data,
                    rcd.width.data, rcd.scal.data, rcd.long.data,
                    rcd.hs.data} );

             std.log.info("--------------------------",.{});       
        }

}


pub fn exist(db : sql3.Database, name :[]const u8 )  bool {
    const Result = struct { count: usize };

    var sqlwrk : []const u8 = undefined;
    if ( std.mem.eql( u8, name ,"")) return false;
     sqlwrk = std.fmt. allocPrint(allocREP,
         "SELECT count(*) as count FROM defrep  WHERE name='{s}'; ",.{name}) catch unreachable;
    defer allocREP.free(sqlwrk);

    WriteAll(sqlwrk);
    
         const select = db.prepare(
            struct {},
            Result,
            sqlwrk,
        ) catch |err| {
                const s = @src();
                    @panic( std.fmt.allocPrint(allocREP,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() name:{s}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,name,err})
                        catch unreachable
                    );
                };
        defer select.finalize();
        select.bind(.{}) catch unreachable;
        defer select.reset();
        while (select.step() catch unreachable) |rcd| {
            std.log.info(
                \\crow_exist:{d}
                , .{rcd.count});
            
            std.log.info("--------------------------",.{});       
        }

        while (select.step() catch unreachable) |rcd| {
                   if ( rcd.count == 1 ) return true ;
        }
        return false;
}



pub fn main() !void {
WriteAll("\x1b[2J");
WriteAll("\x1b[3J");


    Pause("start");
    defrep.name.setZfld("Nameextend");
    defrep.text.setZfld("text de la zone");
    defrep.mnmo.setZfld("name");
    defrep.type.setZfld("T");
    defrep.width.setDcml("10");
    defrep.scal.setDcml("0");
    defrep.long.setDcml("10");
    defrep.hs = false;

        const db = sql3.open("sqlite", "repdb.db", sql3.Mode.ReadWrite) catch |err| {
		const s = @src();
        @panic(std.fmt.allocPrint(allocREP,
        "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{}  init({s})\n\r"
        ,.{s.file, s.line, s.column,s.fn_name,err," repdb.db inconnue "})
        		catch unreachable);
    };
    


    // definiton du répertoir
    isTable(db) catch |err| {
		const s = @src();
        @panic(std.fmt.allocPrint(allocREP,
        "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{}  init({s})\n\r"
        ,.{s.file, s.line, s.column,s.fn_name,err," repdb.db inconnue "})
        		catch unreachable);
    };
	



Print("{s}  {s}  {s}  {s}  {s} {s} {s}  {} {} {} \n",.{
defrep.name.string(), defrep.text.string(), defrep.mnmo.string(), defrep.type.string(),
defrep.width.string(), defrep.scal.string(), defrep.long.string(),
defrep.hs,
sql3.boolean(defrep.hs),
sql3.cbool(defrep.hs)});

    if (!exist(db ,defrep.name.string()))
        insert(db) catch |err| {
    		const s = @src();
            @panic(std.fmt.allocPrint(allocREP,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{})\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,err})
            catch unreachable);
        };




   // defrep.text.setZeros();
    defrep.hs = true;
    update(db) catch |err| {
		const s = @src();
        @panic(std.fmt.allocPrint(allocREP,
        "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{})\n\r"
        ,.{s.file, s.line, s.column,s.fn_name,err})
        		catch unreachable);
    };
db.close();



    const dbr = try sql3.open("sqlite", "repdb.db", sql3.Mode.ReadOnly);

    lgqLIKE(dbr, "") catch |err| {
		const s = @src();
        @panic(std.fmt.allocPrint(allocREP,
        "\n\n\r file:{s} line:{d} column:{d} func:{s}  err:{})\n\r"
        ,.{s.file, s.line, s.column,s.fn_name,err})
        		catch unreachable);
    };

    dbr.close();





    zfld.deinitZfld();
    dcml.deinitDcml();
    dte.deinitDate();
    Pause("stop");
}

