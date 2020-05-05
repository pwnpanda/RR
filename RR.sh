#!/bin/bash

################################################
# ///                                       \\\
#      You can edit your configuration here
#
#
################################################

########################################

# Startup checks
# check if running as root
if [ "$EUID" -ne 0 ]; then
  printE "Run as root!"
  exit
fi

########################################

# Check that there is a domain supplied
if [ $# -eq 0 ]
  then
    echo "No arguments supplied, please supply a domain!"
    exit
fi
# Domain is given
domain=$1
# today
todate=$(date +"%Y-%m-%d")
########################################

# Customizations
FFUF_Threads=50
#----------------------
domain=
#----------------------
TOOLDIR=/root/Bug_Bounty/tools
LOGDIR="/root/Bug_Bounty/logs/$domain/$todate"
RESDIR="/root/Bug_Bounty/reports/$domain/$todate"
gobusterDNSThreads=50
#----------------------
# Add go binaries
PATH=$PATH:/root/go/bin
#----------------------

#################################################
# MagicRecon
#----------------------
# TODO Remember to input your own token here
githubToken=YOUR GITHUB TOKEN
#----------------------
subjackThreads=100
subjackTime=30
#aquatoneTimeout=50000
#----------------------
#Paths
DNS_WORD_LIST=$TOOLDIR/SecLists/Discovery/DNS/namelist.txt
DIR_WORD_LIST=$TOOLDIR/SecLists/Discovery/Web-Content/raft-medium-files-directories.txt
#----------------------

#COLORS
BOLD="\e[1m"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)

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
  echo -e "${BOLD}${YELLOW}[?] $1"
}

# Print error
printE() {
  echo -e "${BOLD}${RED}[!] $1"
}

# Command counter
CMD=0
check() {
  if [[ $? == 0 ]]; then
    print " - [$((CMD += 1))] $1 executed successfully"
  else
    printE " - [$((CMD += 1))] $1 encountered an error"
  fi
}
####################################

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
amass enum -norecursive -noalts -d "$1" -o "$LOGDIR/domains.txt"
check "Amass"

#Crt.sh
print "Certsh"
python "$TOOLDIR/CertificateTransparencyLogs/certsh.py" -d "$1" | tee -a "$LOGDIR/domains.txt"
check "Certsh"

#Github-Search
print "Github-subdomains.py"
python3 "$TOOLDIR/github-search/github-subdomains.py" -d "$1" -t $"githubToken" | tee -a "$LOGDIR/domains.txt"
check "Github-subdomains.py"

#Gobuster
print "Gobuster DNS"
gobuster dns -d "$1" -w "$DNS_WORD_LIST" -t "$gobusterDNSThreads" -o "$LOGDIR/gobusterDomains.txt"
check "Gobuster DNS"
sed 's/Found: //g' "$LOGDIR/gobusterDomains.txt" >> "$LOGDIR/domains.txt"
rm "$LOGDIR/gobusterDomains.txt"

# Assetfinder
print "Assetfinder"
assetfinder --subs-only "$1" | tee -a "$LOGDIR/domains.txt"
check "Assetfinder"

# Subjack
print "Subjack for search subdomains takeover"
subjack -w "$LOGDIR/domains.txt" -t "$subjackThreads" -timeout "$subjackTime" -ssl -c "$TOOLDIR/subjack/fingerprints.json" -v 3
check "Subjack"

#Removing duplicate entries
sort -u "$LOGDIR/domains.txt" -o "$LOGDIR/domains.txt"

#Discovering alive domains
echo -e ""
print " Checking for alive domains.."
cat "$LOGDIR/domains.txt" | httprobe -c 50 -t 3000 | tee -a "$LOGDIR/alive.txt"
check "Alive domains with HTTProbe"

sort "$LOGDIR/alive.txt" | uniq -u

#Corsy
echo -e ""
print "Corsy to find CORS missconfigurations"
python3 "$TOOLDIR/Corsy/corsy.py" -i "$LOGDIR/alive.txt" -o "$LOGDIR/CORS.txt"
check "Corsy"

#Aquatone
# Already runs in lazyrecon, disable for now until integrated
#echo -e ""
#echo -e "${BOLD}${GREEN}[+] Starting Aquatone to take screenshots"

#mkdir -p "$LOGDIR/screenshots"
#check "mkdir screenshots"

#cat "$LOGDIR/alive.txt" | aquatone -screenshot-timeout "$aquatoneTimeout" -out "$LOGDIR/screenshots/"
#check "Aquatone"

#Parse data jo JSON

print "Finding alive domains"
cat "$LOGDIR/alive.txt" | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" > "$LOGDIR/alive.json"
check "Alive domains"

print "Get all domains"
cat "$LOGDIR/domains.txt" | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" > "$LOGDIR/domains.json"
check "All domains"

#########SUBDOMAIN HEADERS#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 2: Storing subdomain headers and response bodies"

print "mkdir headers"
mkdir -p "$LOGDIR/headers"
check "mkdir headers"

print "Gather headers and responses"
# Extract headers and bodies of all endpoints
# extractHeadBody
# TODO DEBUG
touch "$LOGDIR/unresponsive.txt"
interlace -tL "$LOGDIR/alive.txt" -threads 50 -cL "bash -c '$TOOLDIR/RR/support/extractHeadBody.sh _target_ $LOGDIR'"

# log errors for the above command
if [ ! -s "$LOGDIR/unresponsive.txt" ]; then
  printW "Unresponsive endpoints can be found in $LOGDIR/unresponsive.txt!"
fi

#########JAVASCRIPT FILES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 3: Collecting JavaScript files and Hidden Endpoints"

print "Making scripts directory"
mkdir -p "$LOGDIR/scripts"

print "Making scriptsresponse directory"
mkdir -p "$LOGDIR/scriptsresponse"

print "Making responsebody directory"
mkdir -p "$LOGDIR/responsebody"

# TODO DEBUG
# get all responses of script data
# getResponses.sh
ls "$LOGDIR/scriptsresponse" > "$LOGDIR/tmp/files.txt"
interlace -tL "$LOGDIR/tmp/files.txt" -c "bash -c '$TOOLDIR/RR/support/getResponses.sh _target__ $LOGDIR'"

# TODO DEBUG!
# getURL
ls "$LOGDIR/scriptsresponse" > "$LOGDIR/tmp/files2.txt"
interlace -tL "$LOGDIR/tmp/files2.txt" -c "bash -c '$TOOLDIR/RR/support/getURL.sh _target_ $LOGDIR $TOOLDIR/relative-url-extractor/extract.rb /scriptsresponse/_target_ /endpoints/_target_'"

print "Jsearch.py"
organitzationName=$(echo "$domain" | awk -F '.' '{ print $1 }')
print "Making directory for javascript"
JSFOLDER="$LOGDIR/javascript"
mkdir -p "$JSFOLDER"

# TODO DEBUG!
# getJS
interlace -tL "$LOGDIR/alive.txt" -c "bash -c '$TOOLDIR/RR/support/getJS.sh _target_ $TOOLDIR/jsearch/jsearch.py $organitzationName $JSFOLDER'"

#########FILES AND DIRECTORIES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 4: Starting FFUF to find directories and hidden files"

# Make a new logdir for ffuf results
mkdir -p "$LOGDIR/ffuf"

# FFUF Directory scan
# ffufDir
interlace -tL "$LOGDIR/alive.txt" -c "bash -c '$TOOLDIR/RR/support/ffufDir.sh _target_ $DIR_WORD_LIST $FFUF_Threads $LOGDIR'"

# FFUF File extension scan
# TODO

#########NMAP#########
echo -e ""
echo -e "${BOLD}${GREEN}[+]STEP 5: Starting NMAP Scan for alive domains"

mkdir -p "$LOGDIR/nmap"

# nmap all hosts
# nmapHost
# TODO DEBUG
interlace -tL "$LOGDIR/domains.txt" -c "bash -c '$TOOLDIR/RR/support/nmapHost.sh _target_ $LOGDIR'"
print "NMAP done!"

print "Remove temporary directory"
rm -rf "$LOGDIR/tmp"
check "Remove temporary directory"

########################################

# Send over to LazyRecon for further processing
"$TOOLDIR/lazyrecon/lazyrecon.sh $domain"