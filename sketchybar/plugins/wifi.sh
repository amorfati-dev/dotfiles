#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"
SSID=$(ipconfig getsummary en0 2>/dev/null | awk -F 'SSID : ' '/ SSID : / {print $2}')
if [ -n "$SSID" ]; then
  sketchybar --set $NAME icon=" " icon.color=$ACCENT label="$SSID"
else
  sketchybar --set $NAME icon=" " icon.color=$GREY label="off"
fi
