#!/bin/bash
# pushes all waziup images to the docker hub, just makes my life easier, Moji ;)

CNT=""

if [ "$1" != "shutdown" ]; then
	CNT=$1
fi;

	sudo docker-compose stop $CNT
	sudo docker rm $(sudo docker ps -a -q -f name=$CNT)
	#sudo docker system prune -f
	sudo docker rmi -f $(sudo docker images | grep "waziup" | grep "$CNT" | awk '{print $3}')
	#sudo docker rmi -f $(sudo docker images | awk '{print $3}') #Delete all images
	sudo docker-compose -f docker-compose.yml -f docker-compose-build.yml build --force-rm $CNT

allImages=$(sudo docker images | grep "waziup" | awk '{print $1}')

for img in $allImages; do
	docker push "${img}"
done

if [ "$1" == "shutdown" ] || [ "$2" == "shutdown" ]; then

	echo -e "\n\n"
	for i in {30..01}; do
		echo -ne "Shutting down in $i seconds... \033[0K\r"
		sleep 1
	done
	sudo shutdown -P now
fi;

echo -e "\n\nAll done.\n"

exit 0;
