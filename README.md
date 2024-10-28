# service 🫙

A collection of shared services to run on an instance.

- [Proxy](#proxy)
- [MySQL & phpMyAdmin](#mysql--phpmyadmin)


## Configuration

Copy the `.env` template and configure the application.

```sh
cp .env.template .env
```

## Proxy

A reverse proxy that handles port forwarding for incoming traffic to
different hosts and takes care of certificate management.

```sh
make proxy
```

Access the [Traefik] dashboard at `https://proxy.example.com`, with options to
use [Let's Encrypt] for managing production certificates or [Pebble] for
development simulations.

### Add a new service

Add the following labels and `service` network to the service, where each
service must have a unique `ROUTER_KEY`.

```yaml
  myservice:
    labels:
      traefik.enable: true
      traefik.http.routers.ROUTER_KEY.rule: Host(`example.net`)
      traefik.http.routers.ROUTER_KEY.entrypoints: <ENTRYPOINT>
    networks:
      - service
```

Currently supported entrypoints:

Entrypoint | Port
--- | ---
web | 80
websecure | 443
mysql | 3306

Make sure the ports are open on the server.

For `websecure` HTTPS connections, enable TLS.

```yaml
      traefik.http.routers.ROUTER_KEY.tls.certresolver: letsencrypt  # or pebble
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

This creates a [MySQL] server at `mysql.example.com:3306` and a `phpMyAdmin` UI
at `https://phpmyadmin.example.com`.


New MySQL databases are assigned a random password that should be changed:

```sh
docker logs mysql 2>&1 | grep 'GENERATED ROOT PASSWORD'
```

<!-- Links -->
[Let's Encrypt]: https://letsencrypt.org
[MySQL]: https://mysql.com
[Pebble]: https://github.com/letsencrypt/pebble
[phpMyAdmin]: https://phpmyadmin.net
[Traefik]: https://traefik.io
