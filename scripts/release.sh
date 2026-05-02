#!/bin/bash

# VRAMTuner Release Script
# Automates building, packaging, and releasing

set -e

VERSION="${1:-1.0.0}"
REPO_URL="git@github.com:zack/vram-tuner.git"
BUILD_DIR=".build/release"
DIST_DIR="dist"

echo "╔════════════════════════════════════════════════════════╗"
echo "║        VRAMTuner v$VERSION Release Pipeline            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo

# Setup
echo "📋 Setting up release..."
mkdir -p "$DIST_DIR"
rm -rf "$DIST_DIR"/*

# Build
echo "🔨 Building release binary..."
swift build -c release -v

# Create app bundle
echo "📦 Creating app bundle..."
BUNDLE="$DIST_DIR/VRAMTuner.app"
mkdir -p "$BUNDLE/Contents/MacOS"
mkdir -p "$BUNDLE/Contents/Resources"

cp "$BUILD_DIR/VRAMTuner" "$BUNDLE/Contents/MacOS/"
chmod +x "$BUNDLE/Contents/MacOS/VRAMTuner"

# Add icon if available
if [ -f "Sources/icon.png" ]; then
  echo "  Adding icon..."
  mkdir -p /tmp/VRAMTuner.iconset
  sips -z 16 16 Sources/icon.png --out /tmp/VRAMTuner.iconset/icon_16x16.png 2>/dev/null || cp Sources/icon.png "$BUNDLE/Contents/Resources/AppIcon.png"
  if [ -d "/tmp/VRAMTuner.iconset" ]; then
    iconutil -c icns -o "$BUNDLE/Contents/Resources/AppIcon.icns" /tmp/VRAMTuner.iconset 2>/dev/null || true
  fi
fi

# Create Info.plist
cat > "$BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>VRAMTuner</string>
  <key>CFBundleIdentifier</key><string>com.local.vramtuner</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>VRAMTuner</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
EOF

echo "✓ App bundle created"

# Create archive
echo "📦 Creating distribution archive..."
cd "$DIST_DIR"
zip -r "VRAMTuner-$VERSION.zip" VRAMTuner.app/
ls -lh "VRAMTuner-$VERSION.zip"
cd ..

# Create checksums
echo "🔐 Creating checksums..."
cd "$DIST_DIR"
sha256sum "VRAMTuner-$VERSION.zip" > "VRAMTuner-$VERSION.sha256"
md5sum "VRAMTuner-$VERSION.zip" > "VRAMTuner-$VERSION.md5"
cd ..

# Create release notes
echo "📝 Creating release notes..."
cat > "$DIST_DIR/RELEASE_NOTES.md" << EOF
# VRAMTuner v$VERSION

## Release Date
$(date -u +"%Y-%m-%d")

## Features
- Native macOS app for GPU VRAM optimization
- Menu bar integration
- Auto-recommended settings
- Advanced CPU reserve calculator
- Persistent configuration
- Zero external dependencies

## System Requirements
- macOS 13.0+ (Ventura or newer)
- Apple Silicon (M1, M2, M3, M4)

## Installation

### Method 1: Direct Download
1. Download \`VRAMTuner-$VERSION.zip\`
2. Unzip: \`unzip VRAMTuner-$VERSION.zip\`
3. Install: \`mv VRAMTuner.app /Applications/\`

### Method 2: One-Command Install
\`\`\`bash
curl -sL https://github.com/zack/vram-tuner/releases/download/v$VERSION/VRAMTuner-$VERSION.zip | unzip - && mv VRAMTuner.app /Applications/
\`\`\`

### Method 3: From Source
\`\`\`bash
git clone https://github.com/zack/vram-tuner.git
cd vram-tuner
make install
\`\`\`

## Usage

1. Click GPU icon in menu bar (top right)
2. Click "Show Window"
3. Click "Use Recommended" or enter custom MB value
4. Click "Apply"
5. Done! ✓

## Changes in v$VERSION

### Added
- Initial public release
- Full SwiftUI interface
- Menu bar integration
- Advanced settings panel
- Persistent configuration option

### Features
- Real-time VRAM monitoring
- Auto-recommend allocation based on Mac specs
- CPU memory reserve calculator
- Dark mode support
- Complete documentation

## Known Issues
None reported yet. [Report issues](https://github.com/zack/vram-tuner/issues)

## Checksums

### SHA-256
\`\`\`
$(cat "$DIST_DIR/VRAMTuner-$VERSION.sha256")
\`\`\`

### MD5
\`\`\`
$(cat "$DIST_DIR/VRAMTuner-$VERSION.md5")
\`\`\`

## Credits

Built with Swift 5.9+ and SwiftUI.
Based on research from [Peddals Blog](https://blog.peddals.com/en/fine-tune-vram-size-of-mac-for-llm/).

## License

MIT License - See LICENSE file for details

## Support

- [README.md](https://github.com/zack/vram-tuner#readme) - Full documentation
- [QUICKSTART.md](https://github.com/zack/vram-tuner/blob/main/QUICKSTART.md) - User guide
- [Issues](https://github.com/zack/vram-tuner/issues) - Report problems

---

**Download & enjoy faster LLM inference!** 🚀
EOF

# Summary
echo
echo "╔════════════════════════════════════════════════════════╗"
echo "║            ✅ Release Build Complete!                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo
echo "📦 Artifacts created in: $DIST_DIR/"
ls -lh "$DIST_DIR"
echo
echo "🔐 Verify checksums:"
echo "   sha256sum -c $DIST_DIR/VRAMTuner-$VERSION.sha256"
echo
echo "🚀 Next steps:"
echo "   1. Tag release: git tag v$VERSION"
echo "   2. Push tag: git push origin v$VERSION"
echo "   3. Upload to GitHub: gh release create v$VERSION $DIST_DIR/*"
echo
