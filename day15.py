#!/usr/bin/python 

from collections import defaultdict
import heapq

s="""#######
#.E...#
#.....#
#...G.#
#######"""
s="""#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########"""
s="""#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######"""
s="""#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######"""
s="""#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######"""
s="""#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######"""
s="""#######
#G.#..#
#..#.E#
#..#..#
#..#..#
#..#..#
#######"""

s="""################################
######......###...##..##########
######....#.###...##..##########
#####....##.##.........#########
##....##..#.##...........#######
#....#........##........GE.#####
##..##...............G.G......##
##....................#.......##
###............#.......GE.....##
##......##......GGGG..GE......##
#.....####.....G......#...######
#.#########.G.........#..#######
###########...#####G.GE..#######
###########..#######..G.......##
###########.#########......#.###
########..#.#########.........##
#######....G#########........###
##.##.#.....#########.....#..#.#
#...........#########.#...##...#
##...#.......#######..#...#....#
###.##........#####......##...##
###.............GE..........#..#
####.............##........###.#
####............##.........#####
####..##....###G#...#.....######
########....###E.............###
########......##.###.........###
#########.....##.###........####
#########...#.#######.......####
#############..########...######
##############.########.########
################################"""
s="""#########
#G..G..G#
#.......#
#.......#
#G..E..G#
#.......#
#.......#
#G..G..G#
#########"""
s = """#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######"""

s = open("day15.input").read()

#216810 is too high

lines = s.split("\n")
size = len(lines[0])
class Npc(object):
    def __init__(self, x, y, t, id):
        self.x = x
        self.y = y
        self.type = t
        self.hp = 200
        self.ap = 3
        if t == "E":
            self.ap = 15

        self.id = id
    def __repr__(self):
        return " ".join([str(p) for p in [self.id, self.type,(self.y,self.x),self.hp]])
    def __lt__(self, other):
        if self.y == other.y:
            return self.x < other.x
        return self.y < other.y

chars = {}
gnomes = {}
elves = {}
grid = [[' ' for x in range(size)] for y in range(size)]
lastGrid = [[' ' for x in range(size)] for y in range(size)]
pos = {}
i = 0
for y, line in enumerate(lines):
    for x, c in enumerate(line):
        if c in ("G", "E"):
            npc = Npc(x,y,c,i)
            chars[i] = npc
            if c == "G":
                gnomes[i] = npc
            else:
                elves[i] = npc
            i += 1
            grid[y][x] = "."
            pos[(y,x)] = npc
        else:
            grid[y][x] = c

def step():
    for npc in sorted([x for x in chars.values()]):
        if npc.id not in chars:
            continue
        npc = chars[npc.id]
        print(npc)
        if npc.hp <= 0:
            continue
        others = []
        if npc.type == "G":
            selves = gnomes
            others = elves
        elif npc.type == "E":
            selves = elves
            others = gnomes
        if len(others) == 0:
            print("npc gave up", npc.id, npc.type)
            return sum([npc.hp for npc in selves.values()])

        # fight
        y,x = npc.y,npc.x
        adj = [True for c in [(y-1,x), (y,x-1), (y,x+1), (y+1,x)] if c in pos and pos[c].type != npc.type]
        if len(adj) == 0:
            # move
            minCost = 10000
            go = None
            list = search((npc.y,npc.x), npc.type)
            if list is not None and len(list) > 1:
                go = list[1]
            if go:
                print("Move: ", npc, go, minCost)
                del pos[(npc.y,npc.x)]
                npc.y,npc.x = go
                pos[go] = npc
                print_grid(pos,pos)

        # fight
        y,x = npc.y,npc.x
        adj = [(y-1,x), (y,x-1), (y,x+1), (y+1,x)]
        minHP = 10000
        other = None
        for coords in adj:
            if coords in pos:
                c = pos[coords]
                if c.hp < minHP and c.type != npc.type:
                    minHP = c.hp
                    other = c
        if other is None:
            continue
        print("Attack: ", npc, other)
        other.hp -= npc.ap
        if other.hp <= 0:
            # Delete from chars list
            del pos[(other.y,other.x)]
            del chars[other.id]
            if other.type == "G":
                del gnomes[other.id]
            else:
                raise Error
                return false
                del elves[other.id]

def heuristic(a, b):
   return abs(a[0] - b[0]) + abs(a[1] - b[1])

def search(start, typ):
    q = [start]
    open_set = set()
    open_set.add(start)
    closed_set = set()
    rev = {}
    rev[start] = None

    while len(open_set) > 0:
        cur = q.pop(0)
        open_set.remove(cur)

        y,x = cur
        adj = [(y-1,x), (y,x-1), (y,x+1), (y+1,x)]
        for child in adj:
            if child in pos and pos[child].type != typ:
                print("Goal is", cur)
                rev[child] = cur
                return make_path(child, rev)
        for child in adj:
            y,x = child
            if child in closed_set:
                continue
            if y < 0 or y >= size or x < 0 or x >= size:
                continue
            if grid[y][x] == "#":
                continue
            if child in pos:
                continue
            if child not in open_set:
                open_set.add(child)
                rev[child] = cur
                q.append(child)
        closed_set.add(cur)

def make_path(n, rev):
  path = []
  while rev[n] is not None:
    n = rev[n]
    path.append(n)

  path.reverse()
  return path


def print_grid(last_pos, pos):
    for y, line in enumerate(grid):
        out = []
        for x, c in enumerate(line):
            if (y, x) in last_pos:
                out.append(last_pos[(y,x)].type)
                npc = last_pos[(y,x)]
                #out.append(str(pos[(y,x)].id))
            else:
                out.append(c)
        out.append("   ")
        for x, c in enumerate(line):
            if (y, x) in pos:
                out.append(pos[(y,x)].type)
                npc = pos[(y,x)]
                if npc.y != y or npc.x != x:
                    print("NOOOOOOO")
                #out.append(str(pos[(y,x)].id))
            else:
                out.append(c)

        print("".join(out))

print(0)
i = 0
last_pos = {}
while True:
    i+=1
    print(i)
    last_pos = pos.copy()
    done = step()
    print([char for char in chars.values()])
    print_grid(last_pos, pos)
    if done:
        print(i-1,done,(i-1)*done)
        break
