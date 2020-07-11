#!/bin/bash
# $1 is $BODIES (basepath for where to find the file)
# $2 is filename of file in $BODIES (response from web page)
# $3 is $SCRIPTS_DATA (output directory for script content)
# $4 is $SCRIPTS_URL (output directory for urls of scripts
# $5 is $LOGDIR
# shellcheck disable=SC2002
# $2 is with .txt
# $NAME is without .txt
LOG="$5/getResponses_log.txt"
NAME=$(echo "$2" | sed s/.txt//g)
echo "$NAME" >> $LOG
END_POINTS=$(cat "$1/$2" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
for end_point in $END_POINTS; do
  echo "" >> "$LOG"
  echo "$end_point" >> "$LOG"
  len=$(echo "$end_point" | grep "http" | wc -c)
  mkdir -p "$3/$NAME/"
  URL="$end_point"
  if [ "$len" == 0 ]; then
    URL="https://$NAME$end_point"
  fi
  file=$(basename "$end_point")
  fileout=$(echo "$file" | cut -c1-40)
  curl -s -X GET "$URL" -L > "$3/$NAME/$fileout"
  echo "$URL" >>"$4/$2"
done
