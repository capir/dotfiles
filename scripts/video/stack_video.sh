#!/bin/bash

# Usage: ./stack_video.sh left.mp4 right.mp4

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <left_video> <right_video>"
  exit 1
fi

LEFT="$1"
RIGHT="$2"

LEFT_BASENAME=$(basename "$LEFT")
RIGHT_BASENAME=$(basename "$RIGHT")
OUTPUT="stacked-${LEFT_BASENAME%.*}-${RIGHT_BASENAME%.*}.mp4"

# Target height and framerate
TARGET_HEIGHT=720
TARGET_FPS=30

ffmpeg -i "$LEFT" -i "$RIGHT" -filter_complex \
  "[0:v]scale=-1:${TARGET_HEIGHT},fps=${TARGET_FPS}[left]; \
 [1:v]scale=-1:${TARGET_HEIGHT},fps=${TARGET_FPS}[right]; \
 [left][right]hstack=inputs=2" \
  -c:a copy "$OUTPUT"
