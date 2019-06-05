FROM balenalib/rpi-raspbian

MAINTAINER Moji eskandari@fbk.eu

RUN apt-get update -y && \
    apt-get install -y mongodb
   

VOLUME ["/data/db"]
WORKDIR /data
EXPOSE 27017

CMD ["/etc/init.d/mongodb", "stop"]
CMD ["rm", "/var/lib/mongodb/mongod.lock"]
CMD ["/etc/init.d/mongodb", "start"]
#CMD ["mongod", "--repair"]

#ENTRYPOINT ["/"]

