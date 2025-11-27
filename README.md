# Pi-hole (v6) + Unbound

This is a two container setup where Pi-hole uses Unbound as its upstream DNS resolver.

## What is Unbound?

[Unbound](https://nlnetlabs.nl/projects/unbound/about/) is a validating, recursive, caching DNS resolver. Instead of forwarding DNS queries to public DNS servers like Cloudflare (1.1.1.1) or Google (8.8.8.8), Unbound queries authoritative DNS servers directly. This provides:

- **Privacy**: DNS queries stay on your local network
- **DNSSEC Validation**: Cryptographic verification of DNS responses
- **No third-party tracking**: Google/Cloudflare don't see your browsing history
- **Control**: You manage your own DNS resolution

## Unbound DNSSEC Configuration

This setup uses **permissive DNSSEC validation** to balance security with usability:

### How It Works

- **DNSSEC validation is enabled**: Unbound validates DNSSEC signatures when present
- **Failures don't block resolution**: Misconfigured websites still resolve (returns DNS results instead of SERVFAIL)
- **Validation failures are logged**: You can monitor which domains have DNSSEC issues
- **Matches public DNS behavior**: Same compatibility as Cloudflare/Google DNS, but with local privacy

### Why Permissive Mode?

Many legitimate websites have DNSSEC misconfigurations (expired signatures, missing records, etc.). Strict DNSSEC validation would make these sites unreachable for your users. Permissive mode allows resolution while maintaining security awareness through logging.

Major public DNS providers (Cloudflare, Google DNS) also use permissive validation for the same reason.

### Monitoring DNSSEC

To view Unbound logs and see DNSSEC validation results:

```sh
# View recent logs
docker logs unbound --tail 100

# Monitor validation failures in real-time
docker logs unbound -f | grep "validation failure"

# Check logs from last 24 hours
docker logs unbound --since 24h
```

Example log entries:
```
info: validation failure example.com. A IN: signature expired from <server-ip>
info: validation success secure.example.com. A IN
```

### Configuration Details

Key settings in `unbound/unbound.conf`:
- `val-permissive-mode: yes` - Validate but don't block on DNSSEC failures
- `val-log-level: 2` - Detailed validation logging
- `harden-dnssec-stripped: no` - Allow resolution when DNSSEC data is missing
- `verbosity: 1` - Operational logging enabled

## Setup

```sh
$ echo "<web-password>" >> webpassword
```

To start:
```sh
$ docker compose up -d
```

## Redeploy Script

The `redeploy.sh` script handles pulling images, stopping containers, and restarting them. It automatically detects your CPU architecture and uses the appropriate Unbound image (ARM vs x86/64).

**Pull latest images and restart:**
```sh
$ ./redeploy.sh
```

**Restart without pulling images** (useful for config changes):
```sh
$ ./redeploy.sh -s
# or
$ ./redeploy.sh --skip-pull
```

**Show help:**
```sh
$ ./redeploy.sh --help
```
