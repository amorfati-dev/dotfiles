#!/usr/bin/env bash
# Listet alle offenen AeroSpace-Fenster und springt per fzf zum gewählten
aerospace list-windows --all --format '%{window-id} | %{app-name} | %{window-title}' \
  | fzf --reverse --border --prompt "  " \
        --height 100% \
  | awk '{print $1}' \
  | xargs -r aerospace focus --window-id
