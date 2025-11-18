const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("henlo word!\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    // try @import("float_iee754.zig").floatTesticle(gpa.allocator());
    try @import("hackers-delight/hacker.zig").hackerTesticle(gpa.allocator());
    print("godbye word!\n", .{});
}
