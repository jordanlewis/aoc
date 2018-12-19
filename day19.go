package main

import (
	"fmt"
	"strconv"
	"strings"
)

const s = `addi 2 16 2
seti 1 0 4
seti 1 5 5
mulr 4 5 1
eqrr 1 3 1
addr 1 2 2
addi 2 1 2
addr 4 0 0
addi 5 1 5
gtrr 5 3 1
addr 2 1 2
seti 2 6 2
addi 4 1 4
gtrr 4 3 1
addr 1 2 2
seti 1 7 2
mulr 2 2 2
addi 3 2 3
mulr 3 3 3
mulr 2 3 3
muli 3 11 3
addi 1 6 1
mulr 1 2 1
addi 1 6 1
addr 3 1 3
addr 2 0 2
seti 0 3 2
setr 2 3 1
mulr 1 2 1
addr 2 1 1
mulr 2 1 1
muli 1 14 1
mulr 1 2 1
addr 3 1 3
seti 0 9 0
seti 0 5 2`

var m = map[string]func([]int, int, int, int){
	"addr": addr,
	"addi": addi,
	"mulr": mulr,
	"muli": muli,
	"banr": banr,
	"bani": bani,
	"borr": borr,
	"bori": bori,
	"gtir": gtir,
	"gtri": gtri,
	"gtrr": gtrr,
	"eqir": eqir,
	"eqri": eqri,
	"eqrr": eqrr,
	"setr": setr,
	"seti": seti,
}

func addr(input []int, a, b, c int) {
	input[c] = input[a] + input[b]
}

func addi(input []int, a, b, c int) {
	input[c] = input[a] + b
}

func mulr(input []int, a, b, c int) {
	input[c] = input[a] * input[b]
}

func muli(input []int, a, b, c int) {
	input[c] = input[a] * b
}

func banr(input []int, a, b, c int) {
	input[c] = input[a] & input[b]
}

func bani(input []int, a, b, c int) {
	input[c] = input[a] & b
}

func borr(input []int, a, b, c int) {
	input[c] = input[a] | input[b]
}

func bori(input []int, a, b, c int) {
	input[c] = input[a] | b
}

func gtir(input []int, a, b, c int) {
	if a > input[b] {
		input[c] = 1
	} else {
		input[c] = 0
	}
}

func gtri(input []int, a, b, c int) {
	if input[a] > b {
		input[c] = 1
	} else {
		input[c] = 0
	}
}

func gtrr(input []int, a, b, c int) {
	if input[a] > input[b] {
		input[c] = 1
	} else {
		input[c] = 0
	}
}

func eqir(input []int, a, b, c int) {
	if a == input[b] {
		input[c] = 1
	} else {
		input[c] = 0
	}
}

func eqri(input []int, a, b, c int) {
	if input[a] == b {
		input[c] = 1
	} else {
		input[c] = 0
	}
}

func eqrr(input []int, a, b, c int) {
	if input[a] == input[b] {
		input[c] = 1
	} else {
		input[c] = 0
	}
}

func setr(input []int, a, b, c int) {
	input[c] = input[a]
}

func seti(input []int, a, b, c int) {
	input[c] = a
}

func main() {
	var instrs []func([]int, int, int, int)
	var args [][]int
	ip := 2
	register := []int{1, 0, 0, 0, 0, 0}
	for _, line := range strings.Split(s, "\n") {
		fields := strings.Split(line, " ")
		instrs = append(instrs, m[fields[0]])
		a, _ := strconv.Atoi(fields[1])
		b, _ := strconv.Atoi(fields[2])
		c, _ := strconv.Atoi(fields[3])
		args = append(args, []int{a, b, c})
	}
	i := 0
	for {
		idx := register[ip]
		if idx < 0 || idx >= len(instrs) {
			break
		}
		f := instrs[idx]
		abcs := args[idx]
		f(register, abcs[0], abcs[1], abcs[2])
		register[ip]++
		fmt.Println(i, idx, register)
		i++
	}
	fmt.Println(register)
}
