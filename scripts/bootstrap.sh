#!/usr/bin/env bash

set -e

echo "🔧 Bootstrapping Swift development environment..."

# Detect OS
OS="$(uname)"
IS_MACOS=false
IS_UBUNTU=false

if [[ "$OS" == "Darwin" ]]; then
  IS_MACOS=true
elif [[ "$OS" == "Linux" ]]; then
  if grep -qi "ubuntu" /etc/os-release; then
    IS_UBUNTU=true
  fi
fi

if ! $IS_MACOS && ! $IS_UBUNTU; then
  echo "❌ Unsupported OS: $OS. Only macOS and Ubuntu are supported."
  exit 1
fi

# Install swift-format
install_swift_format() {
  if command -v swift-format >/dev/null 2>&1; then
    echo "✅ swift-format already installed"
    return
  fi

  echo "📦 Installing swift-format..."

  if $IS_MACOS; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "❌ Homebrew not found. Please install Homebrew first: https://brew.sh"
      exit 1
    fi
    brew install swift-format

  elif $IS_UBUNTU; then
    # Check if swift is installed
    if ! command -v swift >/dev/null 2>&1; then
      echo "❌ Swift is not installed. Please install Swift first: https://swift.org/download/"
      exit 1
    fi

    # Build swift-format from source
    TMP_DIR=$(mktemp -d)
    echo "📥 Cloning swift-format..."
    git clone https://github.com/apple/swift-format.git "$TMP_DIR"
    cd "$TMP_DIR"

    echo "⚙️ Building swift-format..."
    swift build -c release

    echo "📦 Installing swift-format to /usr/local/bin"
    sudo cp -f .build/release/swift-format /usr/local/bin/
    sudo chmod +x /usr/local/bin/swift-format

    echo "🧹 Cleaning up..."
    cd -
    rm -rf "$TMP_DIR"
  fi
}

# Run installation steps
install_swift_format

echo "✅ Environment setup complete!"
