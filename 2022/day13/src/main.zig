const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const LinearFifo = std.fifo.LinearFifo;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var part1: u64 = 0;
    var part2: u64 = 0;
    var nPair: u64 = 1;
    var l: ?std.json.ValueTree = null;
    var r: ?std.json.ValueTree = null;
    var lines = ArrayList(std.json.Value).init(allocator);
    var buffer: [1024]u8 = undefined;
    var parser = std.json.Parser.init(allocator, true);
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        if (line.len == 0) {
            l = null;
            r = null;
            continue;
        }
        var arr = try parser.parse(line);
        try lines.append(arr.root);
        parser.reset();
        if (l == null) {
            l = arr;
            continue;
        }
        r = arr;
        if (cmp(allocator, l.?.root, r.?.root) <= 0) {
            part1 += nPair;
        }
        nPair += 1;
    }
    parser.reset();
    try lines.append((try parser.parse("[[2]]")).root);
    parser.reset();
    try lines.append((try parser.parse("[[6]]")).root);
    std.sort.sort(std.json.Value, lines.items, allocator, cmpB);

    for (lines.items) |item, idx| {
        if (item != .Array) continue;
        if (item.Array.items.len != 1) continue;
        var elt = item.Array.items[0];
        if (elt != .Array) continue;
        if (elt.Array.items.len != 1) continue;
        elt = elt.Array.items[0];
        if (elt == .Integer) {
            if (elt.Integer == 6 or elt.Integer == 2) {
                if (part2 == 0) {
                    part2 = idx + 1;
                } else {
                    part2 *= idx + 1;
                }
            }
        }
    }

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}


fn cmpB(a: std.mem.Allocator, l: std.json.Value, r: std.json.Value) bool {
    return cmp(a, l, r) < 0 ;
}

fn cmp(a: std.mem.Allocator, lIn: std.json.Value, rIn: std.json.Value) i4 {
    var l = lIn;
    var r = rIn;
    if (l == .Integer and r == .Array) {
        var arr = ArrayList(std.json.Value).init(a);
        arr.items = &[1]std.json.Value{std.json.Value{.Integer = l.Integer}};
        l = std.json.Value{.Array = arr};
    } else if (l == .Array and r == .Integer) {
        var arr = ArrayList(std.json.Value).init(a);
        arr.items = &[1]std.json.Value{std.json.Value{.Integer = r.Integer}};
        r = std.json.Value{.Array = arr};
    }
    if (l == .Integer and r == .Integer) {
        if (l.Integer < r.Integer) {
            return -1;
        } else if (l.Integer > r.Integer) {
            return 1;
        } else return 0;
    } else if (l == .Array and r == .Array) {
        var i: usize = 0;
        while (i < l.Array.items.len) : (i += 1){
            if (i >= r.Array.items.len) return 1;
            var c = cmp(a, l.Array.items[i], r.Array.items[i]);
            if (c < 0) {
                return -1;
            } else if (c > 0) {
                return 1;
            }
        }
        if (l.Array.items.len == r.Array.items.len) return 0;
        return -1;
    }
    unreachable;
}