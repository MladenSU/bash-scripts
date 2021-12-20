#!/bin/bash

domain="$1"


#Colors
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLO='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

#DNSSec check
function dnssec { 
sec=$(whois $domain 2>/dev/null | grep -i DNSSEC)
while read line1 line2
do
	echo -e "${CYAN}$line1${NC} ${YELLO}$line2${NC}"
done <<< "$sec"


}

# Check the name servers
function nsrec { 
ns=$(dig NS +short $domain)
for rec in $ns
do
	if [[ "$ns" == *"siteground"* || "$ns" == *"sgvps"* ]]; then
		echo -e "${CYAN}NS${NC}: ${YELLO}$rec${NC} <--- ${GREEN}Seems to belong to us${NC}"
	else
		echo -e "${CYAN}NS${NC}: ${YELLO}$rec${NC}"
	fi
done
}

# Checking the domain IP address
function ipaddr { 
gogl=$(dig +short $domain | xargs -I{} host {} | grep -o google)
ip=$(dig A +short $domain)
	if [[ "$gogl" =~ "google" ]]; then
		echo -e "${CYAN}A${NC}: ${YELLO}$ip${NC} <--- ${GREEN}Seems to belong to us${NC}"
	else
		echo -e "${CYAN}A${NC}: ${YELLO}$ip${NC}"
	fi
}

# Check the www
function www_addr { 
www=$(dig +short www.$domain)
for rec2 in $www
do
echo -e "${CYAN}WWW${NC}: ${YELLO}$rec2${NC}"
done
}

# Usage
__usage="Usage: ${YELLO}./$(basename $0)${NC} ${CYAN}domain.tld${NC}
		      ${RED}^(Do not prepend www.)${NC}
${YELLO}The script will automatically check${NC} ${RED}www${NC} ${YELLO}as well.${NC}"

function spacer {
        echo "---------------------------------------";
}

function dns_aaaa {
aaaa=$(dig +short aaaa $domain)
	if [[ -z "$aaaa" ]]; then
		echo -e "${CYAN}AAAA${NC}: ${GREEN}No AAAA record found${NC}"
	else
		echo -e "${YELLO}Found AAAA record${NC}: ${RED}$aaaa${NC}"
	fi
}

if [[ ! "$domain" =~ ^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}$ || "$domain" =~ ^www\. ]]; then
 	echo -e "\n${RED}[-] "ERROR!${NC}""
  	echo -e "$__usage\n"
  	exit
else :
fi

ipaddr
www_addr
nsrec
dns_aaaa
dnssec
spacer
