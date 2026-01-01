#!/bin/sh
set -u

printf "PDF password: "
stty -echo
read PASSWORD
stty echo
printf "\n"

find . -type f -name '*.pdf' ! -name 'd_*.pdf' | while IFS= read -r pdf; do
  out="$(dirname "$pdf")/d_$(basename "$pdf")"

  [ -f "$out" ] && continue

  printf 'Decrypting: %s\n' "$pdf"

  if qpdf --password="$PASSWORD" --decrypt "$pdf" "$out" 2>/dev/null; then
    :
  else
    printf 'FAILED (wrong password or unsupported): %s\n' "$pdf" >&2
    rm -f "$out"
  fi
done
