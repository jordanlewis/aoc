const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var nLine: usize = 0;
    var ns1 = ArrayList(i64).init(allocator);
    var ns2 = ArrayList(i64).init(allocator);
    // ords tells you the original position of the number currently at the input position.
    var ords = ArrayList(usize).init(allocator);
    // OrigPosToPos tells you the current position of the number originally at the input position.
    var origPosToPos = ArrayList(usize).init(allocator);
    defer ns1.deinit();
    defer ns2.deinit();
    defer ords.deinit();
    defer origPosToPos.deinit();
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var elt = try parseInt(i64, line, 10);
        try ns1.append(elt);
        try ns2.append(elt);
    }
    try ords.resize(ns1.items.len);
    try origPosToPos.resize(ns1.items.len);

    // Ords should be a map from i (the ordinal of the number we have to move next, in the original list)
    // to the ordinal of the number that we have to move in the new list.
    //
    // in order to update ords, I need to know the *original position* of the number at the *current position*.
    //
    // So I need 2 maps for sure!

    const key = 811589153;

    for ([_]i64{ 1, key }) |k, part| {
        var maxRounds: usize = 1;
        var ns = ns1;
        if (part == 1) {
            maxRounds = 10;
            ns = ns2;
        }
        for (ns.items) |n, i| {
            ords.items[i] = i;
            origPosToPos.items[i] = i;
            ns.items[i] = n * k;
        }
        var nRounds: usize = 0;
        while (nRounds < maxRounds) : (nRounds += 1) {
            //print("list {any} ords {any} origPosToPos {any}\n", .{ ns.items, ords.items, origPosToPos.items });
            for (origPosToPos.items) |ord| {
                //print("list {any} ords {any} origPosToPos {any}\n", .{ ns.items, ords.items, origPosToPos.items });
                var len = @intCast(i64, ns.items.len);
                var n = ns.items[ord];

                var newOrdI = @intCast(i64, ord) + @mod(n, len - 1);
                var wrappedDown = newOrdI < 0;
                var wrappedUp = newOrdI >= len;
                newOrdI = @mod(newOrdI, len);
                if (wrappedUp and newOrdI <= @intCast(i64, ord)) {
                    newOrdI = @mod(newOrdI + 1, len);
                } else if (wrappedDown and newOrdI > @intCast(i64, ord)) {
                    newOrdI = @mod(newOrdI - 1, len);
                }
                var newOrd = @intCast(usize, newOrdI);
                //print("ord={d} newOrd={d} item {d}\n", .{ ord, newOrd, n });

                var oldOrd = ords.items[ord];
                if (newOrd > ord) {
                    std.mem.copy(usize, ords.items[ord..newOrd], ords.items[ord + 1 .. newOrd + 1]);
                    std.mem.copy(i64, ns.items[ord..newOrd], ns.items[ord + 1 .. newOrd + 1]);
                    ns.items[newOrd] = n;
                    ords.items[newOrd] = oldOrd;

                    for (ords.items) |ord2, j| {
                        origPosToPos.items[ord2] = j;
                    }
                } else if (newOrd < ord) {
                    std.mem.copyBackwards(usize, ords.items[newOrd + 1 .. ord + 1], ords.items[newOrd..ord]);
                    std.mem.copyBackwards(i64, ns.items[newOrd + 1 .. ord + 1], ns.items[newOrd..ord]);
                    ns.items[newOrd] = n;
                    ords.items[newOrd] = oldOrd;

                    for (ords.items) |ord2, j| {
                        origPosToPos.items[ord2] = j;
                    }
                }
            }
        }

        // Find the 0 position
        var zeroPos: usize = 0;
        for (ns.items) |n, i| {
            if (n == 0) {
                zeroPos = i;
                break;
            }
        }
        const coords = [_]u32{ 1000, 2000, 3000 };

        var res: i64 = 0;
        for (coords) |coord| {
            var pos = zeroPos + coord;
            print("{d}\n", .{ns.items[pos % ns.items.len]});
            res += ns.items[pos % ns.items.len];
        }
        print("part {d}: {d}\n", .{ part + 1, res });
    }

    //print("part 2: {d}\n", .{part2});
}
