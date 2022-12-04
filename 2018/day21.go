package main

import (
	"fmt"
	"strconv"
	"strings"
)

const s = `seti 123 0 3
bani 3 456 3
eqri 3 72 3
addr 3 2 2
seti 0 0 2
seti 0 0 3
bori 3 65536 4
seti 10649702 3 3
bani 4 255 5
addr 3 5 3
bani 3 16777215 3
muli 3 65899 3
bani 3 16777215 3
gtir 256 4 5
addr 5 2 2
addi 2 1 2
seti 27 7 2
seti 0 6 5
addi 5 1 1
muli 1 256 1
gtrr 1 4 1
addr 1 2 2
addi 2 1 2
seti 25 9 2
addi 5 1 5
seti 17 9 2
setr 5 7 4
seti 7 1 2
eqrr 3 0 5
addr 5 2 2
seti 5 4 2`

func main() {
	var instrs []func([]int, int, int, int)
	var instrss []string
	var args [][]int
	ip := 2
	for _, line := range strings.Split(s, "\n") {
		fields := strings.Split(line, " ")
		instrs = append(instrs, m[fields[0]])
		instrss = append(instrss, fields[0])
		a, _ := strconv.Atoi(fields[1])
		b, _ := strconv.Atoi(fields[2])
		c, _ := strconv.Atoi(fields[3])
		args = append(args, []int{a, b, c})
	}
	register := []int{0, 0, 0, 0, 0, 0}
	i := 0
	found := make(map[int]bool)
	last := -1
	for {
		idx := register[ip]
		if idx == 28 {
			if last == -1 {
				fmt.Println(register[3])
			}
			if _, ok := found[register[3]]; ok {
				fmt.Println(last)
				return
			}
			last = register[3]
			found[last] = true
		}
		if idx < 0 || idx >= len(instrs) {
			break
		}
		f := instrs[idx]
		abcs := args[idx]
		f(register, abcs[0], abcs[1], abcs[2])
		register[ip]++
		i++
	}
}
