#!/usr/bin/python

import re

s = 0
s2 = 0
lines = """abba[mnop]qrst
abcd[bddb]xyyx
aaaa[qwer]tyui
ioxxoj[asdfgh]zxcvbn
aba[bab]xyz
xyx[xyx]xyx
aaa[kek]eke
zazbz[bzb]cdb""".split("\n")
lines = open("7.input").readlines()

for line in lines:
    bracket = False
    ok = False
    ok2 = False
    abas = []
    babs = []
    for i in range(len(line[:-2])):
        if line[i] == "[":
            bracket = True
            continue
        elif line[i] == "]":
            bracket = False
            continue
        grp = line[i:i+4]
        if len(grp) > 3:
            abba = grp[0] == grp[3] and grp[1] == grp[2] and grp[0] != grp[1]
            if bracket and abba:
                ok = False
            if abba:
                ok = True

        grp = line[i:i+3]
        if "[" in grp or "]" in grp:
            continue
        if grp[0] == grp[2] and grp[0] != grp[1]:
            if bracket:
                babs.append(grp)
                for aba in abas:
                    if aba[0] == grp[1] and aba[1] == grp[0]:
                        ok2 = True
            else:
                abas.append(grp)
                for bab in babs:
                    if bab[0] == grp[1] and bab[1] == grp[0]:
                        ok2 = True

    if ok:
        s += 1
    if ok2:
        s2 += 1
print(s, s2)
