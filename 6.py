#!/usr/bin/python

from collections import defaultdict

lines = open("6.input").readlines()

cols = defaultdict(lambda: defaultdict(int))

for line in lines:
    for idx, c in enumerate(line):
        cols[idx][c] += 1

print("".join((sorted(col.items(), key=lambda x: x[1], reverse=True)[0][0] for col in cols.values())))
print("".join((sorted(col.items(), key=lambda x: x[1])[0][0] for col in cols.values())))
