#!/bin/bash
# Launch polybar across multiple monitors and reload on config change
# Ref: https://github.com/polybar/polybar/issues/763

# Run polybar --list-monitors to get monitor names used below
#
# Note: Default  log level is "notice" which prints every time a module or font is loaded so
# instantiating the main bar with "warning" to reduce log bloat. all other calls use -q to supress logging

# A space must preceed -z
if [ -z "$(pgrep -x polybar)" ]; then
  for m in $(polybar --list-monitors | cut -d":" -f1); do
    if [ $m == "DisplayPort-0" ]; then
      MONITOR=$m polybar --log=warning --reload main_bar &
#      MONITOR=$m polybar --log=warning --reload talon_bar &
    elif [ $m == "DisplayPort-1" ]; then
      MONITOR=$m polybar -q --reload left_bar &
    elif [ $m == "HDMI-A-0" ]; then
      MONITOR=$m polybar -q --reload right_bar &
    elif [ $m == "DisplayPort-2" ]; then
      MONITOR=$m polybar -q --reload upper_bar &
    else
      MONITOR=$m polybar -q --reload laptop_bar &
    fi
  done
else
  # Requires `enable-ipc=true` in polybar config
  polybar-msg cmd restart
fi
