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
# change from 50 to not get oom killed
FFUF_Threads=30
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
	SAVEDIR="/var/www/h4x.fun/reports/$domain/$todate"
	;;
  l)
	SAVEDIR=${OPTARG}
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
		SAVEDIR="/var/www/h4x.fun/reports/$domain/$todate"
	else
		SAVEDIR=$(echo $SAVEDIR | sed 's:/*$::')
		SAVEDIR="$SAVEDIR/$todate"
	fi
	;;
  *)
	usage
	;;
  esac
done
shift $((OPTIND-1))

if [ -z "${domain}" ] || [ -z "${SAVEDIR}" ]; then
  usage
fi

#Paths
TOOLDIR="/root/Bug_Bounty/tools"
RESDIR="/root/Bug_Bounty/reports/$domain"
DNS_WORD_LIST=$TOOLDIR/wordlists/SecLists/Discovery/DNS/namelist.txt
DIR_WORD_LIST=$TOOLDIR/wordlists/SecLists/Discovery/Web-Content/raft-medium-files-directories.txt
TMPDIR="/root/Bug_Bounty/tmp/$domain"
LOGS="$SAVEDIR/logs"
LOGFILE="$LOGS/RR_log.txt"
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

if [[ $(echo -n "$SAVEDIR" | wc -c) -gt 35 ]]; then
  PRETTY=$(echo -n "$SAVEDIR" | tail -c 31)
  PRETTY="../~$PRETTY"
else
  PRETTY=$SAVEDIR
fi
if [ -z "$DEBUG" ]; then
  DEBUGPRINT="ON"
else
  DEBUGPRINT="OFF"
fi

# Making directories
#print "Creating directories"
mkdir -p "$SAVEDIR"
mkdir -p "$RESDIR"
mkdir -p "$TMPDIR"
mkdir -p "$LOGS"
check "Creating directories"


printf '%-10s %-67s %10s\n' " " "!############################################################!" " " | lolcat
printf '%-15s %-8s %-35s %8s %15s\n' " " "######" "Target is $domain" "######" " " | lolcat | tee -a $LOGFILE
printf '%-15s %-8s %-35s %8s %15s\n' " " "######" "Savedir is" "######" " " | lolcat | tee -a $LOGFILE
printf '%-15s %-8s %-35s %8s %15s\n' " " "######" "$PRETTY" "######" " " | lolcat | tee -a $LOGFILE
printf '%-15s %-8s %-35s %8s %15s\n' " " "######" "DEBUG is set to $DEBUGPRINT" "######" " " | lolcat | tee -a $LOGFILE
printf '%-10s %-67s %10s\n' " " "!############################################################!" " " | lolcat

echo "RESDIR is: $RESDIR & TOOLDIR is: $TOOLDIR" | tee -a $LOGFILE

# TODO Run lazyrecon first
# TODO output to separate logfile
# LazyRecon

# Done in scan.sh
# Send over to LazyRecon for further processing
# print "LazyRecon"
# $TOOLDIR/lazyrecon/lazyrecon.sh -d "$domain" | tee -a $LOGFILE
# check "LazyRecon"

echo -e "" | tee -a $LOGFILE
echo -e "${BOLD}${GREEN}[+] STEP 1: Starting Subdomain Enumeration" | tee -a $LOGFILE


#Amass
print "Starting Amass"
amass enum -norecursive -noalts -d "$domain" -o "$TMPDIR/domains.txt"
check "Amass"
# Moving results due to weird amass behaviour
amass enum -norecursive -noalts #-dprint "Moving results"
# TODO check change where the above ending was commented out due to error
cp "$TMPDIR/domains.txt" "$SAVEDIR/domains.txt"
check "Move Amass results"

#Crt.sh
print "Certsh"
python "$TOOLDIR/CertificateTransparencyLogs/certsh.py" -d "$domain" | tee -a "$SAVEDIR/domains.txt"
check "Certsh"

#Github-Search
print "Github-subdomains.py"
python3 "$TOOLDIR/github-search/github-subdomains.py" -d "$domain" -t "$githubToken" >> "$SAVEDIR/domains.txt"
check "Github-subdomains.py"

#Gobuster
print "Gobuster DNS"
gobuster dns -d "$domain" -w "$DNS_WORD_LIST" -t "$gobusterDNSThreads" -o "$SAVEDIR/gobusterDomains.txt"
check "Gobuster DNS"
sed 's/Found: //g' "$SAVEDIR/gobusterDomains.txt" >> "$SAVEDIR/domains.txt"
rm "$SAVEDIR/gobusterDomains.txt"

# Assetfinder
print "Assetfinder"
assetfinder --subs-only "$domain" >> "$SAVEDIR/domains.txt"
check "Assetfinder"

# Subjack
print "Subjack for search subdomains takeover"
subjack -w "$SAVEDIR/domains.txt" -t "$subjackThreads" -timeout "$subjackTime" -ssl -c "/root/go/src/github.com/haccer/subjack/fingerprints.json" -v 3 >> "$SAVEDIR/subjack.txt"
check "Subjack"
cat "$SAVEDIR/subjack.txt" | grep -v "[Not Vulnerable]" >> "$SAVEDIR/subjack_vuln.txt"
lines=$(wc -l "$SAVEDIR/subjack_vuln.txt" | cut -d' ' -f1)
if [ $lines -gt 0 ];
then
	python3 /root/slackboth/alert.py "Subdomain vulnerable to hijacking! Check $SAVEDIR/subjack_vuln.txt"
fi

#Removing duplicate entries
sort -u "$SAVEDIR/domains.txt" -o "$SAVEDIR/domains.txt"

# Store domains.txt as a list of all discoveries
cp "$SAVEDIR/domains.txt" "$SAVEDIR/domains_full.txt"

#Removing out of scope domains
print "Removing out of scope domains"
python3 "$TOOLDIR/RR/support/scope/out_of_scope.py" "$domain" "$SAVEDIR/domains.txt" > "$LOGS/out_of_scope.txt"
res=$?
check "Remove out of scope domains"
# No data exists or was written for new domains, so skip overwriting!
if [ $res -ne 0 ];
	then
	print "move old results and use new"
	mv -f "$SAVEDIR/domains.txt_new" "$SAVEDIR/domains.txt"
	check "Overwrite results file with new data"
fi

# Create file with all gathered domains from LazyRecon & RR
cat "$SAVEDIR/domains.txt" >> "$TMPDIR/all_domains.txt"
cat "$SAVEDIR/recon-$todate/alldomains.txt" >> "$TMPDIR/all_domains.txt"
cat "$TMPDIR/all_domains.txt" | sort | uniq >> "$SAVEDIR/all_domains.txt"

#Discovering alive domains
echo -e ""
print " Checking for alive domains.."
# shellcheck disable=SC2002
cat "$SAVEDIR/domains.txt" | httprobe -c 50 -t 3000 >> "$SAVEDIR/alive.txt"
check "Alive domains with HTTProbe"

sort "$SAVEDIR/alive.txt" | uniq > "$SAVEDIR/alive.txt_2"
mv -f "$SAVEDIR/alive.txt_2" "$SAVEDIR/alive.txt"

#Corsy
echo -e ""
print "Corsy to find CORS missconfigurations"
python3 "$TOOLDIR/Corsy/corsy.py" -i "$SAVEDIR/alive.txt" -o "$SAVEDIR/CORS.txt"
check "Corsy"

#Aquatone
# Already runs in lazyrecon, disable for now until integrated
echo -e ""
echo -e "${BOLD}${GREEN}[+] Starting Eyewitness to take screenshots"
SCREENSHOTS="$SAVEDIR/screenshots"
mkdir -p "$SCREENSHOTS"
check "mkdir screenshots"

print "Screenshotting with EyeWitness"
# Not needed --prepend-https adds http(S)//: to all URLS without it
$TOOLDIR/EyeWitness/Python/EyeWitness.py --web -f $SAVEDIR/alive.txt -d $SCREENSHOTS --no-prompt --results 1 >> "$LOGS/eyewitness.log"
check "Eyewitness"

#cat "$SAVEDIR/alive.txt" | aquatone -screenshot-timeout "$aquatoneTimeout" -out "$SAVEDIR/screenshots/"
#check "Aquatone"

#Parse data to JSON

print "Storing alive domains as JSON"
# shellcheck disable=SC2002
cat "$SAVEDIR/alive.txt" | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" > "$SAVEDIR/alive.json"
check "Alive domains"

print "Storing all domains as JSON"
# shellcheck disable=SC2002
cat "$SAVEDIR/domains.txt" | python -c "import sys; import json; print (json.dumps({'domains':list(sys.stdin)}))" > "$SAVEDIR/domains.json"
check "All domains"

#########SUBDOMAIN HEADERS#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 2: Storing subdomain website_data (headers and body)" | tee -a $LOGFILE

WEBSITE_DATA="$SAVEDIR/website_data"
print "mkdir website_data for headers & response bodies"
HEADERS="$WEBSITE_DATA/header" #headers from web page
mkdir -p "$HEADERS"
BODIES="$WEBSITE_DATA/body" # content of web page
mkdir -p "$BODIES"
check "mkdir website_data"

print "Gather website_data and responses"
# Extract website_data and bodies of all endpoints
touch "$SAVEDIR/unresponsive.txt"
# extractHeadBody                                         #URL    #Output base folder
for entry in $(cat "$SAVEDIR/alive.txt"); do
	$TOOLDIR/RR/support/extractHeadBody.sh $entry $WEBSITE_DATA &
done
#printW "DEBUG: $SAVEDIR/alive.txt lines: $(cat $SAVEDIR/alive.txt | wc -l)"
#COMMAND="$TOOLDIR/RR/support/extractHeadBody.sh _target_ $WEBSITE_DATA"
#interlace --silent -tL $SAVEDIR/alive.txt -threads $INTERTHREADS -c "$COMMAND"
#interlace -tL $SAVEDIR/alive.txt -threads $INTERTHREADS -c "$COMMAND"
# Output is headers and data from each web page
# Output goes to $HEADERS and $BODIES
check "Get headers and bodies"

# log errors for the above command
if [[ -s "$SAVEDIR/unresponsive.txt" ]]; then
  printW "Unresponsive endpoints can be found in $SAVEDIR/unresponsive.txt!"
fi

print "Wait for background processes to finish getting all data from webpages"
wait

#########JAVASCRIPT FILES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 3: Collecting JavaScript files and Hidden Endpoints" | tee -a $LOGFILE

print "Making scripts directory"
SCRIPT_DIR="$SAVEDIR/javascript"
mkdir -p "$SCRIPT_DIR"
SCRIPT_URL="$SCRIPT_DIR/URLS"
mkdir -p "$SCRIPT_URL"
SCRIPT_DATA="$SCRIPT_DIR/data"
check "Created JS folders"

# get all responses of script data
ls "$BODIES/" > "$TMPDIR/files.txt"
check "Get list of files with web page content"
# getResponses                                      #Base path #Filename #Output data #Output urls #Logdir
for entry in $(cat "$TMPDIR/files.txt" | sort | uniq ); do
	$TOOLDIR/RR/support/getResponses.sh $BODIES $entry $SCRIPT_DATA $SCRIPT_URL $LOGS &
done
check "Extracting scripts URLs from webpage and store contents"
#COMMAND="$TOOLDIR/RR/support/getResponses.sh $BODIES _target_ $SCRIPT_DATA $SCRIPT_URL"
#interlace --silent -tL $SAVEDIR/tmp/files.txt -threads $INTERTHREADS -c "$COMMAND"
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
# getURL                                         #Basepath   #Folder    #script   #outputpath #logdir
for entry in $(cat "$TMPDIR/files2.txt" | sort | uniq ); do
	$TOOLDIR/RR/support/getURL.sh $SCRIPT_DATA $entry $EXTRACTOR $JS_ENDPOINTS/$entry $LOGS &
done
#COMMAND="$TOOLDIR/RR/support/getURL.sh $SCRIPT_DATA _target_ $EXTRACTOR $JS_ENDPOINTS/_target_ $TMPDIR"
#interlace --silent -tL $SAVEDIR/tmp/files2.txt -threads $INTERTHREADS -c "$COMMAND"
# Output is all endpoints detected within each JS file for the current domain (folder)
# Output is stored in $JS_ENDPOINTS/_target_/<name-of-js-file>
check "Extract endpoints from within found javascript files"

print "Jsearch.py"
organitzationName=$(echo "$domain" | awk -F '.' '{ print $domain }')
# Jsearch creates directory in pwd...so change to tmp dir!
PRE=$(pwd)
cd "$TMPDIR/"
check "Change pwd to tmp"

print "Making directory for javascript"
# Dir creation is by absolute path so no worries
JSEARCH_DIR="$SAVEDIR/jsearch"
mkdir -p "$JSEARCH_DIR"

run=0
# getJS                                        #domain     #Tool    #Organization     #Output folder #logdir
for entry in $(cat "$SAVEDIR/alive.txt" | sort | uniq ); do
	((run++))
	$TOOLDIR/RR/support/getJS.sh $entry $TOOLDIR/jsearch/jsearch.py $organitzationName $JSEARCH_DIR $LOGS &
	if [ $run -gt 10 ]; then
		print "Hit 10 concurrent scans - waiting to not run out of memory"
		run=0
		wait
	fi
done
print "Waiting for last getJS execution"
wait
#COMMAND="$TOOLDIR/RR/support/getJS.sh _target_ $TOOLDIR/jsearch/jsearch.py $organitzationName $JSEARCH_DIR"
#interlace --silent -tL $SAVEDIR/alive.txt -threads $INTERTHREADS -c "$COMMAND"
# Output is all files related to the organization name from the current domain
# Output is stored in $JSEARCH_DIR/_target_/_target_.txt
check "Get JS based on organization name from Jsearch"
# Change back to normal dir because Jsearch is done
cd "$PRE"
check "Move back to original directory"

#########FILES AND DIRECTORIES#########
echo -e ""
echo -e "${BOLD}${GREEN}[+] STEP 4: Starting FFUF to find directories and hidden files" | tee -a $LOGFILE

# Make a new logdir for ffuf results
FFUF_DIR="$SAVEDIR/ffuf"
mkdir -p "$FFUF_DIR"

# FFUF Directory scan - Seems to often have issues, so run normally

# Slow version
run=0
for entry in $(cat "$SAVEDIR/alive.txt" | sort | uniq ); do
	((run++))
	$TOOLDIR/RR/support/ffufDir.sh "$entry" "$DIR_WORD_LIST" "$FFUF_Threads" "$FFUF_DIR" &
	check "FFUF as background task $run"
	if [ $run -gt 3 ]
	then
		print "Hit 4 concurrent scans - waiting to not run out of memory"
		run=0
		wait
	fi
done
print "Waiting for last ffuf scans"
wait
# Fast version
# ffufDir                                         #domain  #Wordlist      # Threads     #Out dir
# COMMAND="$TOOLDIR/RR/support/ffufDir.sh _target_ $DIR_WORD_LIST $FFUF_Threads $FFUF_DIR"
# interlace --silent -tL $SAVEDIR/alive.txt -threads $INTERTHREADS -c "$COMMAND"
# check "Interlace ffuf"
# Output is found directories
# Output can be found in $SAVEDIR/ffuf/domain.txt


#########NMAP#########
echo -e ""
echo -e "${BOLD}${GREEN}[+]STEP 5: Starting NMAP Scan for alive domains" | tee -a $LOGFILE
NMAP_DIR="$SAVEDIR/nmap"
mkdir -p "$NMAP_DIR"
mkdir -p "$LOGS/NMAP"

# nmap all hosts
# Need to make nmap less intrusive on all hosts?
# nmapHost                                      #target url #Output dir
run=0
# Set newline to be separator
# IFS=" "
OIFS=$IFS
IFS="
"
for entry in $(cat "$SAVEDIR/recon-$todate/mass.txt" | sort | uniq ); do
	#echo $entry
	domaindot=$(echo $entry | awk -F " " '{print $1}')
	domain=${domaindot::-1}
	#echo "domaindot: $domaindot domain : $domain"
	dnstype=$(echo $entry | awk -F " " '{print $2}'| tr -d '[:space:]')
	#echo "DNSTYPE: $dnstype"
	ip=""
	if [[ $dnstype == "CNAME" ]];
		then
		name=$(echo $entry | awk -F " " '{print $3}')
		ipall=$(host $name | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
		ip=$(echo $ipall | awk -F " " '{print $1}')
		#echo "IP: $ip"
	elif [[ $dnstype == "A" ]];
		then
		ip=$(echo $entry | awk -F " " '{print $3}')
		#echo "IP: $ip"
	else
		echo "Unknown record type: $dnstype for entry $entry" | tee -a "$LOGS/NMAP/unknown_dns.txt"
	fi

	((run++))
	if [[ ! -z "$ip" ]];
		then
		$TOOLDIR/RR/support/nmapHost.sh "$domain" "$NMAP_DIR" "$TMPDIR" "$LOGS/NMAP" "$ip" &
		check "NMAP as background task"
		if [ $run -gt 10 ]
			then
			print "Hit 10 concurrent scans - waiting to not run out of memory"
			run=0
			wait
		fi
	fi
done
print "Waiting for last nmap scans"
wait
# Restore normal functionality
IFS=$OIFS
# COMMAND="$TOOLDIR/RR/support/nmapHost.sh _target_ $SAVEDIR"
# interlace --silent -tL "$SAVEDIR/domains.txt" -threads $INTERTHREADS -c "$COMMAND"
# Output is open ports
# Output can be found in $SAVEDIR/nmap/_target_.res
# check "Interlace NMAP scan"
print "Waiting for all background processes to finish!"
wait


##############Request Smuggling check#######################
# Scan all alive hosts
# TODO
# OPTIONS -> Returns allowed endpoints
# identify allowed http verbs
# then test with all verbs
# Test all endpoints? Seems like too much traffic

print "Check request smuggling"
mkdir -p "$SAVEDIR/smuggling"
# TODO Debug issue here!
echo "DEBUG MARK"
echo $(ls -la $SAVEDIR/smuggling)
run=0
for entry in $(cat "$SAVEDIR/alive.txt" | sort | uniq ); do
	((run++))
	# Have to remove invalid path characters (//)
	SMUGLOG=$(echo "$SAVEDIR/smuggling/$entry-logfile.txt" | sed 's~http[s]*://~~g')
	python3 $TOOLDIR/smuggler/smuggler.py -m POST -u "$entry" -l "$SMUGLOG" &
	python3 $TOOLDIR/smuggler/smuggler.py -m GET -u "$entry" -l "$SMUGLOG" &
	python3 $TOOLDIR/smuggler/smuggler.py -m PUT -u "$entry" -l "$SMUGLOG" &
	python3 $TOOLDIR/smuggler/smuggler.py -m DELETE -u "$entry" -l "$SMUGLOG" &
	check "Request smuggling"
	if [ $run -gt 6 ]
		then
			print "Hit 6(*4) concurrent scans - waiting to not run out of memory"
			run=0
			wait
	fi
done
print "Waiting for all background processes to finish!"
wait
########################################

#################XSStrike####################################
# Use Nuclei & Templates instead?
# - Extendable
# - Customizable
# - Easy to control

# Poor performance! Want better tool! :(

# python xsstrike.py --seeds /var/www/h4x.fun/reports/finn.no/2020-05-27/recon-2020-05-27/wayback-data/waybackurls_clean.txt --file-log-level INFO --log-file output.txt --skip
# TODO implement
########################################

#########Check for Open Redirects or SSRFs#################

# echo all domains
# run against ssrf_OR_Identifier.sh
print "SSRF / OR script"
mkdir -p $SAVEDIR/ssrf
mkdir -p "$LOGS/ssrf"

# check using script from Twitter
for entry in $(cat "$SAVEDIR/all_domains.txt"); do
	$TOOLDIR/RR/support/ssrf_OR_Identifier.sh "$entry" "http://ssrf.h4x.fun/x/pqCLV?$entry" "$SAVEDIR/ssrf" "$TMPDIR" "$LOGS/ssrf"
	check "SSRF / OR identifier for $entry"
done

# Check using SSRFire
# Run against domain
print "SSRFire"
mkdir -p $SAVEDIR/ssrf/ssrfire
# SSRFire will automatically add test url to callback
# Simple requests using cleaned lists! 
bash -c "BASH_ENV=/root/Bug_Bounty/tools/SSRFire/.profile $TOOLDIR/SSRFire/ssrfire.sh -d $domain -s http://ssrf.h4x.fun/x/pqCLV" >> "$SAVEDIR/ssrf/ssrfire/log.txt"
check "SSRFire"
cp -r $TOOLDIR/SSRFire/output/$domain/* $SAVEDIR/ssrf/ssrfire
check "Copy results ssrfire"
rm -rf $TOOLDIR/SSRFire/output/$domain
check "Remove results ssrfire in tooldir"

##############SQLi Check####################################
# TODO add tamperscripts

# TODO check data generated with sqlmap
print "Make dir and run sqlmap"
mkdir -p $SAVEDIR/sqlmap/
URLFILE="$SAVEDIR/vuln_specific_lists/sqli.txt"
python $TOOLDIR/sqlmap-dev/sqlmap.py --batch -m $URLFILE --random-agent -o --smart --results-file=$SAVEDIR/sqlmap/results.csv >> $SAVEDIR/sqlmap/sqlmap_log.txt
check "Sqlmap"
########################################


