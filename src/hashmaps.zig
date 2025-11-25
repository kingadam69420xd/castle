const std = @import("std");
const print = std.debug.print;
const debug = @import("debug.zig");

fn djb2hash(string: []const u8) usize {
    var result: usize = 5381;
    for (string) |c| {
        result = ((result << 5) + result) + c;
    }
    return result;
}

pub fn hashmapsTesticle(alloc: std.mem.Allocator) !void {
    _ = alloc;
    const hash = djb2hash("foo bar baz");
    print("hash: {}\n", .{hash});
}

// pub const ChainedTable = struct {
//     const Self = @This();
//     const Node = struct {
//         key: []const u8,
//         value: i32,
//         next: ?*Node,
//     };

//     alloc: std.mem.Allocator,
//     nodes: []?*Node,
//     count: usize,

//     pub fn init(alloc: std.mem.Allocator) !ChainedTable {
//         return .{
//             .alloc = alloc,
//             .nodes = alloc.alloc(?*Node, 8),
//             .count = 0,
//         };
//     }

//     pub fn insert(self: *Self, key: []const u8, value: i32) !void {
//         const hash = djb2hash(key);
//         const index = hash % self.nodes.len;
//     }

//     pub fn remove(self: *Self, key: []const u8) ?i32 {
        
//     }

//     pub fn get(self: *Self, key: []const u8) ?i32 {
        
//     }

//     pub fn deinit(self: *Self) void {
        
//     }
// };
