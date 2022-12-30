const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = @Vector(2, i32);
const facing = enum {
    right,
    down,
    left,
    up,
    fn diff(self: facing) point {
        return switch (self) {
            .right => point{ 1, 0 },
            .left => point{ -1, 0 },
            .down => point{ 0, 1 },
            .up => point{ 0, -1 },
        };
    }
    fn fromChar(c: u8) facing {
        return switch (c) {
            '>' => .right,
            '^' => .up,
            'v' => .down,
            '<' => .left,
            else => unreachable,
        };
    }
    fn char(self: facing) u8 {
        return switch (self) {
            .right => '>',
            .left => '<',
            .down => 'v',
            .up => '^',
        };
    }
};

const blizzard = struct {
    pos: point,
    dir: facing,
};

const node = struct {
    wall: bool,
    //blizzards: std.ArrayList(*blizzard),
    c: u8,
};

const timepoint = struct {
    p: point,
    n: usize,
};

const state = struct {
    allocator: std.mem.Allocator,
    map: std.AutoHashMap(timepoint, u8),
    blizzards: ArrayList(*blizzard),
    exit: point,
    maxN: u32,
    maxX: i32,
    maxY: i32,
    mod: u32,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var map = std.AutoHashMap(timepoint, u8).init(allocator);

    var buffer: [1024]u8 = undefined;
    var part1: usize = 0;
    var part2: usize = 0;
    var y: i32 = 0;
    var maxX: i32 = 0;
    var blizzards = ArrayList(*blizzard).init(allocator);
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (y += 1) {
        for (line) |val, x| {
            if (@intCast(i32, x) > maxX) {
                maxX = @intCast(i32, x);
            }
            //var n = try allocator.create(node);
            var curPos = point{ @intCast(i32, x), y };
            if (val == '#' or val == '.') {} else {
                var b = try allocator.create(blizzard);
                b.dir = facing.fromChar(val);
                b.pos = curPos;
                //n.c = val;
                //try n.blizzards.append(b);
                try blizzards.append(b);
            }
            //n.wall = val == '#';
            //n.blizzards = std.ArrayList(*blizzard).init(allocator);

            if (val != '.') {
                try map.put(timepoint{ .p = curPos, .n = 0 }, val);
            }
        }
    }
    var maxY = y - 1;
    print("maxx,y {d} {d}\n", .{ maxX, maxY });
    var exit = point{ maxX - 1, maxY };
    var pos = point{ 1, 0 };
    var s = state{
        .allocator = allocator,
        .map = map,
        .blizzards = blizzards,
        .maxN = 0,
        .maxY = maxY,
        .maxX = maxX,
        .mod = @intCast(u32, (maxY - 1)) * @intCast(u32, (maxX - 1)),
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
    var q = std.AutoHashMap(point, void).init(s.allocator);
    q.put(start.p, {}) catch unreachable;
    var n: usize = start.n;
    while (true) : (n += 1) {
        var mapN = @mod(n, s.mod);
        if (mapN > s.maxN) {
            iterateBoard(s);
        }
        var q2 = std.AutoHashMap(point, void).init(s.allocator);
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
                if (s.map.get(timepoint{ .p = newPos, .n = mapN })) |_| {
                    // Can't move here.
                    continue;
                }
                q2.put(newPos, {}) catch unreachable;
            }
        }
        q.deinit();
        q = q2;
    }
}

fn iterateBoard(s: *state) void {
    s.maxN += 1;
    for (s.blizzards.items) |b| {
        var newPos = b.pos + b.dir.diff();
        if (newPos[0] == 0) {
            newPos[0] = s.maxX - 1;
        } else if (newPos[0] == s.maxX) {
            newPos[0] = 1;
        } else if (newPos[1] == 0) {
            newPos[1] = s.maxY - 1;
        } else if (newPos[1] == s.maxY) {
            newPos[1] = 1;
        }
        //print("b {any} -> {any}\n", .{ b.pos, newPos });
        if (s.map.getPtr(timepoint{ .n = s.maxN, .p = newPos })) |c| {
            c.* = switch (c.*) {
                '<' => '2',
                '>' => '2',
                'v' => '2',
                '^' => '2',
                '2' => '3',
                '3' => '4',
                else => unreachable,
            };
            //print("set to char {s}\n", .{[_]u8{c.*}});
        } else {
            s.map.put(timepoint{ .n = s.maxN, .p = newPos }, b.dir.char()) catch unreachable;
        }
        b.pos = newPos;
    }
    //printMap(s, point{ 0, 0 });
}

fn printMap(s: *state, pos: point) void {
    //print("Map at minute {d}\n", .{s.maxN});
    var foundGuy = false;
    var y: i32 = 0;
    while (y <= s.maxY) : (y += 1) {
        var x: i32 = 0;
        while (x <= s.maxX) : (x += 1) {
            if (s.map.get(timepoint{ .n = s.maxN, .p = point{ x, y } })) |c| {
                print("{s}", .{[_]u8{c}});
            } else if (@reduce(.And, pos == point{ x, y })) {
                print("@", .{});
                foundGuy = true;
            } else {
                if (x == 0 or x == s.maxX or y == 0 or y == s.maxY) {
                    print("#", .{});
                } else {
                    print(".", .{});
                }
                //unreachable;
            }
        }
        print("\n", .{});
    }
    //std.debug.assert(foundGuy);
}
