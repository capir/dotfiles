#!/bin/bash

# Usage: ./label_video.sh input.mp4 "BEFORE"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <video_file> <label_text>"
  exit 1
fi

INPUT="$1"
LABEL="$2"
BASENAME=$(basename "$INPUT")
OUTPUT="${BASENAME%.*}-labeled.mp4"

# Use a common macOS font
FONT="/System/Library/Fonts/Supplemental/Arial Bold.ttf"

ffmpeg -i "$INPUT" -vf "drawtext=fontfile='$FONT': \
  text='$LABEL': \
  fontcolor=white:fontsize=48: \
  box=1:boxcolor=black@0.8:boxborderw=20: \
  x=(w-text_w)/2:y=h-text_h-80" -c:a copy "$OUTPUT"
