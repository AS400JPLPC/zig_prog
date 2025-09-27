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


// arena allocator 
var arenaPgm = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var  allocPgm = arenaPgm .allocator();
fn deinitPgm () void {
	arenaPgm .reset(.free_all);
}



//----------------------
// Define Global DSPF PANEL
//----------------------



pub fn Panel_DEFREP() *pnl.PANEL{
			//----------------------
			var Panel : *pnl.PANEL = pnl.newPanelC("DEFREP",
			1, 1,
			44, 168,
			cdr.line1,
			"Def.REPERTOIRE");

			//----------------------
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F1,true,false,"Help")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F3,true,false,"Exit")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F7,true,false,"Display GRID")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F9,true,false,"Enrg.")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F11,true,false,"Update")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F12,true,false,"Return")) catch unreachable ;
			Panel.button.append(mem.allocTui,btn.newButton(kbd.F23,true,false,"Delette")) catch unreachable ;

			//----------------------
			Panel.label.append(mem.allocTui,lbl.newLabel("L33",3,4,"Name Extended")) catch unreachable ;
			Panel.label.append(mem.allocTui,lbl.newLabel("L320",3,30,"Text")) catch unreachable ;
			Panel.label.append(mem.allocTui,lbl.newLabel("L371",3,81,"MNEMO")) catch unreachable ;
			Panel.label.append(mem.allocTui,lbl.newLabel("L378",3,88,"T")) catch unreachable ;
			Panel.label.append(mem.allocTui,lbl.newLabel("L380",3,90,"Width")) catch unreachable ;
			Panel.label.append(mem.allocTui,lbl.newLabel("L386",3,96,"Scal")) catch unreachable ;
			Panel.label.append(mem.allocTui,lbl.newLabel("L391",3,101,"Long")) catch unreachable ;
			Panel.label.append(mem.allocTui,lbl.newLabel("L396",3,106,"Hs")) catch unreachable ;

			//----------------------


			Panel.field.append(mem.allocTui,fld.newFieldTextFree("NAME",4,4,25,
			"",
			false,
			"Le nom est obligantoire",
			"Nom de la zone étendue",
			"")) catch unreachable ;
			fld.setTask(Panel,fld.getIndex(Panel,"NAME") catch unreachable,"TctlName") catch unreachable ; 


			Panel.field.append(mem.allocTui,fld.newFieldTextFree("TEXT",4,30,50,
			"",
			false,
			"Text Invalide",
			"Libellé zone NAME Extended",
			"")) catch unreachable ;
			fld.setTask(Panel,fld.getIndex(Panel,"TEXT") catch unreachable,"TctlText") catch unreachable ; 


			Panel.field.append(mem.allocTui,fld.newFieldAlphaNumericUpper("MNEMO",4,81,6,
			"",
			false,
			"Mnemonic onmigatoire",
			"mnemoniqque de la zone NAME",
			"")) catch unreachable ;
			fld.setTask(Panel,fld.getIndex(Panel,"MNEMO") catch unreachable,"TctlMnemo") catch unreachable ; 


			Panel.field.append(mem.allocTui,fld.newFieldFunc("TYPE",4,88,1,
			"",
			false,
			"Ctype",
			"Type obligatoire",
			"Type de zone")) catch unreachable ;
			fld.setTask(Panel,fld.getIndex(Panel,"TYPE") catch unreachable,"TctrlType") catch unreachable ; 


			Panel.field.append(mem.allocTui,fld.newFieldUDigit("WIDTH",4,92,3,
			"",
			false,
			"Width Obligatoire",
			"longueur de la zone numérique",
			"[0-9]{1,3}")) catch unreachable ;
			fld.setTask(Panel,fld.getIndex(Panel,"WIDTH") catch unreachable,"TctrlWidth") catch unreachable ; 


			Panel.field.append(mem.allocTui,fld.newFieldUDigit("SCAL",4,97,3,
			"",
			false,
			"Scal Obligatoire",
			"partie decimale",
			"[0-9]{1,3}")) catch unreachable ;
			fld.setTask(Panel,fld.getIndex(Panel,"SCAL") catch unreachable,"TctrlScal") catch unreachable ; 


			Panel.field.append(mem.allocTui,fld.newFieldUDigit("LONG",4,102,3,
			"",
			false,
			"Longueur de la zone extended Invalide",
			"Longueur de la zone",
			"[0-9]{1,3}")) catch unreachable ;
			fld.setProtect(Panel,fld.getIndex(Panel,"LONG") catch unreachable, true) catch unreachable ; 
			fld.setTask(Panel,fld.getIndex(Panel,"LONG") catch unreachable,"TcrtlLong") catch unreachable ; 


			Panel.field.append(mem.allocTui,fld.newFieldSwitch("hs",4,106,false,
			".",
			"Hors service")) catch unreachable ;


			return Panel;


	}



	//Errors
	pub const Error = error{
		main_function_Enum_invalide,
		main_run_EnumTask_invalide,
	};


	var check : bool = false;



//----------------------------------
//  run emun Function ex: combo
//----------------------------------
	fn Ctype( vpnl : *pnl.PANEL , vfld :* fld.FIELD) void {
		var cellPos:usize = 0;
		const Xcombo : *grd.GRID = grd.newGridC(
				"Ctype",
				4, 76,
				5,
				grd.gridStyle,
				grd.CADRE.line1,
		);

		defer grd.freeGrid(Xcombo);
		defer mem.allocTui.destroy(Xcombo);

		grd.newCell(Xcombo,"Type",4, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
		grd.newCell(Xcombo,"Label",10, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
		grd.setHeaders(Xcombo) ;

		// data
		grd.addRows(Xcombo , &.{"??"});

		if (std.mem.eql(u8,vfld.text,"??") == true) 	cellPos = 0;

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
		Ftype,

		none,
		fn run(self: FuncEnum, vpnl : *pnl.PANEL, vfld: *fld.FIELD ) void {
			switch (self) {
			.Ftype => Ctype(vpnl,vfld),
			else => dsperr.errorForms(vpnl, Error.main_function_Enum_invalide),
			}
		}
		fn searchFn ( vtext: [] const u8 ) FuncEnum {
			inline for (@typeInfo(FuncEnum).@"enum".fields) |f| {
				if ( std.mem.eql(u8, f.name , vtext) ) return @as(FuncEnum,@enumFromInt(f.value));
			}
			return FuncEnum.none;
		}
	};
	var callFunc: FuncEnum = undefined;



//----------------------------------
//  run emun Task ex: control Field
//----------------------------------
	fn TctlName(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		if (std.mem.eql(u8, vfld.text ,"")) {
			term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
			term.writeStyled(vfld.text,pnl.FldErr);
			pnl.msgErr(vpnl, "Le nom est obligantoire");
			vpnl.keyField = kbd.task;
			check = true;
		}
	}
	fn TctlText(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		if (std.mem.eql(u8, vfld.text ,"")) {
			term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
			term.writeStyled(vfld.text,pnl.FldErr);
			pnl.msgErr(vpnl, "Text Invalide");
			vpnl.keyField = kbd.task;
			check = true;
		}
	}
	fn TctlMnemo(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		if (std.mem.eql(u8, vfld.text ,"")) {
			term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
			term.writeStyled(vfld.text,pnl.FldErr);
			pnl.msgErr(vpnl, "Mnemonic onmigatoire");
			vpnl.keyField = kbd.task;
			check = true;
		}
	}
	fn TctrlType(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		if (std.mem.eql(u8, vfld.text ,"")) {
			term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
			term.writeStyled(vfld.text,pnl.FldErr);
			pnl.msgErr(vpnl, "Type obligatoire");
			vpnl.keyField = kbd.task;
			check = true;
		}
	}
	fn TctrlWidth(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		if (std.mem.eql(u8, vfld.text ,"")) {
			term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
			term.writeStyled(vfld.text,pnl.FldErr);
			pnl.msgErr(vpnl, "Width Obligatoire");
			vpnl.keyField = kbd.task;
			check = true;
		}
	}
	fn TctrlScal(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		if (std.mem.eql(u8, vfld.text ,"")) {
			term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
			term.writeStyled(vfld.text,pnl.FldErr);
			pnl.msgErr(vpnl, "Scal Obligatoire");
			vpnl.keyField = kbd.task;
			check = true;
		}
	}
	fn TcrtlLong(vpnl: *pnl.PANEL, vfld: *fld.FIELD) void {
		if (std.mem.eql(u8, vfld.text ,"")) {
			term.gotoXY(vpnl.posx + vfld.posx - 1 , vpnl.posy + vfld.posy - 1);
			term.writeStyled(vfld.text,pnl.FldErr);
			pnl.msgErr(vpnl, "Longueur de la zone extended Invalide");
			vpnl.keyField = kbd.task;
			check = true;
		}
	}


	const TaskEnum = enum {
		TctlName,

		TctlText,

		TctlMnemo,

		TctrlType,

		TctrlWidth,

		TctrlScal,

		TcrtlLong,

		none,
		fn run(self: TaskEnum, vpnl : *pnl.PANEL, vfld: *fld.FIELD ) void {
			switch (self) {
			.TctlName => TctlName(vpnl,vfld),
			.TctlText => TctlText(vpnl,vfld),
			.TctlMnemo => TctlMnemo(vpnl,vfld),
			.TctrlType => TctrlType(vpnl,vfld),
			.TctrlWidth => TctrlWidth(vpnl,vfld),
			.TctrlScal => TctrlScal(vpnl,vfld),
			.TcrtlLong => TcrtlLong(vpnl,vfld),
			else => dsperr.errorForms(vpnl, Error.main_run_EnumTask_invalide),
			}
		}
		fn searchFn ( vtext: [] const u8 ) TaskEnum {
			inline for (@typeInfo(TaskEnum).@"enum".fields) |f| {
				if ( std.mem.eql(u8, f.name , vtext) ) return @as(TaskEnum,@enumFromInt(f.value));
			}
			return TaskEnum.none;
		}
	};
	var callTask: TaskEnum = undefined;




// define Panel
var DEFREP : *pnl.PANEL = undefined ;

var nbr_panel : i32 = 1 ;


//----------------------------------
// squelette MAIN 
//----------------------------------

pub fn main() !void {
// init terminal
term.enableRawMode();
defer term.disableRawMode() ;

// init Panel
DEFREP = Panel_DEFREP();

// Initialisation
term.resizeTerm(DEFREP.lines,DEFREP.cols);

term.titleTerm("MY-TITLE");

term.cls();

var Tkey : term.Keyboard = undefined ;
var npnl : i32 = 1 ;

		while(npnl <= nbr_panel) {
			switch(npnl) {
				1 => {
					Tkey = pnl_DEFREP();
					//--- traitement ---
				},
				else => {},
			}
			if (Tkey.Key == kbd.F3) break; // end work
			if (Tkey.Key == kbd.F12 and npnl > 1 ) npnl -=1; // preview work
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
var Tkey : term.Keyboard = undefined ;

	while (true) {
		Tkey.Key = pnl.ioPanel(DEFREP);
		//--- ---

		switch (Tkey.Key) {
			.func => {
			callFunc = FuncEnum.searchFn(DEFREP.field.items[DEFREP.idxfld].procfunc);
			callFunc.run(DEFREP, &DEFREP.field.items[DEFREP.idxfld]);
			},

			// call proc contrôl chek value
			.task => {
			callTask = TaskEnum.searchFn(DEFREP.field.items[DEFREP.idxfld].proctask);
			callTask.run(DEFREP, &DEFREP.field.items[DEFREP.idxfld]);
			},


			//----------------------
			//F1 "Help"
			.F1  => {
			},
			//F7 "Display GRID"
			.F7  => {
			},
			//F9 "Enrg."
			.F9  => {
				for( DEFREP.field.items, 0..) | f , idxfld | {
					if ( !std.mem.eql(u8,f.proctask,"") ) {
						DEFREP.idxfld = idxfld ;
						callTask = TaskEnum.searchFn(f.proctask);
						callTask.run(DEFREP, &DEFREP.field.items[idxfld]);
						if ( check ) break; 
					}
				}
				if (! check ) {
					// work enrg.
					// ...
				}
			},
			//F11 "Update"
			.F11  => {
				for( DEFREP.field.items, 0..) | f , idxfld | {
					if ( !std.mem.eql(u8,f.proctask,"") ) {
						DEFREP.idxfld = idxfld ;
						callTask = TaskEnum.searchFn(f.proctask);
						callTask.run(DEFREP, &DEFREP.field.items[idxfld]);
						if ( check ) break; 
					}
				}
				if (! check ) {
					// work update.
					// ...
				}
			},
			//F12 "Return"
			.F12  => {
			},
			//F23 "Delette"
			.F23  => {
			},
			else => {},

		}

		if (Tkey.Key == kbd.F3) break; // end work
		if (Tkey.Key == kbd.F12) break; // end work
	}

	return Tkey;
}




//----------------------------------
//  run Function ex: SFLD
//----------------------------------
	fn Grept( vpnl : *pnl.PANEL ) ?[] const u8 {
		const SFLDX: *grd.GRID = grd.newGridC(
				"Grept",
				6, 2,
				30,
				grd.gridStyle,
				grd.CADRE.line1,
		);

		if (grd.countColumns(SFLDX)  == 0) {
			grd.newCell(SFLDX,"NAME",25, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
			grd.newCell(SFLDX,"TEXT",50, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgGreen);
			grd.newCell(SFLDX,"MNEMO",6, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgYellow);
			grd.newCell(SFLDX,"T",1, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgRed);
			grd.newCell(SFLDX,"WIGTH",5, grd.REFTYP.UDIGIT, term.ForegroundColor.fgMagenta);
			grd.newCell(SFLDX,"SCAL",4, grd.REFTYP.UDIGIT, term.ForegroundColor.fgMagenta);
			grd.newCell(SFLDX,"LONG",4, grd.REFTYP.UDIGIT, term.ForegroundColor.fgCyan);
			grd.newCell(SFLDX,"Hs",2, grd.REFTYP.TEXT_FREE, term.ForegroundColor.fgRed);
		}
		grd.setHeaders(SFLDX) ;

		// data
		if (grd.countColumns(SFLDX)  == 0) {
		grd.resetRows(SFLDX);
		grd.addRows(SFLDX , &.{"??"});

		}

		// Interrogation
		var Gkey :grd.GridSelect = undefined ;
		defer Gkey.Buf.deinit(mem.allocTui);

		while (true ){
			Gkey =grd.ioGrid(SFLDX ,true);
			pnl.rstPanel(grd.GRID,SFLDX, vpnl);

			if ( Gkey.Key == kbd.esc ) return null ;
			if ( Gkey.Key == kbd.enter ) {
				return Gkey.Buf.items[0];
			}
			if (Gkey.Key    == kbd.pageDown) {
				grd.resetRows(SFLDX);
				grd.addRows(SFLDX , &.{"??"});

			}
			if (Gkey.Key    == kbd.pageUp) {
				grd.resetRows(SFLDX);
				grd.addRows(SFLDX , &.{"??"});

			}
		}
	}
