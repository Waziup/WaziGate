#!/bin/bash
# This script updates all the containers, delete the old and create new containers

SCRIPT_PATH=$(dirname $(realpath $0))

CNTS=$(sudo docker ps -a --format "{{.Names}}")
# CNTS=$(echo "wazigate-edge")

echo -e "Last check:" $(date) "\n"

for cName in $CNTS; do
	cImage=$(sudo docker ps --format '{{.Image}}' -f name=${cName})
    # cImage="waziup/wazigate-edge:V1.0-beta4"
    cImageID=$(sudo docker images ${cImage} --no-trunc -q)
    # echo -e "${cName}\t\t${cImage}\t${cImageID}"

    echo -e "\n--------------------------------\n"
    echo -e "Updating [ ${cName} ]...\n"
    sudo docker pull "${cImage}"

    NewcImageID=$(sudo docker images ${cImage} --no-trunc -q)

    if [ "${cImageID}" != "${NewcImageID}" ]; then
        
        echo -e "\n\t\t * * * New updates downloaded. * * *\n"
        echo -e "Stopping ${cName}"
        sudo docker stop ${cName}
        sudo docker kill ${cName}
        
        echo -e "Deleting ${cName}"
        sudo docker rm ${cName}
        sudo docker rmi -f "${cImageID}"

        echo -e "Creating and Running ${cName}..."
        cd ${SCRIPT_PATH}/../
        sudo docker-compose up -d ${cName}
        cd ${SCRIPT_PATH}
    fi;

    echo "Done"
    echo -e "\n--------------------------------\n"

done

echo -e "All Done :)"
exit 0;