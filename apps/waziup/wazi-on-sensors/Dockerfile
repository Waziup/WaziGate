#FROM alpine:latest AS development
FROM golang:alpine AS development

COPY . /go/src/github.com/Waziup/wazi-on-sensors/
WORKDIR /go/src/github.com/Waziup/wazi-on-sensors/
ENV GOPATH=/go/

RUN apk add --no-cache \
    #    go \
    git \
    curl \
    gcc \
    musl-dev \
    linux-headers \
    zip \
    && mkdir /build/ \
    && zip /build/index.zip docker-compose.yml package.json \
    && cp -r ui /build/ui \
    && go build -o /build/start -i . 

#----------------------------#

FROM alpine:latest AS production

WORKDIR /app/
COPY --from=development /build .
RUN apk --no-cache add \
    ca-certificates \
    tzdata \
    curl \
    && mv index.zip /

ENTRYPOINT ["./start"]
