#!/bin/bash

# Define the exact command string we're looking for
# The [p] is a trick to prevent pgrep from matching its own process
CMD_STRING="[p]lay -c 2 -n synth brownnoise vol 0.1"

# Check if the process is already running
if pgrep -f "$CMD_STRING" > /dev/null
then
    # If it's running, kill it
    pkill -f "$CMD_STRING"
else
    # If it's not running, start it in the background
    # We add &> /dev/null to silence any output from sox
    play -c 2 -n synth brownnoise vol 0.1 &> /dev/null &
fi
