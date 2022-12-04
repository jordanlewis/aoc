#!/usr/bin/python 

from collections import defaultdict
import sys

sys.setrecursionlimit(10000)

l = "^WNE$"
l = "^ENWWW(NEEE|SSE(EE|N))$"
l = "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$"
l = open("20.input").read()


room = {}
edges = defaultdict(set)
start = (0,0)
posesStack = [set([start])]
newPosesStack = []
poses = posesStack.pop()
for c in l[1:-1]:
    if c == "(":
        posesStack.append(poses)
        newPosesStack.append(set())
    elif c == "|":
        newPosesStack[-1].update(poses)
        poses = posesStack[-1]
    elif c == ")":
        newPosesStack[-1].update(poses)
        posesStack.pop()
        poses = newPosesStack.pop()
    else:
        newPoses = set()
        for pos in poses:
            last = pos
            x,y = pos
            if c == "N":
                y -= 1
            elif c == "S":
                y += 1
            elif c == "E":
                x += 1
            elif c == "W":
                x -= 1
            edges[last].add((x,y))
            edges[(x,y)].add(last)
            newPoses.add((x,y))
        poses = newPoses

def draw_room(edges):
    maxX = max(x for x,y in edges)
    maxY = max(y for x,y in edges)
    minX = min(x for x,y in edges)
    minY = min(y for x,y in edges)

    print("#" * (((maxY + 1 - minY) * 2) + 1))
    for y in range(minY, maxY+1):
        l = "#"
        l2 = "#"
        for x in range(minX, maxX+1):
            e = edges[(x,y)]
            if (x,y) == start:
                l += "X"
            elif len(e) > 0:
                l += "."
            else:
                l += "#"
            if (x+1,y) in e:
                l += "|"
            else:
                l += "#"
            if (x,y+1) in e:
                l2 += "-"
            else:
                l2 += "#"
            l2 += "#"
        print(l)
        print(l2)

dists = {}

def search(coord, dist):
    if coord in dists:
        return
    dists[coord] = dist
    for next in edges[coord]:
        search(next, dist+1)
draw_room(edges)
search((0,0),0)

print(max((dist for dist in dists.values())))
print(len([dist for dist in dists.values() if dist >= 1000]))
