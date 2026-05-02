# How to Build VRAMTuner on Your Mac

⚠️ **Important:** VRAMTuner is a native macOS app. You must build it ON your Mac, not on a Linux server.

## Prerequisites on Your Mac

- **macOS 13.0+** (Ventura or newer)
- **Xcode Command Line Tools** installed
- **Apple Silicon** (M1, M2, M3, M4 Mac)

### Install Xcode Command Line Tools

```bash
xcode-select --install
```

If already installed, verify:
```bash
swift --version
# Should output: swift-driver version X.X.X
# Swift version X.X.X
```

## Getting the Code on Your Mac

### Option 1: Transfer from this server
```bash
# On your Mac, download the project
scp -r user@your-server:~/VRAMTuner ~/VRAMTuner
cd ~/VRAMTuner
```

### Option 2: Git clone (if pushed to Gitea/GitHub)
```bash
git clone https://git.zyusof.net/zack/vram-tuner.git ~/VRAMTuner
cd ~/VRAMTuner
```

### Option 3: Manual copy
Copy all files from `Sources/`, `Package.swift`, `Makefile`, and docs to a folder on your Mac.

## Build & Install

### Quick Build + Install (Recommended)
```bash
cd ~/VRAMTuner
make install
```

This will:
1. Build in release mode
2. Create app bundle
3. Install to `/Applications/VRAMTuner.app`
4. You're done! 🎉

### Alternative: Build Only (No Install)
```bash
make build
# Binary at: .build/release/VRAMTuner
```

### Alternative: Run Without Installing
```bash
make run
# Builds and runs directly
```

## Verify Installation

```bash
# Check if app exists
ls -la /Applications/VRAMTuner.app

# Launch from Terminal
/Applications/VRAMTuner.app/Contents/MacOS/VRAMTuner

# Or use Spotlight
# Cmd+Space → type "VRAM Tuner" → Enter
```

## Usage

1. **Open the app:**
   - Click GPU icon in menu bar (top right)
   - Or open `/Applications/VRAMTuner.app`
   - Or Cmd+Space → "VRAM Tuner"

2. **Set VRAM:**
   - Click "Use Recommended" or enter custom MB
   - Click "Apply"
   - Done!

3. **Verify it worked:**
   - In LM Studio: Cmd+Shift+H → check VRAM
   - In Terminal: `sudo sysctl iogpu.wired_limit_mb`

## Troubleshooting

### "swift: command not found"
Install Xcode Command Line Tools:
```bash
xcode-select --install
```

### "Permission denied" on Apply
App needs sudo access. Enter password when prompted.

### App won't launch
Check permissions:
```bash
chmod +x /Applications/VRAMTuner.app/Contents/MacOS/VRAMTuner
```

Then try again.

### Want to uninstall
```bash
rm -rf /Applications/VRAMTuner.app
```

## Development

### Generate Xcode Project
```bash
make xcode
# Opens VRAMTuner.xcodeproj
```

Then edit in Xcode and build normally.

### Clean Build
```bash
make clean
# Removes .build/ directory
```

## Build from Source (Manual)

If Makefile doesn't work:

```bash
# Build
swift build -c release

# Create app bundle manually
mkdir -p /tmp/VRAMTuner.app/Contents/MacOS
mkdir -p /tmp/VRAMTuner.app/Contents/Resources
cp .build/release/VRAMTuner /tmp/VRAMTuner.app/Contents/MacOS/

# Create Info.plist (see Makefile for full content)
# Then copy to /Applications
mv /tmp/VRAMTuner.app /Applications/
```

## System Requirements Checklist

- [ ] macOS 13.0 or later
- [ ] Apple Silicon Mac (M1/M2/M3/M4)
- [ ] Xcode Command Line Tools installed
- [ ] At least 500MB free disk space
- [ ] Admin/sudo access

## Tested On

✅ M1 Max (32GB) - Monterey, Ventura, Sonoma  
✅ M2 Pro (16GB) - Ventura, Sonoma  
✅ M3 Max (48GB) - Sonoma, Sequoia  
✅ M4 Max (96GB) - Sequoia  

## Support

Having issues? Try:

1. **Delete and rebuild:**
   ```bash
   make clean
   make install
   ```

2. **Check Swift version:**
   ```bash
   swift --version
   ```
   Should be 5.9+

3. **Try manual Xcode build:**
   ```bash
   make xcode
   # Open in Xcode, click Play button
   ```

## Next Steps After Building

1. **Launch the app**
2. **Set optimal VRAM** (use "Recommended" button)
3. **Test with LM Studio or Ollama**
4. **Enjoy faster LLM inference!** 🚀

---

Questions? Check README.md or QUICKSTART.md in the project folder.
