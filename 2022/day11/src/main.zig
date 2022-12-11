const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const m = struct {
    items: ArrayList(u64),
    isMult: bool = false,
    isSquare: bool = false,
    operand: u8 = 0,
    div: u8 = 0,
    t: u8 = 0,
    f: u8 = 0,
    nInspects: u64 = 0,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var buffer: [1024]u8 = undefined;
    var part2: u64 = 0;
    var nLine: u64 = 0;
    var monkeys: [8]m = undefined;
    var monkey: u8 = 0;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        if (line.len == 0) {
            continue;
        }
        var iter = tokenize(u8, line, " ");
        var start = iter.next().?;
        switch (start[0]) {
            'M' => {
                monkey = try parseInt(u8, iter.next().?[0..1], 10);
                monkeys[monkey] = m{ .items = ArrayList(u64).init(allocator) };
            },
            'S' => {
                _ = iter.next();
                while (iter.next()) |n| {
                    var tok = n;
                    if (n[n.len - 1] == ',') {
                        tok = n[0 .. n.len - 1];
                    }
                    try monkeys[monkey].items.append(try parseInt(u64, tok, 10));
                }
            },
            'O' => {
                _ = iter.next();
                _ = iter.next();
                _ = iter.next();
                var op = iter.next().?;
                if (op[0] == '*') {
                    monkeys[monkey].isMult = true;
                }
                var operand = iter.next().?;
                if (operand[0] == 'o') {
                    monkeys[monkey].isMult = false;
                    monkeys[monkey].isSquare = true;
                } else {
                    monkeys[monkey].operand = try parseInt(u8, operand, 10);
                }
            },
            'T' => {
                _ = iter.next();
                _ = iter.next();
                var div = iter.next().?;
                monkeys[monkey].div = try parseInt(u8, div, 10);
            },
            'I' => {
                var b = iter.next().?;
                var t = false;
                if (b[0] == 't') {
                    t = true;
                }
                _ = iter.next();
                _ = iter.next();
                _ = iter.next();
                var otherMonkey = try parseInt(u8, iter.next().?, 10);
                if (t) {
                    monkeys[monkey].t = otherMonkey;
                } else {
                    monkeys[monkey].f = otherMonkey;
                }
            },
            else => unreachable,
        }
    }
    var nMonkeys:usize = monkey + 1;
    var round: usize = 0;
    while (round < 10000) : (round +=1 ) {
        monkey = 0;
        while (monkey < nMonkeys) : (monkey += 1) {
            //print("  monkey {}\n", .{monkey});
            var mnk = &monkeys[monkey];
            while (mnk.items.items.len > 0) {
                mnk.nInspects += 1;
                var worry = mnk.items.orderedRemove(0);
                if (mnk.isMult) {
                    worry *= mnk.operand;
                } else if (mnk.isSquare) {
                    worry *= worry;
                } else {
                    worry += mnk.operand;
                }
                // this is for part 1
                //worry /= 3;
                // Mod by the product of the divisible tests
                worry = worry % (2 * 3 * 5 * 7 * 11 * 13 * 17 * 19);
                // this one is for the example
                //worry = worry % (13 * 17 * 19 * 23);
                var target: usize = mnk.f;
                if (worry % mnk.div == 0) {
                    target = mnk.t;
                }
                //print("    throwing item {} to {}\n", .{worry, target});
                try monkeys[target].items.append(worry);
            }
        }
    }
    std.sort.sort(m, monkeys[0..nMonkeys], {}, cmpByActivity);
    print("part 1: {d}\n", .{monkeys[0].nInspects * monkeys[1].nInspects});
    print("part 2: {d}\n", .{part2});
}

fn cmpByActivity(context: void, a: m, b: m) bool {
    return std.sort.desc(u64)(context, a.nInspects, b.nInspects);
}