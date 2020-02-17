#!/usr/bin/python

from collections import defaultdict

s = open("23.input").read()

lines = s.split("\n")

maxRange = 0
maxIdx = 0
bots = []
for idx, line in enumerate(lines):
    if not line:
        break
    fields = line.split(", ")
    range = int(fields[1].split("=")[1])
    x,y,z = [int(x) for x in fields[0][5:-1].split(",")]
    bots.append((x,y,z,range))

    if range > maxRange:
        maxRange = range
        maxIdx = idx
    print(x,y,z,range)

mx, my, mz, mr = bots[maxIdx]
inRange = 0
for bot in bots:
    x,y,z,r = bot
    if abs(mx-x) + abs(my-y) + abs(mz-z) <= maxRange:
        inRange += 1

print(maxRange, maxIdx, inRange)


minx = min((x for x,y,z,r in bots))
miny = min((y for x,y,z,r in bots))
minz = min((z for x,y,z,r in bots))
maxx = max((x for x,y,z,r in bots))
maxy = max((y for x,y,z,r in bots))
maxz = max((z for x,y,z,r in bots))

print(minx,miny,minz,maxx,maxy,maxz)

print(maxx-minx, maxy-miny, maxz-minz)


def intersect(bot, bot2):
    x1,y1,z1,r1 = bot
    x2,y2,z2,r2 = bot2
    return abs(x1-x2) + abs(y1-y2) + abs(z1-z2) <= r1+r2

intersections=defaultdict(set)
for idx, bot in enumerate(bots):
    for idx2, other in enumerate(bots[idx+1:]):
        if intersect(bot,other):
            intersections[idx].add(idx2)
            intersections[idx2].add(idx)

print("\n".join([str((k, len(v))) for k,v in intersections.items()]))

