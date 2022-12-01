#!/bin/bash
# This script updates wazigate-edge and every contianer in the main directory compose file, 
# it deletes the old ones and creates new containers

SCRIPT_PATH=$(dirname $(realpath $0))

cd ${SCRIPT_PATH}/../

CNTS=$(sudo docker-compose ps -q)

echo -e "Last check:" $(date) "\n"

for cId in $CNTS; do
	cImage=$(sudo docker ps --format '{{.Image}}' -f id=${cId})
    
    cImageID=$(sudo docker images ${cImage} --no-trunc -q)
    # echo -e "${cName}\t\t${cImage}\t${cImageID}"

    echo -e "\n--------------------------------\n"
    echo -e "Downloading the latest image ...\n"
    sudo docker pull "${cImage}"

    NewcImageID=$(sudo docker images ${cImage} --no-trunc -q)

    if [ "${cImageID}" != "${NewcImageID}" ]; then
        
        echo -e "\n\t\t * * * New updates downloaded. * * *\n"
        echo -e "Stopping ${cId}"
        sudo docker stop ${cId}
        sudo docker kill ${cId}
        
        echo -e "Deleting ${cId}"
        sudo docker rm -f ${cId}
        sudo docker rmi -f "${cImageID}"

    fi;

    echo "Done"
    echo -e "\n--------------------------------\n"

done

echo -e "Creating and Running all containers..."
cd ${SCRIPT_PATH}/../
sudo docker-compose up -d
cd ${SCRIPT_PATH}

echo -e "All Done :)"
exit 0;