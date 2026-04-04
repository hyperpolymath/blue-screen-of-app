# justfile for Blue Screen of App (Deno + Podman Edition)
# Comprehensive build automation with 100+ recipes

# Variables
container_name := "blue-screen-of-app"
image_name := "blue-screen-of-app:latest"
port := "443"
host := "0.0.0.0"

# Default recipe - show help
default:
    @just --list --unsorted

# ============================================================================
# SETUP & INSTALLATION
# ============================================================================

# Complete project setup
setup: install-deps create-dirs generate-certs setup-env
    @echo "✓ Setup complete! Run 'just dev' to start development"

# Install system dependencies (podman, just, deno)
install-deps:
    @just bootstrap

# Bootstrap - install podman and just based on OS
bootstrap:
    #!/usr/bin/env bash
    ./scripts/bootstrap.sh

# Create necessary directories
create-dirs:
    mkdir -p logs certs dist bin coverage .well-known

# Generate self-signed TLS certificates
generate-certs:
    #!/usr/bin/env bash
    if [ ! -f certs/cert.pem ]; then
        mkdir -p certs
        openssl req -x509 -newkey rsa:4096 -keyout certs/key.pem -out certs/cert.pem \
            -days 365 -nodes -subj "/CN=localhost"
        echo "✓ Generated self-signed certificates"
    else
        echo "✓ Certificates already exist"
    fi

# Setup environment file
setup-env:
    @test -f .env || cp .env.example .env
    @echo "✓ Environment file ready"

# Clean install
install-clean: clean install-deps

# ============================================================================
# DEVELOPMENT
# ============================================================================

# Start development server with watch mode
dev:
    deno task dev

# Start production server
start:
    deno task start

# Start with custom port
[private]
start-port port:
    PORT={{port}} deno task start

# Start on port 8080 (non-privileged)
dev-8080:
    PORT=8080 deno task dev

# Start on port 443 (privileged, requires sudo/capabilities)
dev-443:
    @echo "Starting on privileged port 443..."
    sudo -E deno task start

# Hot reload development
watch:
    deno task dev

# Check Deno version
version:
    @deno --version

# Show Deno info
info:
    deno info src/server.ts

# ============================================================================
# TESTING
# ============================================================================

# Run all tests
test:
    deno task test

# Run tests in watch mode
test-watch:
    deno task test:watch

# Run tests with coverage
test-coverage:
    deno task test
    deno coverage coverage --lcov > coverage/lcov.info

# Run specific test file
test-file file:
    deno test --allow-net --allow-read --allow-env {{file}}

# Run tests with filter
test-filter pattern:
    deno test --allow-net --allow-read --allow-env --filter {{pattern}}

# Run tests verbosely
test-verbose:
    deno test --allow-net --allow-read --allow-env --reporter=verbose

# Generate coverage report
coverage:
    deno coverage coverage --html
    @echo "Coverage report: coverage/html/index.html"

# Check test coverage percentage
coverage-check:
    #!/usr/bin/env bash
    deno coverage coverage --lcov > coverage/lcov.info
    coverage=$(deno coverage coverage | grep "Coverage" | grep -oP '\d+\.\d+')
    echo "Coverage: $coverage%"
    if (( $(echo "$coverage < 80" | bc -l) )); then
        echo "❌ Coverage below 80%"
        exit 1
    fi
    echo "✅ Coverage above 80%"

# ============================================================================
# CODE QUALITY
# ============================================================================

# Lint code
lint:
    deno lint

# Lint and show warnings
lint-verbose:
    deno lint --rules-tags=recommended

# Format code
fmt:
    deno fmt

# Format check (CI)
fmt-check:
    deno fmt --check

# Type check
check:
    deno check src/**/*.ts

# Full quality check (lint + fmt + type + test)
quality: lint fmt-check check test

# Fix all auto-fixable issues
fix: fmt lint

# ============================================================================
# SECURITY
# ============================================================================

# Security audit
security-audit:
    @echo "🔒 Checking for security issues..."
    @echo "Deno has no npm-style audit, checking permissions..."
    @grep -r "allow-" deno.json || echo "No dangerous permissions in deno.json"

# Check for sensitive data
security-scan:
    #!/usr/bin/env bash
    echo "Scanning for secrets..."
    if command -v trufflehog &> /dev/null; then
        trufflehog filesystem . --json
    else
        echo "Install trufflehog for secret scanning"
    fi

# Validate security.txt
security-validate:
    @test -f .well-known/security.txt && echo "✓ security.txt exists" || echo "❌ security.txt missing"

# Generate security report
security-report:
    @echo "Security Report"
    @echo "==============="
    @echo ""
    @echo "TLS Certificates:"
    @test -f certs/cert.pem && openssl x509 -in certs/cert.pem -noout -dates || echo "  No certificates"
    @echo ""
    @echo "Permissions in deno.json:"
    @grep -A 10 "tasks" deno.json | grep "allow"

# ============================================================================
# PODMAN / CONTAINERS
# ============================================================================

# Build container image with Podman
podman-build:
    podman build -t {{image_name}} -f Containerfile .

# Build with no cache
podman-build-nocache:
    podman build --no-cache -t {{image_name}} -f Containerfile .

# Run container with Podman
podman-run:
    podman run -d \
        --name {{container_name}} \
        -p {{port}}:443 \
        --env-file .env \
        -v $(pwd)/logs:/app/logs:Z \
        {{image_name}}

# Run container interactively
podman-run-interactive:
    podman run -it --rm \
        --name {{container_name}}-tmp \
        -p {{port}}:443 \
        --env-file .env \
        {{image_name}}

# Stop container
podman-stop:
    podman stop {{container_name}} || true

# Remove container
podman-rm: podman-stop
    podman rm {{container_name}} || true

# Remove image
podman-rmi:
    podman rmi {{image_name}} || true

# Full cleanup (containers + images)
podman-clean: podman-rm podman-rmi

# View container logs
podman-logs:
    podman logs -f {{container_name}}

# Container shell
podman-shell:
    podman exec -it {{container_name}} /bin/sh

# Inspect container
podman-inspect:
    podman inspect {{container_name}}

# Container stats
podman-stats:
    podman stats {{container_name}}

# Podman system prune
podman-prune:
    podman system prune -af

# Export container
podman-export:
    podman save {{image_name}} -o dist/{{container_name}}.tar

# Import container
podman-import:
    podman load -i dist/{{container_name}}.tar

# Podman health check
podman-health:
    podman healthcheck run {{container_name}}

# Rootless podman info
podman-info:
    podman info

# Generate systemd unit for rootless podman
podman-systemd:
    podman generate systemd --new --files --name {{container_name}}

# ============================================================================
# PODMAN COMPOSE (Pod management)
# ============================================================================

# Start with podman-compose
compose-up:
    podman-compose up -d

# Stop compose
compose-down:
    podman-compose down

# Compose logs
compose-logs:
    podman-compose logs -f

# Compose rebuild
compose-rebuild:
    podman-compose up -d --build

# ============================================================================
# DEPLOYMENT
# ============================================================================

# Deploy to production
deploy: test podman-build
    @echo "Deploying to production..."
    @just podman-stop
    @just podman-rm
    @just podman-run
    @just health-check

# Deploy with rollback capability
deploy-safe:
    #!/usr/bin/env bash
    OLD_IMAGE=$(podman ps -a --filter "name={{container_name}}" --format "{{{{.Image}}")
    just deploy
    if [ $? -ne 0 ]; then
        echo "Deployment failed, rolling back..."
        podman run -d --name {{container_name}} $OLD_IMAGE
    fi

# Blue-green deployment
deploy-blue-green:
    @echo "Blue-green deployment not yet implemented"

# ============================================================================
# MONITORING
# ============================================================================

# Health check
health-check:
    curl -f https://localhost:{{port}}/api/health || echo "Health check failed"

# Get analytics
analytics:
    curl -s https://localhost:{{port}}/api/analytics | deno run --allow-net - | head -50

# Get metrics
metrics:
    curl -s https://localhost:{{port}}/api/metrics

# Monitor logs
monitor:
    tail -f logs/combined.log

# Monitor errors only
monitor-errors:
    tail -f logs/error.log

# Real-time request monitoring
monitor-requests:
    tail -f logs/combined.log | grep "HTTP Request"

# ============================================================================
# API TESTING
# ============================================================================

# Test random error endpoint
api-test-error:
    curl -s https://localhost:{{port}}/api/error | deno run --allow-net -

# Test specific error code
api-test-code code:
    curl -s https://localhost:{{port}}/api/error/{{code}} | deno run --allow-net -

# List all error codes
api-codes:
    curl -s https://localhost:{{port}}/api/codes | deno run --allow-net - | head -50

# List all styles
api-styles:
    curl -s https://localhost:{{port}}/api/styles | deno run --allow-net -

# Test health endpoint
api-health:
    curl -s https://localhost:{{port}}/api/health | deno run --allow-net -

# ============================================================================
# DOCUMENTATION
# ============================================================================

# Generate API documentation
docs-api:
    @echo "Generating API documentation..."
    deno doc --html --name="Blue Screen of App API" src/

# Generate type documentation
docs-types:
    deno doc src/server.ts

# Convert markdown to AsciiDoc
docs-convert-adoc:
    #!/usr/bin/env bash
    for file in *.md; do
        if [ "$file" != "SECURITY.md" ] && [ "$file" != "LICENSE.md" ]; then
            pandoc "$file" -f markdown -t asciidoc -o "${file%.md}.adoc"
            echo "Converted $file to ${file%.md}.adoc"
        fi
    done

# Build documentation site
docs-build:
    @echo "Documentation build not yet implemented"

# Serve documentation locally
docs-serve:
    @echo "Documentation server not yet implemented"

# ============================================================================
# DATABASE & PERSISTENCE
# ============================================================================

# Backup data
backup:
    @echo "Creating backup..."
    tar -czf backups/backup-$(date +%Y%m%d-%H%M%S).tar.gz logs/ .env

# Restore from backup
restore file:
    tar -xzf {{file}}

# List backups
backups:
    ls -lh backups/

# ============================================================================
# PERFORMANCE
# ============================================================================

# Benchmark application
benchmark:
    @echo "Running benchmarks..."
    deno bench

# Load test with autocannon
load-test:
    #!/usr/bin/env bash
    if command -v autocannon &> /dev/null; then
        autocannon -c 100 -d 30 https://localhost:{{port}}
    else
        echo "Install autocannon: npm install -g autocannon"
    fi

# Profile application
profile:
    deno run --allow-net --allow-read --allow-env --v8-flags=--prof src/server.ts

# Memory usage
memory:
    @podman stats --no-stream {{container_name}} | grep {{container_name}}

# ============================================================================
# BUNDLING & COMPILATION
# ============================================================================

# Bundle application
bundle:
    deno task bundle

# Compile to executable
compile:
    deno task compile

# Compile for multiple platforms
compile-all:
    deno compile --target x86_64-unknown-linux-gnu --output bin/bsod-linux-x64 src/server.ts
    deno compile --target x86_64-apple-darwin --output bin/bsod-macos-x64 src/server.ts
    deno compile --target aarch64-apple-darwin --output bin/bsod-macos-arm64 src/server.ts
    deno compile --target x86_64-pc-windows-msvc --output bin/bsod-windows-x64.exe src/server.ts

# ============================================================================
# CLEANUP
# ============================================================================

# Clean generated files
clean:
    rm -rf coverage/ dist/ bin/ logs/*.log

# Clean everything including certs and deps
clean-all: clean
    rm -rf certs/ deno.lock

# Clean Podman artifacts
clean-podman: podman-clean podman-prune

# Nuclear clean (everything)
nuke: clean-all clean-podman
    @echo "🧹 Nuclear clean complete"

# ============================================================================
# UTILITIES
# ============================================================================

# Show environment info
env-info:
    @echo "Environment Information"
    @echo "======================="
    @deno --version
    @echo ""
    @podman --version
    @echo ""
    @just --version

# Count lines of code
loc:
    @echo "Lines of Code:"
    @find src -name "*.ts" | xargs wc -l | tail -1

# Project statistics
stats:
    @echo "Project Statistics"
    @echo "=================="
    @echo "Source files: $(find src -name '*.ts' | wc -l)"
    @echo "Test files: $(find tests -name '*.ts' | wc -l)"
    @echo "Total lines: $(find src tests -name '*.ts' | xargs wc -l | tail -1 | awk '{print $1}')"

# Show project tree
tree:
    tree -I 'node_modules|coverage|dist|bin|.git'

# Generate project report
report:
    @echo "Project Report" > report.txt
    @echo "==============" >> report.txt
    @echo "" >> report.txt
    @just stats >> report.txt
    @echo "" >> report.txt
    @just env-info >> report.txt
    @echo "Report generated: report.txt"

# ============================================================================
# RSR COMPLIANCE
# ============================================================================

# Verify RSR compliance
rsr-verify:
    deno task rsr:verify

# Full RSR validation
rsr-validate: rsr-verify test quality

# Generate RSR report
rsr-report:
    @echo "Generating RSR compliance report..."
    @just rsr-verify > rsr-compliance-report.txt

# ============================================================================
# CI/CD
# ============================================================================

# CI pipeline (what CI runs)
ci: install-deps quality test podman-build

# Pre-commit checks
pre-commit: fmt lint check test

# Pre-push checks
pre-push: pre-commit rsr-verify

# Release preparation
release-prep: clean-all ci
    @echo "Release Checklist:"
    @echo "  [x] Tests pass"
    @echo "  [x] Lint/format pass"
    @echo "  [x] Container builds"
    @echo "  [ ] Update CHANGELOG.adoc"
    @echo "  [ ] Update version in deno.json"
    @echo "  [ ] Create git tag"
    @echo "  [ ] Push to main"

# Tag release
tag version:
    git tag -a v{{version}} -m "Release v{{version}}"
    git push origin v{{version}}

# ============================================================================
# CERTIFICATES
# ============================================================================

# Renew certificates
certs-renew:
    rm -f certs/*.pem
    just generate-certs

# View certificate info
certs-info:
    @test -f certs/cert.pem && openssl x509 -in certs/cert.pem -noout -text || echo "No certificate"

# Validate certificate
certs-validate:
    @test -f certs/cert.pem && openssl verify certs/cert.pem || echo "Invalid certificate"

# ============================================================================
# NETWORKING
# ============================================================================

# Test QUIC connectivity
quic-test:
    @echo "Testing QUIC/HTTP3 connectivity..."
    curl --http3 -k https://localhost:{{port}}/api/health || echo "QUIC not available, falling back to HTTP/2"

# Test HTTP/2
http2-test:
    curl --http2 -k https://localhost:{{port}}/api/health

# Test HTTP/1.1
http1-test:
    curl --http1.1 -k https://localhost:{{port}}/api/health

# Port scan
port-scan:
    @echo "Scanning open ports..."
    @ss -tlnp | grep {{port}} || echo "Port {{port}} not in use"

# Network test
network-test: quic-test http2-test http1-test

# ============================================================================
# DEBUGGING
# ============================================================================

# Debug server with inspector
debug:
    deno run --inspect --allow-net --allow-read --allow-env src/server.ts

# Debug with breakpoint
debug-brk:
    deno run --inspect-brk --allow-net --allow-read --allow-env src/server.ts

# Debug tests
debug-test:
    deno test --inspect-brk --allow-net --allow-read --allow-env

# Verbose logging
verbose:
    LOG_LEVEL=debug deno task dev

# ============================================================================
# HELP
# ============================================================================

# Show detailed help
help:
    @echo "Blue Screen of App - Comprehensive Just Recipes"
    @echo "================================================"
    @echo ""
    @echo "Run 'just' to see all available recipes"
    @echo ""
    @echo "Categories:"
    @echo "  - Setup & Installation"
    @echo "  - Development"
    @echo "  - Testing"
    @echo "  - Code Quality"
    @echo "  - Security"
    @echo "  - Podman/Containers"
    @echo "  - Deployment"
    @echo "  - Monitoring"
    @echo "  - API Testing"
    @echo "  - Documentation"
    @echo "  - Performance"
    @echo "  - Bundling"
    @echo "  - Cleanup"
    @echo "  - RSR Compliance"
    @echo "  - CI/CD"
    @echo "  - Certificates"
    @echo "  - Networking"
    @echo "  - Debugging"
    @echo ""
    @echo "Total recipes: 100+"
