const std = @import("std");
const print = std.debug.print;

pub fn slicersTesticle(alloc: std.mem.Allocator) !void {
    var array = try Array.init(alloc);
    defer array.deinit();
    try array.push(1);
    try array.push(2);
    try array.push(3);
    try array.push(69);
    try array.push(420);
    printInt(array.get(1), "first");
    printInt(array.get(2), "second");
    printInt(array.get(-1), "head");
    printInt(array.get(-2), "before head");
    printInt(array.get(array.top()), "top");
    array.printout();

    var a = try array.toList(2, 5);
    defer a.deinit();
    a.printout("a");

    var b = try a.sublist(2, 4);
    defer b.deinit();
    b.printout("b");

    var c = try b.sublist(2, 2);
    defer c.deinit();
    c.printout("c");

    var d = try a.sublist(-1, 1);
    defer d.deinit();
    d.printout("d");
}

const View = struct {
    pub const empty: View = .{ .start = 0, .length = 0, .mode = .normal };

    pub const Mode = enum {
        normal,
        reversed,
    };

    start: usize,
    length: usize,
    mode: Mode,

    pub fn index(view: View, i: usize) ?usize {
        if (i >= view.length) return null;
        return switch (view.mode) {
            .normal => view.start + i,
            .reversed => view.start + view.length - 1 - i,
        };
    }

    pub fn iter(view: View) Iter {
        return .{ .i = 0, .view = view };
    }

    pub fn isEmpty(view: View) bool {
        return view.length == 0;
    }

    pub fn get(view: View, element_pointer: i32) ?usize {
        return if (epIndex(view.length, element_pointer)) |i| view.index(i) else null;
    }

    pub fn getEP(view: View, i: usize, mode: Mode) i32 {
        if (i < view.start) return 0;
        if (i >= (view.start + view.length)) return 0;
        const a: i32 = @intCast(i - view.start + 1);
        return switch (mode) {
            .normal => a,
            .reversed => epRelative(view.length, a),
        };
    }

    pub fn lazySubview(view: View, first: i32, head: i32) View {
        const a = view.morphIndexToValid(first) orelse return empty;
        const b = view.morphIndexToValid(head) orelse return empty;
        return if (a <= b) .{
            .start = a,
            .length = b - a + 1,
            .mode = .normal,
        } else .{
            .start = b,
            .length = a - b + 1,
            .mode = .reversed,
        };
    }

    pub fn trySubview(view: View, first: i32, head: i32) !View {
        const a = try getIndex(view, first, "first");
        const b = try getIndex(view, head, "head");
        return if (a <= b) .{
            .start = a,
            .length = b - a + 1,
            .mode = .normal,
        } else .{
            .start = b,
            .length = a - b + 1,
            .mode = .reversed,
        };
    }

    pub fn getIndex(view: View, element_pointer: i32, tag: []const u8) !usize {
        const i = epIndex(view.length, element_pointer) orelse return error.ElementPointerCannotBeZero;
        if (i >= view.length) {
            print("error: element pointer *{s}* out of range: {} => {}, length => {}\n", .{ tag, element_pointer, i, view.length });
            return error.ElementPointerOutOfRange;
        }
        return i + view.start;
    }

    pub fn morphIndexToValid(view: View, element_pointer: i32) ?usize {
        const i = epIndex(view.length, element_pointer) orelse return null;
        if (i >= view.length) {
            if (view.length == 0) return null;
            return view.start + view.length - 1;
        } else {
            return i + view.start;
        }
    }

    pub fn printout(view: View) void {
        print("*~VIEW-PRINT~* (length = {})\n", .{view.length});
        if (view.length == 0) {
            print("empty view!\n", .{});
        } else {
            switch (view.mode) {
                .normal => {
                    print("first => {}\nhead => {}\norient => {}\n", .{ view.start, view.start + view.length - 1, view.mode });
                },
                .reversed => {
                    print("first => {}\nhead => {}\norient => {}\n", .{ view.start + view.length - 1, view.start, view.mode });
                },
            }
        }
    }

    pub const Iter = struct {
        i: usize,
        view: View,

        pub fn next(self: *Iter) ?usize {
            if (self.view.index(self.i)) |result| {
                self.i += 1;
                return result;
            } else {
                return null;
            }
        }
    };
};

fn printInt(int: ?i32, tag: []const u8) void {
    if (int) |num| print("{s} => {}\n", .{ tag, num }) else print("{s} => null\n", .{tag});
}

fn epAbsolute(length: usize, element_pointer: i32) i32 {
    return if (element_pointer >= 0) element_pointer else @as(i32, @intCast(length)) - ((-element_pointer) - 1);
}

fn epRelative(length: usize, element_pointer: i32) i32 {
    return if (element_pointer <= 0) element_pointer else -(@as(i32, @intCast(length)) - (element_pointer - 1));
}

fn epIndex(length: usize, element_pointer: i32) ?usize {
    return if (element_pointer == 0) null else @as(usize, @intCast(epAbsolute(length, element_pointer))) - 1;
}

const Array = struct {
    const Self = @This();

    e: []i32,
    count: usize,
    alloc: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator) !*Array {
        const result = try alloc.create(Array);
        result.* = .{
            .e = &[_]i32{},
            .count = 0,
            .alloc = alloc,
        };
        return result;
    }

    pub fn push(self: *Self, value: i32) !void {
        if (self.count >= self.e.len) {
            const new_capacity = if (self.e.len == 0) 8 else self.e.len * 2;
            self.e = try self.alloc.realloc(self.e, new_capacity);
        }
        self.e[self.count] = value;
        self.count += 1;
    }

    pub fn slice(self: *Self) []i32 {
        return self.e[0..self.count];
    }

    pub fn printout(self: *Self) void {
        const s = self.slice();
        print("*~ARRAY-PRINT~* (length = {}) (ptr = 0x{X})\n", .{ s.len, @intFromPtr(self) });
        for (s, 0..) |item, i| {
            print("[{}] ({} {}) => {}\n", .{ i, self.toView().getEP(i, .reversed), self.toView().getEP(i, .normal), item });
        }
    }

    pub fn getWithView(self: *Self, element_pointer: i32, view: View) ?i32 {
        return if (view.get(element_pointer)) |i| self.el(i) else null;
    }

    pub fn get(self: *Self, element_pointer: i32) ?i32 {
        return self.getWithView(element_pointer, self.toView());
    }

    pub fn el(self: *Self, index: usize) ?i32 {
        return if (index < self.count) self.e[index] else null;
    }

    pub fn toView(self: *Self) View {
        return .{
            .start = 0,
            .length = self.count,
            .mode = .normal,
        };
    }

    pub fn toList(self: *Self, first: i32, head: i32) !*List {
        return try List.new(self.alloc, self, try self.toView().trySubview(first, head));
    }

    pub fn top(self: *Self) i32 {
        return @intCast(self.count);
    }

    pub fn iter(self: *Self) Iter {
        return .{
            .iter = self.toView().iter(),
            .array = self,
        };
    }

    pub fn deinit(self: *Self) void {
        self.alloc.free(self.e);
        self.alloc.destroy(self);
    }

    pub const Iter = struct {
        iter: View.Iter,
        array: *Self,

        pub fn next(self: *Iter) ?i32 {
            return if (self.iter.next()) |i| self.array.el(i) else null;
        }
    };
};

const List = struct {
    const Self = @This();
    const Mutability = enum {
        mut,
        imut,
    };

    alloc: std.mem.Allocator,
    array: *Array,
    view: View,

    pub fn new(alloc: std.mem.Allocator, array: *Array, view: View) !*Self {
        const result = try alloc.create(List);

        result.* = .{
            .alloc = alloc,
            .array = array,
            .view = view,
        };

        return result;
    }

    pub fn deinit(self: *Self) void {
        self.alloc.destroy(self);
    }

    pub fn sublist(self: *Self, first: i32, head: i32) !*Self {
        return try List.new(self.alloc, self.array, try self.view.trySubview(first, head));
    }

    pub fn printout(self: *Self, tag: []const u8) void {
        print("*~LIST-PRINT~* (tag = {s}) (length = {}) (order = {s}) (array = 0x{X})\n", .{ tag, self.view.length, switch (self.view.mode) {
            .normal => "normal",
            .reversed => "reversed",
        }, @intFromPtr(self.array) });
        var iter = self.view.iter();
        while (iter.next()) |i| {
            print("[{}] ({} {}) => {?}\n", .{ i, self.view.getEP(i, .reversed), self.view.getEP(i, .normal), self.array.el(i) });
        }
    }
};
