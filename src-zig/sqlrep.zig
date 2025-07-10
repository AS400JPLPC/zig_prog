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

const allocSQL = std.heap.page_allocator;

const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

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
            .hs     = true,
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


    
pub fn main() !void {
stdout.writeAll("\x1b[2J") catch {};
stdout.writeAll("\x1b[3J") catch {};



    var defrep  = repertoir.initRecord();

    pause("start");
    defrep.name.setZfld("Nameextend");
    defrep.text.setZfld("text de la zone");
    defrep.mnmo.setZfld("name");
    defrep.type.setZfld("T");
    defrep.width.setDcml("10");
    defrep.scal.setDcml("0");
    defrep.long.setDcml("10");
    defrep.hs = true;

    
    const db = try sql3.open("sqlite", "repdb.db");
    defer db.close();

// To work in extended digital (DCML) put the TEXT fields
    if (! try db.istable("defrep")) {

        pause("isTable");
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


	
    const defrepSql = struct {
        name: sql3.Text,
        text: sql3.Text,
        mnmo: sql3.Text,
        type: sql3.Text,
        width: sql3.Numeric,
        scal: sql3.Numeric,
        long: sql3.Numeric,
        hs: sql3.Bool
    };



std.debug.print("{s}  {s}  {s}  {s}  {s} {s} {s}  {} {} {} \n",.{
defrep.name.string(), defrep.text.string(), defrep.mnmo.string(), defrep.type.string(),
defrep.width.string(), defrep.scal.string(), defrep.long.string(),
defrep.hs,
sql3.boolean(defrep.hs),
sql3.cbool(defrep.hs)});



    // if (try db.istable("defrep")) {
    //     const insert = try db.prepare(
    //         defrepSql,
    //         void,
    //     \\INSERT INTO defrep (name,text,mnmo,type,width,scal,long,hs)
    //     \\VALUES(:name, :text, :mnmo, :type, :width, :scal, :long,:hs)
    //     ,);
    //     defer insert.finalize();   

    //     try insert.exec(.{
    //         .name  = sql3.text(defrep.name.string()),
    //         .text  = sql3.text(defrep.text.string()),
    //         .mnmo  = sql3.text(defrep.mnmo.string()),
    //         .type  = sql3.text(defrep.type.string()),
    //         .width = sql3.numeric(defrep.width.string()),
    //         .scal  = sql3.numeric(defrep.scal.string()),
    //         .long  = sql3.numeric(defrep.long.string()),
    //         .hs    = sql3.boolean(defrep.hs),
    //          });
    // }




   // defrep.text.setZeros();
    defrep.hs = false;
       {
        const sqlUpdate : []const u8 = std.fmt.allocPrint(allocSQL,
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
        defer allocSQL.free(sqlUpdate);
        pause(sqlUpdate);
        try db.exec(sqlUpdate,.{});
    }



    //Test SELECT full
    {

         const select = try db.prepare(
            struct {},
            defrepSql,
            "SELECT * FROM defrep ",
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


   // Test SELECT index name
    {

         const select = try db.prepare(
            struct {key : sql3.Text},
            defrepSql,
            "SELECT * FROM defrep WHERE name=:key",
        );
        defer select.finalize();
        // Iterate again, name
        defrep.name.setZfld("toto");
        try select.bind(.{.key = sql3.text(defrep.name.string())});

        //try select.bind(.{.key = sql3.text("tata")});
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
             
        }
        std.log.info("--------------------------",.{}); 
    }

   // Test SELECT index HS
    {

         const select = try db.prepare(
            struct {key : i32},
            defrepSql,
            "SELECT * FROM defrep WHERE hs=:key",
        );
        defer select.finalize();
        // Iterate again, HS
        defrep.hs = true;
        try select.bind(.{.key = sql3.cbool(defrep.hs)});

        //try select.bind(.{.key = sql3.text("tata")});
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
             
        }
        std.log.info("--------------------------",.{}); 
    }


    zfld.deinitZfld();
    dcml.deinitDcml();
    dte.deinitAlloc();
    pause("stop");
}


fn pause(text : [] const u8) void {
    std.debug.print("{s}\n",.{text});
   	var buf : [3]u8  =	[_]u8{0} ** 3;
	_= stdin.readUntilDelimiterOrEof(buf[0..], '\n') catch unreachable;

}

