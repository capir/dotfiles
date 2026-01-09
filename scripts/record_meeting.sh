#!/bin/bash
#
# Usage: ./record_meeting.sh output.mp4
#        ./record_meeting.sh ~/Desktop/meeting.mp4
#
# Records macOS screen + microphone using ffmpeg (avfoundation).
# Make sure to check device indices with:
#   ffmpeg -f avfoundation -list_devices true -i ""
#

# ---- Config ----
FRAMERATE=30
VIDEO_DEVICE=1 # usually "Capture screen 0" (check list_devices output)
AUDIO_DEVICE=0 # usually "Built-in Microphone" or "BlackHole"
OUTPUT="$1"

if [[ -z "$OUTPUT" ]]; then
  echo "Usage: $0 output_file.mp4"
  exit 1
fi

ffmpeg -f avfoundation -framerate $FRAMERATE -i "$VIDEO_DEVICE:$AUDIO_DEVICE" \
  -c:v libx264 -preset veryfast -crf 23 \
  -c:a aac -b:a 128k \
  "$OUTPUT"
