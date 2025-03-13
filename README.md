# PiHole (v6) + Unbound

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

If you're on a Raspberry Pi (or any arm machine), run:

```sh
$ ./arm-redeploy.sh
```

Unbound has discrete platform images, so the `arm-redeploy.sh` specifies the unbound-rpi image that that runs on arm devices.

