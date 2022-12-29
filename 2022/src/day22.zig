const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = @Vector(2, i32);

const exit = struct {
    p: point,
    f: facing,
};
const node = struct {
    tile: u8,
    exits: [4]exit,
};

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
    fn char(self: facing) u8 {
        return switch (self) {
            .right => '>',
            .left => '<',
            .down => 'v',
            .up => '^',
        };
    }
};

const face = enum {
    a,
    b,
    c,
    d,
    e,
    f,

    //  ab
    //  c
    // ed
    // f
    fn fromCoord(coord: point) face {
        const pointMap = [_]point{
            point{ 1, 0 }, //=> .a,
            point{ 2, 0 }, //=> .b,
            point{ 1, 1 }, //=> .c,
            point{ 1, 2 }, //=> .d,
            point{ 0, 2 }, //=> .e,
            point{ 0, 3 }, //=> .f,
        };
        for (pointMap) |p, i| {
            if (@reduce(.And, coord == p)) {
                return @intToEnum(face, i);
            }
        }
        unreachable;
    }
    fn toCoord(self: face) point {
        return switch (self) {
            .a => point{ 1, 0 },
            .b => point{ 2, 0 },
            .c => point{ 1, 1 },
            .d => point{ 1, 2 },
            .e => point{ 0, 2 },
            .f => point{ 0, 3 },
        };
    }
};

const trns = struct {
    oldFace: face,
    oldDir: facing,

    newFace: face,
    newDir: facing,
    flip: bool,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [8192]u8 = undefined;
    var part1: i32 = 0;
    var part2: u64 = 0;
    var y: i32 = 0;
    var map = std.AutoHashMap(point, node).init(allocator);
    var rowExtents = std.AutoHashMap(i32, point).init(allocator);
    var colExtents = std.AutoHashMap(i32, point).init(allocator);
    var instrs: []const u8 = undefined;
    var isInstrs = false;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (y += 1) {
        if (isInstrs) {
            // We've found our instruction list.
            instrs = try std.fmt.allocPrint(allocator, "{s}", .{line});
            break;
        }
        if (line.len == 0) {
            isInstrs = true;
            continue;
        }
        var minX: ?i32 = null;
        var maxX: i32 = @intCast(i32, line.len) - 1;
        for (line) |val, i| {
            var x = @intCast(i32, i);
            if (!colExtents.contains(x)) {
                try colExtents.put(x, point{ 10000, 0 });
            }
            if (val == ' ') {
                continue;
            }
            var extent = colExtents.getPtr(x).?;
            if (y < extent.*[0]) {
                extent.*[0] = y;
            }
            if (y > extent.*[1]) {
                extent.*[1] = y;
            }
            if (minX == null) {
                minX = x;
            }
            try map.put(point{ x, y }, node{ .tile = val, .exits = undefined });
        }
        try rowExtents.put(y, point{ minX.?, maxX });
    }

    var mapIter = map.iterator();
    while (mapIter.next()) |ent| {
        if (ent.value_ptr.tile == '#') {
            continue;
        }
        var pos = ent.key_ptr.*;
        for ([_]facing{ .right, .down, .left, .up }) |f| {
            var diff = f.diff();
            var newPos = pos + diff;
            if (map.get(newPos)) |n| {
                if (n.tile != '#') {
                    ent.value_ptr.exits[@enumToInt(f)] = exit{ .p = newPos, .f = f };
                } else {
                    // Ran into a wall - exit is just self.
                    ent.value_ptr.exits[@enumToInt(f)] = exit{ .p = pos, .f = f };
                }
                continue;
            }
            //// Otherwise, we have no tile - wrap around to the other side.
            // Part 1
            //switch (f) {
            //    .right => newPos[0] = rowExtents.get(pos[1]).?[0],
            //    .left => newPos[0] = rowExtents.get(pos[1]).?[1],
            //    .up => newPos[1] = colExtents.get(pos[0]).?[1],
            //    .down => newPos[1] = colExtents.get(pos[0]).?[0],
            //}

            // Part 2
            // A left  -> E Right, x = x, y flipped
            // A up    -> F right, x = y, y = x
            // B up    -> F up,    x = x, y flipped
            // B right -> D left,  x = x, y flipped
            // B down  -> C left,  x = y, y = x
            // C right -> B up,    x = y, y = x
            // C left  -> E down,  x = y, y = x
            // D right -> B left,  x = x, y flipped
            // D down  -> F left,  x = y, y = x
            // E left  -> A right, x = x, y flipped
            // E up    -> C right, x = y, y = x
            // F left  -> A down,  x = y, y = x
            // F down  -> B down,  x = x, y flipped
            // F right -> D up,    x = y, y = x
            const transitions = [_]trns{
                trns{ .oldFace = .a, .oldDir = .left, .newFace = .e, .newDir = .right, .flip = true },
                trns{ .oldFace = .a, .oldDir = .up, .newFace = .f, .newDir = .right, .flip = false },
                trns{ .oldFace = .b, .oldDir = .up, .newFace = .f, .newDir = .up, .flip = true },
                trns{ .oldFace = .b, .oldDir = .right, .newFace = .d, .newDir = .left, .flip = true },
                trns{ .oldFace = .b, .oldDir = .down, .newFace = .c, .newDir = .left, .flip = false },
                trns{ .oldFace = .c, .oldDir = .right, .newFace = .b, .newDir = .up, .flip = false },
                trns{ .oldFace = .c, .oldDir = .left, .newFace = .e, .newDir = .down, .flip = false },
                trns{ .oldFace = .d, .oldDir = .right, .newFace = .b, .newDir = .left, .flip = true },
                trns{ .oldFace = .d, .oldDir = .down, .newFace = .f, .newDir = .left, .flip = false },
                trns{ .oldFace = .e, .oldDir = .left, .newFace = .a, .newDir = .right, .flip = true },
                trns{ .oldFace = .e, .oldDir = .up, .newFace = .c, .newDir = .right, .flip = false },
                trns{ .oldFace = .f, .oldDir = .left, .newFace = .a, .newDir = .down, .flip = false },
                trns{ .oldFace = .f, .oldDir = .down, .newFace = .b, .newDir = .down, .flip = true },
                trns{ .oldFace = .f, .oldDir = .right, .newFace = .d, .newDir = .up, .flip = false },
            };

            //
            // First, map coords to relative square coords

            //  ab
            //  c
            // ed
            // f

            const sideLen = 50;
            var mappedPos = point{ @mod(pos[0], sideLen), @mod(pos[1], sideLen) };
            var squareCoord = point{ @divFloor(pos[0], sideLen), @divFloor(pos[1], sideLen) };

            var oldFace = face.fromCoord(squareCoord);
            var t: trns = undefined;
            var found = false;
            for (transitions) |t2| {
                if (t2.oldFace == oldFace and t2.oldDir == f) {
                    t = t2;
                    found = true;
                    break;
                }
            }
            std.debug.assert(found);
            var newF = t.newDir;
            if (t.flip) {
                newPos = point{ mappedPos[0], sideLen - 1 - mappedPos[1] };
            } else {
                newPos = point{ mappedPos[1], mappedPos[0] };
            }
            // Now map back to real coordinates.
            newPos = newPos + (@splat(2, @intCast(i32, sideLen)) * t.newFace.toCoord());
            print("Trns: {any}{any} => {any}{any}\n", .{ pos, f, newPos, newF });

            if (map.get(newPos)) |n| {
                if (n.tile != '#') {
                    ent.value_ptr.exits[@enumToInt(f)] = exit{ .p = newPos, .f = newF };
                } else {
                    // Ran into a wall - exit is just self.
                    ent.value_ptr.exits[@enumToInt(f)] = exit{ .p = pos, .f = f };
                }
            } else {
                unreachable;
            }
        }
    }

    var start: usize = 0;
    var end: usize = 0;
    var f: facing = .right;
    var pos = point{ rowExtents.get(0).?[0], 0 };
    print("instrs: {s}\n", .{instrs});
    var executedInstrs = ArrayList(u8).init(allocator);
    while (start < instrs.len) {
        while (end < instrs.len and instrs[end] != 'L' and instrs[end] != 'R') {
            end += 1;
        }
        var n = try parseInt(usize, instrs[start..end], 10);
        // Move first.
        var i: usize = 0;
        print("Walking {d}\n", .{n});
        map.getPtr(pos).?.tile = f.char();
        while (i < n) : (i += 1) {
            var nd = map.get(pos).?;
            std.debug.assert(nd.tile != '#');
            var newExit = nd.exits[@enumToInt(f)];
            if (@reduce(.And, pos == newExit.p) and f == newExit.f) {
                break;
            }
            if (f != newExit.f) {
                print("Transition: {any}{any} -> {any}{any}\n", .{ pos, f, newExit.p, newExit.f });
            }
            pos = newExit.p;
            f = newExit.f;
            map.getPtr(pos).?.tile = f.char();
            //print("new pos {any}\n", .{pos});
        }
        try executedInstrs.appendSlice(instrs[start..end]);
        //printMap(map, y);
        start = end;
        if (start >= instrs.len) {
            break;
        }

        print("{d}, {s}\n", .{ @enumToInt(f), [_]u8{instrs[start]} });
        f = switch (instrs[start]) {
            'L' => @intToEnum(facing, @mod(@intCast(i8, @enumToInt(f)) - 1, 4)),
            'R' => @intToEnum(facing, @mod(@intCast(i8, @enumToInt(f)) + 1, 4)),
            else => unreachable,
        };
        try executedInstrs.append(instrs[start]);
        end += 1;
        start += 1;
    }
    print("final pos: {any}, facing: {any}\n", .{ pos, @enumToInt(f) });
    part1 = 1000 * (1 + pos[1]) + 4 * (1 + pos[0]) + @enumToInt(f);

    printMap(map, y);

    print("Executed instrs: {s}\n", .{executedInstrs.items});

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}

fn printMap(map: std.AutoHashMap(point, node), maxY: i32) void {
    var y: i32 = 0;
    while (y < maxY) : (y += 1) {
        var x: i32 = 0;
        var foundLand = false;
        while (x < 150) : (x += 1) {
            if (map.get(point{ x, y })) |n| {
                foundLand = true;
                print("{s}", .{[_]u8{n.tile}});
            } else {
                if (foundLand) {
                    break;
                }
                print(" ", .{});
            }
        }
        print("\n", .{});
    }
}
