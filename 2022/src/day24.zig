const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = @Vector(2, i32);

const timepoint = struct {
    p: point,
    n: usize,
};

const state = struct {
    allocator: std.mem.Allocator,
    board: [][]const u8,
    exit: point,
    maxX: i32,
    maxY: i32,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var part1: usize = 0;
    var part2: usize = 0;
    var y: i32 = 0;
    var maxX: i32 = 0;

    var board = ArrayList([]const u8).init(allocator);

    var input = try stdin.readAllAlloc(allocator, 1024 * 1024);
    var it = std.mem.tokenize(u8, input, "\n");
    while (it.next()) |line| : (y += 1) {
        maxX = @intCast(i32, line.len) - 1;
        try board.append(line);
    }
    var maxY = y - 1;
    print("maxx,y {d} {d}\n", .{ maxX, maxY });
    var exit = point{ maxX - 1, maxY };
    var pos = point{ 1, 0 };
    var s = state{
        .allocator = allocator,
        .board = board.items,
        .maxY = maxY,
        .maxX = maxX,
        .exit = exit,
    };
    part1 = solve(&s, timepoint{ .n = 1, .p = pos });
    s.exit = pos;
    var back = solve(&s, timepoint{ .n = part1, .p = exit });
    s.exit = exit;
    part2 = solve(&s, timepoint{ .n = back, .p = pos });

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}

const adges = [_]point{
    point{ 0, 1 },
    point{ 1, 0 },
    point{ 0, -1 },
    point{ -1, 0 },
    point{ 0, 0 },
};

fn solve(s: *state, start: timepoint) usize {
    var qv = std.AutoHashMap(point, void).init(s.allocator);
    var q2v = std.AutoHashMap(point, void).init(s.allocator);
    var q = &qv;
    var q2 = &q2v;
    q.put(start.p, {}) catch unreachable;
    var n: usize = start.n;
    while (true) : (n += 1) {
        var iter = q.keyIterator();
        while (iter.next()) |pp| {
            var p = pp.*;

            for (adges) |a| {
                var newPos = p + a;
                if (@reduce(.And, newPos == s.exit)) {
                    return n;
                }
                if (newPos[0] <= 0 or newPos[0] >= s.maxX or newPos[1] <= 0 or newPos[1] >= s.maxY) {
                    if (!@reduce(.And, newPos == start.p)) {
                        // Can't walk off edge, but start pos is fine.
                        continue;
                    }
                }
                if (s.board[@intCast(usize, @mod((newPos[1] - 1) - @intCast(i32, n), s.maxY - 1) + 1)][@intCast(usize, newPos[0])] == 'v') continue;
                if (s.board[@intCast(usize, @mod((newPos[1] - 1) + @intCast(i32, n), s.maxY - 1) + 1)][@intCast(usize, newPos[0])] == '^') continue;
                if (s.board[@intCast(usize, newPos[1])][@intCast(usize, @mod((newPos[0] - 1) - @intCast(i32, n), s.maxX - 1) + 1)] == '>') continue;
                if (s.board[@intCast(usize, newPos[1])][@intCast(usize, @mod((newPos[0] - 1) + @intCast(i32, n), s.maxX - 1) + 1)] == '<') continue;
                q2.put(newPos, {}) catch unreachable;
            }
        }
        q.clearAndFree();
        var tmp = q;
        q = q2;
        q2 = tmp;
    }
}
