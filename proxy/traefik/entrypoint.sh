#!/bin/sh

if [ "${CERT_RESOLVER}" = "pebble" ]; then
  cp /etc/pebble/pebble.minica.pem /etc/ssl/certs/pebble.minica.pem
fi

exec traefik $@
