#!/usr/bin/env bash
# Build script for Blue Screen of App
# Compiles ReScript and exports Nickel configuration

set -euo pipefail

echo "🔨 Building Blue Screen of App..."

# Step 1: Compile ReScript
echo "📦 Compiling ReScript modules..."
if command -v rescript &> /dev/null; then
    rescript build
    echo "✅ ReScript compilation complete"
else
    echo "⚠️  ReScript not found, skipping compilation"
    echo "   Run: npm install -g rescript"
fi

# Step 2: Export Nickel configuration to JSON
echo "⚙️  Exporting Nickel configuration..."
if command -v nickel &> /dev/null; then
    nickel export --format json config.ncl > config.json
    echo "✅ Nickel configuration exported to config.json"
else
    echo "⚠️  Nickel not found, creating default config.json"
    cat > config.json <<'EOF'
{
  "app": {
    "name": "Blue Screen of App",
    "version": "2.0.0",
    "url": "https://localhost:443"
  },
  "server": {
    "port": 443,
    "host": "0.0.0.0",
    "env": "production"
  },
  "features": {
    "qrCodes": true,
    "defaultQrUrl": "https://github.com/Hyperpolymath/blue-screen-of-app",
    "analytics": true
  },
  "security": {
    "corsOrigin": "*"
  }
}
EOF
    echo "✅ Default config.json created"
fi

# Step 3: Validate compiled files exist
echo "🔍 Validating build outputs..."
if [ -f "src/ErrorMessages.bs.js" ] && [ -f "src/Analytics.bs.js" ]; then
    echo "✅ All ReScript modules compiled successfully"
elif [ -f "src/ErrorMessages.res" ]; then
    echo "⚠️  ReScript source files found but not compiled"
    echo "   .bs.js files missing - install ReScript and run 'rescript build'"
fi

if [ -f "config.json" ]; then
    echo "✅ Configuration file ready"
fi

echo ""
echo "🎉 Build complete!"
echo ""
echo "To run the server:"
echo "  deno run --allow-net --allow-read --allow-env src/server.js"
echo ""
echo "Or use the justfile:"
echo "  just dev"
