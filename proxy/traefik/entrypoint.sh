#!/bin/sh

if [ "$ENVIRONMENT" = "test" ]; then
  cp /etc/pebble/pebble.minica.pem /etc/ssl/certs/pebble.minica.pem
fi

exec traefik $@
