const std = @import("std");
const List = std.ArrayList;
const Calc = @This();

const Number = struct {
    const Sign = enum {
        positive,
        negetive,
    };
    sign: Sign,
    number: usize
};
