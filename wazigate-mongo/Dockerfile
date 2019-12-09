FROM balenalib/rpi-raspbian

#MAINTAINER Moji mojtaba.eskandari@waziup.org

RUN apt-get update -y && \
    apt-get install -y mongodb
   
EXPOSE 27017

# ENTRYPOINT /etc/init.d/mongodb stop; \
#             mkdir -p /data/db; \
#             rm -f /data/db/mongod.lock; \
#             /etc/init.d/mongodb start; \
#             mongod --repair && \
#             mongod
#--journal

ENTRYPOINT  mkdir -p /data/db; \
            mongod --journal

# ENTRYPOINT ["tail", "-f", "/dev/null"]