# Blue Screen of App - Nickel Configuration
# Nickel is a gradually typed configuration language
# https://nickel-lang.org/

{
  # Application metadata
  app = {
    name = "Blue Screen of App",
    version = "2.0.0",
    description = "A humorous BSOD web application with QUIC support",
    author = "",
    license = "(GPL-3.0-or-later OR Palimpsest-0.8)",
    repository = "https://github.com/Hyperpolymath/blue-screen-of-app",
  },

  # Server configuration
  server = {
    port | default = 443,
    host | default = "0.0.0.0",
    env | default = "production",
    secure | default = true,

    # Protocol preferences
    protocols = {
      quic | default = true,
      http3 | default = true,
      http2 | default = true,
      http1 | default = true,
    },

    # Worker configuration
    workers | default = 4,
    maxConnections | default = 1000,
    keepAliveTimeout | default = 5000,
  },

  # TLS/SSL configuration
  tls = {
    enabled | default = true,
    certFile | default = "./certs/cert.pem",
    keyFile | default = "./certs/key.pem",
    minVersion | default = "TLSv1.3",
    ciphers | default = [
      "TLS_AES_256_GCM_SHA384",
      "TLS_CHACHA20_POLY1305_SHA256",
      "TLS_AES_128_GCM_SHA256",
    ],
  },

  # QUIC-specific configuration
  quic = {
    enabled | default = true,
    maxIdleTimeout | default = 30000,
    initialMaxData | default = 1048576,
    initialMaxStreamDataBidiLocal | default = 262144,
    initialMaxStreamDataBidiRemote | default = 262144,
    initialMaxStreamDataUni | default = 262144,
    initialMaxStreamsBidi | default = 100,
    initialMaxStreamsUni | default = 100,
  },

  # Rate limiting
  rateLimit = {
    enabled | default = true,
    windowMs | default = 900000,  # 15 minutes
    maxRequests | default = 100,

    # Per-endpoint limits
    endpoints = {
      api | default = 100,
      bsod | default = 1000,
      health | default = 10000,
    },
  },

  # Security headers (Helmet.js equivalent)
  security = {
    helmet = {
      contentSecurityPolicy | default = false,  # Disabled for inline styles
      crossOriginEmbedderPolicy | default = true,
      crossOriginOpenerPolicy | default = true,
      crossOriginResourcePolicy | default = true,
      dnsPrefetchControl | default = true,
      frameguard | default = true,
      hidePoweredBy | default = true,
      hsts | default = true,
      ieNoOpen | default = true,
      noSniff | default = true,
      originAgentCluster | default = true,
      permittedCrossDomainPolicies | default = true,
      referrerPolicy | default = true,
      xssFilter | default = true,
    },

    cors = {
      # Set specific origins instead of wildcard for production security
      # Use comma-separated list for multiple origins, e.g., "https://example.com,https://app.example.com"
      origin | default = "https://localhost",
      methods | default = ["GET", "POST"],
      allowedHeaders | default = ["Content-Type", "Authorization"],
      exposedHeaders | default = [],
      credentials | default = false,
      maxAge | default = 86400,
    },
  },

  # Logging configuration
  logging = {
    level | default = "info",
    format | default = "json",

    transports = {
      console = {
        enabled | default = true,
        colorize | default = true,
      },
      file = {
        enabled | default = true,
        errorLog | default = "logs/error.log",
        combinedLog | default = "logs/combined.log",
        maxSize | default = "10m",
        maxFiles | default = 10,
      },
    },
  },

  # Analytics configuration  features = {
    analytics | default = true,
    qrCodes | default = true,
    defaultQrUrl | default = "https://github.com/Hyperpolymath/blue-screen-of-app",

    # Prometheus metrics
    metrics = {
      enabled | default = true,
      endpoint | default = "/api/metrics",
      prefix | default = "bsod_",
    },
  },

  # BSOD styles configuration
  bsod = {
    styles = {
      win10 = {
        enabled | default = true,
        color | default = "#0178D4",
        font | default = "Segoe UI",
      },
      win11 = {
        enabled | default = true,
        color | default = "#0067C0",
        font | default = "Segoe UI Variable",
      },
      win7 = {
        enabled | default = true,
        color | default = "#00579e",
        font | default = "Lucida Console",
      },
      winxp = {
        enabled | default = true,
        color | default = "#0000AA",
        font | default = "Perfect DOS VGA 437",
      },
    },

    defaultStyle | default = "win10",
  },

  # Error messages configuration
  errorMessages = {
    # Enable categories
    categories = {
      standard | default = true,
      developer | default = true,
      custom | default = true,
    },

    # Custom error codes (user-defined)
    custom = [],
  },

  # Container configuration (Podman)
  container = {
    name | default = "blue-screen-of-app",
    image | default = "blue-screen-of-app:latest",
    registry | default = "docker.io",

    # Rootless mode
    rootless | default = true,
    user | default = "denouser",
    uid | default = 1001,
    gid | default = 1001,

    # Resource limits
    resources = {
      cpus | default = 2.0,
      memory | default = "512m",
      memorySwap | default = "1g",
    },

    # Health check
    healthcheck = {
      enabled | default = true,
      interval | default = 30,
      timeout | default = 3,
      retries | default = 3,
      startPeriod | default = 5,
    },
  },

  # Build configuration
  build = {
    # Deno configuration
    deno = {
      version | default = "1.39.1",
      permissions | default = [
        "allow-net",
        "allow-read",
        "allow-env",
      ],
      unstable | default = false,
      importMap | default = null,
    },

    # ReScript configuration
    rescript = {
      version | default = "11.0.0",
      module | default = "es6",
      inSource | default = true,
      suffix | default = ".bs.js",
    },

    # Compilation targets
    targets = [
      "x86_64-unknown-linux-gnu",
      "x86_64-apple-darwin",
      "aarch64-apple-darwin",
      "x86_64-pc-windows-msvc",
    ],
  },

  # RSR (Rhodium Standard Repository) compliance
  rsr = {
    level | default = "bronze",
    version | default = "1.0.0",

    compliance = {
      documentation | default = true,
      wellKnown | default = true,
      dualLicensing | default = true,
      buildSystem | default = true,
      tpcf | default = true,
      security | default = true,
      testing | default = true,
      offlineFirst | default = true,
    },
  },

  # TPCF (Tri-Perimeter Contribution Framework)
  tpcf = {
    currentPerimeter | default = 3,

    perimeters = {
      core = {
        level | default = 1,
        access | default = "full",
        members | default = [],
      },
      trusted = {
        level | default = 2,
        access | default = "triage",
        members | default = [],
      },
      community = {
        level | default = 3,
        access | default = "fork",
        open | default = true,
      },
    },
  },

  # Development configuration
  dev = {
    watch | default = true,
    reload | default = true,
    debugPort | default = 9229,

    # Hot module replacement
    hmr = {
      enabled | default = true,
      port | default = 3001,
    },
  },

  # Testing configuration
  testing = {
    coverage = {
      enabled | default = true,
      threshold | default = 80,
      exclude | default = [
        "tests/",
        "scripts/",
        "dist/",
      ],
    },

    unit = {
      enabled | default = true,
      pattern | default = "**/*.test.js",
    },

    integration = {
      enabled | default = true,
      pattern | default = "**/*.integration.test.js",
    },

    e2e = {
      enabled | default = false,
      pattern | default = "**/*.e2e.test.js",
    },
  },

  # Deployment configuration
  deployment = {
    strategy | default = "rolling",

    environments = {
      development = {
        url | default = "http://localhost:8080",
        secure | default = false,
      },
      staging = {
        url | default = "https://staging.example.com",
        secure | default = true,
      },
      production = {
        url | default = "https://example.com",
        secure | default = true,
      },
    },

    # Blue-green deployment
    blueGreen = {
      enabled | default = false,
      bluePort | default = 443,
      greenPort | default = 444,
    },
  },

  # Backup configuration
  backup = {
    enabled | default = true,
    schedule | default = "0 0 * * *",  # Daily at midnight
    retention | default = 7,  # days
    location | default = "./backups",
  },

  # Monitoring configuration
  monitoring = {
    # Prometheus
    prometheus = {
      enabled | default = true,
      port | default = 9090,
      scrapeInterval | default = 15,
    },

    # Health checks
    health = {
      enabled | default = true,
      endpoint | default = "/api/health",
      checks | default = [
        "database",
        "redis",
        "disk",
        "memory",
      ],
    },
  },

  # Export configuration for different formats
  exports = {
    # JSON export
    toJSON = fun config =>
      std.serialize 'Json config,

    # YAML export (if needed)
    toYAML = fun config =>
      std.serialize 'Yaml config,

    # Environment variables export
    toEnv = fun config =>
      "PORT=" ++ std.to_string config.server.port ++ "\n" ++
      "HOST=" ++ config.server.host ++ "\n" ++
      "NODE_ENV=" ++ config.server.env ++ "\n",
  },
}
