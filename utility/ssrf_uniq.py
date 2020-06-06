# input arg1 is -ssrf-pl.txt file
# input arg2 is keyword to replace
# input arg3 is save location

import sys
cnt = 0
newfile=""
with open(sys.argv[1], "r") as fi:
    new = ""
    for line in fi:
        #print(line)
        keyword = ""
        if sys.argv[2]:
            keyword = sys.argv[2]
        else:
            keyword = "manual"
        #print(F"Keyword {keyword}")
 
        split = line.split(keyword)
        #print(F"Line split: {split}")
        newline=""
        for part in split:
            if part.strip():
                new = part+keyword+str(cnt)
                newline += new
                cnt += 1
                #print(F"Part {part}\nNew {new}")
        #print(newline)
        newfile += newline+"\n"

outfile = ""
if sys.argv[3].strip():
    outfile = sys.argv[3]
else:
    outfile = "/var/www/h4x.fun/reports/"+keyword+"unique-pl.txt"
with open(outfile, "w+") as fi:
    fi.write(newfile)

import subprocess
cmd = "ffuf -s -w "+outfile+" -u FUZZ -t 50"
proc = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
output, error = proc.communicate()
#print(F"Out {output}\n")
if error:
    print(F"Error {error}")
