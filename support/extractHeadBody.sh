#!/bin/bash
# $1 is the target (Full domain name)
# $2 is WEBSITE_DATA (log directory)
NAME=$(echo "$1" | awk -F/ '{print $3}')
curl -s -X GET -H "X-Forwarded-For: h4x.fun" "$1" -I >> "$2/header/$NAME.txt"
curl -s -X GET -H "X-Forwarded-For: h4x.fun" -L "$1" >> "$2/body/$NAME.html"

# If not responsive, log domain name
if [[ $? != 0 ]]; then
  echo -e "$1" >> "$2/unresponsive.txt"
fi
