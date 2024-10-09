#!/usr/bin/env bash
set -euo pipefail

#The echos are for debugging
#echo "ran" > ~/yubikey-down.log

rm ~/.ssh/{id_yubikey,id_yubikey.pub}

#The echo is for debugging
#echo "deleted" >> ~/yubikey-down.log
