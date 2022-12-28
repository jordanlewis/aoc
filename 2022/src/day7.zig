const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const file = struct {
    name: []const u8,
    size: i32,
};

const dir = struct {
    parent: ?*dir = null,
    name: []const u8,
    dirs: ArrayList(*dir),
    files: ArrayList(file),
};

var part1: i32 = 0;
var allDirs: ArrayList(i32) = undefined;
pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    allDirs = ArrayList(i32).init(allocator);

    var buffer: [1024]u8 = undefined;
    var part2: i32 = 0;
    var nLine: u64 = 0;
    var inDir = false;
    var root = dir{
        .dirs = ArrayList(*dir).init(allocator),
        .files = ArrayList(file).init(allocator),
        .name = "",
    };
    var cur: *dir = &root;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        if (nLine == 0) continue;
        var iter = tokenize(u8, line, " ");
        if (inDir and line[0] == '$') {
            inDir = false;
        }
        if (!inDir) {
            // consume $
            _ = iter.next();
            var cmd = iter.next().?;
            if (std.mem.eql(u8, cmd, "ls")) {
                inDir = true;
                continue;
            }
            if (!std.mem.eql(u8, cmd, "cd")) {
                unreachable;
            }
            var newdir = iter.next().?;
            if (std.mem.eql(u8, newdir, "..")) {
                cur = cur.parent.?;
                continue;
            }
            //print("searching for {s}\n", .{newdir});
            for (cur.dirs.items) |child| {
                //print("{s}\n", .{child.name});
                if (std.mem.eql(u8, child.name, newdir)) {
                    cur = child;
                    break;
                }
            } else unreachable;
            continue;
        }
        var x = iter.next().?;
        if (std.mem.eql(u8, x, "dir")) {
            var name = iter.next().?;
            var nameCopy = try allocator.alloc(u8, name.len);
            std.mem.copy(u8, nameCopy, name);
            var d = try allocator.create(dir);
            d.* = dir{ .parent = cur, .name = nameCopy, .dirs = ArrayList(*dir).init(allocator), .files = ArrayList(file).init(allocator) };
            try cur.dirs.append(d);
        } else {
            var n = try parseInt(i32, x, 10);
            var name = iter.next().?;
            try cur.files.append(file{ .name = name, .size = n });
        }
    }
    var totalsize = try recurse(&root);
    var maxsize: i32 = 30000000;
    var cap: i32 = 70000000;

    // Find the smallest directory that's at least totalsize - 30000000;
    std.sort.sort(i32, allDirs.items, {}, comptime std.sort.asc(i32));

    for (allDirs.items) |d| {
        //print("total size {}, max size {}, found {}, unused {}, remaining {}\n", .{ totalsize, maxsize, d, cap - (totalsize - d), totalsize - d });
        if (cap - (totalsize - d) >= maxsize) {
            part2 = d;
            break;
        }
    }

    print("part 1: {d}\n", .{part1});
    print("part 2: {d}\n", .{part2});
}

fn recurse(d: *dir) !i32 {
    var size: i32 = 0;
    for (d.files.items) |f| {
        size += f.size;
    }
    for (d.dirs.items) |child| {
        size += try recurse(child);
    }
    if (size <= 100000) {
        //print("{}\n", .{size});
        part1 += size;
    }
    try allDirs.append(size);
    return size;
}
