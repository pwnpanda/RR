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
DEBUG=1
#----------------------
# Add go binaries and other binaries
PATH=$PATH:/root/go/bin:/snap/bin/:/usr/local/bin/
#----------------------

#################################################
# MagicRecon
#----------------------
# 
githubToken=$(cat /root/Bug_Bounty/tools/github_token.txt)
#----------------------
subjackThreads=100
subjackTime=30
INTERTHREADS=50
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
  echo "[-d] will activate debugging - it needs any input to work!"
  echo "[-t] will set threads for interlace!"
  exit 1
}

# Check that there is a domain supplied
if [ $# -lt 2 ]
  then
    usage
fi

set=0
# Check that there is a domain supplied
while getopts ":u:d:l:t:c:" o; do
  case "${o}" in
  u)
    domain=${OPTARG}
    LOGDIR="/var/www/h4x.fun/reports/$domain/$todate"
    ;;
  l)
    LOGDIR=${OPTARG}
    set=1
  ;;
  d)
    DEBUG=
  ;;
  c)
    INTERTHREADS=${OPTARG}
  ;;
  t)
    todate=${OPTARG}
    if [[ "$set" -eq 0 ]]; then
        LOGDIR="/var/www/h4x.fun/reports/$domain/$todate"
    else
        LOGDIR=$(echo $LOGDIR | sed 's:/*$::')
        LOGDIR="$LOGDIR/$todate"
    fi
    ;;
  *)
    usage
    ;;
  esac
done
shift $((OPTIND-1))

if [ -z "${domain}" ] || [ -z "${LOGDIR}" ]; then
  usage
fi

#Paths
TOOLDIR="/root/Bug_Bounty/tools"
RESDIR="/root/Bug_Bounty/reports/$domain"
DNS_WORD_LIST=$TOOLDIR/wordlists/SecLists/Discovery/DNS/namelist.txt
DIR_WORD_LIST=$TOOLDIR/wordlists/SecLists/Discovery/Web-Content/raft-medium-files-directories.txt
LOGFILE="$LOGDIR/RR_log.txt"
TMPDIR="/root/Bug_Bounty/tmp"
#----------------------

########################################
# Happy Hunting
########################################

#########################################
# Error handling and printing
########################################
# Print success
print() {
  echo -e "${BOLD}${GREEN}[+] $1 ${RESET}" | tee -a $LOGFILE
}

# Print warning
printW() {
  echo -e "${BOLD}${YELLOW}[?] $1 ${RESET}" | tee -a $LOGFILE
}

# Print error
printE() {
  echo -e "${BOLD}${RED}[!] $1 ${RESET}" | tee -a $LOGFILE
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
# clear
#echo -n '
#__________        ___.    .__       /\         __________
#\______   \  ____ \_ |__  |__|  ____)/  ______ \______   \  ____   ____   ____    ____
# |       _/ /  _ \ | __ \ |  | /    \  /  ___/  |       _/_/ __ \_/ ___\ /  _ \  /    \··
# |    |   \(  <_> )| \_\ \|  ||   |  \ \___ \   |    |   \\  ___/\  \___(  <_> )|   |  \·
# |____|_  / \____/ |___  /|__||___|  //____  >  |____|_  / \___  >\___  >\____/ |___|  /
#        \/             \/          \/      \/          \/      \/     \/             \/
#
#
#' | lolcat

if [[ $(echo -n "$LOGDIR" | wc -c) -gt 35 ]]; then
  PRETTY=$(echo -n "$LOGDIR" | tail -c 31)
  PRETTY="../~$PRETTY"
else
  PRETTY=$LOGDIR
fi
if [ -z "$DEBUG" ]; then
  DEBUGPRINT="ON"
else
  DEBUGPRINT="OFF"
fi

# Making directories
#print "Creating directories"
mkdir -p "$LOGDIR"
mkdir -p "$RESDIR"
mkdir -p "$TMPDIR"
check "Creating directories"


printf '%-10s %-67s %10s\n' " " "!############################################################!" " " | lolcat
printf '%-15s %-8s %-35s %8s %15s\n' " " "######" "Target is $domain" "######" " " | lolcat | tee -a $LOGFILE
printf '%-15s %-8s %-35s %8s %15s\n' " " "######" "Logdir is" "######" " " | lolcat | tee -a $LOGFILE
printf '%-15s %-8s %-35s %8s %15s\n' " " "######" "$PRETTY" "######" " " | lolcat | tee -a $LOGFILE
printf '%-15s %-8s %-35s %8s %15s\n' " " "######" "DEBUG is set to $DEBUGPRINT" "######" " " | lolcat | tee -a $LOGFILE
printf '%-10s %-67s %10s\n' " " "!############################################################!" " " | lolcat

echo "RESDIR is: $RESDIR & TOOLDIR is: $TOOLDIR" | tee -a $LOGFILE

echo -e "" | tee -a $LOGFILE
echo -e "${BOLD}${GREEN}[+] STEP 1: Starting Subdomain Enumeration" | tee -a $LOGFILE


#Amass
print "Starting Amass"
amass enum -norecursive -noalts -d "$domain" -o "$TMPDIR/domains.txt"
check "Amass"
# Moving results due to weird amass behaviour
print "Moving results"
cp "$TMPDIR/domains.txt" "$LOGDIR/domains.txt"
check "Move Amass results"

#Crt.sh
print "Certsh"
python "$TOOLDIR/CertificateTransparencyLogs/certsh.py" -d "$domain" | tee -a "$LOGDIR/domains.txt"
check "Certsh"

#Github-Search
print "Github-subdomains.py"
python3 "$TOOLDIR/github-search/github-subdomains.py" -d "$domain" -t "$githubToken" | tee -a "$LOGDIR/domains.txt"
check "Github-subdomains.py"

#Gobuster
print "Gobuster DNS"
gobuster dns -d "$domain" -w "$DNS_WORD_LIST" -t "$gobusterDNSThreads" -o "$LOGDIR/gobusterDomains.txt"
check "Gobuster DNS"
sed 's/Found: //g' "$LOGDIR/gobusterDomains.txt" >> "$LOGDIR/domains.txt"
rm "$LOGDIR/gobusterDomains.txt"

# Assetfinder
print "Assetfinder"
assetfinder --subs-only "$domain" | tee -a "$LOGDIR/domains.txt"
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
echo -e ""
echo -e "${BOLD}${GREEN}[+] Starting Eyewitness to take screenshots"
SCREENSHOTS="$LOGDIR/screenshots"
mkdir -p "$SCREENSHOTS"
check "mkdir screenshots"

print "Screenshotting with EyeWitness"
# Not needed --prepend-https adds http(S)//: to all URLS without it
$TOOLDIR/EyeWitness/Python/EyeWitness.py --web -f $LOGDIR/alive.txt -d $SCREENSHOTS --no-prompt --results 1
check "Eyewitness"

#cat "$LOGDIR/alive.txt" | aquatone -screenshot-timeout "$aquatoneTimeout" -out "$LOGDIR/screenshots/"
#check "Aquatone"

#Parse data to JSON

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
echo -e "${BOLD}${GREEN}[+] STEP 2: Storing subdomain website_data (headers and body)" | tee -a $LOGFILE

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
for entry in $(cat "$LOGDIR/alive.txt"); do
    $TOOLDIR/RR/support/extractHeadBody.sh $entry $WEBSITE_DATA &
done
#printW "DEBUG: $LOGDIR/alive.txt lines: $(cat $LOGDIR/alive.txt | wc -l)"
#COMMAND="$TOOLDIR/RR/support/extractHeadBody.sh _target_ $WEBSITE_DATA"
#interlace --silent -tL $LOGDIR/alive.txt -threads $INTERTHREADS -c "$COMMAND"
#interlace -tL $LOGDIR/alive.txt -threads $INTERTHREADS -c "$COMMAND"
# Output is headers and data from each web page
# Output goes to $HEADERS and $BODIES
check "Get headers and bodies"

# log errors for the above command
if [[ -s "$LOGDIR/unresponsive.txt" ]]; then
  printW "Unresponsive endpoints can be found in $LOGDIR/unresponsive.txt!"
fi

print "Wait for background processes to finish getting all data from webpages"
wait

#########JAVASCRIPT FILES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 3: Collecting JavaScript files and Hidden Endpoints" | tee -a $LOGFILE

print "Making scripts directory"
SCRIPT_DIR="$LOGDIR/javascript"
mkdir -p "$SCRIPT_DIR"
SCRIPT_URL="$SCRIPT_DIR/URLS"
mkdir -p "$SCRIPT_URL"
SCRIPT_DATA="$SCRIPT_DIR/data"
check "Created JS folders"

# get all responses of script data
ls "$BODIES/" > "$TMPDIR/files.txt"
check "Get list of files with web page content"
# getResponses                                      #Base path #Filename #Output data #Output urls
for entry in $(cat "$TMPDIR/files.txt"); do
    $TOOLDIR/RR/support/getResponses.sh $BODIES $entry $SCRIPT_DATA $SCRIPT_URL &
done
check "Extracting scripts URLs from webpage and store contents"
#COMMAND="$TOOLDIR/RR/support/getResponses.sh $BODIES _target_ $SCRIPT_DATA $SCRIPT_URL"
#interlace --silent -tL $LOGDIR/tmp/files.txt -threads $INTERTHREADS -c "$COMMAND"
# Output is the URL for the scripts in $DATA files (web page content) and the actual script
# Output goes to $SCRIPT_URL and $SCRIPT_DATA
# $SCRIPT_URL contains a file pr. domain with Script URLS.
# $SCRIPT_DATA contains subfolders for each domain containing files named after the script with the content inside
#check "Interlace extract script URLs from web page content and store the script contents"
print "Wait for content extraction to finish"
wait

ls "$SCRIPT_DATA" > "$TMPDIR/files2.txt"
JS_ENDPOINTS="$SCRIPT_DIR/Extracted_endpoints"
mkdir -p "$JS_ENDPOINTS"
check "Create dir for extracted endpoints"

# Extractor script
EXTRACTOR="$TOOLDIR/relative-url-extractor/extract.rb"
# getURL                                         #Basepath   #Folder    #script   #output path
for entry in $(cat "$TMPDIR/files2.txt"); do
    $TOOLDIR/RR/support/getURL.sh $SCRIPT_DATA $entry $EXTRACTOR $JS_ENDPOINTS/$entry $TMPDIR &
done
#COMMAND="$TOOLDIR/RR/support/getURL.sh $SCRIPT_DATA _target_ $EXTRACTOR $JS_ENDPOINTS/_target_ $TMPDIR"
#interlace --silent -tL $LOGDIR/tmp/files2.txt -threads $INTERTHREADS -c "$COMMAND"
# Output is all endpoints detected within each JS file for the current domain (folder)
# Output is stored in $JS_ENDPOINTS/_target_/<name-of-js-file>
check "Interlace extract endpoints from within found javascript files"

print "Jsearch.py"
organitzationName=$(echo "$domain" | awk -F '.' '{ print $domain }')
# Jsearch creates directory in pwd...so change to tmp dir!
PRE=$(pwd)
cd "$TMPDIR/"
check "Change pwd to tmp"

print "Making directory for javascript"
# Dir creation is by absolute path so no worries
JSEARCH_DIR="$LOGDIR/jsearch"
mkdir -p "$JSEARCH_DIR"

# getJS                                        #domain     #Tool                      #Organization     #Output folder
for entry in $(cat "$LOGDIR/alive.txt"); do
    $TOOLDIR/RR/support/getJS.sh $entry $TOOLDIR/jsearch/jsearch.py $organitzationName $JSEARCH_DIR &
done
#COMMAND="$TOOLDIR/RR/support/getJS.sh _target_ $TOOLDIR/jsearch/jsearch.py $organitzationName $JSEARCH_DIR"
#interlace --silent -tL $LOGDIR/alive.txt -threads $INTERTHREADS -c "$COMMAND"
# Output is all files related to the organization name from the current domain
# Output is stored in $JSEARCH_DIR/_target_/_target_.txt
check "Interlace get JS based on organization name from Jsearch"
# Change back to normal dir because Jsearch is done
cd "$PRE"
check "Move back to original directory"

#########FILES AND DIRECTORIES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 4: Starting FFUF to find directories and hidden files" | tee -a $LOGFILE

# Make a new logdir for ffuf results
FFUF_DIR="$LOGDIR/ffuf"
mkdir -p "$FFUF_DIR"

# FFUF Directory scan - Seems to often have issues, so run normally

# Slow version
run=0
for entry in $(cat "$LOGDIR/alive.txt"); do
    ((run++))
    $TOOLDIR/RR/support/ffufDir.sh $entry $DIR_WORD_LIST $FFUF_Threads $FFUF_DIR &
    check "FFUF as background task #$run"
    if [[ run > 4]]; then
        print "Hit 4 concurrent scans - waiting to not run out of memory"
        run=0
        wait
    fi
done
# Fast version
# ffufDir                                         #domain  #Wordlist      # Threads     #Out dir
#COMMAND="$TOOLDIR/RR/support/ffufDir.sh _target_ $DIR_WORD_LIST $FFUF_Threads $FFUF_DIR"
#interlace --silent -tL $LOGDIR/alive.txt -threads $INTERTHREADS -c "$COMMAND"
#check "Interlace ffuf"
# Output is found directories
# Output can be found in $LOGDIR/ffuf/domain.txt


#########NMAP#########
echo -e ""
echo -e "${BOLD}${GREEN}[+]STEP 5: Starting NMAP Scan for alive domains" | tee -a $LOGFILE
NMAP_DIR="$LOGDIR/nmap"
mkdir -p "$NMAP_DIR"

# nmap all hosts
# nmapHost                                      #target url #Output dir
for entry in $(cat "$LOGDIR/domains.txt"); do
    $TOOLDIR/RR/support/nmapHost.sh $entry $LOGDIR &
    check "NMAP as background task"
done

# COMMAND="$TOOLDIR/RR/support/nmapHost.sh _target_ $LOGDIR"
# interlace --silent -tL "$LOGDIR/domains.txt" -threads $INTERTHREADS -c "$COMMAND"
# Output is open ports
# Output can be found in $LOGDIR/nmap/_target_.res
# check "Interlace NMAP scan"
print "Waiting for all background processes to finish!"
wait

# Needs to be done AFTER lazyrecon...
# print "Move results to output folder"
# LOGDIR="/var/www/h4x.fun/reports/$domain/$todate"
# RESDIR="/root/Bug_Bounty/reports/$domain"
# cp -R $LOGDIR/* $RESDIR
# check "Move results to output folder"

# print "Remove screenshots from git repo"
# rm -rf "$RESDIR/screenshots"
# check "Removed screenshots from output"

#print "Move all files out of date-folder"
# TODO needs troubleshooting and verification!
# TODO investigate!
# /bin/cp -rf $RESDIR/recon-$todate/* $RESDIR
# check "Move files out of date-folder"
# printf "Remove date folder"
# rm -rf "$RESDIR/recon-$todate"
# check "Remove date folder"

##############Request Smuggling check#######################


########################################

#########Check for Open Redirects or SSRFs#################
# echo all domains
# run against ssrf_OR_Identifier.sh
echo "$LOGDIR/domains.txt" >> "$TMPDIR/all_domains.txt"
echo "$LOGDIR/$recon-$todate/alldomains.txt" >> "$TMPDIR/all_domains.txt"
echo "$TMPDIR/all_domains.txt" | sort | uniq >> "$LOGDIR/all_domains.txt"

for entry in $(cat "$LOGDIR/all_domains.txt"); do
    $TOOLDIR/RR/support/ssrf_OR_Identifier.sh "$entry" "http://ssrf.h4x.fun/x/n6Sfr?$entry"
    check "SSRF / OR identifier for $entry"
done
##############SQLi Check####################################
# TODO add tamperscripts
print "Make dir and run sqlmap"
mkdir -p $LOGDIR/sqlmap/
URLFILE="$LOGDIR/recon-$todate/wayback-data/waybackurls_clean.txt"
python $TOOLDIR/sqlmap-dev/sqlmap.py --batch -m $URLFILE --random-agent -o --smart --results-file=$LOGDIR/sqlmap/results.csv
check "Sqlmap"
########################################

# LazyRecon

# Done in scan.sh
# Send over to LazyRecon for further processing
# print "LazyRecon"
# $TOOLDIR/lazyrecon/lazyrecon.sh -d "$domain" | tee -a $LOGFILE
# check "LazyRecon"

print "Remove temporary dir"
rm -rf "$TMPDIR"
check "remove temporary dir"

