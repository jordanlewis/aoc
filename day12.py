#!/usr/bin/python

from collections import defaultdict

initial = "##..#.#.#..##..#..##..##..#.#....#.....##.#########...#.#..#..#....#.###.###....#..........###.#.#.."
testInitial = "#..#.#..##......###...###"

testStates ="""...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #"""

s = open("day12.input").read()
rules = s.split("\n")
#rules = testStates.split("\n")
d = {}
for r in rules:
    if not r:
        continue
    i,o = r.split(" => ")
    d[i] = o
print(d)

state = {}
next = {}

for i in range(-1000,1000):
    state[i] = "."
for idx, s in enumerate(initial):
    state[idx] = s

for n in range (0,200):
    print(n, "".join([s for s in state.values()][997:1100]))
    print(sum([idx for idx, v in state.items() if v == "#"]))
    for i, s in state.items():
        pat = "".join([state.get(j, ".") for j in range(i-2, i+3)])
        next[i] = d.get(pat, ".")
    for k,v in next.items():
        state[k] = v
    next = {}


#print(state.items())
print([idx for idx, v in state.items() if v == "#"])
print(sum([idx for idx, v in state.items() if v == "#"]))

print(49999999800 * 23 + 4958)
