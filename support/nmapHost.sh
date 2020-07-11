#!/bin/bash
# $1 is target
# $2 is log dir (nmap dir)
# $3 is temporary directory
# $4 is logdir
# $5 is IP

masscan "$5" -p0-65535 --rate 100000 --oG "$3/$1.res" > "$4/$1_log.res"
# Replaced with masscan!
#nmap -sS -p- -T4 "$1" -oG "$3/$1.res" > /dev/null 2>&1
#ls "$3/$1.res"
# Only extracts open ports for further scanning, newline separated
OPEN_PORTS=$(awk -F ":" '/open/{print $3}' "$3/$1.res" | grep -E -o "([0-9]{2,4})/open" | awk -F '/' '{print $1}')
# get open ports as csv
OPEN_PORTS_CSV=$(echo "$OPEN_PORTS" | tr '\n' ',')
echo "Open ports for $1: $OPEN_PORTS_CSV" >> "$4/$1_log.txt"
# in depth nmap of open ports only
nmap -sC -sV -o -T2 -p "$OPEN_PORTS_CSV" "$5" -o "$2/$1.txt" > "$4/$1_nmap_log.txt"
