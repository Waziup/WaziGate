FROM arm64v8/alpine:latest

#MAINTAINER felix.markwordt@waziup.org

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' >> /etc/apk/repositories
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories

RUN apk update
RUN apk add mongodb yaml-cpp=0.6.2-r2
RUN mongo -version
   
EXPOSE 27017

ENTRYPOINT mongod --journal
