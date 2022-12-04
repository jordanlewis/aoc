#!/usr/bin/python

keypadA = {(0,0): "1", (0,1): "2", (0,2): "3", \
           (1,0): "4", (1,1): "5", (1,2): "6", \
           (2,0): "7", (2,1): "8", (2,2): "9"}

keypadB = {(0,2): "1", \
           (1,1): "2", (1,2): "3", (1,3): "4", \
           (2,0): "5", (2,1): "6", (2,2): "7", (2,3): "8", (2,4): "9", \
           (3,1): "A", (3,2): "B", (3,3): "C", \
           (4,2): "D"}

input = """ULL
RRDDD
LURDL
UUUUD""".split("\n")
input = open("2.input").readlines()

def findCode(start, keypad):
    code = []
    pos = start
    for line in input:
        for c in line:
            x,y = pos
            if c == "U":
                y = y - 1
            elif c == "D":
                y = y + 1
            elif c == "L":
                x = x - 1
            elif c == "R":
                x = x + 1
            if (y,x) in keypad:
                pos = x,y
        code.append(pos)
    print("".join(keypad[y,x] for x,y in code))

findCode((1,1),keypadA)
findCode((0,2),keypadB)

