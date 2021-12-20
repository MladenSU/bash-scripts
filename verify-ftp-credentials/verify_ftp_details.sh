#!/bin/bash

#Colors
R='\033[0;31m'
C='\033[0;36m'
Y='\033[1;33m'
G='\033[0;32m'
NC='\033[0m'

#Vars
username=$1
pass=$2
server=$3
__usage="${Y}[-] ${R}Usage: ${G}./$(basename $0) ${Y}ftp_username password server_or_ip${NC}"


#Check whether all args are supplied

if [[ $# -lt 3 ]]; then
	echo -e "${Y}[-] ${R}Not enough arguments supplied!${NC}\n${__usage}"
	exit 1
fi

#Sending the request
echo -e "${Y}[+] ${C}Testing the credentials...${NC}"
send_req=$(curl -s --connect-timeout 10 --insecure "ftp://${server}/" --user "${username}:${pass}")


if [[ -z "$send_req"  ]]; then
	echo -e "${Y}[-] ${R}Details are not correct!\n${Y}[-] ${R}Received an empty response.${NC}"
else
	echo -e "${Y}[+] ${G}Details are correct!\n${Y}[+] ${G}Proof:${NC}\n${send_req}"
fi
