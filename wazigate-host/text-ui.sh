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

    sudo bash ${SCRIPT_PATH}/start_hotspot.sh

    echo -e "\n"
    for i in {10..01}; do
      echo -ne "\tWaiting for the network: ${YELLOW}$i ${NC}seconds... \033[0K\r"
      sleep 1
    done
    do_network_info

  else
    return 0
  fi

}

#---------------------------------#

do_wifi_connect() {
  echo -e "\n\tConnecting to ${BLUE}${1}${NC}...\n"

  sudo cp /etc/wpa_supplicant/wpa_supplicant.conf.orig /etc/wpa_supplicant/wpa_supplicant.conf
  
  sudo wpa_passphrase "${1}" "${2}" | grep -o '^[^#]*' >> /etc/wpa_supplicant/wpa_supplicant.conf
  
  sudo bash ${SCRIPT_PATH}/start_wifi.sh

  echo -e "\n"
  for i in {12..01}; do
    echo -ne "\tWaiting for the network: ${YELLOW}$i ${NC}seconds... \033[0K\r"
    sleep 1
  done
  do_network_info
}

#---------------------------------#

do_wifi_list() {
    
    printf "${YELLOW}\n\tScanning WiFi Network...${NC}" 
    SSID=$(iw wlan0 scan | awk -f ${SCRIPT_PATH}/scan.awk | xargs whiptail --output-fd 3 --title "WiFi Setup" --menu  "Choose your WiFi network" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Close --ok-button Connect 3>&1 >/dev/tty  2>/dev/null)
    echo "Done"

    if [ -n "${SSID}" ]; then
        
        if [ "${SSID}" == "Connect to a Hidden Network" ]; then
          SSID=$(whiptail --inputbox "Network Name (SSID)" 20 70 3>&1 1>&2 2>&3)
          if [ -z "${SSID}" ]; then
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
    "4 Monitor the Containers (Advance)" "" \
    "5 Monitor the Resource usage (Advance)" "" \
    "6 Reboot Wazigate" "" \
    "7 Shutdown Wazigate" "" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    do_finish
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1\ *) do_network_info ;;
      2\ *) do_wifi_list ;;
      3\ *) do_force_ap_mode ;;
      4\ *) do_containers ;;
      5\ *) do_htop ;;
      6\ *) do_reboot ;;
      7\ *) do_shutdown ;;
      # *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac # || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
done

#---------------------------------#