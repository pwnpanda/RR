#!/bin/bash
# $1 is domain
# $2 is tool
# $3 is org name
# $4 is Output folder
# $5 is logging folder

LOG="$5/getJS_log.txt"
NAME=$(echo "$1" | awk -F/ '{print $3}')a
echo "$NAME" >> $LOG
NAMEJSFOLDER="$4/$NAME"
#mkdir -p "$NAMEJSFOLDER"

python3 "$2" -u "$1" -n "$3" >> "$NAMEJSFOLDER/$NAME.txt" 2>&1

if [ ! -s "$NAMEJSFOLDER/$NAME.txt" ]; then
  rm "$JSFOLDER/$NAME.txt"
  echo "No data in file $NAME" >> $LOG
fi

if [ -z "$(ls -A "$NAMEJSFOLDER/")" ]; then
  rmdir "$NAMEJSFOLDER"
  echo "No data in folder $NAMEJSFOLDER" >> $LOG
fi

