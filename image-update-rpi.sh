#!/bin/sh

docker-compose pull
docker-compose down
UNBOUND_IMAGE_SUFFIX=-rpi docker-compose up -d
