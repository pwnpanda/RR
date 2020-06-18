#!/usr/bin/python
import json
import sys
import re

if len(sys.argv) < 3:
    print("Usage: [target] [domains]")
    exit(-1)

deny = []
with open(sys.argv[1],"r+") as f:
    data = f.read()

    js = json.loads(data)
    for i in js["target"]["scope"]["exclude"]:
        host = i["host"]
        deny.append(host)
        #print(host)
res = ""
#print(deny)
with open(sys.argv[2], "r+") as f:
    data = f.read()
    data = data.split("\n")
    #print(data)
    res = data

remove_all = []
for patt in deny:
    r = re.compile(patt)
    remove = list(filter(r.match,res))
    remove_all.extend(remove)

remove_all.sort()
res.sort()
scan = list(set(res) - set(remove_all))
#print(F"Removed {remove_all}")
#print(F"Output {scan}")

with open(sys.argv[2]+"_2", "w+") as f:
    f.write("\n".join(scan))

