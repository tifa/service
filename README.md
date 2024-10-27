# service 🫙

A collection of shared services to run on an instance.

- [Reverse proxy](#reverse-proxy)
- [MySQL & phpMyAdmin](#mysql--phpmyadmin)


## Reverse proxy

Reverse proxy that handles port forwarding for incoming traffic to different
hosts and takes care of certificate management.

```sh
make proxy
```

- [Traefik] at `https://proxy.example.com`

### Add a new service

Add the following labels and `service` network to the service:

```yaml
  myservice:
    labels:
      traefik.enable: true
      traefik.http.routers.<ROUTER_KEY>.rule: Host(`example.net`)
      traefik.http.routers.<ROUTER_KEY>.entrypoints: <ENTRYPOINT>
    networks:
      - service
```

Each service needs to have a unique `ROUTER_KEY`.

Currently supported entrypoints:

Entrypoint | Port
--- | ---
web | 80
websecure | 443
mysql | 3306

Make sure the ports are open on the server.

For `websecure` HTTPS connections, enable TLS.

```yaml
      traefik.http.routers.<ROUTER_KEY>.tls.certresolver: letsencrypt
```

Finally, define the external network at the top level.

```yaml
networks:
  service:
    external: true
```


## Services

The following services depend on the reverse proxy above.

### MySQL & phpMyAdmin

```sh
make mysql
```

- [MySQL] server at `mysql.example.com:3306`
- [phpMyAdmin] UI at `https://phpmyadmin.example.com`


New MySQL databases will be assigned a random password.

```sh
docker logs mysql 2>&1 | grep 'GENERATED ROOT PASSWORD'
```


## Development

Set the `ENVIRONMENT` variable to `test` before running any commands.

```sh
export ENVIRONMENT=test  # default: production
```

In the development environment an extra [Pebble] container is brought up to mock
[Let's Encrypt] certificate issuance.


<!-- Links -->
[Let's Encrypt]: https://letsencrypt.org
[MySQL]: https://mysql.com
[Pebble]: https://github.com/letsencrypt/pebble
[phpMyAdmin]: https://phpmyadmin.net
[Traefik]: https://traefik.io
