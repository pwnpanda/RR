#!/bin/bash
# $1 is domain $2 is tool $3 is org name $4 is JSFOLDER
NAME=$(echo "$1" | awk -F/ '{print $3}')
NAMEJSFOLDER="$4/$NAME"
mkdir -p $NAMEJSFOLDER

python3 "$2" -u "$1" -n "$3" | tee -a "$NAMEJSFOLDER/$NAME.txt"

if [ -z "$(ls -A $NAMEJSFOLDER/)" ]; then
  rmdir "$NAMEJSFOLDER"
fi

if [ ! -s "$NAMEJSFOLDER/$NAME.txt" ]; then
  rm "$JSFOLDER/$NAME.txt"
fi
