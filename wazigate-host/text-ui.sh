#!/bin/bash
# This script starts a text based UI with some basic controls

SCRIPT_PATH=$(dirname $(realpath $0))
ASK_TO_REBOOT=0

#---------------------------------#
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[92m'
RED='\033[91m'
NC='\033[0m'


#---------------------------------#

# Wait for WaziGate to be started
# Is service active? = started
sp='/-\|'
while [ "$(systemctl is-active wazigate)" != "active" ]
do
 printf '\r%.1s %s' "$sp" "$(</tmp/wazigate-setup-step.txt)"
 sp=${sp#?}${sp%???}
 sleep 0.2
done

#---------------------------------#

calc_wt_size() {
  # NOTE: it's tempting to redirect stderr to /dev/null, so supress error 
  # output from tput. However in this case, tput detects neither stdout or 
  # stderr is a tty and so only gives default 80, 24 values
  WT_HEIGHT=17
  WT_WIDTH=$(tput cols)

  if [ -z "${WT_WIDTH}" ] || [ "${WT_WIDTH}" -lt 60 ]; then
    WT_WIDTH=80
  fi
  if [ "${WT_WIDTH}" -gt 178 ]; then
    WT_WIDTH=120
  fi
  WT_MENU_HEIGHT=$((${WT_HEIGHT}-7))
}

#---------------------------------#

do_network_info() {

    printf "${YELLOW}\n\tPreparing the network info...${NC}" 

    DEF_DEV=$(ip route show default | head -n 1 | awk '/default/ {print $5}')
    
    ETH_MAC_ADDR=$(cat /sys/class/net/eth0/address)
    ETH_IP_ADDR=$(ip -4 addr show eth0 | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' | head -n 1)

    W_MAC_ADDR=$(cat /sys/class/net/wlan0/address)
    W_IP_ADDR=$(ip -4 addr show wlan0 | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}' | head -n 1)
    W_SSID=$(iw wlan0 info | grep ssid | awk '{print $2" "$3" "$4" "$5" "$6}')
    
    AP_MODE=$(systemctl is-active --quiet hostapd && echo "1")
    W_MODE="Access Point"
    if [ -z ${AP_MODE} ]; then
      W_MODE="Client WiFi"
    fi

    # Check if waziup server is accessible
    INTERNET_REQ=$(timeout 3 curl -Is https://waziup.io | head -n 1 | awk '{print $2}')
    INTERNET_ACC="No Internet"
    if [ "${INTERNET_REQ}" == "200" ]; then
      INTERNET_ACC="Accessible"
    fi

    echo "Done"

    # wpa_cli status -i wlan0
    
    whiptail --title "Network Information" --yesno "\
    Default Interface:  ${DEF_DEV}
    
    Internet:           ${INTERNET_ACC}

    Ethernet:
        IP Address:     ${ETH_IP_ADDR}
        MAC Address:    ${ETH_MAC_ADDR}

    WiFi:
        WiFi Mode:      ${W_MODE}
        SSID:           ${W_SSID}
        IP Address:     ${W_IP_ADDR}
        MAC Address:    ${W_MAC_ADDR}
    " 20 70 1 \
    --yes-button Refresh --no-button Close

    RET=$?
    if [ $RET -eq 0 ]; then
      do_network_info
    fi
}

#---------------------------------#

do_force_ap_mode() {

  whiptail --yesno "Would you like to switch to Access Point Mode?" 20 60 2
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then

    echo -e "\n\t${YELLOW}Activating Access Point Mode${NC}"

    # Better not delete: to save old connection: (nmcli con down&up id name)
    nmcli c down $(nmcli -f NAME,UUID,DEVICE -p c | grep wlan0 | xargs | awk '{ print $2 }')
    nmcli c up $(nmcli -f NAME,UUID -p c | grep WAZIGATE-AP | sed 's/WAZIGATE-AP//' | xargs)

    do_network_info

  else
    return 0
  fi

}

#---------------------------------#

do_wifi_connect() {
  echo -e "\n\tConnecting to ${BLUE}${1}${NC}...\n"
  
  nmcli dev wifi connect ${1} password ${2}

  do_network_info
}

#---------------------------------#

do_wifi_list() {
    nmcli device wifi rescan
    iw dev wlan0 scan ap-force >/dev/null 2>&1

    printf "${YELLOW}\n\tScanning WiFi Network...${NC}" 
    SSID=$(nmcli -t -f ALL dev wifi | awk -F '[:]' '{ print "\"" $2 " \" \" " $14 " " $16 "\""; }' | xargs whiptail --output-fd 3 --title "WiFi Setup" --menu  "Choose your WiFi network" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Close --ok-button Connect 3>&1 >/dev/tty  2>/dev/null)
    echo "Done"

    if [ -n "${SSID}" ]; then
        
        if [ "${SSID}" == "Connect to a Hidden Network" ]; then
          SSID=$(whiptail --inputbox "Network Name (SSID)" 20 70 3>&1 1>&2 2>&3)
          if [ -z "${SSID}" ]; then
	    echo "Creating Wifi list"
            do_wifi_list
            return 0
          fi
        fi

        WIFI_PASSWORD=$(whiptail --inputbox "Password for ( ${SSID} )" 20 70 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ]; then
          do_wifi_list
          return 0
        fi

        do_wifi_connect "${SSID}" "${WIFI_PASSWORD}"

    fi
}

#---------------------------------#

CLOUD=waziup
CLOUD_API=http://localhost/clouds/$CLOUD

do_clouds() {
  USERNAME=$(curl -s $CLOUD_API | yq ".username")
  if [ -n "$USERNAME" ]; then
    PAUSED=$(curl -s $CLOUD_API | yq ".paused")
    if [[ $PAUSED == "false" ]]; then
      do_clouds_pause
    else
      do_clouds_menu
    fi
  else
    do_clouds_wizard
  fi
}

do_clouds_pause() {
  USERNAME=$(curl -s $CLOUD_API | yq ".username")
  whiptail --yesno "Stop synchronization with cloud now?\nYou are logged in as '$USERNAME'.\n\nYou can change the username and/or password only when the synchronization is stopped." 20 60 2
  if [ $? -eq 0 ]; then # yes
    curl -X POST $CLOUD_API/paused -H "Content-Type: application/json" -d "true"
  fi
}

do_clouds_menu() {
  USERNAME=$(curl -s $CLOUD_API | yq ".username")

  FUN=$(whiptail --title "Cloud Sync '$USERNAME'" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Exit --ok-button Select \
      "1 Change Username" "" \
      "2 Change Password" "" \
      "3 Activate Synchronization" "" \
      3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
      exit 0
    elif [ $RET -eq 0 ]; then
      case "$FUN" in
        1\ *) do_clouds_username ;;
        2\ *) do_clouds_password ;;
        3\ *) do_cloud_unpause ;;
        # *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
      esac # || whiptail --msgbox "There was an error running option $FUN" 20 60 1
    else
      exit 1
    fi
}

do_clouds_username() {
  USERNAME=$(curl -s $CLOUD_API | yq ".username")
  USERNAME=$(whiptail --inputbox "WaziCloud Account Mail/Name" 20 70 "$USERNAME" 3>&1 1>&2 2>&3)
  if [ -z "${USERNAME}" ]; then
    return 0
  fi
  curl -X POST $CLOUD_API/username -H "Content-Type: application/json" -d "\"$USERNAME\""
  do_clouds_password
}

do_cloud_unpause() {
  if curl --fail -X POST $CLOUD_API/paused -H "Content-Type: application/json" -d "false" ; then
    whiptail --msgbox "Synchronization is now ACTIVE." 20 60 1
  else
    whiptail --msgbox "There was an error while activating the synchronization. Check your username and password and try again." 20 60 1
  fi
}

do_clouds_password() {
  TOKEN=$(whiptail --inputbox "WaziCloud Account Password" 20 70 3>&1 1>&2 2>&3)
  if [ -z "${TOKEN}" ]; then
    return 0
  fi
  curl -X POST -H "Content-Type: application/json" -d "\"$TOKEN\"" $CLOUD_API/token

  do_clouds_menu
}

do_clouds_wizard() {
  USERNAME=$(whiptail --inputbox "Welcome to the WaziCloud Setup Wizard!\n\nTo activate synchronization with the WaziCloud, enter your WaziCloud mail below.\n\nYou can create a free account at waziup.io.\n\nUsername / Mail:" 20 70 --title "WaziCloud Setup Wizard" 3>&1 1>&2 2>&3)
  if [ -z "${USERNAME}" ]; then
    return 0
  fi
  curl -X POST $CLOUD_API/username -H "Content-Type: application/json" -d "\"$USERNAME\""
  TOKEN=$(whiptail --inputbox "Enter your WaziCloud Account Password below.\n\nPassword:" 20 70 --title "WaziCloud Setup Wizard" 3>&1 1>&2 2>&3)
  if [ -z "${TOKEN}" ]; then
    return 0
  fi
  curl -X POST $CLOUD_API/token -H "Content-Type: application/json" -d "\"$TOKEN\""
  whiptail --yesno "Active synchronization with cloud now?" 20 60 2
  if [ $? -eq 0 ]; then # yes
    curl -X POST $CLOUD_API/paused -H "Content-Type: application/json" -d "false"
  fi
}

#---------------------------------#

do_containers() {
    
    printf "${YELLOW}\n\tPreparing the docker containers information...${NC}" 
    CON_ID=$(docker ps -a --format '"{{.ID}}" "{{.Names}} \t{{.Status}}"' | column -t -s$'\t' | xargs whiptail --output-fd 3 --title "Docker Containers" --menu  "Choose a container to see the logs" ${WT_HEIGHT} ${WT_WIDTH} ${WT_MENU_HEIGHT} --notags --cancel-button Close --ok-button Logs 3>&1 >/dev/tty 2>/dev/null)
    echo "Done"

    if [ -n "${CON_ID}" ]; then
        
        # echo -e ${YELLOW}${CON_ID}${NC}
        # echo -e $(realpath $0)

        trap 'echo -e "\nStopping the Logs"' INT

        sudo docker logs -f ${CON_ID}

        echo -e ${YELLOW}"Hit Enter to get back"${NC}
        read TMP
        do_containers

    fi
}

#---------------------------------#

do_finish() {
  if [ $ASK_TO_REBOOT -eq 1 ]; then
    whiptail --yesno "Would you like to reboot now?" 20 60 2
    if [ $? -eq 0 ]; then # yes
      sync
      reboot
    fi
  fi
  exit 0
}

#---------------------------------#

do_reboot() {
  whiptail --yesno "Would you like to reboot now?" 20 60 2
  if [ $? -eq 0 ]; then # yes
    sync

    printf "${YELLOW}\n\tStopping the containers gracefully...${NC}" 
    sudo docker stop $(sudo docker ps -q)
    echo "Done"
    sudo reboot
  fi
}

#---------------------------------#

do_shutdown() {
  whiptail --yesno "Would you like to shutdown now?" 20 60 2
  if [ $? -eq 0 ]; then # yes
    sync
    
    printf "${YELLOW}\n\tStopping the containers gracefully...${NC}" 
    sudo docker stop $(sudo docker ps -q)
    echo "Done"
    sudo shutdown -P now
  fi
}

#---------------------------------#

do_htop() {
  CMD=$(which htop top | head -n 1)
  ${CMD}
}

#---------------------------------#

# Everything else needs to be run as root
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo ./text-ui.sh'\n"
  exit 1
fi

#---------------------------------#

calc_wt_size
while true; do
  FUN=$(whiptail --title "WaziGate Software Configuration Tool" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Exit --ok-button Select \
    "1 Network Information" "" \
    "2 Connect to a WiFi network" "" \
    "3 Switch to Access Point Mode" "" \
    "4 WaziCloud Synchronization" "" \
    "5 Monitor the Containers (Advance)" "" \
    "6 Monitor the Resource usage (Advance)" "" \
    "7 Reboot Wazigate" "" \
    "8 Shutdown Wazigate" "" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    do_finish
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1\ *) do_network_info ;;
      2\ *) do_wifi_list ;;
      3\ *) do_force_ap_mode ;;
      4\ *) do_clouds ;;
      5\ *) do_containers ;;
      6\ *) do_htop ;;
      7\ *) do_reboot ;;
      8\ *) do_shutdown ;;
      # *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac # || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
done

#---------------------------------#
