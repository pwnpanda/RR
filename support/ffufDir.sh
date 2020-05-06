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

ffuf -s -u "$1/FUZZ" -recursion -recursion-depth=5 -c -e '/','._','~','_','-','.','0','1','~1','.1','2','.2','.3','.aro','.asp','.aspx','.bac','.backup','.bak','.bat','~bk','.c','.cache','.cfm','.cgi','.com','.conf','.cs','.csproj','.dif','.dist','.dll','.download','.err','.exe','.git','.gpg','.gz','.htm','.html','.inc','.ini','.java','.jhtml','.jnlp','.jsa','.json','.jsp','.jvs','.key','.log','.lst','.map','.mdb','.nsf','.old','.orig','.ovpn','.part','.php','.phtml','.pl','.priv','.reg','.rej','.rsa','s','.sass-cache','.sav','.save','.save.1','.sh','.shtml','.sql','.sublime-project','.sublime-workspace','..swm','..swn','..swo','..swp','.swp','.tar','.tar.gz','.temp','.templ','.tmp','.txt','.un~','.vb','.vbproj','.vi','.wadl','.xml','.zip','.go','.wasm','.rar','' -w "$2" -t "$3" -fs 0 -of html -o "$4/$NAME"

if [ ! -s "$4/$NAME" ]; then
  rm "$4/$NAME"
  echo -e "${BOLD}${YELLOW}[?] No valid paths found for domain $1${RESET}"
fi