const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;

const Format = enum {
    hex,
    binary,
};

const Indianness = enum {
    big,
    little,
};

pub const Opt = struct {
    byte_length: usize = 8,
    format: Format = .hex,
    print_string: bool = true,
    indianness: Indianness = .big,
};

pub fn dumpHex(src: anytype, opt: Opt) !void {
    const copy = src;
    try dumpHexBytes(std.mem.asBytes(&copy), opt);
}

pub fn dumpHexBytes(src: []const u8, opt: Opt) !void {
    if (opt.byte_length == 0) return error.ZeroByteLength;
    // if ((opt.byte_length % 2) != 0) return error.OddByteLength;

    var remaining = src;
    var counter: usize = 0;

    print("*~HEX-DUMP~* ({} bytes)\n", .{src.len});
    loop: while (true) {
        print("{} => ", .{counter});

        const length = if (remaining.len < opt.byte_length) remaining.len else opt.byte_length;
        const diff = if (remaining.len < opt.byte_length) opt.byte_length - remaining.len else 0;

        for (0..opt.byte_length) |i| {
            const index = switch (opt.indianness) {
                .big => i,
                .little => opt.byte_length - i - 1,
            };
            if (index < remaining.len) {
                const byte = remaining[index];
                switch (opt.format) {
                    .hex => {
                        const hex = hexLookup(byte);
                        print("{c}{c} ", .{ hex[0], hex[1] });
                    },
                    .binary => {
                        const binary = binaryLookup(byte);
                        print("{c}{c}{c}{c}_{c}{c}{c}{c} ", .{ binary[0], binary[1], binary[2], binary[3], binary[4], binary[5], binary[6], binary[7] });
                    },
                }
            } else {
                switch (opt.format) {
                    .hex => {
                        print("FF ", .{});
                    },
                    .binary => {
                        print("0000_0000 ", .{});
                    },
                }
            }
        }

        if (opt.print_string) {
            print("=> {s}", .{remaining[0..length]});
            for (0..diff) |_| {
                print("\x00", .{});
            }
        }
        print("\n", .{});

        if (diff > 0) break :loop;
        remaining = remaining[opt.byte_length..];
        if (remaining.len == 0) break :loop;
        counter += 1;
    }
}

fn u8ToHexChar(n: u8) u8 {
    return if (n < 10) n + '0' else n - 10 + 'A';
}

fn hexLookup(byte: u8) [2]u8 {
    return .{ u8ToHexChar(byte >> 4), u8ToHexChar(byte & 0x0F) };
}

fn binaryLookup(byte: u8) [8]u8 {
    return .{
        if ((byte & 0b1000_0000) != 0) '1' else '0',
        if ((byte & 0b0100_0000) != 0) '1' else '0',
        if ((byte & 0b0010_0000) != 0) '1' else '0',
        if ((byte & 0b0001_0000) != 0) '1' else '0',
        if ((byte & 0b0000_1000) != 0) '1' else '0',
        if ((byte & 0b0000_0100) != 0) '1' else '0',
        if ((byte & 0b0000_0010) != 0) '1' else '0',
        if ((byte & 0b0000_0001) != 0) '1' else '0',
    };
}

pub fn binaryLookupBool(byte: u8) [8]bool {
    return .{
        if ((byte & 0b1000_0000) != 0) true else false,
        if ((byte & 0b0100_0000) != 0) true else false,
        if ((byte & 0b0010_0000) != 0) true else false,
        if ((byte & 0b0001_0000) != 0) true else false,
        if ((byte & 0b0000_1000) != 0) true else false,
        if ((byte & 0b0000_0100) != 0) true else false,
        if ((byte & 0b0000_0010) != 0) true else false,
        if ((byte & 0b0000_0001) != 0) true else false,
    };
}

pub fn toBinary(src: anytype, alloc: std.mem.Allocator) !List(bool) {
    const copy = src;
    const bytes = std.mem.asBytes(&copy);
    var list = List(bool).empty;
    for (bytes) |byte| {
        try list.appendSlice(alloc, binaryLookupBool(byte));
    }
    return list;
}
