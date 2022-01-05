#!/usr/bin/env bash

list_of_sites="$(tr ' ' '|' <<< ${@:1})"



while true; do
  all_tabs="$( osascript -e{'set text item delimiters to linefeed','tell app"google chrome"to title of tabs of window 1 as text'})"
  found_list=$(grep -iEo $list_of_sites <<< "$all_tabs")
  for app in $found_list
  do
    osascript -e "
      tell application \"Google Chrome\"
      set windowList to every tab of every window whose URL contain \"$app\"
      repeat with tabList in windowList
      set tabList to tabList as any
      repeat with tabItr in tabList
      set tabItr to tabItr as any
      delete tabItr
      end repeat
      end repeat
      end tell"
  done
  sleep 15
done
