#!/bin/bash
# $1 is domain
# $2 is word list
# $3 is thread number
# $4 is log dir
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Get name
NAME=$(echo "$1" | awk -F/ '{print $3}')

# Change recursion depth due to long execution time
ffuf -s -u "$1/FUZZ" -recursion -recursion-depth=1 -c -e '/','._','~','_','-','.','0','1','~1','.1','2','.2','.3','.aro','.asp','.aspx','.bac','.backup','.bak','.bat','~bk', '_backup', '.cache','.cfm','.cgi','.com','.conf', '.dif','.dist','.dll','.download','.err','.exe','.git','.gpg','.gz','.htm','.html','.inc','.ini','.java','.json','.jsp','.jvs','.key','.log','.lst','.map','.old','.orig','.ovpn','.part','.php','.phtml','.pl','.priv','.rsa','.sav','.save','.save.1','.sh','.shtml','.sql','.sublime-project','.sublime-workspace','..swm','..swn','..swo','..swp','.swp','.tar','.tar.gz','.temp','.templ','.tmp','.txt''.vi','.wadl','.xml','.zip','.go','.wasm','.rar','' -w "$2" -t "$3" -fs 0 -of html -o "$4/$NAME.html"  &>/dev/null

if [ ! -s "$4/$NAME" ]; then
  rm -rf "$4/$NAME" > /dev/null
  echo -e "${BOLD}${YELLOW}[?] No valid paths found for domain $1${RESET}"
fi
