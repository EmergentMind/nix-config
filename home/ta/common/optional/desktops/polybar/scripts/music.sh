#!/bin/bash
# dependencies:
#     playerctl

exec 2>/dev/null

if [ "$(playerctl --ignore-player=firefox,chromium status)" = "Playing" ]; then
  title=`exec playerctl --ignore-player=firefox,chromium metadata xesam:title`
  artist=`exec playerctl --ignore-player=firefox,chromium metadata xesam:artist`
  echo "$artist - $title"
else
  echo "Nothing playing."
fi

