Remote.it automatic self registering
=====================

This script registers a device on remote.it platform using `username` and `password` automaically. 
It is useful for mass production and put this script to be executed on boot.

**Tested on Raspbian only** and needs more love.


Install
-------

This script uses connectd tool developed by remote.it ( https://github.com/remoteit/installer).
you need to install that one first.

```
sudo apt-get update
sudo apt-get install connectd
```

Then you need to download this script and put your credentials in a file next named `creds` in it. Like this:

```
email="your_email@example.com"
password="your_remote.it_password"
```

Then run it with sudo like this:

```
sudo bash path/to/remote.it/setup.sh
```

It used the MAC address of `eth0`, the default ethernet interface on your pi, as the device name with `WAZIGATE_` prefix. If your device is different, modify this.

The script register the device on your remote.it account if the device is not registered. Then it registers the device for `SSH` and `HTTP` protocols.

Adding new protocol
-------------------

If you need to register your device for another protocol, just add its block to the file, look for `Another protocol` and uncomment it and write your protocol.
Example for HTTP:
```
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
```

Then don't forget to modify the `if` condition at the end.

Enjoy :)
