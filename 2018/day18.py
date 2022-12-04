#!/usr/bin/python 

from collections import defaultdict

s = open("day18.input").read()

lines = s.split("\n")

w = len(lines[0])
grid = {}
for y, line in enumerate(lines):
    for x, c in enumerate(line):
        grid[(x,y)] = c

def print_grid():
    for y in range(0, w):
        print("".join((grid[(x,y)] for x in range(0, w))))
print_grid()

def adj(coord):
    x,y = coord
    ret = [(x-1,y), (x-1,y-1), (x, y-1), (x+1,y-1), (x+1,y), (x+1,y+1), (x,y+1), (x-1,y+1)]
    return [(x,y) for x,y in ret if x >= 0 and y>=0 and x<w and y<w]

print(adj((0,0)))

grids = {}
for i in range(600):
    new_grid = {}
    for x in range(w):
        for y in range(w):
            coord = (x,y)
            new_grid[coord] = grid[coord]
            if grid[coord] == ".":
                trees = [c for c in adj(coord) if grid[c] == "|"]
                if len(trees) >= 3:
                    new_grid[coord] = "|"
            elif grid[coord] == "|":
                yards = [c for c in adj(coord) if grid[c] == "#"]
                if len(yards) >= 3:
                    new_grid[coord] = "#"
            elif grid[coord] == "#":
                trees = [c for c in adj(coord) if grid[c] == "|"]
                yards = [c for c in adj(coord) if grid[c] == "#"]
                if len(trees) >= 1 and len(yards) >= 1:
                    new_grid[coord] = "#"
                else:
                    new_grid[coord] = "."
    grid = new_grid
    done = False
    print(i, len([x for x in grid.values() if x == "|"]) * len([x for x in grid.values() if x == "#"]))
    grids[i] = grid

start,end,diff = 502, 474, 28
print(600, len([x for x in grid.values() if x == "|"]) * len([x for x in grid.values() if x == "#"]))

id = (1000000000 - end) % diff
grid = grids[end + id - 1]
print(len([x for x in grid.values() if x == "|"]) * len([x for x in grid.values() if x == "#"]))

