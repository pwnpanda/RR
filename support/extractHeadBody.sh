#!/bin/bash
# $1 is the full domain information
# $2 is the log dir
NAME=$(echo "$1" | awk -F/ '{print $3}')
curl -X GET -H "X-Forwarded-For: h4x.fun" "$1" -I >> "$2/$NAME-head.txt"
curl -s -X GET -H "X-Forwarded-For: h4x.fun" -L "$1" >> "$2/$NAME-body.txt"

# If not responsive, log domain name and increase counter
if [[ $? != 0 ]]; then
  echo -e "$1" >> "$2/unresponsive.txt"
fi
