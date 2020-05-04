#!/bin/bash

################################################
# ///                                       \\\
#      You can edit your configuration here
#
#
################################################
# Customizations
auquatoneThreads=5
subdomainThreads=10
FFUF_Threads=50
subjackThreads=100
subjackTime=30
aquatoneTimeout=50000

githubToken=YOUR GITHUB TOKEN
SECONDS=0
domain=
subreport=

#Paths
TOOLDIR=/root/Bug_Bounty/tools
result_DIR=/root/Bug_Bounty/logs
dirsearchWordlist=$tooldir/dirsearch/db/dicc.txt
massdnsWordlist=$tooldir/clean-jhaddix-dns.txt
chromiumPath=/snap/bin/chromium

DNS_WORD_LIST=$tooldir/SecLists/Discovery/DNS/namelist.txt
DIR_WORD_LIST=$tooldir/SecLists/Discovery/Web-Content/raft-medium-files-directories.txt
# Add go binaries
PATH=$PATH:/root/go/bin

#COLORS
BOLD="\e[1m"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

########################################
# Happy Hunting
########################################

#########################################
# Error handling and printing
########################################
# Print success
print() {
  echo -e "${BOLD}${GREEN}[+] $1"
}

# Print warning
printW() {
  echo -e "${BOLD}${GREEN}[?] $1"
}

# Print error
printE() {
  echo -e "${BOLD}${RED}[!] $1"
}

#Command counter
cmd=0
check() {
  if [[ $? == 0 ]]; then
    print " - [$((CMD += 1))] $1 executed successfully"
  else
    printE " - [$((CMD += 1))] $1 encountered an error"
  fi
}
########################################

#check if running as root
if [ "$EUID" -ne 0 ]
  then printE "Run as root!"
  exit
fi

# clear screen
clear

echo -e "
__________        ___.    .__       /\         __________
\______   \  ____ \_ |__  |__|  ____)/  ______ \______   \  ____   ____   ____    ____
 |       _/ /  _ \ | __ \ |  | /    \  /  ___/  |       _/_/ __ \_/ ___\ /  _ \  /    \\
 |    |   \(  <_> )| \_\ \|  ||   |  \ \___ \   |    |   \\  ___/\  \___(  <_> )|   |  \\
 |____|_  / \____/ |___  /|__||___|  //____  >  |____|_  / \___  >\___  >\____/ |___|  /
        \/             \/          \/      \/          \/      \/     \/             \/
\n\n" | lolcat


echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 1: Starting Subdomain Enumeration"

#Amass
print "Starting Amass"
amass enum -norecursive -noalts -d $1 -o domains.txt
check "Amass"

#Crt.sh
print "Certsh"
python $tooldir/CertificateTransparencyLogs/certsh.py -d $1 | tee -a domains.txt
check "Certsh"

#Github-Search
print "Github-subdomains.py"
python3 $tooldir/github-search/github-subdomains.py -d $1 -t $githubToken | tee -a domains.txt
check "Github-subdomains.py"

#Gobuster
# TODO remove and use FFUF instead!
print "Gobuster DNS"
gobuster dns -d $1 -w $DNS_WORD_LIST -t $gobusterDNSThreads -o gobusterDomains.txt
check "Gobuster DNS"
sed 's/Found: //g' gobusterDomains.txt >>domains.txt
rm gobusterDomains.txt

# Assetfinder
print "Assetfinder"
assetfinder --subs-only $1 | tee -a domains.txt
check "Assetfinder"

# Subjack
print "Subjack for search subdomains takeover"
subjack -w domains.txt -t $subjackThreads -timeout $subjackTime -ssl -c $tooldir/subjack/fingerprints.json -v 3
check "Subjack"

#Removing duplicate entries

sort -u domains.txt -o domains.txt

#Discovering alive domains
echo -e ""
print " Checking for alive domains.."
cat domains.txt | httprobe | tee -a alive.txt
check "Alive domains with HTTProbe"

sort alive.txt | uniq -u

#Corsy
echo -e ""
print "Corsy to find CORS missconfigurations"
python3 $tooldir/Corsy/corsy.py -i alive.txt -o CORS.txt
check "Corsy"

#Aquatone
echo -e ""
echo -e "${BOLD}${GREEN}[+] Starting Aquatone to take screenshots"

mkdir -p screenshots
check "mkdir screenshots"

# TODO remove? Change to static out folder?
CUR_DIR=$(pwd)

cat alive.txt | aquatone -screenshot-timeout $aquatoneTimeout -out screenshots/
check "Aquatone"

#Parse data jo JSON

print "Finding alive domains"
cat alive.txt | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" >alive.json
check "Alive domains"

print "Get all domains"
cat domains.txt | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" >domains.json
check "All domains"

#########SUBDOMAIN HEADERS#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 2: Storing subdomain headers and response bodies"

print "mkdir headers"
mkdir -p headers
check "mkdir headers"

# TODO remove? Change to static out folder?
CURRENT_PATH=$(pwd)

print "Gather headers and responses"
ERR=0
for x in $(cat alive.txt); do
  NAME=$(echo $x | awk -F/ '{print $3}')
  curl -X GET -H "X-Forwarded-For: h4x.fun" $x -I >"$CURRENT_PATH/headers/$NAME"
  curl -s -X GET -H "X-Forwarded-For: h4x.fun" -L $x >"$CURRENT_PATH/responsebody/$NAME"
  # If not responsive, log domain name and increase counter
  if [[ $? != 0 ]]; then
    echo -n "$x\n" >> $LOGDIR/unresponsive.txt
    ((err+=1))
  fi
done

# log errors for the above command
if [[ $ERR -ge 1 ]]; then
  -1
  check "\#$ERR endpoints did not return a response"
  printW "Unresponsive endpoints can be found in $LOGDIR/unresponsive.txt!"
fi


#########JAVASCRIPT FILES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 3: Collecting JavaScript files and Hidden Endpoints"

print "Making scripts directory"
mkdir -p scripts

print "Making scriptsresponse directory"
mkdir -p scriptsresponse

print "Making responsebody directory"
mkdir -p responsebody

CUR_PATH=$(pwd)

# TODO Figure this out and remove/improve formatting

for x in $(ls "$CUR_PATH/responsebody"); do
  printf "\n\n${RED}$x${RESET}\n\n"
  END_POINTS=$(cat "$CUR_PATH/responsebody/$x" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
  for end_point in $END_POINTS; do
    len=$(echo $end_point | grep "http" | wc -c)
    mkdir "scriptsresponse/$x/"
    URL=$end_point
    if [ $len == 0 ]; then
      URL="https://$x$end_point"
    fi
    file=$(basename $end_point)
    curl -X GET $URL -L >"scriptsresponse/$x/$file"
    echo $URL >>"scripts/$x"
  done
done

CUR_DIR=$(pwd)

for domain in $(ls scriptsresponse); do
  #looping through files in each domain
  mkdir -p endpoints/$domain
  for file in $(ls scriptsresponse/$domain); do
    ruby $tooldir/relative-url-extractor/extract.rb scriptsresponse/$domain/$file >>endpoints/$domain/$file

    if [ ! -s endpoints/$domain/$file ]; then
      rm endpoints/$domain/$file
    fi
  done
done

print "Jsearch.py"
organitzationName= sed 's/.com//' <<<"$1"
print "Making directory javascript"
mkdir -p javascript

for domain in $(cat alive.txt); do
  NAME=$(echo $domain | awk -F/ '{print $3}')
  cd javascript/
  mkdir -p $NAME
  print "Searching JS files for $NAME"
  echo -e ""
  python3 $tooldir/jsearch/jsearch.py -u $domain -n "$organitzationName" | tee -a $NAME.txt

  if [ -z "$(ls -A $NAME/)" ]; then
    rmdir $NAME
    printW "No JS files for domain $domain"
  fi

  if [ ! -s $NAME.txt ]; then
    rm $NAME.txt
    printE "0 JS files found for domain $domain"
  fi

  # TODO WTF? Remove and rather cd to correct dir
  cd ..
done

#########FILES AND DIRECTORIES#########
# Todo change to ffuf
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 4: Starting Gobuster to find directories and hidden files"

mkdir -p directories

for domain in $(cat alive.txt); do
  NAME=$(echo $domain | awk -F/ '{print $3}')
  gobuster dir -u $domain -w $DIR_WORD_LIST -t $gobusterDirThreads -o directories/$NAME

  if [ ! -s directories/$NAME ]; then
    rm directories/$NAME
    printW "No valid paths found for domain $domain"
  fi
done

#########NMAP#########
echo -e ""
echo -e "${BOLD}${GREEN}[+]STEP 5: Starting NMAP Scan for alive domains"

mkdir -p nmap

# nmap all hosts
for domain in $(cat domains.txt); do
  nmap -sS -p- -T3 $domain -oG $LOGDIR/nmap/tmp/$domain.res
  # Only extracts open ports for further scanning, newline separated
  OPEN_PORTS=$(awk -F ":" '/open/{print $3}' $LOGDIR/nmap/tmp/$domain.res | grep -E -o "([0-9]{2,4})/open" | awk -F '/' '{print $1}')
  # get open ports as csv
  OPEN_PORTS_CSV=$(echo $OPEN_PORTS | tr '\n' ',')
  # in depth nmap of open ports only
  nmap -sC -sV -o -T2 -p $OPEN_PORTS_CSV -o $LOGDIR/nmap/$domain.res
done
print "NMAP done!"

print "Remove temporary directory NMAP"
rm -rf $LOGDIR/nmap/tmp/
check "Remove temporary directory NMAP"