#!/usr/bin/python 

s="R8, R4, R4, R8"
s = "R2, L5, L4, L5, R4, R1, L4, R5, R3, R1, L1, L1, R4, L4, L1, R4, L4, R4, L3, R5, R4, R1, R3, L1, L1, R1, L2, R5, L4, L3, R1, L2, L2, R192, L3, R5, R48, R5, L2, R76, R4, R2, R1, L1, L5, L1, R185, L5, L1, R5, L4, R1, R3, L4, L3, R1, L5, R4, L4, R4, R5, L3, L1, L2, L4, L3, L4, R2, R2, L3, L5, R2, R5, L1, R1, L3, L5, L3, R4, L4, R3, L1, R5, L3, R2, R4, R2, L1, R3, L1, L3, L5, R4, R5, R2, R2, L5, L3, L1, L1, L5, L2, L3, R3, R3, L3, L4, L5, R2, L1, R1, R3, R4, L2, R1, L1, R3, R3, L4, L2, R5, R5, L1, R4, L5, L5, R1, L5, R4, R2, L1, L4, R1, L1, L1, L5, R3, R4, L2, R1, R2, R1, R1, R3, L5, R1, R4"

pos = (0,0)
heading = 0
poses = {}
found = False
for d, n in ((x[0], int(x[1:])) for x in s.split(", ")):
    if d == "L":
        heading = (heading - 1) % 4
    if d == "R":
        heading = (heading + 1) % 4
    oldx,oldy = pos
    x,y = pos
    if heading == 0:
        y -= n
    elif heading == 1:
        x += n
    elif heading == 2:
        y += n
    elif heading == 3:
        x -= n
    pos = x,y
    for a in range(*sorted((oldx,x+1))):
        if found:
            break
        for b in range(*sorted((oldy,y+1))):
            z = a,b
            if z == pos:
                continue
            if z in poses:
                print("first twice:", abs(sum(z)))
                found = True
                break
            poses[z] = True
        if found:
            break

print(abs(sum(pos)))

