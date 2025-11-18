const std = @import("std");
const print = std.debug.print;
const debug = @import("debug.zig");

pub fn floatTesticle(alloc: std.mem.Allocator) !void {
    _ = alloc;
    for (0..10) |i| {
        const flop: f32 = @floatFromInt(i);
        print("{} => floater: {}\n", .{i, flop});
        try debug.dumpHex(flop, .{.format = .binary, .print_string = false, .byte_length = 4, .indianness = .little});
    }
}
