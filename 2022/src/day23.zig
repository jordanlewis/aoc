const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = @Vector(2, i32);

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var part1: i32 = 0;
    var part2: u64 = 0;
    var y: u64 = 0;
    var elves = std.AutoHashMap(point, void).init(allocator);
    // proposals maps a proposed spot on the map to the number of elves that proposed it.
    var proposals = std.AutoHashMap(point, u32).init(allocator);
    // moves maps positions of elves to the new position of each elf.
    var moves = std.AutoHashMap(point, point).init(allocator);
    var maxX: usize = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (y += 1) {
        for (line) |val, x| {
            if (x > maxX) {
                maxX = x;
            }
            if (val == '#') {
                try elves.put(point{ @intCast(i32, x), @intCast(i32, y) }, {});
            }
        }
    }

    var rules = ArrayList(point).init(allocator);
    try rules.appendSlice(&[_]point{
        point{ 0, -1 }, // north
        point{ 0, 1 }, // south
        point{ -1, 0 }, // west
        point{ 1, 0 }, // east
    });

    const adj = [_]point{
        point{ 0, -1 }, // north
        point{ 0, 1 }, // south
        point{ 1, 0 }, // east
        point{ -1, 0 }, // west
        point{ 1, -1 }, // ne
        point{ -1, -1 }, // nw
        point{ 1, 1 }, // se
        point{ -1, 1 }, // sw
    };

    var i: usize = 0;
    var nElves = elves.count();
    //print("n elves: {d}\n", .{nElves});
    while (true) : (i += 1) {
        var nMoves: u64 = 0;
        //print("Round {d}: rules{any}\n", .{ i, rules.items });
        var it = elves.keyIterator();
        while (it.next()) |elfP| {
            var elf = elfP.*;
            // If there are no adjacent elves, do nothing.
            //print("Moving elf {any}\n", .{elf});
            var found = false;
            for (adj) |p| {
                if (elves.contains(elf + p)) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                //print("no djacent elves\n", .{});
                continue;
            }

            rulesLoop: for (rules.items) |r| {
                var dirs = [3]point{ r, r, r };
                if (r[0] == 0) {
                    dirs[1][0] = 1;
                    dirs[2][0] = -1;
                } else {
                    dirs[1][1] = 1;
                    dirs[2][1] = -1;
                }
                for (dirs) |dir| {
                    //print("Checking dir {any}: ", .{dir});
                    if (elves.contains(elf + dir)) {
                        //    print("conflict\n", .{});
                        continue :rulesLoop;
                    }
                    //print("free\n", .{});
                }
                //print("Found matching rule {any}\n", .{r});
                // We found a matching rule.
                try moves.put(elf, elf + r);
                var n: u32 = 1;
                if (proposals.get(elf + r)) |oldN| {
                    n = oldN + 1;
                }
                try proposals.put(elf + r, n);
                break;
            }
        }
        // Update the rules list.
        try rules.append(rules.orderedRemove(0));

        var newElves = std.AutoHashMap(point, void).init(allocator);
        // Now process proposals.
        it = elves.keyIterator();
        while (it.next()) |elfP| {
            var elf = elfP.*;
            var maybeM = (moves.get(elf));
            if (maybeM == null) {
                try newElves.put(elf, {});
                continue;
            }
            var move = maybeM.?;
            if (proposals.get(move)) |prop| {
                if (prop > 1) {
                    //print("Bonk at {any} from {any}\n", .{ move, elf });
                    try newElves.put(elf, {});
                    continue;
                }
            } else {
                unreachable;
            }
            //print("Moving elf {any} to {any}\n", .{ elf, move });
            // We found a proposal to move an elf, and we know the next space is clear.
            nMoves += 1;
            try newElves.put(move, {});
        }
        proposals.clearAndFree();
        moves.clearAndFree();
        std.debug.assert(newElves.count() == nElves);
        //print("n elves: {d}\n", .{newElves.count()});
        elves.deinit();
        elves = newElves;
        //print("\nafter round {d}\n\n", .{i});
        //printMap(elves, maxX, maxY);

        if (i == 9) {
            // Round 10: calculate rect and empty spaces within for part 1.
            var extents = maxRect(elves);
            print("Extents: {any}\n", .{extents});
            part1 = (extents[1] + 1 - extents[0]) * (extents[3] + 1 - extents[2]) - @intCast(i32, nElves);
        }

        if (nMoves == 0) {
            part2 = i + 1;
            break;
        }
    }

    // Calculate rect.
    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}

fn maxRect(elves: std.AutoHashMap(point, void)) @Vector(4, i32) {
    var ret = @Vector(4, i32){ std.math.maxInt(i32), std.math.minInt(i32), std.math.maxInt(i32), std.math.minInt(i32) };
    var it = elves.keyIterator();
    while (it.next()) |elfP| {
        var elf = elfP.*;
        if (elf[0] < ret[0]) {
            ret[0] = elf[0];
        }
        if (elf[0] > ret[1]) {
            ret[1] = elf[0];
        }
        if (elf[1] < ret[2]) {
            ret[2] = elf[1];
        }
        if (elf[1] > ret[3]) {
            ret[3] = elf[1];
        }
    }
    return ret;
}

fn printMap(elves: std.AutoHashMap(point, void), maxX: usize, maxY: usize) void {
    var y: usize = 0;
    while (y <= maxY) : (y += 1) {
        var x: usize = 0;
        while (x <= maxX) : (x += 1) {
            if (elves.contains(point{ @intCast(i32, x), @intCast(i32, y) })) {
                print("#", .{});
            } else {
                print(".", .{});
            }
        }
        print("\n", .{});
    }
}
