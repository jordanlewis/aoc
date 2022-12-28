const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const point = struct {
    x: i64,
    y: i64,
};

const sensor = struct {
    x: i64,
    y: i64,
    r: i64,
};

const range = struct {
    minX: i64,
    maxX: i64,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const ptr = try allocator.create(i32);
    print("ptr={*}\n", .{ptr});
    //var lineMap = std.AutoHashMap(point, bool).init(allocator);
    //defer lineMap.deinit();

    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    const targetY: i64 = 4000000;
    var sensors = ArrayList(sensor).init(allocator);
    defer sensors.deinit();
    var ranges = ArrayList(range).init(allocator);
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var iter = tokenize(u8, line, " ");
        var s:sensor = undefined;
        var beacon:point = undefined;
        // Sensor at x=2, y=18: closest beacon is at x=-2, y=15
        _ = iter.next();
        _ = iter.next();
        var xVal = iter.next().?;
        var yVal = iter.next().?;
        s.x = try parseInt(i64, xVal[2..xVal.len-1], 10);
        s.y = try parseInt(i64, yVal[2..yVal.len-1], 10);
        _ = iter.next();
        _ = iter.next();
        _ = iter.next();
        _ = iter.next();
        xVal = iter.next().?;
        yVal = iter.next().?;
        beacon.x = try parseInt(i64, xVal[2..xVal.len-1], 10);
        beacon.y = try parseInt(i64, yVal[2..], 10);

        s.r = try std.math.absInt(beacon.x - s.x) + try std.math.absInt(beacon.y - s.y);
        try sensors.append(s);
    }
    print("sensors {any}\n", .{sensors.items});

    var y: i64 = 0;
    while (y <= targetY) : (y += 1) {
        ranges.items = ranges.items[0..0];
        if (@mod(y, 100000) == 0) {
            print("y: {d}\n", .{y});
        }
        for (sensors.items) |s| {
            var remainingDistance = s.r - (try std.math.absInt(s.y - y));
            //print("remaining distance: {any} {d}\n", .{s, remainingDistance});
            if (remainingDistance < 0) {
                continue;
            }
            try ranges.append(range{.minX = s.x - remainingDistance, .maxX = s.x + remainingDistance});
            //print("sensor {d}, {any}, {any}, {d}\n", .{y, s, ranges.items, s.r});
        }

        //print("y: {d}, {any}\n", .{y, ranges.items});
        while (ranges.items.len > 1) {
            var r = ranges.pop();
            var foundIntersection = false;
            for (ranges.items) |r2, i| {
                if (r.maxX+1 < r2.minX or r.minX-1 > r2.maxX) {
                    // Non-overlapping.
                    continue;
                }
                //print("merged ranges, {any}, {any} => ", .{r, r2});
                ranges.items[i].minX = @min(r.minX, r2.minX);
                ranges.items[i].maxX = @max(r.maxX, r2.maxX);
                //print("{any}\n", .{ranges.items[i]});
                foundIntersection = true;
                break;
            }
            //print("ranges @ {d}, {any}\n", .{y, ranges.items});
            if (!foundIntersection) {
                print("non overlapping ranges @ {d}, {any}, {any}\n", .{y, ranges.items, r});
                break;
            }
        }
    }

    print("ranges: {any}\n", .{ranges.items});

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}
