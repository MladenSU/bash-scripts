#!/usr/bin/env bash

# COLORS
R='\033[0;31m'
C='\033[0;36m'
Y='\033[1;33m'
G='\033[1;32m'
DG='\033[1;30m'
W='\033[0;37m'
NC='\033[0m'

function ok_prnt {
  echo -e "${2}${G}[+] ${G}${1}${NC}"
}

function no_prnt {
  echo -e "${2}${R}[-] ${Y}${1}${NC}"
}

function flexy_color {
  echo -e "${!1}${@: 2}${NC}"
}
## END OF COLORS ##


function is_running { # Check whether the restricting script is running already and grabs the PID
  pid=$(ps aux | grep "[k]iller.sh" | awk '{print $2}' | tr '\n' ' '| sed 's/ $//')
  test ! -z "${pid}" && export script_pid=${pid}
}


function abort_script { # Kills the restricting script
  is_running
  if [[ ! -z "${script_pid}" ]]; then
    kill -9 ${script_pid}
    ok_prnt "Killed the running process(es) - ${script_pid}"
  else
    ok_prnt "No process detected, so nothing to do here. Bye!"
  fi
}


function verify_site { # Verifies that the site is not starting with dash which can break the -b option
  args=$@
  for item in $args; do
    [[ "$item" =~ ^- ]] && { no_prnt "One of the provided sites starts with dash which is not OK!" ; usage; exit ; }
  done
}


function call_killer { # Call the restricting script
  script_full_path=$(dirname "$0")
  verify_site $@
  test -z "$*" && { no_prnt "You did not provide website to be blocked!" ; usage ; exit ; }
  ok_prnt "Blocking - ${*}"
  (bash ${script_full_path}/killer.sh $@ &)
  ok_prnt "Done! The process is running in the background!"
}


function process_info { # Checks what exactly is being blocked at the moment. Used for the -s option.
  uniq_blocks=$(ps a | grep "[k]iller.sh" | awk '{for(i=7;i<=NF;i++) printf $i" "; print ""}' | tr ' ' '\n' | sort -u | grep -vE "^$" |tr '\n' ' ')
  test -z "$uniq_blocks" && ok_prnt "Not blocking any site(s) at the moment!" || ok_prnt "Currently blocking - ${uniq_blocks}"
}


function usage {
  __usage="\n Usage: ./$(basename $0) [-b] [-d] [-h] [-s]

  ---------------------------------
  -b | --block // Blocks given pages.
    Example:
    ./$(basename $0) -b facebook youtube ...
  ---------------------------------
  -d | --deactivate //  Kills currently running sessions of the script.
  ---------------------------------
  -h | --help // Displays the help message.
  ---------------------------------
  -s | --status  // Shows what the script is currently blocking.\n"

  flexy_color "C" "$__usage"
}


function auto_check { # Check if the process is running in the BG and ask the user whether he would like to stop it before proceed
  is_running
  if [[ ! -z "${script_pid}" ]]; then
    no_prnt "The script is already running in the background! To check what exactly is running please use the status option (-s | --status)"
    while true; do
      read -p "-- Would you like to abort it? (y/n): " ab_ans
      if [[ "${ab_ans}" == "y" ]]; then
        abort_script
        break
      elif [[ "${ab_ans}" == "n" ]]; then
        ok_prnt "OK! Continuing..."
        break
      else
        continue
      fi
    done
  fi
}

while [[ "${1}" =~ ^- && ! "${1}" == "--" ]]; do case $1 in
  -d | --deactivate )
    abort_script
    exit
    ;;

  -b | --block )
    shift;
    auto_check
    args=$@;
    call_killer $args
    ;;

  -s | --status )
    process_info
    ;;

  -h | --help )
    usage
    ;;
esac; shift; done
