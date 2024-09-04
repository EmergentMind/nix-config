#!/bin/bash

### AUTHOR:         Johann Birnick (github: jbirnick)
### PROJECT REPO:   https://github.com/jbirnick/polybar-timer

## FUNCTIONS

now () { date --utc +%s; }

killTimer () { rm -rf /tmp/polybar-timer ; }
timerRunning () { [ -e /tmp/polybar-timer/ ] ; }

timerExpiry () { cat /tmp/polybar-timer/expiry ; }
timerLabel () { cat /tmp/polybar-timer/label ; }
timerAction () { cat /tmp/polybar-timer/action ; }

secondsLeft () { echo $(( $(timerExpiry) - $(now) )) ; }
minutesLeft () { echo $(( ( $(secondsLeft)  + 59 ) / 60 )) ; }

printExpiryTime () { dunstify -u low -r -12345 "Timer expires at $( date -d "$(secondsLeft) sec" +%H:%M)" ;}

deleteExpiryTime () { dunstify -C -12345 ; }

updateTail () {
  if timerRunning && [ $(minutesLeft) -le 0 ]
  then
    eval $(timerAction)
    killTimer
  fi

  if timerRunning
  then
    echo "$(timerLabel) $(minutesLeft)"
  else
    echo "${STANDBY_LABEL}"
  fi
}

## MAIN CODE

case $1 in
  tail)
    STANDBY_LABEL=$2

    trap updateTail USR1

    while true
     do
     updateTail
     sleep ${3} &
     wait
    done
    ;;
  update)
    kill -USR1 $(pgrep --oldest --parent ${2})
    ;;
  new)
    killTimer
    mkdir /tmp/polybar-timer
    echo "$(( $(now) + 60*${2} ))" > /tmp/polybar-timer/expiry
    echo "${3}" > /tmp/polybar-timer/label
    echo "${4}" > /tmp/polybar-timer/action
    printExpiryTime
    ;;
  increase)
    if timerRunning
    then
      echo "$(( $(cat /tmp/polybar-timer/expiry) + ${2} ))" > /tmp/polybar-timer/expiry
    else
      exit 1
    fi
    printExpiryTime
    ;;
  cancel)
    killTimer
    deleteExpiryTime
    ;;
  *)
    echo "Please read the manual at https://github.com/jbirnick/polybar-timer ."
    ;;
esac
