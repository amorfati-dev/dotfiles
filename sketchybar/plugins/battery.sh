#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"
P=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)
CHG=$(pmset -g batt | grep 'AC Power')
[ -z "$P" ] && exit 0
COL=$FG
if [ -n "$CHG" ]; then ICON=" "; COL=$GREEN
else
  case $P in
    100|9[0-9]|8[0-9]) ICON=" " ;;
    [6-7][0-9]) ICON=" " ;;
    [3-5][0-9]) ICON=" " ;;
    [1-2][0-9]) ICON=" "; COL=$YELLOW ;;
    *) ICON=" "; COL=$RED ;;
  esac
fi
sketchybar --set $NAME icon="$ICON" icon.color=$COL label="${P}%"
