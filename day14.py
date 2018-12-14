#!/usr/bin/python 

from collections import defaultdict

s = open("day14.input").read()

lines = s.split("\n")

n = 47801
a = [3,7]
x,y = 0,1

s = [int(x) for x in "047801"]
print(s)

while True:
    #print(a[x] + a[y])
    for i in str(a[x] + a[y]):
        a.append(int(i))
    #print("new", new)
    #print("a", a)
    x = (x + a[x] + 1) % len(a)
    y = (y + a[y] + 1) % len(a)
    #print("x,y", x,y)
    #print("x,y",a[x],a[y])
    if len(a) % 100000 == 0:
        print(len(a))
    found = True
    if len(a) < 6:
        continue
    for i in range(0, 6):
        if s[i] != a[-6+i]:
            found = False
            break
    if found:
        print(len(a))
        break
