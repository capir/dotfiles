#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <video_file>"
  exit 1
fi

FILE="$1"

ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,r_frame_rate,bit_rate \
  -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=0 "$FILE"
