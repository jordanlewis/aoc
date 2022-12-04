package main

import (
	"fmt"
	"strconv"
)

func main2() {
	//s := []int{5, 9, 4, 1, 4}
	s := []int{0, 4, 7, 8, 0, 1}
	a := make([]int, 2, 399200000)
	a[0] = 3
	a[1] = 7
	x := 0
	y := 1
	for {
		sum := a[x] + a[y]
		if sum < 10 {
			a = append(a, sum)
		} else {
			for _, c := range strconv.Itoa(a[x] + a[y]) {
				a = append(a, int(c-'0'))
			}
		}
		x = (x + a[x] + 1) % len(a)
		y = (y + a[y] + 1) % len(a)
		if len(a)%200000 == 0 {
			fmt.Println(len(a))
		}
		found := true
		if len(a) < len(s)+1 {
			continue
		}
		for i := 0; i < len(s); i++ {
			if s[i] != a[len(a)-len(s)+i-1] {
				found = false
				break
			}
		}
		if found {
			fmt.Println(a[len(a)-6:])
			fmt.Println(len(a) - len(s))
			break
		}
		for i := 0; i < len(s); i++ {
			if s[i] != a[len(a)-len(s)+i] {
				found = false
				break
			}
		}
		if found {
			fmt.Println(a[len(a)-6:])
			fmt.Println(len(a) - len(s))
			break
		}
	}
}
