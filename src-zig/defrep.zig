//----------------------
//---date text----------
//----------------------

const std = @import("std");
// terminal Fonction
const term = @import("cursed");
// keyboard
const kbd = @import("cursed").kbd;
// alloc
const mem = @import("alloc");

// cadre
const cdr = @import("forms").CADRE;
const lne = @import("forms").LINE;

// const dsp = @import("forms").debeug;

// Error
const dsperr = @import("forms").dsperr;

// frame
const frm = @import("forms").frm;

// panel
const pnl = @import("forms").pnl;

// button
const btn = @import("forms").btn;

// label
const lbl = @import("forms").lbl;

// flied
const fld = @import("forms").fld;

// line horizontal
const lnh = @import("forms").lnh;

// line vertival
const lnv = @import("forms").lnv;

// line grid/combo
const grd = @import("grid").grd;

// tools utility
const utl = @import("utils");

// tools regex
const reg = @import("mvzr");

const sql3 = @import("sqlite");
const trep = @import("defrep");

// arena allocator
var arenaPgm = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocPgm = arenaPgm.allocator();
fn deinitPgm() void {
    arenaPgm.reset(.free_all);
}

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



//----------------------
// Define Global DSPF PANEL
//----------------------

pub fn Panel_DEFREP() *pnl.PANEL {
    //----------------------
    var Panel: *pnl.PANEL = pnl.newPanelC("DEFREP", 1, 1, 44,132, cdr.line1, "Def.REPERTOIRE");

    //----------------------
    Panel.button.append(mem.allocTui, btn.newButton(kbd.F1, true, false, "Help")) catch unreachable;
    Panel.button.append(mem.allocTui, btn.newButton(kbd.F3, true, false, "Exit")) catch unreachable;
    Panel.button.append(mem.allocTui, btn.newButton(kbd.F4, true, false, "QUERY")) catch unreachable;
    Panel.button.append(mem.allocTui, btn.newButton(kbd.F7, true, false, "Display GRID")) catch unreachable;
    Panel.button.append(mem.allocTui, btn.newButton(kbd.F9, true, false, "Enrg.")) catch unreachable;
    Panel.button.append(mem.allocTui, btn.newButton(kbd.F11, true, false, "Update")) catch unreachable;
    Panel.button.append(mem.allocTui, btn.newButton(kbd.F12, true, false, "Return")) catch unreachable;
    Panel.button.append(mem.allocTui, btn.newButton(kbd.F23, true, false, "Delette")) catch unreachable;
	Panel.button.append(mem.allocTui,btn.newButton(kbd.pageUp,true,false,"")) catch unreachable ;
	Panel.button.append(mem.allocTui,btn.newButton(kbd.pageDown,true,false,"")) catch unreachable ;

    //----------------------
    Panel.label.append(mem.allocTui, lbl.newLabel("L33", 3, 4, "Name Extended")) catch unreachable;
    Panel.label.append(mem.allocTui, lbl.newLabel("L320", 3, 30, "Text")) catch unreachable;
    Panel.label.append(mem.allocTui, lbl.newLabel("L371", 3, 81, "MNEMO")) catch unreachable;
    Panel.label.append(mem.allocTui, lbl.newLabel("L378", 3, 88, "T")) catch unreachable;
    Panel.label.append(mem.allocTui, lbl.newLabel("L380", 3, 90, "Width")) catch unreachable;
    Panel.label.append(mem.allocTui, lbl.newLabel("L386", 3, 96, "Scal")) catch unreachable;
    Panel.label.append(mem.allocTui, lbl.newLabel("L391", 3, 101, "Long")) catch unreachable;
    Panel.label.append(mem.allocTui, lbl.newLabel("L396", 3, 106, "Hs")) catch unreachable;
    //----------------------

    // info task != "" -> requires= false

    Panel.field.append(mem.allocTui, fld.newFieldTextFree("REFNAME", 4, 4, 25, "", false, // requires
        "Le nom est obligantoire",
        "Nom de la zone étendue",
         "^[a-z]{1,1}[a-z0-9\\-_ ]{1,}$")) catch unreachable;
    fld.setTask(Panel, fld.getIndex(Panel, "REFNAME") catch unreachable, "TctlRefName") catch unreachable;

    Panel.field.append(mem.allocTui, fld.newFieldTextFree("TEXT", 4, 30, 50, "",
        false, "Text Invalide",
        "Libellé de la zone NAME Extended", "")) catch unreachable;
    fld.setTask(Panel, fld.getIndex(Panel, "TEXT") catch unreachable, "TctlText") catch unreachable;

    Panel.field.append(mem.allocTui, fld.newFieldAlphaNumeric("MNEMO", 4, 81, 6,"", false,
        "Mnemonic onmigatoire",
       "mnemoniqque de la zone NAME", "")) catch unreachable;
    fld.setTask(Panel, fld.getIndex(Panel, "MNEMO") catch unreachable, "TctlMnemo") catch unreachable;

    Panel.field.append(mem.allocTui, fld.newFieldFunc("TYPE", 4, 88, 1, "",
        false,
        "Ctype",
        "Type obligatoire",
        "Type de zone")) catch unreachable;
    fld.setTask(Panel, fld.getIndex(Panel, "TYPE") catch unreachable, "TctrlType") catch unreachable;

    Panel.field.append(mem.allocTui, fld.newFieldUDigit("WIDTH", 4, 92, 3, "",
        false,
        "Width Obligatoire",
        "longueur de la zone numérique",
        "[0-9]{1,3}")) catch unreachable;
    fld.setTask(Panel, fld.getIndex(Panel, "WIDTH") catch unreachable, "TctrlWidth") catch unreachable;

    Panel.field.append(mem.allocTui, fld.newFieldUDigit("SCAL", 4, 98, 2, "",
        false,
        "Scal Obligatoire",
        "partie decimale",
        "[0-9]{1,2}")) catch unreachable;
    fld.setTask(Panel, fld.getIndex(Panel, "SCAL") catch unreachable, "TctrlScal") catch unreachable;

    Panel.field.append(mem.allocTui, fld.newFieldUDigit("LONG", 4, 102, 3, "",
        false,
        "Longueur extended Invalide",
        "Longueur de la zone",
        "[0-9]{1,3}")) catch unreachable;
    fld.setProtect(Panel, fld.getIndex(Panel, "LONG") catch unreachable, true) catch unreachable;
    fld.setTask(Panel, fld.getIndex(Panel, "LONG") catch unreachable, "TcrtlLong") catch unreachable;

    Panel.field.append(mem.allocTui, fld.newFieldSwitch("hs", 4, 106,
        false,
        ".",
        "Hors service")) catch unreachable;

    return Panel;
}


//----------------------
// Define Global DSPF PANEL
//----------------------



pub fn Panel_PQUERY() *pnl.PANEL{
			//----------------------
			var Panel : *pnl.PANEL = pnl.newPanelC("PQUERY",
			1, 1,
			41, 132,
			cdr.line1,
			"QUERY");

			//----------------------
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F1,true,false,"Help")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F3,true,false,"Exit")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F12,true,false,"Return")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.ctrlV,true,false,"ctrlV")) catch unreachable ;

			//----------------------
			Panel.label.append(mem.allocTui,lbl.newLabel("L43",4,3,"Field:")) catch unreachable ;
			Panel.label.append(mem.allocTui,lbl.newLabel("L73",7,3,"Text:")) catch unreachable ;

			//----------------------


			Panel.field.append(mem.allocTui,fld.newFieldFunc("zfield",4,9,25,
			"",
			false,
			"Cquery",
			"saisie obligatoire",
			"Choix des zones à scaner")) catch unreachable ;

			Panel.field.append(mem.allocTui,fld.newFieldTextFree("ztext",7,8,20,
			"",
			false,
			"Zone obligatoire",
			"recherhe valeur",
			"")) catch unreachable ;
			fld.setTask(Panel,fld.getIndex(Panel,"ztext") catch unreachable,"Tctlztext") catch unreachable ;


			return Panel;


	}





//Errors
pub const Error = error{
    main_function_Enum_invalide,
    main_run_EnumTask_invalide,
};

var check: bool = false;

//----------------------------------
//  run emun Function ex: combo
//----------------------------------
fn Ctype(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    var cellPos: usize = 0;
    const Xcombo: *grd.GRID = grd.newGridC(
        "Ctype",
        5,
        76,
        5,
        grd.gridStyle,
        grd.CADRE.line1,
    );

    defer grd.freeGrid(Xcombo);
    defer mem.allocTui.destroy(Xcombo);

    grd.newCell(Xcombo, "Type", 4, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
    grd.newCell(Xcombo, "Label", 10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
    grd.setHeaders(Xcombo);

    // data
    grd.addRows(Xcombo, &.{ "T", "Text" });
    grd.addRows(Xcombo, &.{ "N", "Numéric" });
    grd.addRows(Xcombo, &.{ "D", "Date" });
    grd.addRows(Xcombo, &.{ "B", "Bool" });
    grd.addRows(Xcombo, &.{ "I", "Int64" });

    if (std.mem.eql(u8, vfld.text, "T") == true) cellPos = 0;
    if (std.mem.eql(u8, vfld.text, "N") == true) cellPos = 1;
    if (std.mem.eql(u8, vfld.text, "D") == true) cellPos = 2;
    if (std.mem.eql(u8, vfld.text, "B") == true) cellPos = 3;
    if (std.mem.eql(u8, vfld.text, "I") == true) cellPos = 4;

    // Interrogation
    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.deinit(mem.allocTui);

    Gkey = grd.ioCombo(Xcombo, cellPos);
    pnl.rstPanel(grd.GRID, Xcombo, vpnl);

    if (Gkey.Key == kbd.esc) return;
    vfld.text = Gkey.Buf.items[0];
    return;
}


fn Cquery( vpnl : *pnl.PANEL , vfld :* fld.FIELD) void {
	const cellPos:usize = 0;
	const Xcombo : *grd.GRID = grd.newGridC(
			"Cquery",
			4, 39,
			6,
			grd.gridStyle,
			grd.CADRE.line1,
	);

	defer grd.freeGrid(Xcombo);
	defer mem.allocTui.destroy(Xcombo);

	grd.newCell(Xcombo,"ztext",25, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
	grd.setHeaders(Xcombo) ;

	// data
	grd.addRows(Xcombo , &.{"refname"});
	grd.addRows(Xcombo , &.{"text"});
    grd.addRows(Xcombo , &.{"mnmo"});
    grd.addRows(Xcombo , &.{"type"});
    grd.addRows(Xcombo , &.{"hs"});

	// Interrogation
	var Gkey :grd.GridSelect = undefined ;
	defer Gkey.Buf.deinit(mem.allocTui);

	Gkey =grd.ioCombo(Xcombo,cellPos);
	pnl.rstPanel(grd.GRID,Xcombo, vpnl);

	if ( Gkey.Key == kbd.esc ) return ;
	vfld.text = Gkey.Buf.items[0];
	return ;
}

const FuncEnum = enum {
    Ctype,

	Cquery,

	none,
    fn run(self: FuncEnum, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        switch (self) {
            .Ctype  => Ctype(vpnl, vfld),
            .Cquery => Cquery(vpnl, vfld),
            else => dsperr.errorForms(vpnl, Error.main_function_Enum_invalide),
        }
    }
    fn searchFn(vtext: []const u8) FuncEnum {
        inline for (@typeInfo(FuncEnum).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(FuncEnum, @enumFromInt(f.value));
        }
        return FuncEnum.none;
    }
};
var callFunc: FuncEnum = undefined;

//----------------------------------
//  run emun Task ex: control Field
//----------------------------------
fn TctlRefName(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if (std.mem.eql(u8, vfld.text, "")) {
        term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text, pnl.FldErr);
        pnl.msgErr(vpnl, "Le nom est obligantoire");
        vpnl.keyField = kbd.task;
        check = true;
    }
}

fn TctlText(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if (std.mem.eql(u8, vfld.text, "")) {
        term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text, pnl.FldErr);
        pnl.msgErr(vpnl, "Text Invalide");
        vpnl.keyField = kbd.task;
        check = true;
    }
}

fn TctlMnemo(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if (std.mem.eql(u8, vfld.text, "")) {
        term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text, pnl.FldErr);
        pnl.msgErr(vpnl, "Mnemonic onmigatoire");
        vpnl.keyField = kbd.task;
        check = true;
    }
}
fn TctrlType(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if (std.mem.eql(u8, vfld.text, "")) {
        term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text, pnl.FldErr);
        pnl.msgErr(vpnl, "Type obligatoire");
        vpnl.keyField = kbd.task;
        check = true;
    }
}

fn TctrlWidth(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    if (std.mem.eql(u8, vfld.text, "")) {
        term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text, pnl.FldErr);
        pnl.msgErr(vpnl, "Width Obligatoire");
        vpnl.keyField = kbd.task;
        check = true;
    }

    const xx = fld.getText(vpnl, fld.getIndex(vpnl, "TYPE") catch unreachable) catch unreachable;
    if (std.mem.eql(u8, xx, "B")) vfld.text = "1";
    if (std.mem.eql(u8, xx, "N")) {
        var width: u64 = 0;
        if (!std.mem.eql(u8, vfld.text, ""))
            width = std.fmt.parseUnsigned(u64, vfld.text, 10) catch unreachable;
        if (width > 34) {
            term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
            term.writeStyled(vfld.text, pnl.FldErr);
            pnl.msgErr(vpnl, "zone numérique trop grande");
            vpnl.keyField = kbd.task;
            check = true;
        }
    }
    if (std.mem.eql(u8, xx, "D")) {
        var width: u64 = 0;
        if (!std.mem.eql(u8, vfld.text, ""))
            width = std.fmt.parseUnsigned(u64, vfld.text, 10) catch unreachable;
        if (width != 10) {
            term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
            term.writeStyled(vfld.text, pnl.FldErr);
            pnl.msgErr(vpnl, "zone date invalide  long = 10 ");
            vpnl.keyField = kbd.task;
            check = true;
        }
    }
    fld.printField(vpnl, vpnl.field.items[vpnl.idxfld]);
    fld.displayField(vpnl, vpnl.field.items[vpnl.idxfld]);
}

fn TctrlScal(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    const vtype = fld.getText(vpnl, fld.getIndex(vpnl, "TYPE") catch unreachable) catch unreachable;
    if (!std.mem.eql(u8, vtype, "N")) {
        vfld.text = "0" ;
        fld.printField(vpnl, vpnl.field.items[vpnl.idxfld]);
        fld.displayField(vpnl, vpnl.field.items[vpnl.idxfld]);
        return;
    }


    if (std.mem.eql(u8, vfld.text, "")) {
        term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text, pnl.FldErr);
        pnl.msgErr(vpnl, "Scal Obligatoire");
        vpnl.keyField = kbd.task;
        check = true;
        fld.printField(vpnl, vpnl.field.items[vpnl.idxfld]);
        fld.displayField(vpnl, vpnl.field.items[vpnl.idxfld]);
        return;
    }

    var width: u64 = 0;
    var scal: u64 = 0;
    const xx = fld.getText(vpnl, fld.getIndex(vpnl, "WIDTH") catch unreachable) catch unreachable;
    if (!std.mem.eql(u8, xx, ""))
        width = std.fmt.parseUnsigned(u64, xx, 10) catch unreachable;
    scal = std.fmt.parseUnsigned(u64, vfld.text, 10) catch unreachable;
    if (width + scal > 34) {
        term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text, pnl.FldErr);
        pnl.msgErr(vpnl, "zone numérique width + scal trop grande max: 34");
        vpnl.keyField = kbd.task;
        check = true;
    }

    fld.printField(vpnl, vpnl.field.items[vpnl.idxfld]);
    fld.displayField(vpnl, vpnl.field.items[vpnl.idxfld]);
}

fn TcrtlLong(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
    var width: u64 = 0;
    var xx = fld.getText(vpnl, fld.getIndex(vpnl, "WIDTH") catch unreachable) catch unreachable;
    if (!std.mem.eql(u8, xx, "")) {
        width = std.fmt.parseUnsigned(u64, xx, 10) catch unreachable;
    }

    var scal: u64 = 0;
    xx = fld.getText(vpnl, fld.getIndex(vpnl, "SCAL") catch unreachable) catch unreachable;
    if (!std.mem.eql(u8, xx, "")) {
        scal = std.fmt.parseUnsigned(u64, xx, 10) catch unreachable;
        scal += 1 ; // add ","
    }

    width += scal ;
    vfld.text = std.fmt.allocPrint(mem.allocTui, "{d}", .{width}) catch unreachable;

    fld.printField(vpnl, vpnl.field.items[vpnl.idxfld]);
    fld.displayField(vpnl, vpnl.field.items[vpnl.idxfld]);

    if (std.mem.eql(u8, vfld.text, "0")) {
        term.gotoXY(vpnl.posx + vfld.posx - 1, vpnl.posy + vfld.posy - 1);
        term.writeStyled(vfld.text, pnl.FldErr);
        pnl.msgErr(vpnl, "Longueur extended Invalide");
        vpnl.keyField = kbd.task;
        check = true;
    }
}

	fn Tctlztext(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		if (std.mem.eql(u8, vfld.text ,"")) {
			term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
			term.writeStyled(vfld.text,pnl.FldErr);
			pnl.msgErr(vpnl, "Zone obligatoire");
			vpnl.keyField = kbd.task;
			check = true;
		}
	}

const TaskEnum = enum {
    TctlRefName,

    TctlText,

    TctlMnemo,

    TctrlType,

    TctrlWidth,

    TctrlScal,

    TcrtlLong,

	Tctlztext,

    none,
    fn run(self: TaskEnum, vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
        check = false;
        switch (self) {
            .TctlRefName => TctlRefName(vpnl, vfld),
            .TctlText => TctlText(vpnl, vfld),
            .TctlMnemo => TctlMnemo(vpnl, vfld),
            .TctrlType => TctrlType(vpnl, vfld),
            .TcrtlLong => TcrtlLong(vpnl, vfld),
            .TctrlWidth => TctrlWidth(vpnl, vfld),
            .TctrlScal => TctrlScal(vpnl, vfld),
            .Tctlztext => Tctlztext(vpnl,vfld),
            else => dsperr.errorForms(vpnl, Error.main_run_EnumTask_invalide),
        }
    }
    fn searchFn(vtext: []const u8) TaskEnum {
        inline for (@typeInfo(TaskEnum).@"enum".fields) |f| {
            if (std.mem.eql(u8, f.name, vtext)) return @as(TaskEnum, @enumFromInt(f.value));
        }
        return TaskEnum.none;
    }
};
var callTask: TaskEnum = undefined;

// define Panel
var PDEFREP: *pnl.PANEL = undefined;

// define Panel
var PQUERY : *pnl.PANEL = undefined ;

var nbr_panel: i32 = 1;


var dbr : sql3.Database = undefined;
var dbrw : sql3.Database = undefined;
//----------------------------------
// squelette MAIN
//----------------------------------

pub fn main() !void {
    // init terminal
    term.enableRawMode();
    defer term.disableRawMode();

    // init Panel
    PDEFREP = Panel_DEFREP();

    // init Panel
    PQUERY = Panel_PQUERY();

    // Initialisation
    term.resizeTerm(PDEFREP.lines, PDEFREP.cols);

    term.titleTerm("MY-REPERTOIRE");

    term.cls();

    var Tkey: term.Keyboard = undefined;
    var npnl: i32 = 1;


     dbr = sql3.open("sqlite", "repdb.db", sql3.Mode.ReadOnly) catch |err| {
        const s = @src();
            @panic( std.fmt.allocPrint(allocPgm,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}() err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,err})
                catch unreachable
            );
        };
    defer dbr.close();

    dbrw = sql3.open("sqlite", "repdb.db", sql3.Mode.ReadWrite) catch |err| {
        const s = @src();
            @panic( std.fmt.allocPrint(allocPgm,
            "\n\n\r file:{s} line:{d} column:{d} func:{s}() err:{}\n\r"
            ,.{s.file, s.line, s.column,s.fn_name,err})
                catch unreachable
            );
        };
    defer dbrw.close();


    while (npnl <= nbr_panel) {
        switch (npnl) {
            1 => {
                Tkey = pnl_DEFREP();
                //--- traitement ---
            },
            else => {},
        }
        if (Tkey.Key == kbd.F3) break; // end work
        if (Tkey.Key == kbd.F12 and npnl > 1) npnl -= 1; // preview work
    }
}

//----------------------------------
// squelette PANEL
//----------------------------------

fn pnl_DEFREP() term.Keyboard {

    //----------------------------------
    //  run Function ex: PANEL
    //----------------------------------
    // defines the receiving structure of the keyboard

    var Tkey: term.Keyboard = undefined;

    var ok : bool = false;

    while (true) {
        Tkey.Key = pnl.ioPanel(PDEFREP);
        //--- ---

        switch (Tkey.Key) {
            // call function Combo ...
            .func => {
                callFunc = FuncEnum.searchFn(PDEFREP.field.items[PDEFREP.idxfld].procfunc);
                callFunc.run(PDEFREP, &PDEFREP.field.items[PDEFREP.idxfld]);
            },

            // call proc contrôl chek value
            .task => {
                callTask = TaskEnum.searchFn(PDEFREP.field.items[PDEFREP.idxfld].proctask);
                callTask.run(PDEFREP, &PDEFREP.field.items[PDEFREP.idxfld]);
            },
            //----------------------
            //F1 "Help"
            .F1 => {},

            .F4 => {

                Tkey = pnl_PQUERY();

            },
            //F7 "Display GRID"
            .F7 => {
                ok = Grepertoire(PDEFREP, .F7) ;
                if (ok) {
                    fld.setText(PDEFREP,0,trep.defrep.refname.string()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,1,trep.defrep.text.string()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,2,trep.defrep.mnmo.string()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,3,trep.defrep.type.string()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,4,trep.defrep.width.strUInt()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,5,trep.defrep.scal.strUInt()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,6,trep.defrep.long.strUInt()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setSwitch(PDEFREP,7,trep.defrep.hs) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    pnl.printPanel(PDEFREP);
                }
            },
            //F9 "Enrg."
            .F9 => {
                for (PDEFREP.field.items, 0..) |f, idxfld| {
                    if (!std.mem.eql(u8, f.proctask, "")) {
                        PDEFREP.idxfld = idxfld;
                        callTask = TaskEnum.searchFn(f.proctask);
                        callTask.run(PDEFREP, &PDEFREP.field.items[idxfld]);
                        if (check) break;
                    }
                }
                if (!check) {
                    // work enrg.
                    trep.defrep.refname.setZfld(PDEFREP.field.items[0].text);
                    trep.defrep.text.setZfld(PDEFREP.field.items[1].text);
                    trep.defrep.mnmo.setZfld(PDEFREP.field.items[2].text);
                    trep.defrep.type.setZfld(PDEFREP.field.items[3].text);
                    trep.defrep.width.setDcml(PDEFREP.field.items[4].text);
                    trep.defrep.scal.setDcml(PDEFREP.field.items[5].text);
                    trep.defrep.long.setDcml(PDEFREP.field.items[6].text);
                    if (PDEFREP.field.items[7].zwitch == false) trep.defrep.hs =true else trep.defrep.hs = false;

                    if( ! trep.insert(dbrw)) pnl.msgErr(PDEFREP, "enregistrement inconnu")
                    else pnl.msgErr(PDEFREP, "enregistrement ajouter");
                    fld.clearAll(PDEFREP);
                    _= Grepertoire(PDEFREP,.pageUp);
                    PDEFREP.idxfld =0;
                    pnl.printPanel(PDEFREP);
                }
            },
            //F11 "Update"
            .F11 => {
                for (PDEFREP.field.items, 0..) |f, idxfld| {
                    if (!std.mem.eql(u8, f.proctask, "")) {
                        PDEFREP.idxfld = idxfld;
                        callTask = TaskEnum.searchFn(f.proctask);
                        callTask.run(PDEFREP, &PDEFREP.field.items[idxfld]);
                        if (check) break;
                    }
                }
                if (!check) {
                    // work update.

                    trep.defrep.refname.setZfld(PDEFREP.field.items[0].text);
                    trep.defrep.text.setZfld(PDEFREP.field.items[1].text);
                    trep.defrep.mnmo.setZfld(PDEFREP.field.items[2].text);
                    trep.defrep.type.setZfld(PDEFREP.field.items[3].text);
                    trep.defrep.width.setDcml(PDEFREP.field.items[4].text);
                    trep.defrep.scal.setDcml(PDEFREP.field.items[5].text);
                    trep.defrep.long.setDcml(PDEFREP.field.items[6].text);
                    if (PDEFREP.field.items[7].zwitch == true) trep.defrep.hs =true else trep.defrep.hs = false;


                    if( ! trep.update(dbrw)) pnl.msgErr(PDEFREP, "enregistrement inconnu")
                    else pnl.msgErr(PDEFREP, "enregistrement mis à jour");
                    fld.clearAll(PDEFREP);
                    _= Grepertoire(PDEFREP,.pageUp);
                    PDEFREP.idxfld =0;
                    pnl.printPanel(PDEFREP);

                }
            },
            //F12 "Return"
            .F12 => {},
            //F23 "Delette"
            .F23 => {
                trep.defrep.refname.setZfld(PDEFREP.field.items[0].text);
                if( ! trep.delete(dbrw, trep.defrep.refname.string() )) pnl.msgErr(PDEFREP, "enregistrement inconnu")
                else pnl.msgErr(PDEFREP, "enregistrement supprimer");
                fld.clearAll(PDEFREP);
                pnl.printPanel(PDEFREP);

            },
			//pageUp ""
			.pageUp  => {
			    _= Grepertoire(PDEFREP,.pageUp) ;
			},
			//pageDown ""
			.pageDown  => {
			    _= Grepertoire(PDEFREP,.pageDown) ;
			},
            else => {},
        }

        if (Tkey.Key == kbd.F3) break; // end work
        if (Tkey.Key == kbd.F12) {
            fld.clearAll(PDEFREP);
            pnl.printPanel(PDEFREP);
            break; // end work
         }
    }
    return Tkey;
}

fn pnl_PQUERY() term.Keyboard {

//----------------------------------
//  run Function ex: PANEL
//----------------------------------
// defines the receiving structure of the keyboard
var Tkey : term.Keyboard = undefined ;

    var ok : bool = false;
    pnl.clearPanel(PQUERY);

    while (true) {
        Tkey.Key = pnl.ioPanel(PQUERY);

    	//--- ---

    	switch (Tkey.Key) {
        	.func => {
        	callFunc = FuncEnum.searchFn(PQUERY.field.items[PQUERY.idxfld].procfunc);
        	callFunc.run(PQUERY, &PQUERY.field.items[PQUERY.idxfld]);
        	},

        	// call proc contrôl chek value
        	.task => {
        	callTask = TaskEnum.searchFn(PQUERY.field.items[PQUERY.idxfld].proctask);
        	callTask.run(PQUERY, &PQUERY.field.items[PQUERY.idxfld]);
        	},


        	//----------------------
        	//F1 "Help"
        	.F1  => {
        	},
        	//F12 "Return"
        	.F12  => {
        	    pnl.rstPanel(pnl.PANEL,PQUERY,PDEFREP);
             //    Tkey.Key = kbd.esc;
        	    // return Tkey;
        	},
        	//ctrlV "ctrlV"
        	.ctrlV  => {
                pnl.rstPanel(pnl.PANEL,PQUERY,PDEFREP);
        	    ok = Grepertoire(PDEFREP,.ctrlV) ;
        	    if (ok) {
                    fld.setText(PDEFREP,0,trep.defrep.refname.string()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,1,trep.defrep.text.string()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,2,trep.defrep.mnmo.string()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,3,trep.defrep.type.string()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,4,trep.defrep.width.strUInt()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,5,trep.defrep.scal.strUInt()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setText(PDEFREP,6,trep.defrep.long.strUInt()) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    fld.setSwitch(PDEFREP,7,trep.defrep.hs) catch |err| {dsperr.errorForms(PDEFREP,err);};
                    PDEFREP.idxfld =0;
                    pnl.printPanel(PDEFREP);
                }

                return Tkey;
        	},
        	else => {},

    	}

		if (Tkey.Key == kbd.F3) break; // end work
		if (Tkey.Key == kbd.F12) break; // end work
	}

	return  Tkey;
}

//----------------------------------
//  run Function ex: SFLD
//----------------------------------
fn Grepertoire(vpnl: *pnl.PANEL, vkbd: term.kbd) bool {
    _= vpnl;
    const SFLDX: *grd.GRID = grd.newGridC(
        "Grept",
        6,
        2,
        30,
        grd.gridStyle,
        grd.CADRE.line1,
    );

    if (grd.countColumns(SFLDX) == 0) {
        grd.newCell(SFLDX, "REFNAME", 25, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
        grd.newCell(SFLDX, "TEXT", 50, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
        grd.newCell(SFLDX, "MNEMO", 6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
        grd.newCell(SFLDX, "T", 1, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgRed);
        grd.newCell(SFLDX, "WIGTH", 5, grd.REFTYP.UDIGIT, term.ForegroundColor.fgMagenta);
        grd.newCell(SFLDX, "SCAL", 4, grd.REFTYP.UDIGIT, term.ForegroundColor.fgMagenta);
        grd.newCell(SFLDX, "LONG", 4, grd.REFTYP.UDIGIT, term.ForegroundColor.fgCyan);
        grd.newCell(SFLDX, "Hs", 1, grd.REFTYP.SWITCH, term.ForegroundColor.fgRed);
    }
    grd.setHeaders(SFLDX);

    // data
    grd.resetRows(SFLDX);

    if (vkbd == kbd.F7) trep.defrep.refname.setZfld(PDEFREP.field.items[0].text);
    if (vkbd == kbd.ctrlV){
        trep.lgqQUERY(dbr, PQUERY.field.items[0].text, PQUERY.field.items[1].text); // full
    }
    else trep.pgDown(dbr, trep.defrep.refname.string(), 30);

    for (trep.rows.items, 0..) |_, n| {
    grd.addRows(SFLDX, &.{trep.rows.items[n].refname.string(),
        trep.rows.items[n].text.string(), trep.rows.items[n].mnmo.string(),
        trep.rows.items[n].type.string(), trep.rows.items[n].width.string(), trep.rows.items[n].scal.string(),
        trep.rows.items[n].long.string(), sql3.zbool(trep.rows.items[n].hs) });
    }

    // Interrogation
    var Gkey: grd.GridSelect = undefined;
    defer Gkey.Buf.deinit(mem.allocTui);

    while (true) {
        if (vkbd == kbd.ctrlV)  Gkey = grd.ioGrid(SFLDX, false)
        else Gkey = grd.ioGrid(SFLDX, true);

        // pnl.rstPanel(grd.GRID, SFLDX, vpnl);

        if (Gkey.Key == kbd.esc) return false;
        if (Gkey.Key == kbd.enter) {
            trep.lgqQUERY(dbr,"refname",Gkey.Buf.items[0]);
            return true;
        }
        if (Gkey.Key == kbd.pageDown) {
            grd.resetRows(SFLDX);
            trep.pgDown(dbr, trep.defrep.refname.string(), 30);
            for (trep.rows.items, 0..) |_, n| {
            grd.addRows(SFLDX, &.{trep.rows.items[n].refname.string(),
                trep.rows.items[n].text.string(), trep.rows.items[n].mnmo.string(),
                trep.rows.items[n].type.string(), trep.rows.items[n].width.string(), trep.rows.items[n].scal.string(),
                trep.rows.items[n].long.string(), sql3.zbool(trep.rows.items[n].hs) });
            }
        }
        if (Gkey.Key == kbd.pageUp) {
            grd.resetRows(SFLDX);
            trep.pgUp(dbr, trep.rows.items[0].refname.string(), 30);
            for (trep.rows.items, 0..) |_, n| {
            grd.addRows(SFLDX, &.{trep.rows.items[n].refname.string(),
                trep.rows.items[n].text.string(), trep.rows.items[n].mnmo.string(),
                trep.rows.items[n].type.string(), trep.rows.items[n].width.string(), trep.rows.items[n].scal.string(),
                trep.rows.items[n].long.string(), sql3.zbool(trep.rows.items[n].hs) });
            }
        }
    }
}
