#!/usr/bin/env python

print("part 1:",(lambda d:sum([(f:=lambda k:0 if k=="COM" else 1+f(d[k]))(k) for k in d]))({x[4:7]:x[:3] for x in open("data/day6.txt")}))
print("part 2:",(lambda d:(g:=lambda e,k,n:n+e[k] if k in e else g(e,d[k],n+1))((f:=lambda k,n:{} if k=="COM" else {k:n}|f(d[k],n+1))("YOU",-1),"SAN",-1))({x[4:7]:x[:3] for x in open("data/day6.txt")}))

