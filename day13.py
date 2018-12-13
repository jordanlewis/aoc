#!/usr/bin/python

from collections import defaultdict

s = open("day13.input").read()
lines = s.split("\n")

stateDict = {"l": "s", "s": "r", "r": "l"}
class Cart(object):
    def __init__(self, x, y, dir, id):
        self.x = x
        self.y = y
        self.dir = dir
        self.id = id
        self.state = "l" # l -> s -> r ->
    def __repr__(self):
        return " ".join([str(p) for p in [self.id, self.x,self.y,self.dir,self.state]])
    def __lt__(self, other):
        if self.y == other.y:
            return self.x < other.x
        return self.y < other.y
    def r(self):
        cart.x += 1
        cart.dir = ">"
    def l(self):
        cart.x -= 1
        cart.dir = "<"
    def u(self):
        cart.y -= 1
        cart.dir = "^"
    def d(self):
        cart.y += 1
        cart.dir = "v"
    def move(self, floor):
        #print(self.id, self.x, self.y, self.dir, floor)
        next = states[self.dir]
        t = next[floor]
        if floor == "+":
            l, s, r = t
            if self.state == "l":
                t = l
            elif self.state == "s":
                t = s
            elif self.state == "r":
                t = r
            self.state = stateDict[self.state]

        if t == "v":
            self.d()
        elif t == "^":
            self.u()
        elif t == ">":
            self.r()
        elif t == "<":
            self.l()
        else:
            panic()

d = {}
carts = {}
cId = 0
for y, line in enumerate(lines):
    for x, c in enumerate(line):
        if c == " ":
            continue
        if c in ("v", "^"):
            carts[cId] = Cart(x,y,c,cId)
            cId += 1
            d[(x,y)] = "|"
        elif c in ("<", ">"):
            carts[cId] = Cart(x,y,c,cId)
            cId += 1
            d[(x,y)] = "-"
        else:
            d[(x,y)] = c
print(carts)

def panic():
    print("NOOOO")

states = {}

# l s r
states[">"] = {"-": ">", "\\": "v", "/": "^", "+": ("^", ">", "v")}
states["<"] = {"-": "<", "\\": "^", "/": "v", "+": ("v", "<", "^")}
states["v"] = {"|": "v", "\\": ">", "/": "<", "+": (">", "v", "<")}
states["^"] = {"|": "^", "\\": "<", "/": ">", "+": ("<", "^", ">")}

i = 0
print( len(carts))
while True:
    done = False
    if len(carts) == 1:
        print([(cart.x,cart.y) for cart in carts.values()])
        break
    for cart in sorted(carts.values()):
        floor = d[(cart.x,cart.y)]
        cart.move(floor)
        for other in carts.values():
            if cart.id == other.id:
                continue
            if cart.x == other.x and cart.y == other.y:
                print("Crash", cart.x, cart.y)
                del carts[cart.id]
                del carts[other.id]
                break
    i += 1
