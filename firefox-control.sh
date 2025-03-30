#!/usr/bin/env bash

# Use xdotool to change the current Firefox URL to a new one.

URL="$1"

# Not necessary if we're in kiosk mode with one window.
# ID=$(xdotool search --name "Refli")
# xdotool windowactivate --sync "$ID"

# xdotool needs some kind of access to the X session.
# Normally it should be possible to give access to root (when called from
# the NixOS tests), but I didn't manage yet to do it.
su - user -c "DISPLAY=:0 xdotool key ctrl+l"
su - user -c "DISPLAY=:0 xdotool type $URL"
su - user -c "DISPLAY=:0 xdotool key Return"
