#!/usr/bin/python

input = (123257,647015)

print("part 1:", len(list((y for y in range(input[0],input[1]) if (lambda x: any((x[i]==x[i+1] for i in range(len(x)-1))) and all((x[i]<=x[i+1] for i in range(len(x)-1))))(str(y))))))
print("part 2:", len(list((y for y in range(input[0],input[1]) if (lambda x: all((x[i]<=x[i+1] for i in range(len(x)-1))) and any((len(list(g))==2 for _,g in itertools.groupby(x))))(str(y))))))
