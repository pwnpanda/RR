#!/bin/bash
# $1 is $BODIES (basepath for where to find the file)
# $2 is filename of file in $BODIES (response from web page)
# $3 is $SCRIPTS_DATA (output directory for script content)
# $4 is $SCRIPTS_URL (output directory for urls of scripts
# shellcheck disable=SC2002
END_POINTS=$(cat "$2/$1" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
for end_point in $END_POINTS; do
  len=$(echo "$end_point" | grep "http" | wc -c)
  mkdir -p "$3/$2/"
  URL="$end_point"
  if [ "$len" == 0 ]; then
    URL="https://$2$end_point"
  fi
  file=$(basename "$end_point")
  curl -s -X GET "$URL" -L > "$3/$2/$file"
  echo "$URL" >>"$4/$2"
done
