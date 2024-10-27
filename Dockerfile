FROM traefik:latest AS proxy

COPY ./proxy/logrotate/ /etc/logrotate.d/

RUN apk update \
    && apk add \
        logrotate \
    && rm -rf /var/cache/apk/*


FROM ubuntu:20.04 AS server

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        python3 \
        python3-pip \
        openssh-server \
        sudo \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd
