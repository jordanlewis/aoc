#!/usr/bin/python

from collections import defaultdict

lines = open("4.input").readlines()

s = 0
for line in lines:
    l, r = line.strip().split("[")
    fields = l.split("-")
    lets = defaultdict(int)
    letters, id = "".join(fields[:-1]), int(fields[-1])
    for let in letters:
        lets[let] += 1
    words = ["".join([chr(ord("a") + ((ord(c) - ord("a") + id) % 26)) for c in group]) for group in fields[:-1]]
    if words[0] == "northpole":
        print(words, id)
    exp = "".join((l for l, n in sorted(sorted(lets.items(), key=lambda i: i[0]), key=lambda i:i[1], reverse=True)[:5]))
    checksum = r[:-1]
    if exp == checksum:
        s += id
print(s)
