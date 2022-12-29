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
        print("{s}: {any}\n", .{ mCopy, monk });
        try map.put(mCopy, monk);
    }

    part1 = recurse(map, "root");

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}

fn recurse(map: std.StringHashMap(*monkey), name: []const u8) i64 {
    var m = map.get(name).?;
    if (m.val) |n| {
        return n;
    }
    var l = recurse(map, m.l);
    var r = recurse(map, m.r);
    m.val = switch (m.op) {
        .plus => l + r,
        .minus => l - r,
        .mult => l * r,
        .div => @divExact(l, r),
    };
    return m.val.?;
}
