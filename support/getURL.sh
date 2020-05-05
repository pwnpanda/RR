#!/bin/bash
# $1 domain $2 base dir $3 tool $4 infile $5 outfile
mkdir -p "$2/endpoints/$1"
for file in $(ls "$2/scriptsresponse/$1"); do
  ruby "$3" "$2/$4/$file" >> "$2/$5/$file"

  if [ ! -s "$LOGDIR/endpoints/$1/$file" ]; then
    rm "$2/endpoints/$1/$file"
  fi
done