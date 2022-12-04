#!/usr/bin/python

import hashlib

id = b"ugkcyxxp"


p = []
p2 = {}
i = 0
m = hashlib.md5()
m.update(id)
nums = list("0123456789")
while len(p2) < 8:
    h = m.copy()
    h.update(str(i).encode("utf-8"))
    s = h.hexdigest()
    if s[:5] == "00000":
        p.append(s[5])
        pos, char = s[5], s[6]
        if pos in nums:
            pos = int(pos)
            if pos < 8 and pos not in p2:
                p2[pos] = char

    i += 1

print("".join(p[:8]))
print("".join(p2[i] for i in range(8)))

