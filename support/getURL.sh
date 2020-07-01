#!/bin/bash
# $1 is $SCRIPT_DATA (the base path, root directory)
# $2 is the folder name of the folder containing the script body files
# $3 is the extraction script
# $4 is $JSENDPOINTS/_target_
# $5 is debug logging folder

BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)


# Make output folder for current domain being processed
# In case .txt is appended, remove it
log="$5/js_endpoints_parsing.txt"
OUT=$(echo "$4" | sed s/.txt//g | sed s/.html//g)
#echo ""
#echo "DATA:"
echo "1: $1 2: $2 3: $3 4: $4 5: $5" >>"$log"
echo "Output name: $OUT" >>"$log"
mkdir -p "$OUT"
dir=$1/$2/*.js
shopt -s nullglob
if [ "$(ls -A $dir)" ]; then
    for f in $dir; do
        echo "">>"$log"
        filename=$(basename $f)
        echo "Filename: $filename" >>"$log"
        ruby "$3" "$f" >> "$OUT/$filename"
        
        echo "command is: ruby $3 $f redir to $OUT/$filename" >> "$log"

        if [ ! -s "$OUT/$filename" ]; then
            echo "${RED}No content for $filename${RESET}" | tee -a "$log"
            rm "$OUT/$filename"
        fi
    done
else
    # handle the case of no files
    echo -e "\n\n${BOLD}${RED}[!] No files in getURL!! \n\n${RESET}" | tee -a "$log"
fi
shopt -u nullglob
