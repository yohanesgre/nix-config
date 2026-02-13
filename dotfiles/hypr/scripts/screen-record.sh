#!/bin/bash

# Directory to save videos
SAVE_DIR="$HOME/Videos/Recordings"
mkdir -p "$SAVE_DIR"

FILENAME="$SAVE_DIR/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"

# Check if wf-recorder is already running
if pgrep -x "wf-recorder" > /dev/null; then
    killall -s SIGINT wf-recorder
    notify-send "Recording" "Stopped and saved to $SAVE_DIR" -i camera-video
else
    if [ "$1" == "region" ]; then
        notify-send "Recording" "Select a region to start" -i camera-video
        wf-recorder -g "$(slurp)" -f "$FILENAME" &
    else
        notify-send "Recording" "Full screen recording started" -i camera-video
        wf-recorder -f "$FILENAME" &
    fi
fi
