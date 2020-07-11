#!/usr/bin/python
import json
import sys
import re
from os import path

if len(sys.argv) < 3:
    print("Usage: [target] [domains]")
    exit(-1)

# Check if file exists
if not path.exists(sys.argv[1]):
    print("File does not exists - test all urls")
    exit(-1)

# Extract out of scope regexes
deny = []
with open(sys.argv[1],"r+") as f:
    data = f.read()

    js = json.loads(data)
    for i in js["target"]["scope"]["exclude"]:
        host = i["host"]
        deny.append(host)
        #print(host)

# Get all domains from file
res = ""
#print(deny)
with open(sys.argv[2], "r+") as f:
    data = f.read()
    data = data.split("\n")
    #print(data)
    res = data

# Find results matching out of scope
remove_all = []
for patt in deny:
    r = re.compile(patt)
    remove = list(filter(r.match,res))
    remove_all.extend(remove)

# remove from file
remove_all.sort()
res.sort()
scan = list(set(res) - set(remove_all))
#print(F"Removed {remove_all}")
#print(F"Output {scan}")

# Write new file with correct data
outname = sys.argv[2]+"_new"
print(F"Outfile: {outname}")
with open(outname, "w+") as f:
    f.write("\n".join(scan))

