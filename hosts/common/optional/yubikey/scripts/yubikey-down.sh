#!/usr/bin/env bash
set -euo pipefail

echo "ran" >/home/ta/yubikey-down.log
#rm /etc/ssh/{id_yubikey,id_yubikey.pub}
rm /home/ta/.ssh/{id_yubikey,id_yubikey.pub}

echo "deleted" >>/home/ta/yubikey-down.log
