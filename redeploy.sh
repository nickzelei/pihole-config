#!/bin/sh

# Determine which docker compose command to use
if command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
else
  echo "Error: Docker Compose not found." >&2
  exit 1
fi

$COMPOSE_CMD pull
$COMPOSE_CMD down

ARCH=${DEPLOY_ARCH:-$(uname -m)}
echo "Detected architecture: $ARCH"

if [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  UNBOUND_IMAGE_SUFFIX=-rpi $COMPOSE_CMD up -d
else
  $COMPOSE_CMD up -d
fi
