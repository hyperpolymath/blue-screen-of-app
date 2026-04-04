#!/usr/bin/env bash

# Bootstrap script for Blue Screen of App
# Installs podman, just, and deno based on OS

set -e

echo "🚀 Blue Screen of App Bootstrap"
echo "================================"
echo ""

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Podman
install_podman() {
    echo "📦 Installing Podman..."

    case $OS in
        linux)
            if command_exists apt-get; then
                # Debian/Ubuntu
                sudo apt-get update
                sudo apt-get install -y podman
            elif command_exists dnf; then
                # Fedora/RHEL
                sudo dnf install -y podman
            elif command_exists pacman; then
                # Arch
                sudo pacman -S --noconfirm podman
            elif command_exists zypper; then
                # openSUSE
                sudo zypper install -y podman
            else
                echo "❌ Unsupported Linux package manager"
                echo "Please install podman manually: https://podman.io/getting-started/installation"
                exit 1
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install podman
                # Initialize podman machine for macOS
                podman machine init || true
                podman machine start || true
            else
                echo "❌ Homebrew not found"
                echo "Install Homebrew first: https://brew.sh"
                exit 1
            fi
            ;;
        windows)
            echo "On Windows, please install Podman Desktop:"
            echo "https://podman.io/getting-started/installation#windows"
            exit 1
            ;;
    esac

    echo "✅ Podman installed"
}

# Install just
install_just() {
    echo "📦 Installing just..."

    case $OS in
        linux)
            if command_exists cargo; then
                cargo install just
            elif command_exists apt-get; then
                # Try to install from package manager
                sudo apt-get install -y just || cargo install just
            elif command_exists dnf; then
                sudo dnf install -y just || cargo install just
            elif command_exists pacman; then
                sudo pacman -S --noconfirm just || cargo install just
            else
                # Download pre-built binary
                curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
            fi
            ;;
        macos)
            if command_exists brew; then
                brew install just
            else
                curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
            fi
            ;;
        windows)
            echo "On Windows, install just with:"
            echo "  cargo install just"
            echo "or download from: https://github.com/casey/just/releases"
            exit 1
            ;;
    esac

    echo "✅ just installed"
}

# Install Deno
install_deno() {
    echo "📦 Installing Deno..."

    case $OS in
        linux|macos)
            curl -fsSL https://deno.land/install.sh | sh

            # Add Deno to PATH
            export DENO_INSTALL="$HOME/.deno"
            export PATH="$DENO_INSTALL/bin:$PATH"

            # Add to shell RC files
            for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
                if [ -f "$rc" ]; then
                    if ! grep -q "DENO_INSTALL" "$rc"; then
                        echo "" >> "$rc"
                        echo '# Deno' >> "$rc"
                        echo 'export DENO_INSTALL="$HOME/.deno"' >> "$rc"
                        echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> "$rc"
                    fi
                fi
            done
            ;;
        windows)
            echo "On Windows, run:"
            echo "  irm https://deno.land/install.ps1 | iex"
            exit 1
            ;;
    esac

    echo "✅ Deno installed"
}

# Install ReScript
install_rescript() {
    echo "📦 Installing ReScript compiler..."

    # ReScript needs npm for now, but we'll use deno later
    if ! command_exists npm; then
        echo "⚠️  npm not found, skipping ReScript (you can compile manually)"
        return
    fi

    npm install -g rescript@latest
    echo "✅ ReScript installed"
}

# Check and install each tool
echo "Checking dependencies..."
echo ""

if command_exists podman; then
    echo "✅ Podman already installed ($(podman --version))"
else
    install_podman
fi

if command_exists just; then
    echo "✅ just already installed ($(just --version))"
else
    install_just
fi

if command_exists deno; then
    echo "✅ Deno already installed ($(deno --version | head -1))"
else
    install_deno
fi

if command_exists rescript; then
    echo "✅ ReScript already installed ($(rescript -version))"
else
    install_rescript
fi

echo ""
echo "================================"
echo "✅ Bootstrap complete!"
echo ""
echo "Installed:"
echo "  - Podman: $(command_exists podman && podman --version || echo 'not found')"
echo "  - just: $(command_exists just && just --version || echo 'not found')"
echo "  - Deno: $(command_exists deno && deno --version | head -1 || echo 'not found')"
echo "  - ReScript: $(command_exists rescript && rescript -version || echo 'not found')"
echo ""
echo "Next steps:"
echo "  1. Run 'just setup' to initialize the project"
echo "  2. Run 'just dev' to start development server"
echo ""
echo "For help: just help"
