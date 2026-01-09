#!/bin/zsh

PROFILE=$1
shift

PASS=$(pass show cli/db/$PROFILE | head -n 1)

#echo $PASS

if [[ $# -eq 0 ]]; then
    mycli --password="$PASS" -d "$PROFILE"
else
    mycli --password="$PASS" -d "$PROFILE" -e "$@"
fi
