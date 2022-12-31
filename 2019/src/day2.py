#!/usr/bin/env python

import sys, itertools, operator

print("part 1:", (lambda x: list(itertools.takewhile(lambda v: v == None, [x.__setitem__(x[i+3], {1: operator.add, 2: operator.mul}[x[i]](x[x[i+1]],x[x[i+2]])) if x[i] != 99 else 0 for i in range(0,len(x)//4*4,4)])))(x := [int(item[1]) if item[0] not in (1,2) else {1:12,2:2}[item[0]] for item in enumerate(open("data/day2.txt").read().strip().split(","))])[0] or x[0])

print("part 2:", (lambda g: next((100*s[1]+s[2] for s in g if s[0]==19690720))) ((lambda x: list(itertools.takewhile(lambda v: v == None, [x.__setitem__(x[i+3], {1: operator.add, 2: operator.mul}[x[i]](x[x[i+1]],x[x[i+2]])) if x[i] != 99 else 0 for i in range(0,len(x)//4*4,4)])))(x := [int(item[1]) if item[0] not in (1,2) else {1:a,2:b}[item[0]] for item in enumerate(open("data/day2.txt").read().strip().split(","))])[0] or x[:3] for a in range(1,100) for b in range(1,100)))
