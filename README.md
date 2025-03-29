# Pi-hole (v6) + Unbound

This is a two container setup where pihole uses unbound as its upstream provider.

## Setup

```sh
$ echo "<web-password>" >> webpassword
```

To start:
```sh
$ docker compose up -d
```

To pull images and restart:
```sh
$ ./redeploy.sh
```
