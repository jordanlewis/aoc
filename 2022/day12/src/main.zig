const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = struct {
    x: i64,
    y: i64,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    var grid: [41][179]u8 = std.mem.zeroes([41][179]u8);
    var distances: [41][179]u16 = std.mem.zeroes([41][179]u16);
    var start = point{ .x = 0, .y = 0 };
    var end = point{ .x = 0, .y = 0 };
    var nCol: u64 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        nCol = line.len;
        for (line) |s, i| {
            grid[nLine][i] = s;
            if (s == 'S') {
                start.x = @intCast(i64, i);
                start.y = @intCast(i64, nLine);
                grid[nLine][i] = 'a';
            } else if (s == 'E') {
                end.x = @intCast(i64, i);
                end.y = @intCast(i64, nLine);
                grid[nLine][i] = 'z';
            }
        }
    }

    var i: usize = 0;
    while (i < nLine) : (i += 1) {
        var j: usize = 0;
        while (j < nCol) : (j += 1) {
            if (grid[i][j] != 'a' and grid[i][j] != 'S') continue;
            start.x = @intCast(i64, j);
            start.y = @intCast(i64, i);
            distances = std.mem.zeroes([41][179]u16);
            var q = ArrayList(*point).init(allocator);
            try q.append(&start);
            while (q.items.len > 0) {
                var p = q.orderedRemove(0);
                var dist = distances[@intCast(usize, p.y)][@intCast(usize, p.x)];
                for ([_]point{ .{ .x = -1, .y = 0 }, .{ .x = 1, .y = 0 }, .{ .x = 0, .y = -1 }, .{ .x = 0, .y = 1 } }) |dir| {
                    var newXI = p.x + dir.x;
                    var newYI = p.y + dir.y;
                    if (newXI < 0 or newXI >= nCol) continue;
                    if (newYI < 0 or newYI >= nLine) continue;
                    var newX = @intCast(usize, newXI);
                    var newY = @intCast(usize, newYI);
                    if (grid[newY][newX] > grid[@intCast(usize, p.y)][@intCast(usize, p.x)] + 1) continue;
                    var oldDist = distances[newY][newX];
                    if (oldDist == 0 or oldDist > dist + 1) {
                        distances[newY][newX] = dist + 1;
                        var newP = try allocator.create(point);
                        newP.* = point{ .x = newXI, .y = newYI };
                        try q.append(newP);
                    }
                }
            }
            var best = distances[@intCast(usize, end.y)][@intCast(usize, end.x)];
            if (best == 0) continue;
            if (part2 == 0 or best < part2) part2 = best;
        }
    }
    print("part 2: {d}\n", .{part2});
}
