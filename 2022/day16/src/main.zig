const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const key = struct {
    id1: [2]u8,
    id2: [2]u8,
    m: u64,
    b: std.bit_set.IntegerBitSet(64),
    pub fn format(
        self: key,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("{s}{s}: {d},{b}", .{self.id1, self.id2, self.m, self.b.mask});
    }
};

const room = struct {
    idx: u64,
    exits: ArrayList([]const u8),
    rate: u64,
    memo: std.AutoHashMap(key, u64),
    // Include other metadata later when we're doing our algorithm.
    pub fn format(
        self: room,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("{d} -> ", .{self.rate});
        for (self.exits.items) |exit| {
            try writer.print("{s} ", .{exit});
        }
    }
};

var max: u64 = 0;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const ptr = try allocator.create(i32);
    print("ptr={*}\n", .{ptr});

    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    var valves = std.StringHashMap(*room).init(allocator);
    defer valves.deinit();
    var b = std.bit_set.IntegerBitSet(64).initFull();
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var iter = tokenize(u8, line, " ;,");
        _ = iter.next();
        var valveName = iter.next().?;
        _ = iter.next();
        _ = iter.next();
        var rateWord = iter.next().?;
        //print("{s} {s}\n", .{rateWord, rateWord[5..rateWord.len]});
        var rate = try parseInt(u64, rateWord[5..rateWord.len], 10);
        _ = iter.next();
        _ = iter.next();
        _ = iter.next();
        _ = iter.next();
        var r = try allocator.create(room);
        r.* = room{
            .idx = nLine,
            .rate = rate,
            .exits = ArrayList([]const u8).init(allocator),
            .memo = std.AutoHashMap(key, u64).init(allocator),
        };
        if (rate > 0) {
            b.unset(nLine);
        }
        while (iter.next()) |word| {
            var wCopy = try allocator.alloc(u8, word.len);
            std.mem.copy(u8, wCopy, word);
            try r.exits.append(wCopy);
        }
        var wCopy = try allocator.alloc(u8, valveName.len);
        std.mem.copy(u8, wCopy, valveName);
        try valves.put(wCopy, r);
    }
    var iter = valves.keyIterator();
    while (iter.next()) |k| {
        var r = valves.get(k.*).?;
        print("{s}: {any}\n", .{k.*, r});
    }
    
    //part1 = try recurse(valves, "AA", 1, b);
    print("part 1: {d}\n", .{part1});

    var memo = std.AutoHashMap(key, u64).init(allocator);
    defer memo.deinit();

    var path = ArrayList([]const u8).init(allocator);
    defer path.deinit();
    part2 = try recurse2(&path, &memo, valves, "AA", "AA", 1, b);

    print("part 2: {d}\n", .{part2});
}

// elephant position
// human position
// valve state

// returns the most pressure that could be released starting at input m and id.
fn recurse2(path: *ArrayList([]const u8), memo: *std.AutoHashMap(key, u64), valves: std.StringHashMap(*room), id1: []const u8, id2: []const u8, m: u64, b: std.bit_set.IntegerBitSet(64)) !u64 {
    if (m > 26 or b.mask == 1 << 64) {
        // We have no more minutes, compare total and backtrack.
        //if (curTotal > max) {
        //    max = curTotal;
        //}
        return 0;
    }

    var me: []const u8 = undefined;
    var el: []const u8 = undefined;

    //print("entering {d} {s}\n", .{m, id});
    // Total flow is r.rate * 30 - m;
    var r = valves.get(id1).?;
    var r2 = valves.get(id2).?;
    var k = key{.m = m, .b = b, .id1 = undefined, .id2 = undefined};
    if (std.mem.lessThan(u8, id2, id1)) {
        std.mem.copy(u8, &k.id1, id2);
        std.mem.copy(u8, &k.id2, id1);
    } else {
        std.mem.copy(u8, &k.id1, id1);
        std.mem.copy(u8, &k.id2, id2);
    }
    if (memo.get(k)) |foundMax| {
        //if (curTotal + foundMax > max) {
        //    max = foundMax;
        //}
        return foundMax;
    }

    var curMax:u64 = 0;
    if (r.rate != 0) {
        var oldRate = r.rate;
        r.rate = 0;
        var totalFlow = (oldRate * (26 - m));
        var newB = b;
        newB.set(r.idx);
        //print("{s}: gives {d}\n", .{id, totalFlow});

        if (!std.mem.eql(u8, id1, id2)) {
            // Have the elephant open its valve!!!
            var elephantRate = r2.rate;
            r2.rate = 0;
            var elephantFlow = (elephantRate * (26 - m));
            newB.set(r2.idx);
            var found = try recurse2(path, memo, valves, id1, id2, m+1, newB) + totalFlow + elephantFlow;
            if (found > curMax) {
                me = "@@";
                el = "@@";
                curMax = found;
            }
            newB.unset(r2.idx);
            r2.rate = elephantRate;
        }

        // Move the elephant!!!!
        for (r2.exits.items) |*item| {
            var found = try recurse2(path, memo, valves, id1, item.*, m+1, newB) + totalFlow;
            if (found > curMax) {
                me = "@@";
                el = item.*;
                curMax = found;
            }
        }
        r.rate = oldRate;
    }
    for (r.exits.items) |*item| {
        // Try having the elephant open the valve.
        var oldRate = r2.rate;
        r2.rate = 0;
        var totalFlow = (oldRate * (26 - m));
        var newB = b;
        newB.set(r2.idx);
        var found = try recurse2(path, memo, valves, item.*, id2, m+1, newB) + totalFlow;
        if (found > curMax) {
            curMax = found;
            me = item.*;
            el = id2;
        }
        r2.rate = oldRate;
        //print("{s}: gives {d}\n", .{id, totalFlow});
        // Try moving the elephant.
        for (r2.exits.items) |*elephantItem| {
            found = try recurse2(path, memo, valves, item.*, elephantItem.*, m+1, b);
            if (found > curMax) {
                curMax = found;
                me = item.*;
                el = elephantItem.*;
            }
        }
    }
    //print("memoized {any} = {d}\n", .{k, curMax});
    try memo.put(k, curMax);
    var component = try memo.allocator.alloc(u8, 4);
    std.mem.copy(u8, component[0..2], me[0..2]);
    std.mem.copy(u8, component[2..], el[0..2]);
    try path.append(component);
    return curMax;
}


// returns the most pressure that could be released starting at input m and id.
fn recurse(valves: std.StringHashMap(*room), id: []const u8, m: u64, b: std.bit_set.IntegerBitSet(64)) !u64 {
    if (m > 30 or b.mask == 1 << 64) {
        // We have no more minutes, compare total and backtrack.
        //if (curTotal > max) {
        //    max = curTotal;
        //}
        return 0;
    }
    //print("entering {d} {s}\n", .{m, id});
    // Total flow is r.rate * 30 - m;
    var r = valves.get(id).?;
    var k = key{.id1= undefined, .id2= undefined, .m = m, .b = b};
    if (r.memo.get(k)) |foundMax| {
        //if (curTotal + foundMax > max) {
        //    max = foundMax;
        //}
        return foundMax;
    }
    var curMax:u64 = 0;
    if (r.rate != 0) {
        // Explore opening valve.
        //var newTotal = curTotal + (r.rate * (30 - m));
        var oldRate = r.rate;
        r.rate = 0;
        var totalFlow = (oldRate * (30 - m));
        var newB = b;
        newB.set(r.idx);
        //print("{s}: gives {d}\n", .{id, totalFlow});
        var found = try recurse(valves, id, m+1, newB) + totalFlow;
        if (found > curMax) {
            curMax = found;
        }
        r.rate = oldRate;
    }
    for (r.exits.items) |item| {
        var found = try recurse(valves, item, m+1, b);
        if (found > curMax) {
            curMax = found;
        }
    }
    //print("memoized {s}@{any} = {d}\n", .{id, k, curMax});
    try r.memo.put(k, curMax);
    return curMax;
}