#!/bin/bash
SCRIPT_PATH=$(dirname $(realpath $0))

bash $SCRIPT_PATH/oled/oled.sh &
bash $SCRIPT_PATH/buttons/buttons.sh &
bash $SCRIPT_PATH/host.sh &
bash $SCRIPT_PATH/fan/fan.sh &