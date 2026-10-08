# oodns: Sovereign DNS RESOLVER

<div align="center">

```
================================================================================
                                oodns
               Sovereign openOODA DNS RESOLVER
================================================================================
```

**Sovereign DNS RESOLVER**  
*Asynchronous DNS resolver supporting DNS-over-HTTPS and capability allowlists.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64 | aarch64](https://img.shields.io/badge/Arch-x86__64%20%7C%20aarch64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64 & aarch64)
```bash
curl -fsSL https://openooda-tools.github.io/oodns/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S oodns-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oodns/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oodns/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oodns-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oodns/uninstall.sh | bash
```

---

## 2. CLI Usage

```
usage: oodns [options] <domain> [TYPE]

Sovereign DNS resolver supporting DNS-over-HTTPS and capability allowlists.

Options:
  <domain>             domain name to resolve (e.g. openooda.org)
  [TYPE]               record type: A, AAAA, MX, TXT, CNAME, NS, PTR, SOA, SRV [default: A]
  @<server>            nameserver to query (e.g. @1.1.1.1, @8.8.8.8, @127.0.0.53)
  -s, --server <ip>    override target nameserver IP address
  -p, --port <port>    override query destination port [default: 53]
  -t, --type <type>    explicit record type selector
  -x, --reverse <ip>   reverse DNS lookup for IPv4 or IPv6 address
      --doh [url]      query via RFC 8484 DNS-over-HTTPS endpoint
      --allowlist <csv> restrict resolution targets to allowed domain patterns
      +short           terse answer output mode (rdata values only)
      +tcp             force transmission over TCP
  -j, --json           output formatted as structured JSON Lines
  -D, --demo           synthetic DNS resolution showcase across record types
      --mcp            run as Model Context Protocol stdio server
      --test           run internal verification anchor suite
  -h, --help           display this help and exit
  -v, --version        output version information and exit
```

---

## 3. Theming Integration (`oote`)

`oodns` synchronizes visual styles and status colors with [oote](https://github.com/openOODA-tools/oote):
* **Configuration:** Reads active palette from `~/.openooda/theme.oot`.
* **Environment Overrides:** Respects `$OODA_THEME` and `$NO_COLOR`.

---

## 4. Model Context Protocol (MCP)

When invoked with `--mcp`, `oodns` runs a JSON-RPC 2.0 stdio server providing 6 sovereign tools for AI coding agents:

* `dns_resolve`: Resolve domain names to record types (`domain`, `record_type`, `server`, `timeout_ms`).
* `dns_lookup`: Quick IP resolution (A/AAAA) for domain.
* `dns_reverse`: Reverse DNS pointer lookup (`ip`).
* `dns_doh`: Query via RFC 8484 DNS-over-HTTPS endpoint (`domain`, `record_type`, `endpoint`).
* `dns_validate`: Validate domain against capability allowlist rules (`domain`, `allowlist`).
* `dns_demo`: Run full synthetic DNS resolution showcase across record types.

---

## 5. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit tokens (&NetCap, &TlsCap, &McpCap). Physical absence of ambient disk/net leakage.
* **Negative-Trust Architecture:** Strict input validation and operational limits.
* **Hermetic Binary:** Standalone zero-dependency executable.

---

## 6. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
