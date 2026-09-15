#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"
FOCUSED=$(aerospace list-workspaces --focused)
NON_EMPTY=$(aerospace list-workspaces --monitor all --empty no)
for sid in $(seq 1 9); do
  if [ "$sid" = "$FOCUSED" ]; then
    sketchybar --set space.$sid drawing=on background.drawing=on background.color=$ACCENT icon.color=$BAR
  elif echo "$NON_EMPTY" | grep -qx "$sid"; then
    sketchybar --set space.$sid drawing=on background.drawing=off icon.color=$FG
  else
    sketchybar --set space.$sid drawing=off
  fi
done
