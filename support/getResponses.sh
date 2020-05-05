#!/bin/bash
# $1 is response_file  $2 is out directory
END_POINTS=$(cat "$2/responsebody/$1" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
for end_point in $END_POINTS; do
  len=$(echo "$end_point" | grep "http" | wc -c)
  mkdir -p "$2/scriptsresponse/$1/"
  URL="$end_point"
  if [ "$len" == 0 ]; then
    URL="https://$1$end_point"
  fi
  file=$(basename "$end_point")
  curl -s -X GET "$URL" -L > "$2/scriptsresponse/$1/$file"
  echo "$URL" >>"$2/scripts/$1"
done
