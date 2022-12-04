#!/usr/bin/python

from collections import defaultdict

s = open("day19.input").read()

lines = s.split("\n")

def addr(input, a, b, c):
    input[c] = input[a] + input[b]

def addi(input, a, b, c):
    input[c] = input[a] + b

def mulr(input, a, b, c):
    input[c] = input[a] * input[b]

def muli(input, a, b, c):
    input[c] = input[a] * b

def banr(input, a, b, c):
    input[c] = input[a] & input[b]

def bani(input, a, b, c):
    input[c] = input[a] & b

def borr(input, a, b, c):
    input[c] = input[a] | input[b]

def bori(input, a, b, c):
    input[c] = input[a] | b

def gtir(input, a, b, c):
    input[c] = 1 if a > input[b] else 0

def gtri(input, a, b, c):
    input[c] = 1 if input[a] > b else 0

def gtrr(input, a, b, c):
    input[c] = 1 if input[a] > input[b] else 0

def eqir(input, a, b, c):
    input[c] = 1 if a == input[b] else 0

def eqri(input, a, b, c):
    input[c] = 1 if input[a] == b else 0

def eqrr(input, a, b, c):
    input[c] = 1 if input[a] == input[b] else 0

def setr(input, a, b, c):
    input[c] = input[a]

def seti(input, a, b, c):
    input[c] = a

funcs = [addr, addi, mulr, muli, banr, bani, borr, bori, gtir, gtri, gtrr, eqir, eqri, eqrr, setr, seti]


instrs = []
ip = int(lines[0].split()[1])

register = [1,0,0,0,0,0]
for y, line in enumerate(lines[1:]):
    if not line:
        continue
    fields = line.split()
    f = globals()[fields[0]]
    args = [int(x) for x in fields[1:]]
    instrs.append((f, args))

while True:
    idx = register[ip]
    if idx < 0 or idx >= len(instrs):
        break
    f, args = instrs[idx]
    a,b,c = args
    f(register, a,b,c)
    register[ip] += 1
print(register)
