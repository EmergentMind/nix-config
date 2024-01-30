#!/usr/bin/env bash

if [ ! -z $1 ]; then
	export HOST=$1
else
	export HOST=$(hostname)
fi

sudo nixos-rebuild --impure --flake .#$HOST switch
