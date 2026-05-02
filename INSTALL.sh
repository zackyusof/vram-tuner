#!/bin/bash

# VRAMTuner Installation Script
# One-command install from GitHub/Gitea

set -e

VERSION="1.0.0"
REPO_URL="${1:-https://github.com/zack/vram-tuner.git}"
INSTALL_DIR="$HOME/VRAMTuner"

echo "╔════════════════════════════════════════════════════════╗"
echo "║          VRAM Tuner v$VERSION Installation               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command -v swift &> /dev/null; then
    echo "❌ Swift not found. Install Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "❌ Git not found"
    exit 1
fi

echo "✓ Swift $(swift --version | grep -oE '[0-9]+\.[0-9]+') detected"
echo

# Clone/update repo
echo "📥 Cloning repository..."
if [ -d "$INSTALL_DIR" ]; then
    echo "   Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin main
else
    echo "   Cloning from $REPO_URL..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

echo "✓ Repository ready at $INSTALL_DIR"
echo

# Build
echo "🔨 Building VRAMTuner..."
make clean > /dev/null 2>&1 || true
make build -j4

echo "✓ Build complete"
echo

# Install
echo "📍 Installing to /Applications..."
make install

echo
echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ INSTALLATION COMPLETE!                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo
echo "🚀 Launch VRAMTuner:"
echo "   • Click GPU icon in menu bar"
echo "   • Cmd+Space → 'VRAM Tuner'"
echo "   • /Applications/VRAMTuner.app"
echo
echo "📖 Documentation:"
echo "   • README.md - Full technical docs"
echo "   • QUICKSTART.md - User guide"
echo
echo "🐛 Report issues:"
echo "   $REPO_URL/issues"
echo
