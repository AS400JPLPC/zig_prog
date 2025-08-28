const std = @import("std");

const zfld = @import("zfield").ZFIELD;
const dcml = @import("decimal").DCMLFX;
pub const dte = @import("datetime").DATE;
pub const dtm = @import("datetime").DTIME;
pub const Idm = @import("datetime").DATE.Idiom;
pub const Tmz = @import("timezones");

const sql3 = @import("sqlite");

const allocREP = std.heap.page_allocator;

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


    pub fn clearRecord( r : *repertoir) void {
        r.name.clear();
        r.name.clear();
        r.text.clear();
        r.mnmo.clear();
        r.type.clear();
        r.width.setZeros();
        r.scal.setZeros();
        r.long.setZeros();
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

pub   var defrep  = repertoir.initRecord();
pub   var rows = std.ArrayList(repertoir).initCapacity(allocREP,0) catch unreachable;

pub fn  clearRows() void {
    rows.shrinkAndFree(allocREP,0);}

     
pub fn createTable(db : sql3.Database)  bool {
// To work in extended digital (DCML) put the TEXT fields and BOOL
    if (db.istable("defrep"))  return false;

        db.exec(
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
	    , .{}) catch |err| {
            const s = @src();
                @panic( std.fmt.allocPrint(allocREP,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}() err:{}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,err})
                    catch unreachable
                );
            };
	return true;
}


pub fn insert(db : sql3.Database)  bool {
    if (! db.istable("defrep") ) return false; 
    if ( existRows(db,defrep.name.string())) return false; 
        const insertSQL =  db.prepare(
            defrepSQL,
            void,
        \\INSERT INTO defrep (name,text,mnmo,type,width,scal,long,hs)
        \\VALUES(:name, :text, :mnmo, :type, :width, :scal, :long,:hs)
        ,) catch |err| {
            const s = @src();
                @panic( std.fmt.allocPrint(allocREP,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}() err:{}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,err})
                    catch unreachable
                );
            };
        defer insertSQL.finalize();

        insertSQL.exec(.{
            .name  = sql3.text(defrep.name.string()),
            .text  = sql3.text(defrep.text.string()),
            .mnmo  = sql3.text(defrep.mnmo.string()),
            .type  = sql3.text(defrep.type.string()),
            .width = sql3.numeric(defrep.width.string()),
            .scal  = sql3.numeric(defrep.scal.string()),
            .long  = sql3.numeric(defrep.long.string()),
            .hs    = sql3.boolean(defrep.hs),
             }) catch |err| {
                const s = @src();
                    @panic( std.fmt.allocPrint(allocREP,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,err})
                        catch unreachable
                    );
                };
    return true;

}



pub fn update(db : sql3.Database)  bool {

    if (!db.istable("defrep") ) return false;
    if ( !existRows(db,defrep.name.string())) return false;
        const updateSQL : []const u8 = std.fmt.allocPrint(allocREP,
        \\UPDATE defrep SET
        \\text = '{s}', mnmo = '{s}', type = '{s}',
        \\width = {s}, scal = {s}, long = {s}, hs = {d}
        \\WHERE name='{s}'
        ,   .{
                defrep.text.string(), defrep.mnmo.string(), defrep.type.string(),
                defrep.width.string(), defrep.scal.string(), defrep.long.string(), sql3.cbool(defrep.hs),
                defrep.name.string()
            ,}) catch |err| {
                const s = @src();
                    @panic( std.fmt.allocPrint(allocREP,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,err})
                        catch unreachable
                    );
                };
        defer allocREP.free(updateSQL);
        db.exec(updateSQL,.{}) catch unreachable;
    return true;    

}



// logique LIKE
pub fn lgqLIKE(ldbr : sql3.Database, name: [] const u8, like : []const u8 )  void{
    var sqlwrk : []const u8 = undefined;
    sqlwrk = std.fmt. allocPrint(allocREP,"SELECT * FROM defrep WHERE {s} LIKE '%{s}%' ORDER BY name ASC",
                .{name, like}) catch unreachable;
                
   
    rows.shrinkAndFree(allocREP,0);
        
         const select = ldbr.prepare(
            struct {},
            defrepSQL,
            sqlwrk,
        ) catch |err| {
                const s = @src();
                    @panic( std.fmt.allocPrint(allocREP,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() name:{s}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,like,err})
                        catch unreachable
                    );
                };


        defer select.finalize();
       // Iterate again, full

        select.bind(.{}) catch unreachable;
        defer select.reset();

        while (select.step() catch unreachable) |rcd| {
            defrep.name.setZfld(rcd.name.data);
            defrep.text.setZfld(rcd.text.data);
            defrep.mnmo.setZfld(rcd.mnmo.data);
            defrep.type.setZfld(rcd.type.data);
            defrep.width.setDcml(rcd.width.data);
            defrep.scal.setDcml(rcd.scal.data);
            defrep.long.setDcml(rcd.long.data);
            defrep.hs = rcd.hs.data;
            rows.append(allocREP,defrep)
             catch |err| {
                const s = @src();
                    @panic( std.fmt.allocPrint(allocREP,
                    "\n\n\r file:{s} line:{d} column:{d} func:{s}() name:{s}  err:{}\n\r"
                    ,.{s.file, s.line, s.column,s.fn_name,like,err})
                        catch unreachable
                    );
                };

       }

}




pub fn existRows(db : sql3.Database, name :[]const u8 )  bool {
    const Result = struct { count: usize };

    var sqlwrk : []const u8 = undefined;

    sqlwrk = std.fmt. allocPrint(allocREP,
         "SELECT count(*) as count FROM defrep  WHERE name='{s}'; ",.{name}) catch unreachable;
    defer allocREP.free(sqlwrk);


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
                   if ( rcd.count == 1 ) return true ;
        }
        return false;
}






pub fn delete(db : sql3.Database, name :[]const u8 )  bool {
    if (!db.istable("defrep") ) return false;
    if ( !existRows(db,defrep.name.string())) return false;
    var sqlwrk : []const u8 = undefined;
    sqlwrk = std.fmt. allocPrint(allocREP,
         "DELETE FROM defrep  WHERE name='{s}'",.{name}) catch unreachable;
    defer allocREP.free(sqlwrk);

    db.exec(sqlwrk, .{})
        catch |err| {
            const s = @src();
                @panic( std.fmt.allocPrint(allocREP,
                "\n\n\r file:{s} line:{d} column:{d} func:{s}() name:{s}  err:{}\n\r"
                ,.{s.file, s.line, s.column,s.fn_name,name,err})
                    catch unreachable
                );
            };
    if ( !existRows(db,defrep.name.string())) return true;
    return false;
}
