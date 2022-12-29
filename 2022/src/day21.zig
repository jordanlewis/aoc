const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const op = enum {
    plus,
    minus,
    mult,
    div,
};

const monkey = struct {
    val: ?i64,
    op: op,
    l: []const u8,
    r: []const u8,

    pub fn format(
        self: monkey,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("{any} | {any} {any} {s}", .{ self.val, self.l, self.op, self.r });
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var part1: i64 = 0;
    var part2: i64 = 0;
    var nLine: u64 = 0;
    var map = std.StringHashMap(*monkey).init(allocator);
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var iter = tokenize(u8, line, ": ");
        var m = iter.next().?;
        var mCopy = try std.fmt.allocPrint(allocator, "{s}", .{m});
        var monk: *monkey = try allocator.create(monkey);
        monk.* = std.mem.zeroes(monkey);
        var arg = iter.next().?;
        if (parseInt(i64, arg, 10)) |n| {
            monk.val = n;
        } else |_| {
            monk.l = try std.fmt.allocPrint(allocator, "{s}", .{arg});
            monk.op = switch (iter.next().?[0]) {
                '+' => .plus,
                '-' => .minus,
                '*' => .mult,
                '/' => .div,
                else => unreachable,
            };
            monk.r = try std.fmt.allocPrint(allocator, "{s}", .{iter.next().?});
        }
        try map.put(mCopy, monk);
    }

    part1 = findSum(map, "root", false).?;

    // part 2:
    var root = map.get("root").?;
    var l = findSum(map, root.l, true);
    if (l) |val| {
        part2 = recurse2(map, root.r, val).?;
    } else {
        part2 = recurse2(map, root.l, findSum(map, root.r, true).?).?;
    }

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}

fn findSum(map: std.StringHashMap(*monkey), name: []const u8, ignoreHuman: bool) ?i64 {
    if (ignoreHuman and std.mem.eql(u8, name, "humn")) {
        return null;
    }
    var m = map.get(name).?;
    if (m.val) |n| {
        return n;
    }
    var l = findSum(map, m.l, ignoreHuman);
    var r = findSum(map, m.r, ignoreHuman);
    if (l == null or r == null) {
        return null;
    }
    return switch (m.op) {
        .plus => l.? + r.?,
        .minus => l.? - r.?,
        .mult => l.? * r.?,
        .div => @divExact(l.?, r.?),
    };
}

//     11
// x   -   y     => x-10 = 11
// hmn     10

//     11
// x   -   y     => 10-x = 11
// 10      hmn

// x   -   y
// 10     humn
//
// I know left is null, and I know the sum of right, so I need to invert the operation to get the
// value that human should return.

fn recurse2(map: std.StringHashMap(*monkey), name: []const u8, exp: i64) ?i64 {
    if (std.mem.eql(u8, name, "humn")) {
        return exp;
    }
    var m = map.get(name).?;
    var l = findSum(map, m.l, true);
    var val: i64 = undefined;
    var constIsLeft = l != null;
    if (l) |v| {
        val = v;
    } else {
        val = findSum(map, m.r, true).?;
    }
    var newExp: i64 = undefined;
    // Invert val
    switch (m.op) {
        .plus => newExp = exp - val,
        .minus => {
            if (constIsLeft) {
                newExp = val - exp;
            } else {
                newExp = exp + val;
            }
        },
        .mult => newExp = @divExact(exp, val),
        .div => {
            if (constIsLeft) {
                newExp = @divExact(val, exp);
            } else {
                newExp = exp * val;
            }
        },
    }
    if (constIsLeft) {
        return recurse2(map, m.r, newExp);
    }
    return recurse2(map, m.l, newExp);
}
