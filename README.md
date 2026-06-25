<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2025-2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->

[![License: PMPL-1.0](https://img.shields.io/badge/License-MPL--2.0-blue.svg)](https://github.com/hyperpolymath/palimpsest-license) :toc: :icons: font

<div class="lead" wrapper="1">

*Does exactly what it says on the tin… or screen.*

</div>

A humorous web app displaying authentic Blue Screen of Death errors.
Built with **Deno**, **ReScript**, and **Podman**.

[![License: PMPL-1.0](https://img.shields.io/badge/License-MPL--2.0-blue.svg)](https://github.com/hyperpolymath/palimpsest-license)
![Deno](https://img.shields.io/badge/deno-2.0-brightgreen)
![RSR](https://img.shields.io/badge/RSR-Bronze-orange)

# Quick Start

```bash
./scripts/bootstrap.sh  # Install Deno, Podman, Just
just build              # Compile ReScript + export config
just podman-run         # Deploy container
# Visit https://localhost:443
```

# Features

- 🎨 Four authentic BSOD styles (Win10, Win11, Win7, WinXP)

- 🎭 25+ humorous error messages

- 📡 REST API with analytics

- 🔒 QUIC/HTTP3 with HTTP/2 fallback

- ⚙️ Nickel configuration language

- 🐳 Rootless Podman containers

- 🔧 100+ Just recipes

# Architecture

- **Runtime**: Deno (no Node.js, no npm)

- **Business Logic**: ReScript (type-safe)

- **Server**: Minimal JavaScript glue code

- **Containers**: Podman (rootless)

- **Protocols**: QUIC/HTTP3/HTTP2/HTTP1.1

- **Config**: Nickel → JSON export

- **Port**: 443 (HTTPS)

# Development

```bash
just dev           # Development mode
just test          # Run tests
just build         # Compile everything
just validate      # RSR compliance check
```

See [Deployment Guide](DEPLOYMENT.adoc) for details.

# API

```bash
curl https://localhost:443/api/error
curl https://localhost:443/api/codes
curl https://localhost:443/api/health
```

See [API Documentation](API.adoc).

# Contributing

See [Contributing](CONTRIBUTING.adoc) and [TPCF](TPCF.adoc).

# License

Dual-licensed: GPL-3.0-or-later OR Palimpsest-0.8. See
[LICENSE](LICENSE).

------------------------------------------------------------------------

💙 **It’s not a bug, it’s a CRITICAL_PROCESS_DIED error!**
