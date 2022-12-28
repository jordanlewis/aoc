const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const blueprint = struct {
    oreOreCost: u64,
    claOreCost: u64,
    obsOreCost: u64,
    obsClaCost: u64,
    geoOreCost: u64,
    geoObsCost: u64,

    maxOreCost: u64,
};

const ore: usize = 0;
const cla: usize = 1;
const obs: usize = 2;
const geo: usize = 3;
// ore, cla, obs, geo
const matType = @Vector(4, u64);

const state = struct {
    minutes: u64,

    robos: matType,
    mats: matType,
};

const cache = struct {
    maxGeoRobos: std.AutoHashMap(u64, u64),
    memo: std.AutoHashMap(state, u64),
};

const maxMinutes = 24;
pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var part1: u64 = 0;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    var blueprints = ArrayList(blueprint).init(allocator);
    defer blueprints.deinit();
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        var iter = tokenize(u8, line, " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.:");
        var b: blueprint = undefined;
        // skip blueprint number
        _ = iter.next();
        b.oreOreCost = try parseInt(u64, iter.next().?, 10);
        b.claOreCost = try parseInt(u64, iter.next().?, 10);
        b.obsOreCost = try parseInt(u64, iter.next().?, 10);
        b.obsClaCost = try parseInt(u64, iter.next().?, 10);
        b.geoOreCost = try parseInt(u64, iter.next().?, 10);
        b.geoObsCost = try parseInt(u64, iter.next().?, 10);
        b.maxOreCost = @max(b.oreOreCost, @max(b.claOreCost, @max(b.obsOreCost, b.geoOreCost)));
        try blueprints.append(b);
    }

    for (blueprints.items) |b, i| {
        print("{any}\n", .{b});
        var s = std.mem.zeroes(state);
        s.minutes = 1;
        s.robos[ore] = 1;
        var c = cache{
            .maxGeoRobos = std.AutoHashMap(u64, u64).init(allocator),
            .memo = std.AutoHashMap(state, u64).init(allocator),
        };
        defer c.maxGeoRobos.deinit();
        defer c.memo.deinit();
        var maxGeodes = recurse(&c, b, s);
        var quality = (i+1) * maxGeodes;
        print("Blueprint {d}: max {d} quality {d}\n", .{i+1, maxGeodes, quality});
        part1 += quality;
    }
    print("cache {d}\n", .{cacheHits});
    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}

var cacheHits: u64 = 0;
// Recurse returns the number of new geodes that can be created given the state.
fn recurse(c: *cache, b: blueprint, s: state) u64 {
    if (c.maxGeoRobos.get(s.minutes)) |maxGeoRobos| {
        if (maxGeoRobos > s.robos[geo]) {
            return 0;
        }
    }
    c.maxGeoRobos.put(s.minutes, s.robos[geo]) catch unreachable;

    if (s.minutes == maxMinutes) {
        if (s.robos[geo] == 2) {
            print("final state{any}\n", .{s});
        }
        return s.robos[geo];
    }
    var canBuildGeo = s.mats[ore] >= b.geoOreCost and s.mats[obs] >= b.geoObsCost;

    if (!canBuildGeo and s.minutes == maxMinutes-1) {
        return s.robos[geo] * 2;
    }

    if (c.memo.get(s)) |ret| {
        cacheHits += 1;
        //print("Recurse cached: {any}\n", .{s});
        return ret;
    }
    //print("Recurse: {any}\n", .{s});

    var curMax: u64 = 0;

    //var canBuildGeo = s.robos[obs] >= b.geoObsCost and s.robos[ore] >= b.geoOreCost;

    //if (canBuildGeo) {
    //    return s.mats[geo] + s.robos[geo] * (maxMinutes+1 - s.minutes);
    //}

    if (canBuildGeo) {
        var newS = s;
        newS.minutes += 1;
        newS.mats[ore] -= b.geoOreCost;
        newS.mats[obs] -= b.geoObsCost;
        newS.mats = newS.mats + s.robos;
        newS.robos[geo] += 1;
        // recurse with state including new geo robo.
        curMax = @max(recurse(c, b, newS), curMax);
    } else {
        var didSomething = false;

        if (s.robos[ore] < b.maxOreCost and s.mats[ore] >= b.oreOreCost) {
            didSomething = true;
            var newS = s;
            newS.minutes += 1;
            newS.mats[ore] -= b.oreOreCost;
            newS.mats = newS.mats + s.robos;
            newS.robos[ore] += 1;
            // recurse with state including new ore robo.
            curMax = @max(recurse(c, b, newS), curMax);
        }

        if (s.robos[cla] < b.obsClaCost and s.mats[ore] >= b.claOreCost) {
            didSomething = true;
            var newS = s;
            newS.minutes += 1;
            newS.mats[ore] -= b.claOreCost;
            newS.mats = newS.mats + s.robos;
            newS.robos[cla] += 1;
            // recurse with state including new cla robo.
            curMax = @max(recurse(c, b, newS), curMax);
        }

        if (s.robos[obs] < b.geoObsCost and s.mats[ore] >= b.obsOreCost and s.mats[cla] >= b.obsClaCost) {
            didSomething = true;
            var newS = s;
            newS.minutes += 1;
            newS.mats[ore] -= b.obsOreCost;
            newS.mats[cla] -= b.obsClaCost;
            newS.mats = newS.mats + s.robos;
            newS.robos[obs] += 1;
            // recurse with state including new obs robo.
            curMax = @max(recurse(c, b, newS), curMax);
        }

            // Do nothing.
            var newS = s;
            newS.minutes += 1;
            newS.mats = s.mats + s.robos;
            curMax = @max(recurse(c, b, newS), curMax);
    }

    var key = s;
    key.mats[geo] = 0;
    c.memo.put(key, curMax) catch unreachable;
    return curMax + s.robos[geo];
}