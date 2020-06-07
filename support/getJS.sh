#!/bin/bash
# $1 is domain
# $2 is tool
# $3 is org name
# $4 is Output folder

NAME=$(echo "$1" | awk -F/ '{print $3}')
NAMEJSFOLDER="$4/$NAME"
mkdir -p "$NAMEJSFOLDER"

python3 "$2" -u "$1" -n "$3" >> "$NAMEJSFOLDER/$NAME.txt" 2>&1

if [ -z "$(ls -A "$NAMEJSFOLDER/")" ]; then
  rmdir "$NAMEJSFOLDER"
fi

if [ ! -s "$NAMEJSFOLDER/$NAME.txt" ]; then
  rm "$JSFOLDER/$NAME.txt"
fi
