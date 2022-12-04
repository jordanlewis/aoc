#!/usr/bin/python

groups = []
f = open("day25.input").read()

for line in f.split("\n"):
    if not line:
        continue
    vals = [int(x) for x in line.split(",")]
    foundIdxs = []
    for idx, group in enumerate(groups):
        for other in group:
            if sum((abs(vals[x]-other[x]) for x in range(4))) <= 3:
                foundIdxs.append(idx)
                break

    newGroup = [vals]
    for idx in sorted(foundIdxs, reverse=True):
        newGroup.extend(groups[idx])
        del groups[idx]
    groups.append(newGroup)

print(list(map(len, groups)))
print(len(groups))
