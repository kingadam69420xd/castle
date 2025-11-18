const std = @import("std");
const print = std.debug.print;
const debug = @import("debug.zig");

fn utf8ByteLength(src: []const u8) !usize {
    if (src.len == 0) return error.InputStringIsZeroLength;
    if ((src[0] & 0b1000_0000) == 0) return 1;
    const length: usize = blk: {
        if ((src[0] & 0b1110_0000) == 0b1100_0000) {
            break :blk 2;
        } else if ((src[0] & 0b1111_0000) == 0b1110_0000) {
            break :blk 3;
        } else if ((src[0] & 0b1111_1000) == 0b1111_0000) {
            break :blk 4;
        } else {
            return error.FirstByteIsNotValidUTF8Header;
        }
    };
    if (length > src.len) return error.LengthOfUTF8HeaderGreaterThanLengthOfString;
    for (src[0..length]) |c| {
        if ((c & 0b1000_0000) == 0) return error.MalformedUTF8Codepoint;
    }
    return length;
}

fn utf8IsValid(src: []const u8) bool {
    var slice: []const u8 = src[0..];
    while (slice.len > 0) {
        const length = utf8ByteLength(slice) catch return false;
        slice = slice[length..];
    }
    return true;
}

const replacement_code = "�";

fn utf8CloneToValid(alloc: std.mem.Allocator, src: []const u8) !std.ArrayList(u8) {
    var list = std.ArrayList(u8).empty;
    var slice: []const u8 = src[0..];
    while (slice.len > 0) {
        const length = utf8ByteLength(slice) catch {
            try list.appendSlice(alloc, replacement_code);
            slice = slice[1..];
            continue;
        };
        try list.appendSlice(alloc, slice[0..length]);
        slice = slice[length..];
    }
    return list;
}

fn utf8Testicle(alloc: std.mem.Allocator) !void {
    _ = alloc;
    print("utf8 test => begin\n", .{});
    print("utf8 print => \u{03BB}\n", .{});
    const a = "ajdoiawdibafwa1++21___";
    const b = "\u{03BB}";
    const c = "Az0!ñéαΩ中𐍈";

    const valid = utf8IsValid(c);
    print("{s} => {}\n", .{ c, valid });
    var slicer: []const u8 = c[0..];
    while (slicer.len > 0) {
        const length = try utf8ByteLength(slicer);
        print("{s} => {}\n", .{ slicer[0..length], length });
        slicer = slicer[length..];
    }

    try debug.dumpHex(a, .{});
    try debug.dumpHex(b, .{ .format = .binary });
    try debug.dumpHex(c, .{ .format = .binary });

    print("utf8 test => end\n", .{});
}
