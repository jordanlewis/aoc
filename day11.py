#!/usr/bin/python

from collections import defaultdict

n = 5153

cells = defaultdict(int)

def f(n,x,y):
    rackID = x+10
    p = rackID * y
    p += n
    p *= rackID
    ps = str(p)
    zz = 0
    if len(ps) >= 3:
        zz = ps[-3]
    p = int(zz) - 5
    return p

for x in range(1, 301):
    for y in range(1, 301):
        cells[(x,y)] = f(5153,x,y)

print(cells[(3,5)])
print( f(57, 122,79))
print( f(39, 217,196))
print( f(71, 101,153))

sums = defaultdict(lambda: defaultdict(int))

sums[1] = cells

maxSum = 0
maxCoords = ()
maxN = 0
for n in range(2,301):
    print(n)
    grid = sums[n-1]
    for x in range(1,301-n+1):
        for y in range(1,301-n+1):
            s = grid[(x,y)]
            s += sum([cells[(x+n-1,y+j)] for j in range(0,n)])
            s += sum([cells[(x+j,y+n-1)] for j in range(0,n-1)])
            sums[n][(x,y)] = s
            if s > maxSum:
                print("new sum", s,x,y,n)
                maxSum = s
                maxCoords = (x,y)
                maxN = n

maxSum = 0
maxCoords = ()
maxN = 0



#for x in range(1, 301):
#    for y in range(1, 301):
#        sum = 0
#        sum += cells[(x,y)]
#        for n in range (1, min(301 - x, 301-y)):
#            for i in range(0,n):
#                sum += cells[(x+i, y+n)]
#                if i != n-1:
#                    sum += cells[(x+n, y+i)]
#            if sum > maxSum:
#                print("new sum", sum)
#                maxSum = sum
#                maxCoords = (x,y)
#                maxN = n
#print(maxSum, maxCoords, maxN)
