const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const ptr = try allocator.create(i32);
    std.debug.print("ptr={*}\n", .{ptr});

    var buffer: [1024]u8 = undefined;
    var nLine: u64 = 0;
    var buckets: [9]ArrayList(u8) = .{ArrayList(u8).init(allocator)} ** 9;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        if (line.len == 0 or line[0] == ' ') continue;
        if (line[0] == '[') {
            var x: u8 = 0;
            while (x < 9) : (x += 1) {
                if (line.len < 1 + 4 * x) {
                    break;
                }
                const str = line[1 + (4 * x)];
                if (str != ' ') {
                    try buckets[x].insert(0, str);
                    try stdout.print("{}\n", .{buckets[x].items[buckets[x].items.len - 1]});
                }
            }
            continue;
        }

        var iter = std.mem.split(u8, line, " ");
        _ = iter.next();
        var n = @intCast(usize, try std.fmt.parseInt(i64, iter.next().?, 10));
        _ = iter.next();
        const src = @intCast(usize, try std.fmt.parseInt(i64, iter.next().?, 10)) - 1;
        _ = iter.next();
        const dst = @intCast(usize, try std.fmt.parseInt(i64, iter.next().?, 10)) - 1;

        try stdout.print("moving {} {}({})->{}({})\n", .{ n, src, dst, buckets[src].items.len, buckets[dst].items.len });
        const origN = n;
        // part 1:
        // while (n > 0) : (n -= 1) {
        //     const x = buckets[src].pop();
        //     try buckets[dst].append(x);
        // }
        while (n > 0) : (n -= 1) {
            try buckets[dst].append(buckets[src].items[buckets[src].items.len - n]);
        }
        buckets[src].items.len -= origN;
    }
    for (buckets) |bucket| {
        const s = [_]u8{bucket.items[bucket.items.len - 1]};
        try stdout.print("{s}", .{s});
    }
    try stdout.print("\n", .{});
}
