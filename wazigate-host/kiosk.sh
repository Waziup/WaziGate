#!/bin/bash
# This script starts the gateway in Kiosk Mode if an HDMI display is attached to it

SCRIPT_PATH=$(dirname $(realpath $0))

#HDMI_STATUS=$(tvservice -s | awk '{print $2}')
#NO_DISPLAY=$((HDMI_STATUS & 1))

HDMI_STATUS=$(tvservice -l | grep "HDMI")

if [ -z "$HDMI_STATUS" ]; then
    echo "No HDMI display found!"
    exit 0;
fi

# kweb -KJJE, file:///$SCRIPT_PATH/init-hdmi-ui.html

sed -i 's/"exited_cleanly": false/"exited_cleanly": true/' ~/.config/chromium/Default/Preferences
chromium-browser --noerrdialogs --kiosk file:///$SCRIPT_PATH/init-hdmi-ui.html --incognito --disable-translate