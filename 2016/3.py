#!/usr/bin/python

lines = open("3.input").readlines()

s = 0
cols = [[],[],[]]
for l in lines:
    fields = [int(x.strip()) for x in l.split()]
    a,b,c = sorted(fields)
    if a + b > c:
        s += 1
    for idx, field in enumerate(fields):
        cols[idx].append(field)

print(s)

z = cols[0]
z.extend(cols[1])
z.extend(cols[2])

s = 0
for i in range(int(len(z) / 3)):
    a,b,c = sorted(z[i*3:(i*3)+3])
    if a + b > c:
        s += 1
print(s)
