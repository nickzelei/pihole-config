# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Docker Compose configuration for Pi-hole v6 with Unbound as a recursive DNS resolver. Pi-hole provides DNS-based ad blocking, while Unbound handles DNS resolution directly from authoritative servers (instead of forwarding to public DNS like Cloudflare or Google).

## Architecture

**Two-container setup:**
- **pihole**: DNS filtering and web interface (port 8080 for web UI, port 53 for DNS)
- **unbound**: Recursive DNS resolver that Pi-hole uses as its upstream DNS server

**Key integration point:** Pi-hole forwards DNS queries to unbound via `FTLCONF_dns_upstreams=unbound#53` (compose.yml:14)

**DNSSEC Configuration:** This setup uses **permissive DNSSEC validation** (not strict mode):
- Validates DNSSEC signatures when present
- Logs validation failures but doesn't block resolution (returns DNS results instead of SERVFAIL)
- Configured via `val-permissive-mode: yes` and `harden-dnssec-stripped: no` in unbound.conf
- See README.md for detailed explanation and monitoring commands

## Common Commands

### Start the containers
```sh
docker compose up -d
```

### Pull latest images and restart
```sh
./deploy.sh
```

### View logs
```sh
# Pi-hole logs
docker logs pihole

# Unbound logs (useful for DNSSEC validation monitoring)
docker logs unbound --tail 100
docker logs unbound -f | grep "validation failure"
```

### Stop containers
```sh
docker compose down
```

## Configuration Files

- **compose.yml**: Main Docker Compose configuration
  - Pi-hole web password loaded from `webpassword` file (via Docker secrets)
  - Unbound image suffix controlled by `UNBOUND_IMAGE_SUFFIX` env var (.env file)

- **unbound/unbound.conf**: Unbound DNS resolver configuration (mounted read-only into container)
  - Performance tuning for cache sizes, threads, etc.
  - Security settings including access control for private networks
  - DNSSEC validation in permissive mode
  - Logging configuration (verbosity: 1, val-log-level: 2)

- **webpassword**: Contains Pi-hole admin password (gitignored, must be created manually)

- **.env**: Environment variables for compose file
  - `UNBOUND_IMAGE_SUFFIX`: Set to empty string for x86/64, or `-rpi` for ARM (auto-detected by redeploy.sh)

## Initial Setup

To set up from scratch:
1. Create webpassword file: `echo "<your-password>" >> webpassword`
2. Start containers: `docker compose up -d`
3. Access Pi-hole web interface at http://localhost:8080

## Architecture-Specific Deployment

The `deploy.sh` script auto-detects CPU architecture:
- ARM platforms (armv7l, aarch64, arm64): Uses `mvance/unbound-rpi` image
- x86/64 platforms: Uses `mvance/unbound` image
