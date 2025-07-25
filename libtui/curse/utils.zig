    ///----------------------
    /// boite à outils
    ///----------------------
const std = @import("std");

const utf = @import("std").unicode;

// display grid
pub const CTRUE = "✔";
pub const CFALSE = " ";

pub const CMP = enum { LT, EQ, GT };

pub const ALIGNS = enum { left, rigth };




///------------------------------------
/// utility
///------------------------------------
//free memory
var arenaUtl = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub var allocUtl = arenaUtl.allocator();

pub fn deinitUtl() void {
    arenaUtl.deinit();
    arenaUtl = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    allocUtl = arenaUtl.allocator();
}

/// Errors that may occur when using String
pub const ErrUtils = error{char_not_digital_invalide};

pub fn strToUint(str: []const u8) usize {
    if (str.len == 0) return 0;

    var digit: [1][]u8 = undefined;
    var buffer: [100]u8 = [_]u8{0} ** 100;

    digit[0] = std.fmt.bufPrint(buffer[0..], "{s}", .{str}) catch |err| {
        @panic(@errorName(err));
    };

    for (digit, 0..) |d, idx| {
        if (!std.ascii.isDigit(d[idx])) {
            @panic(@errorName(ErrUtils.char_not_digital_invalide));
        }
    }

    return std.fmt.parseUnsigned(u64, str, 10) catch |err| {
        @panic(@errorName(err));
    };
}

pub fn UintToStr(v: usize) []const u8 {
    return std.fmt.allocPrint(allocUtl, "{d}", .{v}) catch |err| {
        @panic(@errorName(err));
    };
}

pub fn strToUsize(v: []const u8) usize {
    return std.fmt.parseUnsigned(u64, v, 10) catch |err| {
        @panic(@errorName(err));
    };
}
pub fn usizeToStr(v: usize) []const u8 {
    return std.fmt.allocPrint(allocUtl, "{d}", .{v}) catch |err| {
        @panic(@errorName(err));
    };
}



/// Iterator support iteration string
pub const iteratStr = struct {
	var strbuf:[] const u8 = undefined;

	/// Errors that may occur when using String
	pub const ErrNbrch = error{
		InvalideAllocBuffer,
	};
	


	pub const StringIterator = struct {
		buf: []u8 ,
		index: usize ,


		fn allocBuffer ( size :usize) ErrNbrch![]u8 {
			const buf = allocUtl.alloc(u8, size) catch {
				return ErrNbrch.InvalideAllocBuffer;
			};
			return buf;
		}

		/// Deallocates the internal buffer
		pub fn deinit(self: *StringIterator) void {
			if (self.buf.len > 0)	allocUtl.free(self.buf);
			strbuf = undefined;
		}

		pub fn next(it: *StringIterator) ?[]const u8 {
			const optional_buf: ?[]u8	= allocBuffer(strbuf.len) catch return null;
			
			it.buf= optional_buf orelse "";
			var idx : usize = 0;

			while (true) {
				if (idx >= strbuf.len) break;
				it.buf[idx] = strbuf[idx];
				idx += 1;
			}

			if (it.index == it.buf.len) return null;
			idx = it.index;
			it.index += getUTF8Size(it.buf[idx]);
			return it.buf[idx..it.index];
		}

	};

	/// iterator String
	pub fn iterator(str:[] const u8) StringIterator {
		// strbuf = std.fmt.allocPrint(allocUtl,"{s}", str) catch |err| {@panic(@errorName(err));};
        strbuf = str;
		return StringIterator{
			.buf = undefined,
			.index = 0,
		};
	}

	/// Returns the UTF-8 character's size
	fn getUTF8Size(char: u8) u3 {
		return std.unicode.utf8ByteSequenceLength(char) 
			catch |err| { @panic(@errorName(err));};
	}
};




/// number characters String
pub fn nbrCharStr(str: []const u8) usize {
    var wl : usize =0;
    var iter = iteratStr.iterator(str);
    defer iter.deinit();
    while (iter.next()) |_|    { wl += 1 ;}
    return wl;
}

/// remove espace to STRING left and rigth
pub fn trimStr(str: []const u8) []const u8 {
    const val = std.mem.trim(u8, str, " ");
    return val;
}

/// is String isAlphabetic Latin
pub fn isAlphabeticStr(str: []const u8) bool {
    const result = allocUtl.alloc(u8, str.len) catch |err| {
        @panic(@errorName(err));
    };
    defer allocUtl.free(result);

    std.mem.copy(u8, result, str);
    var idx: usize = 0;
    var b: bool = true;
    while (idx < result.len) : (idx += 1) {
        if (!std.ascii.isAlphabetic(result[idx])) b = false;
    }
    return b;
}

/// is String Upper Latin
pub fn isUpperStr(str: []const u8) bool {
    const result = allocUtl.alloc(u8, str.len) catch |err| {
        @panic(@errorName(err));
    };
    defer allocUtl.free(result);

    std.mem.copy(u8, result, str);
    var idx: usize = 0;
    var b: bool = true;
    while (idx < result.len) : (idx += 1) {
        if (!std.ascii.isUpper(result[idx])) b = false;
    }
    return b;
}

/// is String Lower Latin
pub fn isLowerStr(str: []const u8) bool {
    const result = allocUtl.alloc(u8, str.len) catch |err| {
        @panic(@errorName(err));
    };
    defer allocUtl.free(result);

    std.mem.copy(u8, result, str);
    var idx: usize = 0;
    var b: bool = true;
    while (idx < result.len) : (idx += 1) {
        if (!std.ascii.iLower(result[idx])) b = false;
    }
    return b;
}

/// is String isDigit
pub fn isDigitStr(str: []const u8) bool {
    var b: bool = true;
    const view = std.unicode.Utf8View.init(str) catch |err| {@panic(@errorName(err)); };
    var iter = view.iterator();

    while (iter.nextCodepoint()) |x| {
        switch (x) {
            '0'...'9' => continue,
            else => b = false,
        }
    }
    return b;
}



/// is String isDecimal
pub fn isDecimalStr(str: []const u8) bool {
    var idx: usize = 0;
    var p: bool = false; // dot
    var b: bool = true;
    const view = std.unicode.Utf8View.init(str) catch |err| {@panic(@errorName(err)); };
    var iter = view.iterator();
    while (iter.nextCodepoint()) |x| : (idx += 1) {
        switch (x) {
            '0'...'9' => continue,

            '.' => {
                if (p) b = false else {
                    p = true;
                    continue;
                } // control is . unique
            },

            '-' => {
                if (idx == 0) continue else b = false;
            },

            '+' => {
                if (idx == 0) continue else b = false;
            },

            else => b = false,
        }
    }
    return b;
}

/// is String isDigit
pub fn isSignedStr(str: []const u8) bool {
    var b: bool = true;
    const view = std.unicode.Utf8View.init(std.mem.trim(u8, str, " ")) catch |err| {@panic(@errorName(err)); };
    var iter = view.iterator();
    while (iter.nextCodepoint()) |x| {   
        switch (x) {
            '-' => b = true,

            '+' => b = true,

            else => b = false,
        }
        break;
    }
    return b;
}

/// is String isLetter
/// testing caracter Keyboard 103
pub fn isLetterStr(str: []const u8) bool {
    var b: bool = true;
    const view = std.unicode.Utf8View.init(str) catch |err| {@panic(@errorName(err)); };
    var iter = view.iterator();
    while (iter.nextCodepoint()) |x| {

        
        switch (x) {
            '0'...'9' => b = false,
            '&' => b = false,
            '¹' => b = false,
            '²' => b = false,
            '³' => b = false,
            '¼' => b = false,
            '½' => b = false,
            '¾' => b = false,
            '~' => b = false,
            '"' => b = false,
            '#' => b = false,
            '\'' => b = false,
            '{' => b = false,
            '(' => b = false,
            '[' => b = false,
            '-' => b = false,
            '|' => b = false,
            '`' => b = false,
            '_' => b = false,
            92 => b =false ,
            '^' => b = false,
            '@' => b = false,
            '°' => b = false,
            ')' => b = false,
            ']' => b = false,
            '+' => b = false,
            '=' => b = false,
            '}' => b = false,
            '€' => b = false,
            '$' => b = false,
            '£' => b = false,
            '¢' => b = false,
            '¥' => b = false,
            'þ' => b = false,
            '¨' => b = false,
            'ø' => b = false,
            '‘' => b = false,
            '´' => b = false,
            '%' => b = false,
            'µ' => b = false,
            '*' => b = false,
            '<' => b = false,
            '>' => b = false,
            '«' => b = false,
            '»' => b = false,
            '↕' => b = false,
            '↓' => b = false,
            '↑' => b = false,
            '←' => b = false,
            '→' => b = false,
            '↔' => b = false,
            '↙' => b = false,
            '↘' => b = false,
            '↖' => b = false,
            '↗' => b = false,
            '©' => b = false,
            '®' => b = false,
            '™' => b = false,
            '¬' => b = false,
            '¿' => b = false,
            '?' => b = false,
            ',' => b = false,
            '×' => b = false,
            '.' => b = false,
            ';' => b = false,
            '÷' => b = false,
            '/' => b = false,
            ':' => b = false,
            '¡' => b = false,
            '§' => b = false,
            '!' => b = false,
            320 => b = false,
            8217 => b = false,
            else => {},
        }
        if (b == false ) return b;
    }
    return b;
}

/// is String isSpecial
// testing caracter Keyboard 103
// force omit ; csv
pub fn isSpecialStr(str: []const u8) bool {
    var b: bool = true;
    const view = std.unicode.Utf8View.init(str) catch |err| {@panic(@errorName(err)); };
    var iter = view.iterator();
    while (iter.nextCodepoint()) |x| {
        switch (x) {
            '&' => continue,
            '¹' => continue,
            '²' => continue,
            '³' => continue,
            '¼' => continue,
            '½' => continue,
            '¾' => continue,
            '#' => continue,
            '{' => continue,
            '(' => continue,
            '[' => continue,
            '-' => continue,
            '|' => continue,
            '\'' => continue,
            '@' => continue,
            '°' => continue,
            ')' => continue,
            ']' => continue,
            '+' => continue,
            '=' => continue,
            '}' => continue,
            '€' => continue,
            '$' => continue,
            '£' => continue,
            '¢' => continue,
            '¥' => continue,
            '%' => continue,
            '*' => continue,
            '¿' => continue,
            '?' => continue,
            ',' => continue,
            '.' => continue,
            '÷' => continue,
            '/' => continue,
            ':' => continue,
            '¡' => continue,
            '§' => continue,
            '!' => continue,
            '_' => continue,

            else => b = false,
        }
    }
    return b;
}

// is String Punctuation
// force omit ' ; csv
pub fn isPunct(str: []const u8) bool {
    var b: bool = true;
    const view = std.unicode.Utf8View.init(str) catch |err| {@panic(@errorName(err)); };
    var iter = view.iterator();
    while (iter.nextCodepoint()) |x| {

        switch (x) {
            '.' => continue,
            ':' => continue,
            ',' => continue,
            '!' => continue,
            '-' => continue,
            '(' => continue,
            ')' => continue,
            '>' => continue,
            '<' => continue,
            '«' => continue,
            '»' => continue,
            '`' => continue,
            '/' => continue,
            '[' => continue,
            ']' => continue,
            else => b = false,
        }
    }
    return b;
}

// is String omit char
pub fn isCarOmit(str: []const u8) bool {
    var b: bool = true;
    const view = std.unicode.Utf8View.init(str) catch |err| {@panic(@errorName(err)); };
    var iter = view.iterator();
    while (iter.nextCodepoint()) |x| {
        switch (x) {
            ';' => continue,
            '~' => continue,
            '|' => continue,
            '_' => continue,
            '"' => continue,
            '\'' => continue,
            '\\' => continue,
            else => b = false,
        }
    }
    return b;
}

/// is String to PASSWORD
/// !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~
/// omit , ; / \ _ ` | ~
pub fn isPassword(str: []const u8) bool {
    var iter = iteratStr.iterator(str);
    defer iter.deinit();
    var b: bool = true;
    while (iter.next()) |ch| {
    const view = std.unicode.Utf8View.init(ch) catch |err| {@panic(@errorName(err)); };
    var iter2 = view.iterator();
        while (iter2.nextCodepoint()) |x| {
            switch (x) {
                '!' => continue,
                '#' => continue,
                '$' => continue,
                '%' => continue,
                '&' => continue,
                '(' => continue,
                ')' => continue,
                '*' => continue,
                '+' => continue,
                '-' => continue,
                '.' => continue,
                ':' => continue,
                '<' => continue,
                '=' => continue,
                '>' => continue,
                '?' => continue,
                '@' => continue,
                '[' => continue,
                ']' => continue,
                '^' => continue,
                '{' => continue,
                '}' => continue,

                else => {
                    if (isLetterStr(ch)) continue;
                    if (isDigitStr(ch)) continue;
                    b = false;
                },
            }
        }
    }    
    return b;
}

/// is String to Mail
/// a-zA-Z 0-9 +.-_@
pub fn isMailStr(str: []const u8) bool {
    var iter = iteratStr.iterator(str);
    defer iter.deinit();
    var b: bool = true;
    while (iter.next()) |ch| {
        const view = std.unicode.Utf8View.init(str) catch |err| {@panic(@errorName(err)); };
        var iter2 = view.iterator();
        while (iter2.nextCodepoint()) |x| {

            switch (x) {
                '+' => continue,
                '-' => continue,
                '_' => continue,
                '.' => continue,
                '@' => continue,
                '!' => continue,
                '#' => continue,
                '$' => continue,
                '%' => continue,
                '&' => continue,
                '*' => continue,
                '/' => continue,
                '=' => continue,
                '?' => continue,
                 39 => continue,
                '`' => continue,
                '{' => continue,
                '}' => continue,
                '|' => continue,
                '~' => continue,
                '^' => continue,
                else => {
                    if (isLetterStr(ch)) continue;
                    if (isDigitStr(ch)) continue;
                    if (x >= 191 and x <= 255) return false;
                    b = false;
                },
            }
        }
    }    
    return b;
}

/// upper-case String Latin
pub fn upperStr(str: []const u8) []const u8 {
    const work = allocUtl.alloc(u8, str.len) catch |err| {
        @panic(@errorName(err));
    };
    defer allocUtl.free(work);

    @memcpy(work, str);
    var string: []const u8 = "";
    
    var iter = iteratStr.iterator(work);
    defer iter.deinit();
    var i :usize = 0;
    var zone : [4]   u8 = undefined;
    var car :[]const u8 = undefined;
    var r : u21 = 0 ;
    while (iter.next()) |ch | {
        const view = std.unicode.Utf8View.init(str) catch |err| {@panic(@errorName(err)); };
        var iter2 = view.iterator();
        const x : u21 = iter2.nextCodepoint() orelse 0  ; 
        r = 0 ;
        if ( x >= 97 and x <= 122 )  r = x - 32;
        if ( x >= 224 and x <= 255 )  r = x - 32;
        if ( x == 339 )  r = x - 1;
        if ( x == 255 )  r = 376;
        if (r > 0 ) { 
                zone = [_]u8{0} ** 4;
                i = utf.utf8Encode(r,&zone) catch unreachable;
                car = "";
                car = zone[0..i];
                string = concatStr(string, car);
        }        
        else {string = concatStr(string, ch);
}    
    }
    return string;
}

/// Lower String Latin
pub fn lowerStr(str: []const u8) []const u8 {
    const result = allocUtl.alloc(u8, str.len) catch |err| {
        @panic(@errorName(err));
    };
    defer allocUtl.free(result);

    std.mem.copy(u8, result, str);
    var idx: usize = 0;
    while (idx < result.len) : (idx += 1) {
        result[idx] = std.ascii.toLower(result[idx]);
    }
    return std.fmt.allocPrint(
        allocUtl,
        "{s}",
        .{result},
    ) catch |err| {
        @panic(@errorName(err));
    };
}

/// concat String
pub fn concatStr(a: []const u8, b: []const u8) []const u8 {
    return std.fmt.allocPrint(
        allocUtl,
        "{s}{s}",
        .{ a, b },
    ) catch |err| {
        @panic(@errorName(err));
    };
}

/// comp string
/// LT EQ GT -> enum CMP
pub fn compStr(str1: []const u8, str2: []const u8) CMP {
    const order = std.mem.order(u8, str1, str2);
    switch (order) {
        .lt => return CMP.LT,
        .eq => return CMP.EQ,
        .gt => return CMP.GT,
    }
}

/// aligned string
pub fn alignStr(text: []const u8, aligns: ALIGNS, wlen: usize) []const u8 {
    var idx: usize = 0;
    var iter = iteratStr.iterator(text);

    var string: []const u8 = "";

    while (iter.next()) |ch| {
        idx += 1;
        if (idx > wlen) break;
        if (idx == 1) string = ch else {
            string = concatStr(string, ch);
        }
    }

    if (aligns == ALIGNS.left) {
        while (idx < wlen) : (idx += 1) {
            string = concatStr(string, " ");
        }
    }

    if (aligns == ALIGNS.rigth) {
        while (idx < wlen) : (idx += 1) {
            string = concatStr(" ", string);
        }
    }

    return string;
}



/// Delete Items ArrayList
pub fn removeListStr(self: *std.ArrayList([]const u8), i: usize) void {
    var LIST = std.ArrayList([]const u8).init(allocUtl);
    var idx: usize = 0;
    for (self.items) |val| {
        if (idx != i - 1) LIST.append(val) catch |err| {
            @panic(@errorName(err));
        };
        idx += 1;
    }
    self.clearAndFree();

    for (LIST.items) |val| {
        self.append(val) catch |err| {
            @panic(@errorName(err));
        };
    }
}

/// Add Text ArrayList
pub fn addListStr(self: *std.ArrayList([]const u8), text: []const u8) void {
    var iter = iteratStr.iterator(text);
    defer iter.deinit();
    while (iter.next()) |ch| {
        self.append(ch) catch |err| { @panic(@errorName(err)); };
     }
 }

/// ArrayList to String
pub fn listToStr(self: std.ArrayList([]const u8)) []const u8 {
    var result: []const u8 = "";
    var idx : usize = 0;
    for (self.items) |_| {
        result = concatStr(result,self.items[idx]);
        idx += 1;
    }
    return result;
}

///------- bool--------------
/// bool to str
pub fn boolToStr(v: bool) []const u8 {
    return if (v) "1" else "0";
}

/// str to bool
pub fn strToBool(v: []const u8) bool {
    return if (std.mem.eql(u8, v, "1")) true else false;
}

/// str to switch STRUE/SFALSE bool
pub fn strToCbool(v: []const u8) []const u8 {
    return if (std.mem.eql(u8, v, "1")) CTRUE else CFALSE;
}

/// bool to switch STRUE/SFALSE
pub fn boolToCbool(v: bool) []const u8 {
    return if (v == true) CTRUE else CFALSE;
}

/// switch STRUE/SFALSE bool to bool
pub fn cboolToBool(v: []const u8) bool {
    return if (std.mem.eql(u8, v, CTRUE)) true else false;
}

// switch STRUE / SFALSE bool to str
pub fn cboolToStr(v: []const u8) []const u8 {
    return if (std.mem.eql(u8, v, CTRUE)) "1" else "0";
}
