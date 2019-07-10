#!/bin/bash
# @author: Moji eskandari@fbk.eu Jul 05th 2019
#

#---------------------------------------#

SCRIPT_PATH=$(dirname $(realpath $0))

#----------------------------------#

#check if the server is accessible
acc=$(curl -Is https://remote.it | head -n 1 | awk '{print $2}')
if [ "$acc" != "200" ]; then
	echo "Remote.it is not accessible"
	exit 1
fi

#----------------------------------#

. $SCRIPT_PATH/creds

USERNAME="$email"
PASSWORD="$password"
AUTHHASH="REPLACE_AUTHHASH"
DEVELOPERKEY=""
MAXSEL=6

. /usr/bin/connectd_library

checkForRoot
checkForUtilities
platformDetection
connectdCompatibility
userLogin
testLogin

checkForServices<<EOF
n
EOF