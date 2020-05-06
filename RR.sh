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

# today
todate=$(date +"%Y-%m-%d")
########################################

# Customizations
FFUF_Threads=50
gobusterDNSThreads=50
domain=
DEBUG=0
#----------------------
# Add go binaries
PATH=$PATH:/root/go/bin
#----------------------

#################################################
# MagicRecon
#----------------------
# 
githubToken=$(cat /root/Bug_Bounty/tools/github_token.txt)
#----------------------
subjackThreads=100
subjackTime=30
#aquatoneTimeout=50000
#----------------------

#COLORS
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
TURQ=$(tput setaf 6)
RESET=$(tput sgr0)

#------------------------------------------------------

usage() {
  echo "No arguments supplied, please supply a domain and optionally the base directory for results!"
  echo "Usage: ./RR.sh -u <domain> [-l Log Directory] [-d <anything>]"
  echo "[LOG Directory] needs to be a valid path"
  echo "[-d] will activate debugging - it needs some input to work!"
  exit 1
}

# Check that there is a domain supplied
while getopts ":u:d:l:" o; do
  case "${o}" in
  u)
    domain=${OPTARG}
    LOGDIR="/root/Bug_Bounty/logs/$domain/$todate"
    ;;
  l)
    LOGDIR=${OPTARG}
  ;;
  d)
    DEBUG=1
  ;;
  *)
    usage
    ;;
  esac
done

#Paths
TOOLDIR="/root/Bug_Bounty/tools"
RESDIR="/root/Bug_Bounty/reports/$domain/$todate"
DNS_WORD_LIST=$TOOLDIR/wordlists/SecLists/Discovery/DNS/namelist.txt
DIR_WORD_LIST=$TOOLDIR/wordlists/SecLists/Discovery/Web-Content/raft-medium-files-directories.txt
#----------------------

########################################
# Happy Hunting
########################################

#########################################
# Error handling and printing
########################################
# Print success
print() {
  echo -e "${BOLD}${GREEN}[+] $1 ${RESET}"
}

# Print warning
printW() {
  echo -e "${BOLD}${YELLOW}[?] $1 ${RESET}"
}

# Print error
printE() {
  echo -e "${BOLD}${RED}[!] $1 ${RESET}"
}

# Command counter
CMD=0
check() {
  if [[ $? == 0 ]]; then
    print "[$((CMD += 1))]${TURQ} $1 executed successfully!"
  else
    printE "[$((CMD += 1))] $1 encountered an error!"
  fi

  # Debugging
  if [ -z "$DEBUG" ];
  then
    echo -e "\n"
    read -p "Press enter to continue"
  fi
}
####################################

# clear screen
clear

echo -e "
__________        ___.    .__       /\\         __________
\______   \\  ____ \\_ |__  |__|  ____)/  ______ \\______   \\  ____   ____   ____    ____
 |       _/ /  _ \\ | __ \\ |  | /    \\  /  ___/  |       _/_/ __ \\_/ ___\\ /  _ \\  /    \\
 |    |   \\(  <_> )| \\_\\ \\|  ||   |  \\ \\___ \\   |    |   \\  ___/\\  \\___(  <_> )|   |  \\
 |____|_  / \\____/ |___  /|__||___|  //____  >  |____|_  / \\___  >\\___  >\\____/ |___|  /
        \\/             \\/          \\/      \\/          \\/      \\/     \\/             \\/
\n\n" | lolcat

echo -e "\n!################################!" | lolcat
echo -e "#### Target is $domain  ####" | lolcat
echo -e "#### Logdir is $LOGDIR  ####" | lolcat
echo -e "#### DEBUG is set to $DEBUG  ####" | lolcat
echo -e "!################################!\n\n" | lolcat

echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 1: Starting Subdomain Enumeration"

# Making directories
print "Creating directories"
mkdir -p "$LOGDIR"
mkdir -p "$RESDIR"
check "Creating directories"

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
python3 "$TOOLDIR/github-search/github-subdomains.py" -d "$1" -t "$githubToken" | tee -a "$LOGDIR/domains.txt"
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
subjack -w "$LOGDIR/domains.txt" -t "$subjackThreads" -timeout "$subjackTime" -ssl -c "/root/go/src/github.com/haccer/subjack/fingerprints.json" -v 3
check "Subjack"

#Removing duplicate entries
sort -u "$LOGDIR/domains.txt" -o "$LOGDIR/domains.txt"

#Discovering alive domains
echo -e ""
print " Checking for alive domains.."
# shellcheck disable=SC2002
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
# shellcheck disable=SC2002
cat "$LOGDIR/alive.txt" | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" > "$LOGDIR/alive.json"
check "Alive domains"

print "Get all domains"
# shellcheck disable=SC2002
cat "$LOGDIR/domains.txt" | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" > "$LOGDIR/domains.json"
check "All domains"

#########SUBDOMAIN HEADERS#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 2: Storing subdomain website_data (headers and body)"

WEBSITE_DATA="$LOGDIR/website_data"
print "mkdir website_data for headers & response bodies"
HEADERS="$WEBSITE_DATA/header" #headers from web page
mkdir -p "$HEADERS"
BODIES="$WEBSITE_DATA/body" # content of web page
mkdir -p "$BODIES"
check "mkdir website_data"

print "Gather website_data and responses"
# Extract website_data and bodies of all endpoints
touch "$LOGDIR/unresponsive.txt"
# extractHeadBody                                         #URL    #Output base folder
COMMAND="bash -c '$TOOLDIR/RR/support/extractHeadBody.sh _target_ $WEBSITE_DATA'"
interlace --silent -tL "$LOGDIR/alive.txt" -threads 50 -c "$COMMAND"
# Output is headers and data from each web page
# Output goes to $HEADERS and $BODIES
check "Interlace get headers and bodies"

# log errors for the above command
if [ ! -s "$LOGDIR/unresponsive.txt" ]; then
  printW "Unresponsive endpoints can be found in $LOGDIR/unresponsive.txt!"
fi

#########JAVASCRIPT FILES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 3: Collecting JavaScript files and Hidden Endpoints"

print "Making scripts directory"
SCRIPT_DIR="$LOGDIR/javascript"
mkdir -p "$SCRIPT_DIR"
SCRIPT_URL="$SCRIPT_DIR/URLS"
mkdir -p "$SCRIPT_URL"
SCRIPT_DATA="$SCRIPT_DIR/data"
check "Created JS folders"

# get all responses of script data
mkdir -p "$LOGDIR/tmp"
ls "$BODIES/" > "$LOGDIR/tmp/files.txt"
check "Get list of files with web page content"
# getResponses                                      #Base path #Filename #Output data #Output urls
COMMAND="bash -c '$TOOLDIR/RR/support/getResponses.sh $BODIES _target_ $SCRIPT_DATA $SCRIPT_URL'"
interlace --silent -tL "$LOGDIR/tmp/files.txt" -threads 50 -c "$COMMAND"
# Output is the URL for the scripts in $DATA files (web page content) and the actual script
# Output goes to $SCRIPT_URL and $SCRIPT_DATA
# $SCRIPT_URL contains a file pr. domain with Script URLS.
# $SCRIPT_DATA contains subfolders for each domain containing files named after the script with the content inside
check "Interlace extract script URLs from web page content and store the script contents"


ls "$SCRIPT_DATA" > "$LOGDIR/tmp/files2.txt"
JS_ENDPOINTS="$SCRIPT_DIR/Extracted_endpoints"
mkdir -p JS_ENDPOINTS
check "Create dir for extracted endpoints"

# Extractor script
EXTRACTOR="$TOOLDIR/relative-url-extractor/extract.rb"
# getURL                                         #Basepath   #Folder    #script   #output path
COMMAND="bash -c '$TOOLDIR/RR/support/getURL.sh $SCRIPT_DATA _target_ $EXTRACTOR $JS_ENDPOINTS/_target_'"
interlace --silent -tL "$LOGDIR/tmp/files2.txt" -threads 50 -c "$COMMAND"
# Output is all endpoints detected within each JS file for the current domain (folder)
# Output is stored in $JS_ENDPOINTS/_target_/<name-of-js-file>
check "Interlace extract endpoints from within found javascript files"

print "Jsearch.py"
organitzationName=$(echo "$domain" | awk -F '.' '{ print $1 }')
print "Making directory for javascript"
JSEARCH_DIR="$LOGDIR/jsearch"
mkdir -p "$JSEARCH_DIR"

# getJS                                        #domain     #Tool                      #Organization     #Output folder
COMMAND="bash -c '$TOOLDIR/RR/support/getJS.sh _target_ $TOOLDIR/jsearch/jsearch.py $organitzationName $JSEARCH_DIR'"
interlace --silent -tL "$LOGDIR/alive.txt" -threads 50 -c "$COMMAND"
# Output is all files related to the organization name from the current domain
# Output is stored in $JSEARCH_DIR/_target_/_target_.txt
check "Interlace get JS based on organization name from Jsearch"


#########FILES AND DIRECTORIES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 4: Starting FFUF to find directories and hidden files"

# Make a new logdir for ffuf results
FFUF_DIR="$LOGDIR/ffuf"
mkdir -p "$FFUF_DIR"

# FFUF Directory scan
# ffufDir                                         #domain  #Wordlist      # Threads     #Out dir
COMMAND="bash -c '$TOOLDIR/RR/support/ffufDir.sh _target_ $DIR_WORD_LIST $FFUF_Threads $FFUF_DIR'"
interlace --silent -tL "$LOGDIR/alive.txt" -threads 50 -c "$COMMAND"
check "Interlace ffuf"
# Output is found directories
# Output can be found in $LOGDIR/ffuf/domain.txt

# FFUF File extens --silention scan
# TODO dev

#########NMAP#########
echo -e ""
echo -e "${BOLD}${GREEN}[+]STEP 5: Starting NMAP Scan for alive domains"
NMAP_DIR="$LOGDIR/nmap"
mkdir -p "$NMAP_DIR"

# nmap all hosts
# nmapHost                                      #target url #Output dir
COMMAND="bash -c '$TOOLDIR/RR/support/nmapHost.sh _target_ $LOGDIR'"
interlace --silent -tL "$LOGDIR/domains.txt" -threads 50 -c "$COMMAND"
# Output is open ports
# Output can be found in $LOGDIR/nmap/_target_.res
check "Interlace NMAP scan"


print "Remove temporary directory"
rm -rf "$LOGDIR/tmp"
check "Remove temporary directory"

print "Move results to output folder"
cp -R "$LOGDIR" "$RESDIR"
check "Move results to output folder"

########################################

# Send over to LazyRecon for further processing
bash -c '"$TOOLDIR/lazyrecon/lazyrecon.sh" "$domain"'

