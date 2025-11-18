const std = @import("std");
const print = std.debug.print;
const debug = @import("../debug.zig");
const assert = std.debug.assert;

pub fn hackerTesticle(alloc: std.mem.Allocator) !void {
    _ = alloc;
    print("\n*~HACKER-TESTICLE~*\n\n", .{});
    try turnOffRightMostBit();
    try turnOnRightMostBit();
    try turnOffTrailingBits();
    try turnOnTrailingBits();
    try createAWordOfSingle1BitAtRightMost0Bit();
    try createAWordOfSingle0BitAtRightMost1Bit();
    try createAWordWithOnesInTrailingZeros();
    try createAWordWithZerosInTrailingOnes();
    try isolateRightMost1Bit();
    try createAWordWithOnesAfterTrailingOne();
    try createAWordWithOnesAfterTrailingZero();
    try turnOffRightMostContiguousOnes();
}

const opt: debug.Opt = .{
    .format = .binary,
    .byte_length = 1,
    .print_string = false,
};

fn turnOffRightMostBit() !void {
    print("turn *OFF* right most bit: 1 => 0\n", .{});
    const a: u8 = 0b01011000;
    const b = a & (a - 1);
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn turnOnRightMostBit() !void {
    print("turn *ON* right most bit: 0 => 1\n", .{});
    const a: u8 = 0b10100111;
    const b = a | (a + 1);
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn turnOffTrailingBits() !void {
    print("turn *OFF* trailing on bits: 0111 => 0000\n", .{});
    const a: u8 = 0b10100111;
    const b = a & (a + 1);
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn turnOnTrailingBits() !void {
    print("turn *ON* trailing off bits: 1000 => 1111\n", .{});
    const a: u8 = 0b11001000;
    const b = a | (a - 1);
    // (bit-or a (- a 1))
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn createAWordOfSingle1BitAtRightMost0Bit() !void {
    print("create a word of a single 1 bit at the rightmost 0 bit: 1010_0111 => 0000_1000\n", .{});
    print(" => also creates a word of all 0s if none\n", .{});
    const a: u8 = 0b1010_0111;
    const b = (~a) & (a + 1);
    // (bit-and (bit-not a) (+ a 1))
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn createAWordOfSingle0BitAtRightMost1Bit() !void {
    print("create a word of a single 0 bit at the rightmost 1 bit: 1010_1000 => 1111_0111\n", .{});
    print(" => also creates a word of all 1s if none\n", .{});
    const a: u8 = 0b1010_1000;
    const b = (~a) | (a - 1);
    // (bit-or (bit-not a) (- a 1))
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn createAWordWithOnesInTrailingZeros() !void {
    print("create a word of trailing 1 bits from the trailing 0 bits: 0101_1000 => 0000_0111\n", .{});
    const a: i8 = 0b0101_1000;
    const b = (~a) & (a - 1);
    assert(b == 0b0000_0111);

    // optional versions that produce the same result:
    const c = ~(a | (-a));
    const d = (a & (-a)) - 1;
    assert((b == c) and (b == d));
    
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn createAWordWithZerosInTrailingOnes() !void {
    print("create a word of trailing 0 bits from the trailing 1 bits: 1010_0111 => 1111_1000\n", .{});
    const a: u8 = 0b1010_0111;
    const b = (~a) | (a + 1);
    assert(b == 0b1111_1000);
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn isolateRightMost1Bit() !void {
    print("isolates the rightmost 1 bit producing 0 if not: 1010_1000 => 0000_1000\n", .{});
    const a: i8 = @bitCast(@as(u8, 0b1010_1000));
    const b = a & (-a);
    // (bit-and a (toggle-first-bit a))
    assert(b == 0b0000_1000);
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn createAWordWithOnesAfterTrailingOne() !void {
    print("creates a word with trailing ones after (and including) the rightmost 1 bit: 0101_1000 => 0000_1111\n", .{});
    print(" => produces all ones if no 1 bit, and produces the number 1 if all 1s\n", .{});
    const a: u8 = 0b0101_1000;
    const b = a ^ (a - 1);
    // (bit-xor a (- a 1))
    assert(b == 0b0000_1111);
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("--------\n", .{});
    const c: u8 = 0;
    const d = c ^ (c -% 1); // zig wrapping -
    assert(d == 0b1111_1111);
    try debug.dumpHex(c, opt);
    try debug.dumpHex(d, opt);
    print("--------\n", .{});
    const e: u8 = 0b1111_1111;
    const f = e ^ (e - 1);
    assert(f == 1);
    try debug.dumpHex(e, opt);
    try debug.dumpHex(f, opt);
    print("\n", .{});
}

fn createAWordWithOnesAfterTrailingZero() !void {
    print("creates a word with trailing ones after (and including) the rightmost 0 bit: 0101_0111 => 0000_1111\n", .{});
    const a: u8 = 0b0101_0111;
    const b = a ^ (a + 1);
    assert(b == 0b0000_1111);
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    print("\n", .{});
}

fn turnOffRightMostContiguousOnes() !void {
    print("turn of right most contiguous ones: 0101_1100 => 0100_0000\n", .{});
    const a: i8 = 0b0101_1100;
    const b = ((a | (a - 1)) + 1) & a;
    assert(b == 0b0100_0000);
    try debug.dumpHex(a, opt);
    try debug.dumpHex(b, opt);
    // alternative method:
    const c = ((a & (-a)) + a) & a;
    assert(b == c);
    print("\n", .{});
}
