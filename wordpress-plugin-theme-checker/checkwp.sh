#!/bin/bash
#CREATED by Mladen

#Colors
R='\033[0;31m'
C='\033[0;36m'
Y='\033[1;33m'
G='\033[0;32m'
NC='\033[0m'

function _color {
        case $1 in
                red) color=1;;
                yellow) color=3;;
                green) color=2;;
        esac
        shift
        tput setaf ${color}
        echo -e "$*"
        tput sgr0
}

function l_info { _color green "$*"; }
function l_warn { _color yellow "$*"; }
function l_err  { _color red "$*"; }


echo -e "${G}\nSearching for WordPress application(s)...\n${NC}"

available_paths=$(find ~/ -name wp-config.php 2>/dev/null | sed 's/\/wp-config\.php//g')

declare -a doms
trap ctrl_c INT


function spacer {
    l_info "---------------------------------------------"
}
function ctrl_c() {
    clean_up
    exit 0
}

function getdom {
    gethome=$(wp --skip-plugins --skip-themes option get home --path=$1  2>/dev/null)
    if [[ -z "$gethome" ]];then
        echo "nofetchabbort"
    else
        spacer
        echo -e "${C}Domain: ${Y}$gethome${NC}"
        echo -e "${C}Path: ${Y}$path${NC}"
        corev=$(wp core version --skip-plugins --skip-themes --path=$1 2>/dev/null)
        isforup=$(wp core check-update  --skip-plugins --skip-themes --path=$1 2>/dev/null | awk '{print $1}' |tail -1)
        if [[ "${isforup::-1}" =~ "Success" ]];then
            echo -e "${C}WordPress core version: ${Y}$corev ${G}(Latest)${NC}"
        else
            echo -e "${C}WordPress core version: ${Y}$corev ${R}(Outdated) ${Y}- update to latest $isforup!${NC}"
        fi
        wp core verify-checksums --skip-plugins --skip-themes --path=$1 > /dev/null 2>&1
        if [[ $? == 0 ]];then
            echo -e "${C}Core verify-checksums: ${G}Yes (Success)${NC}"
        else
            echo -e "${C}Core verify-checksums: ${R}No (Error)${NC}"
        fi
        spacer
    fi
}

function getplug {
    l_info "[+] Plugins:"
    getupplug=$(wp --skip-plugins --skip-themes plugin list --fields=name,update --update=available --path=$1  2>/dev/null | grep -vE "^name\s" | awk '{print "\033[0;36mUpdate: \033[1;33m"$2,"|","\033[0;36mPlugin:\033[1;33m "$1"\033[0m"}' )
    if [[ -z "$getupplug" ]];then
        echo -e "${G} - All plugins are up to date!${NC}"
    else
        echo -e "$getupplug" | column -s "|" -t
    fi
}

function gettheme {
    l_info "\n[+] Themes"
    getuptheme=$(wp --skip-plugins --skip-themes theme list --fields=name,update --update=available --path=$1  2>/dev/null | grep -vE "^name\s" | awk '{print "\033[0;36mUpdate: \033[1;33m"$2,"|","\033[0;36mTheme:\033[1;33m "$1"\033[0m"}')
    if [[ -z "$getuptheme" ]];then
        echo -e "${G} - All themes are up to date!${NC}"
    else
        echo -e "$getuptheme" | column -s "|" -t
    fi
}

function clean_up {
    echo -e "\n${Y}[+] Cleaning up...${NC}"
    for loc in $available_paths; do
        sed -i '/VULN_API_TOKEN/d' ${loc}/wp-config.php
    done
    echo -e "${G}[+] Done${NC}"
}


function vulnscan {
    echo -e "\n${G}[+] Scanning for vulnerabilities...${NC}"
    echo -e "${Y}[-] Note that the scan will be false-positve if the WP core version is < 5.6!${NC}\n"
    if [[ ! $(wp vuln 2>/dev/null) ]];then
        wp --quiet package install https://github.com/10up/wpcli-vulnerability-scanner/archive/refs/heads/develop.zip
    fi

    TOKEN="define ('VULN_API_TOKEN', 'N2W8uynj22Povsf4kszpnCXQESpyzUzpvA0JznCvyLU');"
    for w in $available_paths; do
        echo $TOKEN >> ${w}/wp-config.php
    done

    vuln_plug=$(wp vuln plugin-status --porcelain --path=$1 --skip-plugins --skip-themes 2>/dev/null)
    vul_theme=$(wp vuln theme-status --porcelain --path=$1 --skip-plugins --skip-themes 2>/dev/null)

    if [[ -z "$vuln_plug" && -z "$vul_theme" ]];then
        echo -e "${G}[+] No vulnerabilities have been detected.${NC}"
        return 0
    fi

    if [[ -n "$vuln_plug" ]]; then
        echo -e "${Y}[-] Vulnerability detected in:${NC}"
        for p in $vuln_plug; do
            echo -e "${Y}Plugin: ${R}$p${NC}"
        done
    fi

    if [[ -n "$vul_theme" ]]; then
        echo -e "${Y}[-] Vulnerability detected in:${NC}"
        for t in $vul_theme; do
            echo -e "${Y}Theme: ${R}$t${NC}"
        done
    fi
}


if [[ -n $available_paths ]]; then
    echo -e "\n\t\t${C}Found ${Y}$(wc -l <<< "$available_paths") ${C}WordPress application(s)${NC}\n"
    for p in $available_paths; do
        conv=$(echo $p | tr "/" " " | awk '{print $4" - "$5"/"$6}')
        doms+=("${conv}")
    done
    doms+=("Check all applications.")
    doms+=("Exit")

    PS3='Select an application: '
    select opt in "${doms[@]}"; do
        domain="$opt"
        break
    done
    if [[ -z "$domain" ]]; then
	echo -e "${Y}[-] Your choice is either out of the list or below 0${NC}!"
        clean_up
        exit 0
    fi

    if [[ $domain =~ "Check all" ]];then
        l_info "\nChecking all applications ...\n"
        for path in $available_paths;do
            if [[ "$(getdom $path)" == "nofetchabbort" ]];then
                spacer
                echo -e "${R}[-] ${C}Domain: ${R}Could not fetch the domain. Either database error or missing entry!${NC}"
                echo -e "${C}[+] Path: ${Y}$path${NC}"
                spacer
            else
                getdom $path
                getplug $path
                gettheme $path
		#Remove due to API limits            vulnscan $path
            fi
            echo
        done
    elif [[ $domain == "Exit" ]]; then
        clean_up
        exit 0
    else
        grep -q "$SUB" <<< "$STR"
        conv_d=$(echo $domain | sed 's/\ - /\//g')
        echo -e "\n${G}Checking ${conv_d::-1} ...\n${NC}"
        for p in $available_paths; do
            if grep -q "/${conv_d::-1}" <<< "$p";then
                path=$p
            fi
        done

        if [[ "$(getdom $path)" == "nofetchabbort" ]];then
            spacer
            echo -e "${R}[-] ${C}Domain: ${R}Could not fetch the domain. Either database error or missing entry!${NC}"
            echo -e "${C}[+] Path: ${Y}$path${NC}"
            spacer
        else
            getdom $path
            getplug $path
            gettheme $path
#Remove due to API limits            vulnscan $path
        fi
    fi
else
    echo -e "${Y}[-] No WordPress applications were found! ${NC}"
fi
clean_up
