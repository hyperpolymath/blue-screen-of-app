# Containerfile for Podman (replaces Dockerfile)
# Multi-stage build for Blue Screen of App with Deno

# Stage 1: Builder
FROM docker.io/denoland/deno:alpine-1.39.1 AS builder

WORKDIR /app

# Copy deno configuration
COPY deno.json deno.lock* ./

# Copy source code
COPY src/ ./src/
COPY tests/ ./tests/

# Cache dependencies
RUN deno cache src/server.ts

# Run tests
RUN deno test --allow-net --allow-read --allow-env

# Stage 2: Runtime
FROM docker.io/denoland/deno:alpine-1.39.1

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S denouser && \
    adduser -S denouser -u 1001 -G denouser

WORKDIR /app

# Copy application from builder
COPY --from=builder --chown=denouser:denouser /app ./

# Copy additional files
COPY --chown=denouser:denouser .well-known/ ./.well-known/
COPY --chown=denouser:denouser LICENSES/ ./LICENSES/

# Create logs directory
RUN mkdir -p logs && chown denouser:denouser logs

# Switch to non-root user
USER denouser

# Expose privileged port 443 (requires --cap-add=NET_BIND_SERVICE or rootless)
EXPOSE 443

# Health check using deno
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD deno run --allow-net scripts/healthcheck.ts || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["deno", "run", "--allow-net", "--allow-read", "--allow-env", "src/server.ts"]
