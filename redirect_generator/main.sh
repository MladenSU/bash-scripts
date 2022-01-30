#!/bin/bash


# VARS #

R='\033[0;31m'
C='\033[1;36m'
Y='\033[1;33m'
G='\033[1;32m'
NC='\033[0m'

red_from="$1"
red_to="$2"

__usage="\n${C}Usage:
${G}bash -c \"\$(curl -s http://scripts.devsnull.com/generate_redirect.sh)\" -s ${Y}redirect_from.com redirect_to.com${NC}\n"

# END VARS #


function ok_prnt {
  echo -e "${3}${G}[+] ${C}${1} ${G}${2}${NC}"
}

function no_prnt {
  echo -e "${2}${R}[-] ${Y}${1}${NC}"
}

function flexy_color {
  echo -e "${!1}${@: 2}${NC}"
}

function red_gen {
curl -s 'http://redirect.devsnull.com/' \
  --data-raw "tabbed_rewrites=${red_from}+${red_to}&type=2&desc_comments=0" \
  --compressed \
  --insecure | egrep 'RewriteCond|RewriteRule' | cut -d '>' -f2
}

function exist_htaccess {
  httaccess=$(find . -maxdepth 1 -name ".htaccess" 2> /dev/null)
  test ! -z "${httaccess}" && ok_prnt ".htaccess:" "Located!" || { no_prnt "There is no .htaccess in the current folder! You're here - ${PWD}" ; exit 0 ; }
}

function box {
  text=${1}
  lines="-------------------------------------------"
  flexy_color "G" "${lines}\n${text}\n${lines}"
}

function proto_check {
  url=${1}
  var_name=${2}
  if ! [[ "${1}" =~ ^http.?:\/\/ ]]; then
    no_prnt "Detected that the provided URL (${url}) does not contain protocol. Automatically adding 'http://'"
    ok_prnt "Transformed:" "${url} -> http://${url}"
    export ${var_name}="http://${url}"
  fi
}

function build_urls {
  proto_check ${1} "red_from"
  proto_check ${2} "red_to"

}

function add_redirect {
  output=$(red_gen)
  ok_prnt "Result:"
  box "${output}"
  while true
  do
    read -n 1 -r -p "-- Shall I add it to the .htaccess? y/n: " ans
    if [[ "$(tr 'Y' 'y' <<< "${ans}")" == "y" ]]; then
      ok_prnt "Added to the .htaccess successfully!" "" "\n"
      echo -e "\n${output}" >> .htaccess
      break
    elif [[ "$(tr 'N' 'n' <<< "${ans}")" == "n" ]]; then
      ok_prnt "Aborting the process and NOT adding the rule in the .htaccess! Bye!" "" "\n"
      exit 0
    fi
  done
}



### MAIN ###

if [[ "$#" -lt 2 || "$#" -gt 2 ]]; then
	echo -e "${__usage}"
else
  exist_htaccess
  build_urls $red_from $red_to
  ok_prnt "Building redirect:" "$red_from -> $red_to "
  add_redirect
fi
