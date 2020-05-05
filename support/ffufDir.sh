#!/bin/bash
# $1 is domain $2 is word list $3 is thread number $4 is log dir
YELLOW=$(tput setaf 3)
BOLD="\e[1m"

# Get name
NAME=$(echo "$1" | awk -F/ '{print $3}')

ffuf -u "$1" -recursion -recursion-depth=5 -c -w "$2" -t "$3" -fs 0 -o "$4/ffuf/$NAME"

if [ ! -s "$4/ffuf/$NAME" ]; then
  rm "$4/ffuf/$NAME"
  echo -e "${BOLD}${YELLOW}[?] No valid paths found for domain $1"
fi