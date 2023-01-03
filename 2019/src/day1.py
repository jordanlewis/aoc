#!/usr/bin/env python

import itertools

print("part 1:", sum([int(n)//3-2 for n in open("data/day1.txt").readlines()]))
print("part 2:", sum((sum(list(itertools.takewhile(lambda x: x > 0, itertools.accumulate(itertools.repeat(int(n)), lambda a, b: a//3-2)))[1:]) for n in open("data/day1.txt").readlines())))

