#!/bin/bash
# $1 is $SCRIPT_DATA (the base path, root directory)
# $2 is the folder name of the folder containing the script body files
# $3 is the extraction script
# $4 is $LOGDIR/_target_ (logging base path)

BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)


# Make output folder for current domain being processed
mkdir -p "$4/$2"
for file in $1/$2; do
  [[ -e "$file" ]] || echo -e "\n\n${BOLD}${RED}[!] No files in getURL!! \n\n${RESET}";break  # handle the case of no files
  ruby "$3" "$1/$2/$file" >> "$4/$file"

  if [ ! -s "$4/$file" ]; then
    rm "$4/$file"
  fi
done