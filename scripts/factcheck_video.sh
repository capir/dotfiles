#!/usr/bin/env bash

youtube_transcript_api $1 --format text --language ro | fabric -p ~/.config/fabric/patterns/factcheck_video.md -v "LANGUAGE:Romanian"
