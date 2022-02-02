FROM balenalib/rpi-raspbian

#MAINTAINER Moji mojtaba.eskandari@waziup.org

RUN apt-get update -y && \
    apt-get install -y mongodb
   
EXPOSE 27017

ENTRYPOINT mkdir -p /data/db; \
           mongod --journal
