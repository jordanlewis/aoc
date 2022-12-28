const std = @import("std");
const ArrayList = std.ArrayList;
const tokenize = std.mem.tokenize;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;

const wh = struct {
    width: u64,
    height: u64,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const ptr = try allocator.create(i32);
    print("ptr={*}\n", .{ptr});

    var buffer: [100000]u8 = undefined;
    var part1: i64 = 0;
    var part2: i64 = 0;
    var nLine: u64 = 0;

    var board = ArrayList([7]u8).init(allocator);
    defer board.deinit();
    var maxHeights = ArrayList(i64).init(allocator);
    defer maxHeights.deinit();
    var jets: []const u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(buffer[0..], '\n')) |line| : (nLine += 1) {
        jets = line;
        break;
    }


    const rocks: [5][]const u8 = .{
        "####",
        \\.#.
        \\###
        \\.#.
        ,
        \\..#
        \\..#
        \\###
        ,
        \\#
        \\#
        \\#
        \\#
        ,
        \\##
        \\##
    };
    const empty = ".......";
    var whs: [5]wh = undefined;

    for (rocks) |rock, i| {
        var it = tokenize(u8, rock, "\n");
        whs[i].height = 0;
        whs[i].width = 0;
        while (it.next()) |line| {
            whs[i].height += 1;
            whs[i].width = line.len;
        }
        print("{s}\n{any}\n", .{rock, whs[i]});
    }
    print("{s}\n", .{jets});

    var nRock: u64 = 0;
    var curRock: u64 = 0;
    var curJet: u64 = 0;
    var maxHeight: i64 = -1;
    while (nRock < 20000) : (nRock += 1) {
        //print("nRock {d}\n", .{nRock});
        // First select our rock.
        var rock = rocks[curRock];

        var x: u64 = 2;
        var y: u64 = @intCast(u64, maxHeight + @intCast(i64, 3 + whs[curRock].height));
        if (board.items.len <= y) {
            //print("Resizing {d}{d}{d}\n", .{board.items.len, y, y-board.items.len});
            try board.appendNTimes(empty.*, y - board.items.len+1);
        }

        // Now, alternate dropping and jetting the rock.
        while (true) {
            //printBoardRock(board, rock, x, y);
            // First jet the rock.
            var oldX = x;
            var hitEdge = false;
            if (jets[curJet] == '<') {
                //print("left\n",.{});
                if (x == 0) {
                    hitEdge = true;
                } else {
                    x -= 1;
                }
            } else {
                //print("right\n",.{});
                if (x == 6) {
                    hitEdge = true;
                } else {
                    x += 1;
                }
            }
            if (curJet >= jets.len-1) {
                //print("wrapped jet around {d}, {c} {c}\n", .{curJet, jets[curJet], jets[0]});
                curJet = 0;
            } else {
                curJet += 1;
            }
            //print("pre colides x y {any} {d} {d}\n", .{hitEdge, x, y});
            if (hitEdge or collides(board, rock, wh{.width = x, .height = y}, whs[curRock])) {
                // Hit something; return to old position and continue in the loop.
                x = oldX;
            }
            //printBoardRock(board, rock, x, y);
            // Now drop the rock.
            //print("drop\n", .{});
            var hitBottom = false;
            if (y > 0) {
                y -= 1;
            } else {
                hitBottom = true;
            }
            if (hitBottom or collides(board, rock, wh{.width = x, .height = y}, whs[curRock])) {
                if (!hitBottom) {
                    y += 1;
                }
                var it = tokenize(u8, rock, "\n");
                var rY: u8 = 0;
                while (it.next()) |line| {
                    for (line) |char, rX| {
                        if (char == '#') {
                            board.items[y-rY][x+rX] = '#';
                        }
                    }
                    rY += 1;
                }
                //print("{s}\n{any}\n", .{rock, whs[i]});
                var oldMaxHeight = maxHeight;
                var newMaxHeight = @intCast(i64, y);
                if (newMaxHeight > maxHeight) {
                    maxHeight = newMaxHeight;
                }
                // Append the diff between the old and new max heights.
                try maxHeights.append(maxHeight - oldMaxHeight);

                break;
            }
            //print("dropped. new y {d}\n", .{y});
            //print("New x y {d} {d}\n", .{x, y});
        }
        curRock += 1;
        if (curRock >= rocks.len) {
            curRock = 0;
        }
    }

    printBoard(board);

    part1 = maxHeight+1;
    print("part 1: {d}\n", .{part1});
    print("{any}\n", .{maxHeights});

// For part 2, we cheated by using the python shell and some vim / regexp stuff.
// We found the first repeating pattern and summed it up and did some divmod stuff.
// The better way to do this would be to write an algorithm that finds the longest repeat
// in a string, but I was too lazy to figure out how to do this.
// The python that I used to calculate the result looked like this:
//In [18]: prefix = "123200020212202122221322012302133200200202320132420001013300132401324213220123221334013320133001222013220030401304001200132201334012301123011230001301123221213002220022121322012302132    ...: 201304213320133021332213200121011330002300123001332013300132001330002300123401332013200112220030002"
//
//In [19]: len(prefix)
//Out[19]: 282
//
//In [20]: repeat = "320121301224012300133401334013220133200220013240003001212213320022021322212240130221222212222133201321213200122111232013012121201321113222122221322013200121301324213322132011330013342    ...: 1332013020132421332212300130401332013220121401230012300030101330212120132220034213340133001212213340130301321212200132400012013300121200230013220122001221003240133001320013240122401330002030132    ...: 2213222123200234000302021201332012142121300301213320132221322013300133000222212342133401321003340123001303002110132221324012120133401321003220132201230213300133001224013030130320303002200133021    ...: 3300123011320013222130201212213320133221212212340123201334002300023221334013220133201330012120030421330010320132201320012110133201324002202133420330200300133021212210320133221322200300130201334    ...: 0133221330013320122201302012220133000222013300132401334012112122401304002300023401334013302133201221113322132201303213340132201324013322132111222213320100421234012132032201031213300123011332013    ...: 2201330013340133000230011220022200230013042122201334013320123011212213042123010304213300121201303013200021301121203020122221320213212132001322002020032200232213322130201332213222133201230103220    ...: 0230013340132201330013340123221330012300132001301113220133421332212200133001322203002023200230213040133020304013220133421334213022003221330013020122001334203002132401320213302021201322013200133    ...: 2212220103221220213220121201320003300133201220013240022201230212120133200222013342003000203013300132421320213220133201330012320130301230012120122001304212320123001334213220130101230003300130300    ...: 2122132001130202340132201320002320123201320212222133001330013342133001032212220021400122002140123001332011222132201330013322132200222013220132001212200300133401330001320133400232013220023201334    ...: 213030030201334013"
//
//In [21]: len(repeat)
//Out[21]: 1745
//
//In [22]: numRepeats = (1000000000000 - len(prefix)) // len(repeat)
//
//In [23]:
//
//In [23]: repeatSum = sum(int(x) for x in repeat)
//
//In [24]: prefixSum = sum(int(x) for x in prefix)
//
//In [25]:
//
//In [25]: prefixSum + (numRepeats * repeatSum) + sum(int(x) for x in repeat[:(1000000000000 - len(prefix)) % len(repeat)])
//Out[25]: 1575931232076

    print("part 2: {d}\n", .{part2});
}

fn collides(board: ArrayList([7]u8), rock: []const u8, pos: wh, rockWH: wh) bool {
    if (pos.width < 0 or pos.width + rockWH.width > 7 or @intCast(i64, pos.height) - @intCast(i64, rockWH.height) < -1) {
        //print("early return {d} {d} \n", .{pos.width, rockWH.width});
        return true;
    }
    var it = tokenize(u8, rock, "\n");
    var rY: u8 = 0;
    while (it.next()) |line| {
        for (line) |char, rX| {
            //print("{d} {d} {d} {d}\n", .{pos.height, rY, pos.width, rX});
            if (char == '#' and board.items[pos.height-rY][pos.width+rX] == '#') {
                return true;
            }
        }
        rY += 1;
    }
    return false;
}

fn printBoardRock(board: ArrayList([7]u8), rock: []const u8, x: u64, y: u64) void {
    var it = tokenize(u8, rock, "\n");
    var rY: u8 = 0;
    while (it.next()) |line| {
        for (line) |char, rX| {
            if (char == '#' and board.items[y-rY][x+rX] == '.') {
                board.items[y-rY][x+rX] = '@';
            }
        }
        rY += 1;
    }
    printBoard(board);
    it = tokenize(u8, rock, "\n");
    rY = 0;
    while (it.next()) |line| {
        for (line) |char, rX| {
            if (char == '#' and board.items[y-rY][x+rX] == '@') {
                board.items[y-rY][x+rX] = '.';
            }
        }
        rY += 1;
    }
}

fn printBoard(board: ArrayList([7]u8)) void {
    var x:u64 = 0;
    while (x < board.items.len) {
        x += 1;
        print("|{s}|\n", .{board.items[board.items.len - x]});
    }
}