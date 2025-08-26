#!/bin/zsh

PROFILE=$1
shift

PASS=$(pass show cli/db/$PROFILE | head -n 1)

mycli --password="$PASS" -d $PROFILE "$@"
