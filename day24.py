#!/usr/bin/python

from collections import defaultdict
import re

immunes = """3578 units each with 3874 hit points (immune to radiation) with an attack that does 10 bludgeoning damage at initiative 17
865 units each with 10940 hit points (weak to bludgeoning, cold) with an attack that does 94 cold damage at initiative 19
3088 units each with 14516 hit points (immune to cold) with an attack that does 32 bludgeoning damage at initiative 4
2119 units each with 6577 hit points (immune to slashing, fire; weak to cold) with an attack that does 22 bludgeoning damage at initiative 6
90 units each with 2089 hit points (immune to bludgeoning) with an attack that does 213 cold damage at initiative 14
1341 units each with 4768 hit points (immune to bludgeoning, radiation, cold) with an attack that does 34 bludgeoning damage at initiative 1
2846 units each with 5321 hit points (immune to cold) with an attack that does 17 cold damage at initiative 13
4727 units each with 7721 hit points (weak to radiation) with an attack that does 15 fire damage at initiative 10
1113 units each with 11891 hit points (immune to cold; weak to fire) with an attack that does 80 fire damage at initiative 18
887 units each with 5712 hit points (weak to bludgeoning) with an attack that does 55 slashing damage at initiative 15"""

infection = """3689 units each with 32043 hit points (weak to cold, fire; immune to slashing) with an attack that does 16 cold damage at initiative 7
33 units each with 10879 hit points (weak to slashing) with an attack that does 588 slashing damage at initiative 12
2026 units each with 49122 hit points (weak to bludgeoning) with an attack that does 46 fire damage at initiative 16
7199 units each with 9010 hit points (immune to radiation, bludgeoning; weak to slashing) with an attack that does 2 slashing damage at initiative 8
2321 units each with 35348 hit points (weak to cold) with an attack that does 29 radiation damage at initiative 20
484 units each with 21952 hit points with an attack that does 84 radiation damage at initiative 9
2531 units each with 24340 hit points with an attack that does 18 fire damage at initiative 3
54 units each with 31919 hit points (immune to bludgeoning, cold) with an attack that does 1178 radiation damage at initiative 5
1137 units each with 8211 hit points (immune to slashing, radiation, bludgeoning; weak to cold) with an attack that does 14 bludgeoning damage at initiative 11
2804 units each with 17948 hit points with an attack that does 11 radiation damage at initiative 2"""

#immunes="""17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
#989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3"""
#
#infection="""801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
#4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4"""

class Grp(object):
    def __init__(self, id,n, hp, dmg, initiative,weaknesses,immunes,typ):
        self.id = id
        self.n = n
        self.hp = hp
        self.dmg = dmg
        self.initiative = initiative
        self.weaknesses = weaknesses
        self.immunes = immunes
        self.typ = typ
    def ep(self):
        return self.n * self.dmg
    def dmgTo(self, other):
        if self.typ in other.immunes:
            #print(self.id, "would deal", 0, "to", other.id)
            return 0
        d = self.ep()
        if self.typ in other.weaknesses:
            d *= 2
        #print(self.id, "would deal", d, "to", other.id)
        return d
    def __repr__(self):
        return " ".join([str(x) for x in [self.id, self.n, self.hp, self.dmg, self.initiative, self.weaknesses,self.immunes,self.typ]])

    def __lt__(self, other):
        if self.ep() == other.ep():
            return self.initiative < other.initiative
        return self.ep() < other.ep()

def gan(s):
  return [int(x) for x in re.findall(r'-?\d+', s)]

def weak(s):
    return re.findall("weak to (.*?)(?:;|\))", s)

def immune(s):
    return re.findall("immune to (.*?)(?:;|\))", s)

def parse(lines):
    grps = []
    for id, line in enumerate(lines):
        u, hp, dmg, initiative = gan(line)
        weaknesses = [x.split(", ") for x in weak(line)]
        if len(weaknesses) > 0:
            weaknesses = weaknesses[0]
        immunes = [x.split(", ") for x in immune(line)]
        if len(immunes) > 0:
            immunes = immunes[0]
        typ = re.findall("\d+? (\w*?) damage", line)[0]
        grps.append(Grp(id+1,u,hp,dmg,initiative,weaknesses,immunes,typ))
    return grps

def left(grps):
    #print ("left", sum(grp.n for grp in grps))
    return sum(grp.n for grp in grps)

boost = 29
while True:
    inf = set(parse(infection.split("\n")))
    imm = set(parse(immunes.split("\n")))
    boost += 1
    for grp in imm:
        grp.dmg += boost
    while left(inf) > 0 and left(imm) > 0:
        #print("choose")
        for s,a,b in (("inf", inf, imm), ("imm",imm,inf)):
            #print(s, "is choosing")
            remaining = set(b)
            for grp in sorted(a, reverse=True):
                #print("Consider grp", grp.id)
                grp.curTarget = None
                targets = sorted(remaining, key=lambda other: (grp.dmgTo(other), other.ep(), other.initiative), reverse=True)
                if len(targets) == 0:
                    continue
                t = targets[0]
                #print("top target", t.id, grp.dmgTo(t))
                if grp.dmgTo(t) == 0:
                    continue
                remaining.remove(t)
                grp.curTarget = t

        grps = set(inf)
        grps.update(imm)

        #print("attacK======")
        for grp in sorted(grps, key=lambda grp: grp.initiative, reverse=True):
            if grp.n <= 0:
                continue
            if grp.curTarget is None:
                continue
            #print("I am grp ", grp.id, grp.n, grp.curTarget.id)
            deadUnits = min(grp.dmgTo(grp.curTarget) // grp.curTarget.hp, grp.curTarget.n)
            #print("Killed", grp.curTarget.n, deadUnits)
            grp.curTarget.n -= deadUnits
            if grp.curTarget.n <= 0:
                inf.discard(grp.curTarget)
                imm.discard(grp.curTarget)

    print(boost, left(inf), left(imm))
    if left(imm) > 0:
        print(boost, left(imm))
        break
