#!/bin/sh

# Parse flags
SKIP_PULL=0
while [ $# -gt 0 ]; do
  case "$1" in
    -s|--skip-pull)
      SKIP_PULL=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -s, --skip-pull    Skip pulling Docker images"
      echo "  -h, --help         Show this help message"
      exit 0
      ;;
    *)
      echo "Error: Unknown option $1" >&2
      echo "Run '$0 --help' for usage information" >&2
      exit 1
      ;;
  esac
done

# Determine which docker compose command to use
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif docker-compose --version >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "Error: Docker Compose not found." >&2
  exit 1
fi

ARCH=${DEPLOY_ARCH:-$(uname -m)}
echo "Detected architecture: $ARCH"

if [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
  if [ "$SKIP_PULL" -eq 0 ]; then
    UNBOUND_IMAGE_SUFFIX=-rpi $COMPOSE_CMD pull
  fi
  $COMPOSE_CMD down
  UNBOUND_IMAGE_SUFFIX=-rpi $COMPOSE_CMD up -d
else
  if [ "$SKIP_PULL" -eq 0 ]; then
    $COMPOSE_CMD pull
  fi
  $COMPOSE_CMD down
  $COMPOSE_CMD up -d
fi
