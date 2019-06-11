#!/bin/bash
# @author: Moji eskandari@fbk.eu Jun 7th 2019
# This file uses empty tool (http://empty.sourceforge.net/) to interact with weavedinstaller in order to register the Raspi in the platform
#

email="email@example.com"		# Remote.it email (Change it!)
password="Remote.itPassword"		# password (Change it!)

#---------------------------------------#

#Using Rapi MAC address as device ID
MAC=$(cat /sys/class/net/eth0/address)
MAC=${MAC//:}
gwId="${MAC^^}"

#echo "WAZIGATE_$gwId" > done.txt

#check if the server is accessible
acc=$(curl -Is https://remote.it | head -n 1 | awk '{print $2}')
if [ "$acc" != "200" ]; then
	echo "Remote.it is not accessible"
	exit
fi

if [ ! -f done.txt ]; then

	echo "Registring to Remote.it with ID: WAZIGATE_$gwId"
	echo "WAZIGATE_$gwId" > ongoing.txt

	sudo weavedinstaller <<EOF
1
$email
$password
WAZIGATE_$gwId
1
1
y
SSH-WAZIGATE_$gwId
1
2
y
HTTP-WAZIGATE_$gwId
4
EOF

	rm ongoing.txt
	echo "WAZIGATE_$gwId\nSSH-WAZIGATE_$gwId\nHTTP-WAZIGATE_$gwId" > done.txt

fi
