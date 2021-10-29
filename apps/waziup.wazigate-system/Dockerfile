FROM python:2 AS ui
# pyhton is required to build libsass for node-sass
# https://github.com/sass/node-sass/issues/3033

# libgnutls30 is required for
# https://github.com/nodesource/distributions/issues/1266
RUN apt-get update && apt-get install -y --no-install-recommends curl git libgnutls30
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y --no-install-recommends nodejs

COPY ui/. /app

WORKDIR /app/

RUN npm i && npm run build

################################################################################


FROM golang:1.16-alpine AS app

ENV CGO_ENABLED=0
ENV GO111MODULE=on

RUN apk add --no-cache ca-certificates tzdata git

COPY . /app

WORKDIR /app/

RUN go build -ldflags "-s -w" -o wazigate-system .

################################################################################


FROM alpine:latest AS production

RUN apk add --no-cache iw gawk ca-certificates tzdata curl

WORKDIR /app/

COPY --from=ui /app/node_modules/react/umd ui/node_modules/react/umd
COPY --from=ui /app/node_modules/react-dom/umd ui/node_modules/react-dom/umd
COPY --from=ui /app/index.html /app/favicon.ico ui/
COPY --from=ui /app/dist ui/dist
COPY --from=ui /app/icons ui/icons

COPY --from=app /app/wazigate-system .

ENV WAZIUP_MONGO=wazigate-mongo:27017

HEALTHCHECK CMD curl --fail http://localhost || exit 1 

VOLUME /var/lib/waziapp

ENTRYPOINT ["./wazigate-system"]
