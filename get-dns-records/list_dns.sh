#!/bin/bash

#Easy dig made by Mladen Uzunov (beta version) release 24/Dec/2020

in_domain="$1"
domain=$(echo ${in_domain} | tr 'A-Z' 'a-z')


#Colors
R='\033[0;31m'
C='\033[0;36m'
Y='\033[1;33m'
G='\033[0;32m'
NC='\033[0m'
under=$(tput smul)
nounder=$(tput rmul)


function spacer { echo "---------------------------------------"; }

function a_record {
	get_a_record=$(dig A +short $domain)
	if [[ -n "${get_a_record}" ]]
  	then
  		for ip in $get_a_record
  		do
  			echo -e "${C}A:${NC}${G} $ip${NC}"
  		done
	elif [[ -z "${get_a_record}" ]]	
	then	
    	    echo -en "${C}A:${NC}${R} No A record/s was/were found${NC}\n"
	fi	
}

function mx_record {
	get_mx_record=$(dig mx +short $domain)
	if [[ -n "${get_mx_record}" ]]
  	then
  		while read priority rec
  		do
  			echo -e "${C}MX:${NC}${G} $priority $rec ${NC}"
  		done <<< "$get_mx_record"

	elif [[ -z "${get_mx_record}" ]]	
	then	
    	    echo -en "${C}MX:${NC}${R} No MX record/s was/were found${NC}\n"
	fi	
}

function ns_record {
	get_ns_record=$(dig ns +short $domain)
	if [[ -n "${get_ns_record}" ]]
  	then
  		for ns in $get_ns_record
  		do
  			echo -e "${C}NS:${NC}${G} $ns${NC}"
  		done
	elif [[ -z "${get_ns_record}" ]]	
	then	
    	    echo -en "${C}NS:${NC}${R} No Name Servers were found${NC}\n"
	fi	
}

function www_record {
	if [[ $(host www.$domain | head -1 | egrep -o 'alias|address') =~ "alias" ]]
	then 
		cname=$(dig +short cname www.$domain)
		for name in $cname
		do
		echo -e "${C}WWW:${NC}${G} $name${NC}"
		done
	elif [[ $(host $domain | head -1 | egrep -o 'alias|address') =~ "address" ]]
	then
		address=$(dig +short www.$domain)
		for add in $address
		do
		echo -e "${C}WWW:${NC}${G} $add${NC}"
		done
	else
		echo -en "${C}WWW:${NC}${R} Nothing found for www.$domain ${NC}\n"
	fi
}

function txt_record {

	get_txt_rec=$(dig +short txt $domain)
	while read line
	do
		if [[ -n "${line}" ]]
  		then
  			echo -e "${C}TXT:${NC}${G} $line${NC}"
		elif [[ -z "${line}" ]]
    	then
    	    echo -en "${C}TXT:${NC}${R} No TXT record/s was/were found${NC}\n"
		fi
	done <<< "$get_txt_rec"
}

function dnssec { 
	sec=$(whois $domain 2>/dev/null | grep -i DNSSEC)
	while read line1 line2
	do
		if [[ "$line2" =~ [Uu]nsigned ]]
		then
			echo -e "${C}$line1${NC} ${G}$line2${NC}"
		elif [[ -n "${line2}" ]]
		then
			echo -e "${C}$line1${NC} ${R}$line2${NC}"
		else 
			echo -en "${C}DNSSEC:${NC}${R} No DNSSEC record/s was/were found${NC}\n"
		fi
	done <<< "$sec"
}



__usage="Usage: ${Y}./$(basename $0)${NC} ${C}domain.tld${NC}
		    ${R}^(Do not prepend www.)${NC}
${Y}The script will automatically check${NC} ${R}www${NC} ${Y}as well.${NC}"


if [[  "$domain" =~ ^www\. || ! "$domain" =~ ^([a-z0-9]|xn--)+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,8}$ ]]; then
 	echo -e "\n${R}[-] "ERROR!"${NC}"
  	echo -e "$__usage\n"
  	exit
else 
	echo -e "\n${under}Domain${nounder}: ${Y}$domain${NC}"
	spacer
	a_record
	spacer
	www_record
	spacer
	ns_record
	spacer
	mx_record
	spacer
	txt_record
	spacer
	dnssec
	spacer
	echo
fi
