#!/usr/bin/python 

d,t = 510, (10,10)
d,t = 11394, (7,701)

elevels = {}
gindexes = {}

for y in range(0, t[1]+1):
    for x in range(0,t[0]+1):
        coord = x,y
        if x == 0:
            gindexes[coord] = y * 48271
        elif y == 0:
            gindexes[coord] = x * 16807
        elif coord == t:
            gindexes[coord] = 0
        else:
            gindexes[coord] = elevels[(x-1,y)] * elevels[(x,y-1)]
        elevels[coord] = (gindexes[coord] + d) % 20183

def cavetype(elevel):
    t = elevel % 3
    if t == 0:
        return "."
    elif t == 1:
        return "="
    elif t == 2:
        return "|"

def draw_cave(elevels):
    for y in range(0,t[1]+1):
        print("".join([cavetype(elevels[(x,y)]) for x in range(0,t[0]+1)]))

draw_cave(elevels)

print(sum((elevels[(x,y)] % 3 for x in range(0,t[0]+1) for y in range(0,t[1]+1))))
