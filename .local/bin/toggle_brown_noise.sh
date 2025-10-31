#!/bin/bash

# Check if a sox process playing brown noise is already running
if pgrep -f "sox -n -d synth brownnoise" > /dev/null
then
    # If it's running, kill it
    pkill -f "sox -n -d synth brownnoise"
else
    # If it's not running, start it in the background
    sox -n -p synth brownnoise &
fi
