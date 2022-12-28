const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var buckets1: [9]ArrayList(u8) = .{ArrayList(u8).init(allocator)} ** 9;
    var buckets2: [9]ArrayList(u8) = .{ArrayList(u8).init(allocator)} ** 9;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
        if (line.len == 0 or line[0] == ' ') continue;
        if (line[0] == '[') {
            var iter = std.mem.tokenize(u8, line, "[] ");
            while (iter.next()) |x| {
                try buckets1[iter.index / 4].insert(0, x[0]);
                try buckets2[iter.index / 4].insert(0, x[0]);
            }
            continue;
        }

        var iter = std.mem.tokenize(u8, line, " movefromto");
        var n = try std.fmt.parseInt(usize, iter.next().?, 10);
        const src = try std.fmt.parseInt(usize, iter.next().?, 10) - 1;
        const dst = try std.fmt.parseInt(usize, iter.next().?, 10) - 1;

        const origN = n;
        while (n > 0) : (n -= 1) {
            const x = buckets1[src].pop();
            try buckets1[dst].append(x);
        }
        n = origN;
        while (n > 0) : (n -= 1) {
            try buckets2[dst].append(buckets2[src].items[buckets2[src].items.len - n]);
        }
        buckets2[src].items.len -= origN;
    }
    for ([_][9]ArrayList(u8){buckets1, buckets2}) |bs, i| {
        print("part {d}: ", .{i});
        for (bs) |b| {
            const s = [_]u8{b.items[b.items.len - 1]};
            print("{s}", .{s});
        }
        print("\n", .{});
    }
}
