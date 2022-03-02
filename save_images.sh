IMAGES=`cat docker-compose.yml | yq .services[].image | envsubst`

echo "Saving images:\n $IMAGES"

docker-compose -f docker-compose.yml pull
docker save -o wazigate_images.tar $IMAGES
