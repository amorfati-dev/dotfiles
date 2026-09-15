#!/usr/bin/env bash
[ "$SENDER" = "front_app_switched" ] && sketchybar --set front_app label="$INFO"
