#!/bin/bash
# $1 is target
# $2 is log dir (nmap dir)
# $3 is temporary directory
nmap -sS -p- -T3 "$1" -oG "$3/$1.res" > /dev/null 2>&1
#ls "$3/$1.res"
# Only extracts open ports for further scanning, newline separated
OPEN_PORTS=$(awk -F ":" '/open/{print $3}' "$3/$1.res" | grep -E -o "([0-9]{2,4})/open" | awk -F '/' '{print $2}')
# get open ports as csv
OPEN_PORTS_CSV=$(echo "$OPEN_PORTS" | tr '\n' ',')
# in depth nmap of open ports only
nmap -sC -sV -o -T2 -p "$OPEN_PORTS_CSV" -o "$2/$1.res" > /dev/null 2>&1
