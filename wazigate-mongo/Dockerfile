FROM balenalib/rpi-raspbian

MAINTAINER Moji mojtaba.eskandari@waziup.org

RUN apt-get update -y && \
    apt-get install -y mongodb
   
VOLUME ["/data/db"]
WORKDIR /data
EXPOSE 27017

ENTRYPOINT /etc/init.d/mongodb stop; \
			rm /data/mongod.lock; \
			/etc/init.d/mongodb start; \
			mongod --repair && \
			mongod
