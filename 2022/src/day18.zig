const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = @Vector(3, i64);

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var pointSet = std.AutoHashMap(point, void).init(allocator);
    defer pointSet.deinit();
    var maxPoint: point = .{0, 0, 0};
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        var iter = tokenize(u8, line, ",");
        comptime var i = 0;
        var p: point = undefined;
        inline while (i < 3) : (i += 1) {
            p[i] = try parseInt(i64, iter.next().?, 10);
            maxPoint[i] = @max(maxPoint[i], p[i]);
        }
        try pointSet.put(p, {});
    }

    part1 = surfaceArea(pointSet);

    // Start from any outer point, and do DFS, finding all points that are reachable.
    // Once we find a wall, +1 the output.

    var q = ArrayList(point).init(allocator);
    defer q.deinit();

    var visited = std.AutoHashMap(point, void).init(allocator);
    defer visited.deinit();
    try q.append(point{-1, 0, 0});
    while (q.items.len > 0) {
        var p = q.orderedRemove(0);
        if (visited.contains(p)) {
            continue;
        }
        try visited.put(p, {});
        adgeloop: for (adge) |p2| {
            var p3 = p + p2;
            comptime var dim: usize = 0;
            inline while (dim < 3): (dim += 1) {
                if (p3[dim] > maxPoint[dim]+1 or p3[dim] < -1) {
                    continue :adgeloop;
                }
            }
            var wall = pointSet.contains(p3);
            if (wall) {
                part2 += 1;
            } else if (!visited.contains(p3)) {
                try q.append(p3);
            }
        }

    }

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}

const adge = [_]point{
    point{1, 0, 0},
    point{-1, 0, 0},
    point{0, 1, 0},
    point{0, -1, 0},
    point{0, 0, 1},
    point{0, 0, -1},
};

fn surfaceArea(pointSet: std.AutoHashMap(point, void)) u64 {
    var iter = pointSet.keyIterator();
    var ret: u64 = 0;
    while (iter.next()) |p| {
        inline for (adge) |a| {
            var x = p.* + a;
            if (!pointSet.contains(x)) {
                ret += 1;
            }
        }
    }
    return ret;
}