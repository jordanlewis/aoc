#!/usr/bin/env python

print("part 1:", list((lambda x,u,n,S,h:type('',(object,),{"o":[0,lambda a,b,c:S(x,c[0],a[1]+b[1]),lambda a,b,c:S(x,c[0],a[1]*b[1]),lambda a:S(x,a[0],h),lambda a:S(u,1,a[1]),lambda a,b:S(u,0,b[1]) or 1 if a[1] else 0,lambda a,b:0 if a[1] else S(u,0,b[1]) or 1,lambda a,b,c:S(x,c[0], 1 if a[1]<b[1] else 0),lambda a,b,c:S(x,c[0],1 if a[1]==b[1] else 0)],"__iter__":lambda s:s,"__next__":lambda s: (lambda m: s.o[m](*((z,z) if x[u[0]]//10**(p+2)%10 else (z,x[z]) for p,z in enumerate(x[u[0]+1:u[0]+n[m]]))) or S(u,0,u[0]+n[m]) if m<99 else exec("raise StopIteration"))(x[u[0]]%100)}))(x:=list(map(int,open("data/day5.txt").read().strip().split(","))), q:=[0,0],[0,4,4,2,2,3,3,4,4],list.__setitem__,1)()) and q[1])

print("part 2:", list((lambda x,u,n,S,h:type('',(object,),{"o":[0,lambda a,b,c:S(x,c[0],a[1]+b[1]),lambda a,b,c:S(x,c[0],a[1]*b[1]),lambda a:S(x,a[0],h),lambda a:S(u,1,a[1]),lambda a,b:S(u,0,b[1]) or 1 if a[1] else 0,lambda a,b:0 if a[1] else S(u,0,b[1]) or 1,lambda a,b,c:S(x,c[0], 1 if a[1]<b[1] else 0),lambda a,b,c:S(x,c[0],1 if a[1]==b[1] else 0)],"__iter__":lambda s:s,"__next__":lambda s: (lambda m: s.o[m](*((z,z) if x[u[0]]//10**(p+2)%10 else (z,x[z]) for p,z in enumerate(x[u[0]+1:u[0]+n[m]]))) or S(u,0,u[0]+n[m]) if m<99 else exec("raise StopIteration"))(x[u[0]]%100)}))(x:=list(map(int,open("data/day5.txt").read().strip().split(","))), q:=[0,0],[0,4,4,2,2,3,3,4,4],list.__setitem__,5)()) and q[1])