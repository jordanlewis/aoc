#!/usr/bin/python 

from collections import defaultdict
import sys

sys.setrecursionlimit(100000)

s="""x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504"""
s = open("day17.input").read()
lines = s.split("\n")

minX = 1000
maxX = 0
minY = 1000
maxY = 0
grid = {}
grid[(500,0)] = "+"
for a, line in enumerate(lines):
    if not line:
        break
    fields = line.split(", ")
    coord = fields[0][0]
    if coord == "x":
        x = int(fields[0][2:])
        if x > maxX:
            maxX = x
        if x < minX:
            minX = x
        ya, yb = [int(y) for y in fields[1][2:].split("..")]
        if ya < minY:
            minY = ya
        if yb > maxY:
            maxY = yb
        for y in range(ya, yb+1):
            grid[(x, y)] = "#"
    else:
        y = int(fields[0][2:])
        if y > maxY:
            maxY = y
        if y < minY:
            minY = y
        xa, xb = [int(y) for y in fields[1][2:].split("..")]
        for x in range(xa, xb+1):
            grid[(x, y)] = "#"
        if xa < minX:
            minX = xa
        if xb > maxX:
            maxX = xb
print(minX, maxX, minY, maxY)

waters = {}
newWaters = {}
done = {}
def get(x,y):
    if (x,y) in done and not done[(x,y)]:
        return "|"
    if (x,y) in grid:
        return "#"
    if (x,y) in waters:
        return "~"
    return "."
def print_grid():
    for y in range(0, maxY+5):
        print("".join((get(x,y) for x in range(minX-5, maxX+5))))


i = 0

dead = 3

def find(coord, left=False, right=False, d=False, l=True):
    if coord in done:
        return done[coord]
    if coord in grid:
        done[coord] = True
        return True
    x,y = coord
    if y > maxY:
        print("ohno")
        return False
    if coord not in waters:
        if len(waters) > 80000:
            print_grid()
            return
        waters[coord] = True
    down = (x,y+1)
    if d and down in done:
        done[coord] = done[down]
        return done[down]
    filled = down in done and not done[down]
    ret = find(down, d=True)
    if not ret:
        done[coord] = ret
        return ret
    # Down is filled. We must spill left and right.
    # Spill left.
    ret = True
    ret2 = True
    if not right:
        ret = find((x-1,y), left=True)
    if not left:
        ret2 = find((x+1,y), right=True, l=ret and l)
    # propagate falses to left
    if not ret2 and not right:
        cur = (x-1,y)
        while grid.get(cur, ".") != "#" and done[cur]:
            print(cur)
            done[cur] = False
            cur = (cur[0]-1,cur[1])
    done[coord] = ret and ret2 and l
    return ret and ret2 and l

while True:
    cur = (500,1)
    last_waters = dict(waters)
    print(find(cur))
    if waters == last_waters:
        break
    i += 1
    print("\n" + str(i))
    print_grid()
    break
print (len([w for w in waters if w[1] > minY]))
print (len([w for w in waters if w[1] > minY and done[w]]))
