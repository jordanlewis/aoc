const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const t = struct {
    val: i8,
    seen: bool,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var maxScore: u64 = 0;
    var nLine: u64 = 0;
    var trees: [99][99]t = std.mem.zeroes([99][99]t);
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        for (line) |val, i| {
            var s = [_]u8{val};
            var n = try parseInt(i8, &s, 10);
            trees[nLine][i] = t{ .val = n, .seen = false };
        }
    }
    print("hi\n", .{});
    var visible: u32 = 0;
    var rowlen: u32 = 0;
    var i: usize = 0;
    while (i < trees.len) : (i += 1) {
        var curMax: i8 = -1;
        rowlen = trees[i].len;
        var j: usize = 0;
        while (j < rowlen) : (j += 1) {
            var tree = &trees[i][j];
            if (tree.val > curMax) {
                curMax = tree.val;
                if (!tree.seen) {
                    print("1 {} > {} {} {}\n", .{ tree, curMax, i, j });
                    visible += 1;
                    trees[i][j].seen = true;
                }
            }
        }
        curMax = -1;
        j = rowlen;
        while (j > 0) {
            j -= 1;
            var tree = &trees[i][j];
            if (tree.val > curMax) {
                print("2 {} > {}\n", .{ tree, curMax });
                curMax = tree.val;
                if (!tree.seen) {
                    visible += 1;
                    trees[i][j].seen = true;
                }
            }
        }
    }
    i = 0;
    while (i < rowlen) : (i += 1) {
        var j: usize = 0;
        var curMax: i8 = -1;
        while (j < trees.len) : (j += 1) {
            var tree = &trees[j][i];
            if (tree.val > curMax) {
                print("3 {} > {}\n", .{ tree, curMax });
                curMax = tree.val;
                if (!tree.seen) {
                    visible += 1;
                    trees[j][i].seen = true;
                }
            }
        }
        curMax = -1;
        j = trees.len;
        while (j > 0) {
            j -= 1;
            var tree = &trees[j][i];
            if (tree.val > curMax) {
                print("4 {} > {}\n", .{ tree, curMax });
                curMax = tree.val;
                if (!tree.seen) {
                    visible += 1;
                    trees[j][i].seen = true;
                }
            }
        }
    }

    for (trees) |row, a| {
        for (row) |_, b| {
            var x = scenicScore(a, b, trees);
            if (x > maxScore) {
                maxScore = x;
            }
        }
    }
    print("part 1: {d}\n", .{visible});
    print("part 2: {d}\n", .{maxScore});
}

fn scenicScore(i: usize, j: usize, trees: [99][99]t) u64 {
    if (i == 0 or j == 0 or i == trees.len - 1 or j == trees[0].len - 1) {
        return 0;
    }
    print("{} {} ({})::::::\n", .{ i, j, trees[i][j].val });
    var height: i8 = trees[i][j].val;

    var ret: u64 = 0;
    var x = j + 1;
    print("x {}\n", .{x});
    while (x < trees[i].len) : (x += 1) {
        ret += 1;
        print("going right {} {} {}\n", .{ i, x, trees[i][x].val });
        if (trees[i][x].val >= height) {
            break;
        }
    }
    print("{}\n", .{ret});
    var counter: u64 = 0;
    x = j;
    while (x > 0) {
        x -= 1;
        counter += 1;
        if (trees[i][x].val >= height) {
            break;
        }
    }
    print("{}\n", .{counter});
    ret *= counter;

    counter = 0;
    x = i + 1;
    while (x < trees.len) : (x += 1) {
        counter += 1;
        if (trees[x][j].val >= height) {
            break;
        }
    }
    print("{}\n", .{counter});
    ret *= counter;

    counter = 0;
    x = i;
    while (x > 0) {
        x -= 1;
        counter += 1;
        if (trees[x][j].val >= height) {
            break;
        }
    }
    print("{}\n", .{counter});

    ret *= counter;
    print("{} {} ({}) = {}\n", .{ i, j, trees[i][j].val, ret });
    return ret;
}
