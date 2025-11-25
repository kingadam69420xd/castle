const std = @import("std");
const print = std.debug.print;
const debug = @import("debug.zig");
const List = std.ArrayList;

const opt: debug.Opt = .{ .format = .binary, .print_string = false, .byte_length = 4, .indianness = .little };

pub fn floatTesticle(alloc: std.mem.Allocator) !void {
    _ = alloc;
    // try debug.dumpHex(@as(f32, 1.0), opt);
    // try debug.dumpHex(@as(f32, -1.0), opt);
    // const pos_inf: f32 = @bitCast(@as(u32, 0x7F80_0000));
    // const neg_inf: f32 = @bitCast(@as(u32, 0xFF80_0000));
    // try debug.dumpHex(pos_inf, opt);
    // try debug.dumpHex(neg_inf, opt);
    // print("pos inf: {}\n", .{pos_inf});
    // print("neg inf: {}\n", .{neg_inf});
    //                                 seee_eeee_efff_ffff_ffff_ffff_ffff_ffff
    const a: f32 = @bitCast(@as(u32, 0b0100_0000_1011_0100_0000_0000_0000_0000));
    try debug.dumpHex(a, opt);
    print("floater: {}\n", .{a});
}

pub fn bytesToBits(bytes: []const u8, alloc: std.mem.Allocator) !List(bool) {
    var list = List(bool).empty;
    for (bytes) |byte| {
        try list.appendSlice(alloc, debug.binaryLookupBool(byte));
    }
    return list;
}

