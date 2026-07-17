# Option 1: TLS on Perl (Short-term, Low-risk)

**Timeline**: 1-2 weeks  
**Effort**: 1 person  
**Risk**: Low  
**Trade-off**: Keeps Perl stack, defers full modernization

---

## Approach

Add `IO::Socket::SSL` listener to `bin/Engine.pm` to encrypt telnet traffic.

**Outcome**: 
- Players connect to port 23 (or configurable) via TLS instead of plaintext
- Interactive login (username/password) works as before
- ANSI colors continue to work
- Telnet protocol completely replaced (break with past)

---

## Implementation Steps

### 1. Add IO::Socket::SSL Dependency

**File**: `bin/Engine.pm` (top of file)

```perl
use IO::Socket::SSL;
```

Ensure Perl package is installed:
```bash
cpan IO::Socket::SSL
```

### 2. Modify Listener Creation

**Current code** (Engine.pm, somewhere in `init()` or `new()`):
```perl
my $listener = IO::Socket::INET->new(
    LocalHost => 'localhost',
    LocalPort => $self->port(),
    Listen    => 5,
    Reuse     => 1,
) or die "Cannot listen: $!";
```

**New code**:
```perl
my $listener = IO::Socket::SSL->new(
    LocalHost => 'localhost',
    LocalPort => $self->port(),
    Listen    => 5,
    Reuse     => 1,
    SSL_cert_file  => 'cfg/server.crt',   # Self-signed certificate
    SSL_key_file   => 'cfg/server.key',   # Private key
    SSL_version    => 'SSLv23',           # Allow TLS 1.2+
) or die "Cannot listen: $!";
```

### 3. Generate Self-Signed Certificate

One-time setup:
```bash
openssl req -x509 -newkey rsa:2048 -keyout cfg/server.key -out cfg/server.crt \
    -days 365 -nodes -subj "/CN=localhost"
```

This creates:
- `cfg/server.crt` — Certificate (public)
- `cfg/server.key` — Private key

### 4. Update Configuration

**File**: `cfg/world.cfg`

```
# TLS Configuration
UseSSL = 1
SSLCertFile = cfg/server.crt
SSLKeyFile = cfg/server.key
```

### 5. Client Connection

Players now connect via TLS client (e.g., `openssl s_client`):
```bash
openssl s_client -connect localhost:23
```

Or any telnet client that supports TLS (most modern ones do).

---

## Benefits

✓ **Encryption live in 1-2 weeks**  
✓ **Low risk** — isolated socket change  
✓ **No scripting changes** — wizard code untouched  
✓ **Backward-compatible with gameplay** — login flow identical  
✓ **Can migrate to Python later** — this is a stepping stone

---

## Drawbacks

✗ **Keeps Perl** — no modernization of language/syntax  
✗ **Async still weak** — select/fork remains  
✗ **Self-signed cert** — browser/client warnings (acceptable for MUD)  
✗ **Not SSH** — TLS != SSH (but cryptographically equivalent)  

---

## Testing Checklist

- [ ] Server starts without errors
- [ ] Can connect via TLS client
- [ ] Login flow works (username/password)
- [ ] ANSI colors display correctly
- [ ] Commands execute normally
- [ ] Multi-client scenario (5+ simultaneous logins)
- [ ] Heartbeat fires correctly
- [ ] No memory leaks on sustained connection
- [ ] Crash/restart recovery works (Mudmon)

---

## Post-Launch

Once TLS is live:
- Document client setup (which TLS clients to use)
- Monitor logs for SSL/TLS errors
- Evaluate Python migration (Option 2) at leisure

No rush — this is a stable stopping point.

---

## Cost of This Choice

**Later migration to Python**:
- Port existing TLS listener code to Python asyncio (straightforward)
- All other modernization benefits still available

**No downside** — this is a foundation, not a trap.

---

## Recommended If

- You need encryption now, Python rewrite is uncertain
- You want to ship quickly and iterate
- You prefer lower risk over faster modernization
- You're unsure about 8-week rewrite commitment
