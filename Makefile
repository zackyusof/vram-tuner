.PHONY: build run clean install help

PROJECT_NAME = VRAMTuner
BUILD_DIR = .build
APP_NAME = VRAMTuner.app
BUNDLE_PATH = $(BUILD_DIR)/release/$(APP_NAME)

help:
	@echo "VRAMTuner - macOS VRAM Optimization Tool"
	@echo ""
	@echo "Available targets:"
	@echo "  make build      - Build the application"
	@echo "  make run        - Build and run the application"
	@echo "  make install    - Install to /Applications"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make xcode      - Generate Xcode project"

build:
	@echo "Building VRAMTuner..."
	swift build -c release

run: build
	@echo "Launching VRAMTuner..."
	swift run -c release VRAMTuner

install: build
	@echo "Installing to /Applications..."
	@if [ -d "/Applications/VRAMTuner.app" ]; then \
		rm -rf /Applications/VRAMTuner.app; \
	fi
	@echo "Creating app bundle..."
	@mkdir -p /tmp/VRAMTuner.app/Contents/MacOS
	@mkdir -p /tmp/VRAMTuner.app/Contents/Resources
	@cp $(BUILD_DIR)/release/VRAMTuner /tmp/VRAMTuner.app/Contents/MacOS/
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '<plist version="1.0">' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '<dict>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>CFBundleDevelopmentRegion</key><string>en</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>CFBundleExecutable</key><string>VRAMTuner</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>CFBundleIdentifier</key><string>com.local.vramtuner</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>CFBundleName</key><string>VRAMTuner</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>CFBundlePackageType</key><string>APPL</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>CFBundleShortVersionString</key><string>1.0</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>CFBundleVersion</key><string>1</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>LSMinimumSystemVersion</key><string>13.0</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '  <key>NSPrincipalClass</key><string>NSApplication</string>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '</dict>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@echo '</plist>' >> /tmp/VRAMTuner.app/Contents/Info.plist
	@mv /tmp/VRAMTuner.app /Applications/
	@echo "✓ VRAMTuner installed to /Applications/VRAMTuner.app"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "✓ Clean complete"

xcode:
	@echo "Generating Xcode project..."
	@swift package generate-xcodeproj
	@echo "✓ Open VRAMTuner.xcodeproj with Xcode"
