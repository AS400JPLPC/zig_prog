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
    defrep.name.setZfld("AS400JPLPC");
    defrep.prenom.setZfld("Jean-Pierre");
    defrep.rue1.setZfld(" 01 rue du sud-ouest");
    defrep.ville.setZfld("Narbonne");
    defrep.pays.setZfld("France");
    defrep.base.setDcml("126.12");
    defrep.nbritem.setDcml("12345");
    defrep.taxe.setDcml("1.25");

    
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
	    \\ "hs"     BOOL CHECK("ok" IN (0, 1)),
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




    if (try db.istable("defrep")) {
        const insert = try db.prepare(
            defrepSql,
            void,
        \\INSERT INTO defrep (name,text,mnmo,type,width,scal,long,denrg,dmaj,hs)
        \\VALUES(:name, :text, :mnmo, :type, :width, :scal, :long, :denrg, :dmaj, :hs)
        ,);
        defer insert.finalize();   

        try insert.exec(.{
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




    defrep.ttc.setZeros();
    defrep.ok = false;
   // UPDATE  where name ="AS400JPLPC"
    {
        // for test value ttc big decimal check finance Force quoted values for DCML  
        const sqlUpdate : []const u8 = std.fmt.allocPrint(allocSQL,
            "UPDATE Zoned SET (ttc,ok)=(\"{s}\",{d}) WHERE name='{s}'",
                .{defrep.ttc.string(),sql3.cbool(defrep.ok),defrep.name.string(),})
                catch {@panic("init Update invalide");};
        defer allocSQL.free(sqlUpdate);
        pause(sqlUpdate);
        try db.exec(sqlUpdate,.{});
    }



    // Test SELECT
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
                \\id:{d}
                \\name:{s} prenom: {s}
                \\rue1:{s} rue2:{s}
                \\ville:{s} pays:{s}
                \\base:{s} taxe:{s} htx:{s} ttc:{s} nbritem:{s}
                \\date:{s}
                \\ok:{}
                , .{rcd.id orelse 0,
                    rcd.name.data, rcd.prenom.data, rcd.rue1.data, rcd.rue2.data, rcd.ville.data, rcd.pays.data,
                    rcd.base.data, rcd.taxe.data, rcd.htx.data, rcd.ttc.data, rcd.nbritem.data,
                    rcd.date.data , rcd.ok.data} );

             std.log.info("--------------------------",.{});       
        }


    }


    defrep.ttc.rate(defrep.base,defrep.nbritem,defrep.taxe);
    defrep.ok = true;
    defrep.date.dateOff();

    // UPDATEd id = 1
    {
        // for test value ttc big decimal check finance Force quoted values for DCML  
   defrep.ttc.setDcml("912345678901234567890123456789.0123");
        const sqlUpdate : []const u8 = std.fmt.allocPrint(allocSQL,
            "UPDATE Zoned SET (name,ttc,date,ok)=('{s}', \"{s}\", \"{s}\", {d}) WHERE id='{d}'",
                .{"COUCOU",defrep.ttc.string(),defrep.date.string(),sql3.cbool(defrep.ok),1,})
                catch {@panic("init Update invalide");};
        defer allocSQL.free(sqlUpdate);
        pause(sqlUpdate);
        try db.exec(sqlUpdate,.{});

        std.log.info("--------------------------",.{});
    }

   // Test SELECT
    {

         const select = try db.prepare(
            struct {key : i32},
            defrepSql,
            "SELECT * FROM Zoned WHERE id=:key",
        );
        defer select.finalize();
       // Iterate again, full

        try select.bind(.{.key = 1});
        defer select.reset();

        while (try select.step()) |rcd| {
            std.log.info(
                \\id:{d}
                \\name:{s} prenom: {s}
                \\rue1:{s} rue2:{s}
                \\ville:{s} pays:{s}
                \\base:{s} taxe:{s} htx:{s} ttc:{s} nbritem:{s}
                \\date:{s}
                \\ok:{}
                , .{rcd.id orelse 0,
                    rcd.name.data, rcd.prenom.data, rcd.rue1.data, rcd.rue2.data, rcd.ville.data, rcd.pays.data,
                    rcd.base.data, rcd.taxe.data, rcd.htx.data, rcd.ttc.data, rcd.nbritem.data,
                    rcd.date.data , rcd.ok.data} );
             
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

