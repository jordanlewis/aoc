#!/usr/bin/env python

import functools, itertools

print("part 1:", min((sum((abs(c) for c in x))) for x in functools.reduce(lambda x,y: x.intersection(y), (set(itertools.accumulate(itertools.chain.from_iterable((itertools.repeat({"R":(0,1),"L":(0,-1),"U":(-1,0),"D":(1,0)}[y[0]],int(y[1:])) for y in x.strip().split(","))), lambda a,b: tuple(sum(i) for i in zip(a,b)))) for x in open("data/day3.txt").readlines()))))
print("part 2:", min((lambda x: [x[0][k]+x[1][k]+2 for k in functools.reduce(lambda a,b: a.keys() & b.keys(), x)])(list({x[1]:x[0] for x in reversed(list(enumerate((itertools.accumulate(itertools.chain.from_iterable((itertools.repeat({"R":(0,1),"L":(0,-1),"U":(-1,0),"D":(1,0)}[y[0]],int(y[1:])) for y in x.strip().split(","))), lambda a,b: tuple(sum(i) for i in zip(a,b)))))))} for x in open("data/day3.txt").readlines()))))
