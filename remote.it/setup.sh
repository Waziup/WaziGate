#!/bin/bash
# @author: Moji eskandari@fbk.eu Jun 25th 2019
#

# It is recommended to store the email and password in a file named "creds" next to this file with the same flowwing format
email="email@example.com"		# Remote.it email (Change it!)
password="Remote.itPassword"	# password (Change it!)

#---------------------------------------#

SCRIPT_PATH=$(dirname $(realpath $0))

#Logs (needs care)
#exec 1>$SCRIPT_PATH/remote.it.log 2>&1
#set -x


#Using Rapi MAC address as device ID
MAC=$(cat /sys/class/net/eth0/address)
MAC=${MAC//:}
gwId="${MAC^^}"

#----------------------------------#

#check if the server is accessible
acc=$(curl -Is https://remote.it | head -n 1 | awk '{print $2}')
if [ "$acc" != "200" ]; then
	echo "Remote.it is not accessible"
	exit
fi

if [ -f $SCRIPT_PATH/done.txt ]; then
	echo "Already registered."
	exit
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

#----------------------------------#

registerRemoteIT()
{
	setConnectdPort "$PROTOCOL"
	#configureConnection

	getHardwareID
	echo "Registring the device with HardwareID: $HardwareID and Name: $SNAME"
	installProvisioning
	installStartStop
	fetchUID
	checkUID
	preregisterUID
	registerDevice <<EOF
$SNAME
EOF

}

#----------------------------------#

rtServices=`checkForServices<<EOF
n
EOF`

#----------------------------------#

echo "Registring WAZIGATE_$gwId" > $SCRIPT_PATH/ongoing.txt

if [[ $rtServices == *"WAZIGATE_$gwId"* ]]; then

	echo "Already Registered under name [ WAZIGATE_$gwId ]" 
	echo "Already Registered under name [ WAZIGATE_$gwId ]" >> $SCRIPT_PATH/ongoing.txt

else

	PROTOCOL=rmt3
	PORT=65535
	SNAME="WAZIGATE_$gwId"
	registerRemoteIT

	echo "$error" >> $SCRIPT_PATH/ongoing.txt
	echo "Done" >> $SCRIPT_PATH/ongoing.txt

fi

#--------------------#

echo "Registring SSH..." >> $SCRIPT_PATH/ongoing.txt

if [[ $rtServices == *"SSH-WAZIGATE_$gwId"* ]]; then
	
	echo "SSH is already registered [ SSH-WAZIGATE_$gwId ]"
	echo "SSH already registered [ SSH-WAZIGATE_$gwId ]" >> $SCRIPT_PATH/ongoing.txt
	
else

	#Register the device for SSH
	PROTOCOL=ssh
	PORT=22
	SNAME="SSH-WAZIGATE_$gwId"
	registerRemoteIT

	echo "$error"

	echo "$error" >> $SCRIPT_PATH/ongoing.txt
	echo "Done" >> $SCRIPT_PATH/ongoing.txt

fi

#--------------------#

echo "Registring HTTP..." >> $SCRIPT_PATH/ongoing.txt

if [[ $rtServices == *"HTTP-WAZIGATE_$gwId"* ]]; then
	
	echo "HTTP is already registered [ HTTP-WAZIGATE_$gwId ]"
	echo "HTTP already registered [ HTTP-WAZIGATE_$gwId ]" >> $SCRIPT_PATH/ongoing.txt
	
else

	#Register the device for HTTP
	PROTOCOL=web
	PORT=80
	SNAME="HTTP-WAZIGATE_$gwId"
	registerRemoteIT

	echo "$error"

	echo "$error" >> $SCRIPT_PATH/ongoing.txt
	echo "Done" >> $SCRIPT_PATH/ongoing.txt

fi

#--------------------#

#Double check if everything is done correctly

rtServices=`checkForServices<<EOF
n
EOF`

if [[ $rtServices == *"WAZIGATE_$gwId"* ]] && [[ $rtServices == *"SSH-WAZIGATE_$gwId"* ]] && [[ $rtServices == *"HTTP-WAZIGATE_$gwId"* ]]; then

	rm -f $SCRIPT_PATH/ongoing.txt
	echo -e "WAZIGATE_$gwId\nSSH-WAZIGATE_$gwId\nHTTP-WAZIGATE_$gwId" > $SCRIPT_PATH/done.txt
	echo -e "\n\t\t* * * All done successfully :) * * *\n"
	exit 0
fi

echo "There are some erros! Check the logs please."
exit 1
