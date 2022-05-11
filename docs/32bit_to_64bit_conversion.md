32bit to 64bit Conversion of the Gateway
========================================

This document describes the conversion of the baseimage and its dependent components from armv7l (32bit arm architecture) to armv8 or aarch64 (64bit arm architecture).

The updated architecture has many benefits, the major one is better maintained packages and containers. Many of them were outdated, because manufactures stopped supporting the armv7l architecture. Other than that it also improves the performance significantly for Raspberry Pi 4 (in particular for the 4GB version), but even on Raspberry Pi 3b there are improvements measurable.

The new platform was tested on Raspberry PI 3b and Raspberry PI 4. 

---------------------------

Conversion of the baseimage
---------------------------

The baseimage is created with help of the official [RPi-Distro/pi-gen Repository](https://github.com/RPi-Distro/pi-gen). Due to the fact that there is no graphical interface needed for the baseimage, stage 4 and 5 are not included.

In stage 3 WaziGate components will installed on the image. WaziApps are base on Docker images, so Docker will be included in the baseimage. The scripts will use Docker to pull some images from the Docker hub and place them inside the new OS. The WaziGate library will be installed at /var/lib/wazigate/.

In former 32-bit builds, a old version of mongo-db was just installed on the host operating system. Mongo-db runs now in a 64-bit docker container.

The old [install script](https://github.com/Waziup/wazigate-gen/blob/64bit/stage3/03-wazigate/files/wazigate/setup.sh) did not used docker-compose, to eliminate redundancy and improve resilience a [docker-compose.yml](https://github.com/Waziup/wazigate-gen/blob/64bit/stage3/03-wazigate/files/wazigate/docker-compose.yml) was introduced.  

### Steps involved in building the baseimage

1. Clone the repository [Waziup/wazigate-gen](https://github.com/Waziup/wazigate-gen/tree/64bit):

```
git clone --branch 64bit https://github.com/Waziup/wazigate-gen.git
```

2. Set the following environment variables:

```
IMG_NAME              = 'WaziGate'
FIRST_USER_PASS       = 'loragateway'
TARGET_HOSTNAME       = 'wazigate'
PI_GEN_REPO           = 'https://github.com/Waziup/WaziGate-ISO-gen'
WAZIGATE_TAG          = 'latest'
WAZIGATE_VERSION      = 'v2'
```

3. Issue the following command:

```
./build.sh
```

---------------------------

Conversion of containers
------------------------

### Mongo-db

The baseimage for the container was changed from [balenalib/rpi-raspbian](https://hub.docker.com/r/balenalib/rpi-raspbian) to [arm64v8/alpine:latest](https://hub.docker.com/r/arm64v8/alpine/). This improved the filesize of the image.

 The version of Mongo-db is:
```
# mongod --version
db version v4.0.5
git version: 3739429dd92b92d1b0ab120911a23d50bf03c412
OpenSSL version: OpenSSL 1.1.1l  24 Aug 2021
allocator: system
modules: none
build environment:
    distarch: aarch64
    target_arch: aarch64
```

### WaziGate Edge

WaziGate Edge was also build and updated to arm64.

This can be done by issuing the following commands:

```
cd wazigate-edge
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx build --platform linux/arm64 -t waziup/wazigate-edge:64_v2 --load .
```

### Redis

A new version of docker image was used:

```
# redis-server --version
Redis server v=6.2.6 sha=00000000:0 malloc=jemalloc-5.1.0 bits=64 build=d2900a09677e54f7

```

### PostgreSQL

A new version of docker image was used:

```
#  postgres -V postgres
postgres (PostgreSQL) 14.1
```

### Chirpstack

Chirpstack containers:
- chirpstack-network-server
- chirpstack-application-server 
- chirpstack-gateway-bridge 

Are not updated/converted to arm64 at the moment.
