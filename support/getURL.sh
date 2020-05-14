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
OUT=$(echo "$4"| sed s/.txt//g)
mkdir -p "$OUT"
ID=$RANDOM
echo "1: $1 2: $2 3: $3 4: $4 5: $5" >>"$5/getURL_$ID.txt"
for file in $1/$2/*; do
  echo "File: $file" >>"$5/getURL_$ID.txt"
  [[ -e "$file" ]] || echo -e "\n\n${BOLD}${RED}[!] No files in getURL!! \n\n${RESET}";break  # handle the case of no files
  ruby "$3" "$1/$2/$file" >> "$OUT/$file"
  
  echo "command is: ruby $3 $1/$2/$3/$file redir to $OUT/$file" >> "$5/getURL_$ID.txt"

  if [ ! -s "$OUT/$file" ]; then
    echo "No content for $file" >>"$5/getURL_$ID.txt"
    rm "$OUT/$file"
  fi
done
