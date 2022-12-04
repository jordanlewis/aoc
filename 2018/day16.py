#!/usr/bin/python 

from collections import defaultdict


s = open("day16.input").read()
lines = s.split("\n")

def addr(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a] + input[b]
    return output

def addi(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a] + b
    return output

def mulr(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a] * input[b]
    return output

def muli(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a] * b
    return output

def banr(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a] & input[b]
    return output

def bani(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a] & b
    return output

def borr(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a] | input[b]
    return output

def bori(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a] | b
    return output

def gtir(inst, a, b, c, input):
    output = input[:]
    output[c] = 1 if a > input[b] else 0
    return output

def gtri(inst, a, b, c, input):
    output = input[:]
    output[c] = 1 if input[a] > b else 0
    return output

def gtrr(inst, a, b, c, input):
    output = input[:]
    output[c] = 1 if input[a] > input[b] else 0
    return output

def eqir(inst, a, b, c, input):
    output = input[:]
    output[c] = 1 if a == input[b] else 0
    return output

def eqri(inst, a, b, c, input):
    output = input[:]
    output[c] = 1 if input[a] == b else 0
    return output

def eqrr(inst, a, b, c, input):
    output = input[:]
    output[c] = 1 if input[a] == input[b] else 0
    return output

def setr(inst, a, b, c, input):
    output = input[:]
    output[c] = input[a]
    return output

def seti(inst, a, b, c, input):
    output = input[:]
    output[c] = a
    return output

funcs = [addr, addi, mulr, muli, banr, bani, borr, bori, gtir, gtri, gtrr, eqir, eqri, eqrr, setr, seti]

opcodes = {}

for i in range(16):
    opcodes[i] = set(funcs)

sample = {}
totalMatched = 0
for line in lines:
    fields = line.split()
    input = []
    if len(fields) == 0:
        continue
    if fields[0] == "Before:":
        input.append(int(fields[1][1]))
        input.append(int(fields[2][0]))
        input.append(int(fields[3][0]))
        input.append(int(fields[4][0]))
        sample["in"] = input
    elif fields[0] == "After:":
        output = []
        output.append(int(fields[1][1]))
        output.append(int(fields[2][0]))
        output.append(int(fields[3][0]))
        output.append(int(fields[4][0]))
        sample["out"] = output
        print(sample)
        matched = 0
        inst,a,b,c = sample["stuff"]
        for func in funcs:
            if output == func(inst, a, b, c, sample["in"]):
                print(func)
                matched += 1
            else:
                opcodes[inst].discard(func)
        if matched >= 3:
            totalMatched += 1
        print("matched:", matched)
    elif len(fields) > 0:
        sample["stuff"] = [int(x) for x in fields]
print(totalMatched)

print([(opcode, len(funcs)) for opcode, funcs in opcodes.items()])

remaining = [k for k in opcodes.keys()]

while len(remaining) > 0:
    cur = remaining.pop(0)
    if len(opcodes[cur]) > 1:
        remaining.append(cur)
        continue
    func = [x for x in opcodes[cur]][0]
    for o in opcodes:
        if o != cur:
            opcodes[o].discard(func)

print(opcodes)

p = open("day16.input2").read()
register = [0,0,0,0]
for line in p.split("\n"):
    if len(line) == 0:
        continue
    inst, a, b, c = [int(x) for x in line.split()]
    func = next(iter(opcodes[inst]))
    register = func(inst, a,b,c,register)

print(register)
