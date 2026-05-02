# VRAMTuner — Complete Deployment Pipeline

## Overview

This guide covers the complete end-to-end deployment pipeline for VRAMTuner, from source code to end-user installation.

---

## 📊 Pipeline Architecture

```
Source Code (GitHub/Gitea)
    ↓
GitHub Actions / Gitea Actions (CI/CD)
    ├─ Build (Swift)
    ├─ Test & Lint
    ├─ Create App Bundle
    └─ Generate Artifacts
    ↓
Automated Releases
    ├─ GitHub Releases
    ├─ Distribution Archives
    ├─ Checksums & Signatures
    └─ Release Notes
    ↓
User Installation
    ├─ Direct Download
    ├─ One-Command Install
    └─ From Source Build
```

---

## 🔧 Components

### 1. Build Automation

**Files:**
- `.github/workflows/build.yml` — GitHub Actions workflow
- `.gitea/workflows/build.yml` — Gitea Actions workflow
- `Makefile` — Local build commands
- `Package.swift` — Swift Package definition

**Triggers:**
- Push to `main` branch
- Pull requests to `main`
- Tag creation (`v*`)

**Jobs:**
- ✅ Build with Swift 5.9+
- ✅ Lint & validate
- ✅ Create app bundle
- ✅ Upload artifacts
- ✅ Deploy releases

### 2. Release Automation

**Files:**
- `scripts/release.sh` — Release pipeline script
- `.release` — Release configuration
- `INSTALL.sh` — User installation script

**Output:**
- VRAMTuner-{version}.zip
- VRAMTuner-{version}.sha256
- VRAMTuner-{version}.md5
- RELEASE_NOTES.md

### 3. Distribution

**Methods:**
1. GitHub Releases (automated)
2. Direct download link
3. One-command installer
4. Source code clone

---

## 📈 Step-by-Step Deployment

### Step 1: Push to GitHub

```bash
# Add GitHub remote
git remote add github https://github.com/zack/vram-tuner.git

# Push code
git push -u github main

# Push all branches
git push github --all
git push github --tags
```

### Step 2: Enable GitHub Actions

1. Go to GitHub repository
2. Click "Actions" tab
3. Enable Actions for the repository
4. Workflows automatically run on push

### Step 3: Create Release

```bash
# Tag the release
git tag v1.0.0
git push github v1.0.0

# GitHub Actions automatically:
# - Builds release binary
# - Creates app bundle
# - Generates checksums
# - Creates release page
```

### Step 4: Publish Release

GitHub Actions creates the release automatically when you push a tag. Or manually:

```bash
# Using GitHub CLI
gh release create v1.0.0 \
  dist/VRAMTuner-1.0.0.zip \
  --title "VRAMTuner v1.0.0" \
  --generate-notes
```

### Step 5: User Installation

Users can then:

```bash
# Method 1: Download and unzip
unzip VRAMTuner-1.0.0.zip
mv VRAMTuner.app /Applications/

# Method 2: One-command
curl -sL https://github.com/zack/vram-tuner/releases/download/v1.0.0/INSTALL.sh | bash

# Method 3: From source
git clone https://github.com/zack/vram-tuner.git
cd vram-tuner
make install
```

---

## 🔐 Security & Integrity

### Checksums

GitHub Actions automatically generates:
- SHA-256 hashes
- MD5 hashes
- Release notes with checksums

Users verify:
```bash
sha256sum -c VRAMTuner-1.0.0.sha256
# VRAMTuner-1.0.0.zip: OK
```

### Code Signing (Optional)

For App Store distribution:
```bash
# Configure in .release
CODE_SIGN_REQUIRED=true
CODE_SIGN_IDENTITY="Developer ID Application: Name"
```

### Notarization (Optional)

For Gatekeeper compliance:
```bash
# Configure in .release
NOTARIZE=true

# GitHub Actions will:
# 1. Build binary
# 2. Create DMG
# 3. Submit to Apple
# 4. Wait for approval
# 5. Staple ticket
```

---

## 📦 Release Assets

### Each Release Includes

1. **VRAMTuner-{version}.zip**
   - Complete app bundle
   - Ready to extract to /Applications
   - Size: ~15-20 MB

2. **VRAMTuner-{version}.sha256**
   - SHA-256 checksum for verification

3. **VRAMTuner-{version}.md5**
   - MD5 checksum for verification

4. **RELEASE_NOTES.md**
   - Version info
   - Features & changes
   - Installation instructions
   - Checksums
   - System requirements

5. **Artifacts**
   - Build logs (if failed)
   - Debug symbols (if included)

---

## 🚀 Deployment Commands

### Local Development Build

```bash
cd ~/VRAMTuner
make clean      # Clean build directory
make build      # Build for testing
make run        # Build and run
make install    # Build and install to /Applications
```

### Release Build

```bash
# Automated via GitHub Actions
git tag v1.0.0
git push github v1.0.0

# Or manual release script
./scripts/release.sh 1.0.0
```

### Verify Installation

```bash
# Check app
ls -la /Applications/VRAMTuner.app

# Test launch
/Applications/VRAMTuner.app/Contents/MacOS/VRAMTuner

# Verify in menu bar
# Should see GPU icon after launch
```

---

## 🔄 Continuous Integration

### On Every Push to Main

1. ✅ Build with Swift
2. ✅ Run linter & validator
3. ✅ Create app bundle
4. ✅ Upload artifacts
5. ✅ Publish artifact URLs

### On Every Tag (Release)

1. ✅ All above steps
2. ✅ Generate checksums
3. ✅ Create release notes
4. ✅ Create GitHub Release
5. ✅ Upload distribution files
6. ✅ Notify users

### Build Status

View at: `https://github.com/zack/vram-tuner/actions`

---

## 📊 Metrics & Monitoring

### CI/CD Metrics

- Build time: ~30 seconds
- Success rate: Should be 100%
- Test coverage: N/A (Swift compilation)
- Artifact size: ~15-20 MB zip

### Deployment Tracking

GitHub Actions provides:
- Build logs (each workflow)
- Artifact downloads (metrics)
- Release downloads (analytics)
- Commit history

---

## 🛠️ Troubleshooting

### Build Fails

1. Check workflow logs: Actions tab → latest run
2. Verify Swift version: workflow shows 5.9+
3. Check syntax: `swift build` locally
4. View full error: Click failed job

### Release Not Created

1. Verify tag format: `v` + semver (v1.0.0)
2. Check Actions enabled on GitHub
3. Wait for workflow to complete (2-5 min)
4. Check Releases page: might need refresh

### App Won't Install

1. Verify SHA-256: `sha256sum -c`
2. Check macOS version: must be 13.0+
3. Check app permissions: `chmod +x`
4. Try from source: `make install`

### Can't Download

1. Check GitHub connection
2. Try different release asset
3. Use one-command installer
4. Clone and build from source

---

## 📋 Deployment Checklist

- [ ] Code changes complete & tested
- [ ] Documentation updated
- [ ] Version number bumped
- [ ] Changelog updated
- [ ] Tests passing locally
- [ ] Git commit created
- [ ] Tag created (`git tag v1.0.0`)
- [ ] Tag pushed (`git push origin v1.0.0`)
- [ ] GitHub Actions workflow running
- [ ] Build successful
- [ ] App bundle created
- [ ] Checksums generated
- [ ] Release page auto-created
- [ ] Assets uploaded
- [ ] Release published
- [ ] Announce release

---

## 🎯 Full Deployment Workflow

```bash
# 1. Commit changes
git add .
git commit -m "Your changes"
git push origin main

# 2. Tag release
git tag v1.0.0 -a -m "VRAMTuner v1.0.0: [features]"
git push origin v1.0.0

# 3. Wait for GitHub Actions (2-5 minutes)
# Watch: https://github.com/zack/vram-tuner/actions

# 4. Check release
# Go to: https://github.com/zack/vram-tuner/releases

# 5. Users can now install:
# Download from GitHub Releases
# Or: One-command install
# Or: Clone and build
```

---

## 📚 References

- **Build Tool**: Swift Package Manager
- **Build System**: Makefile
- **CI/CD Platforms**: GitHub Actions, Gitea Actions
- **Distribution**: GitHub Releases
- **Installation**: INSTALL.sh, Makefile

---

## 📞 Support

For issues with the deployment pipeline:
1. Check GitHub Actions logs
2. Review workflow files (.github/workflows/)
3. Test locally with `make build`
4. Check script permissions: `chmod +x`

For end-user installation issues:
1. Verify macOS version (13.0+)
2. Verify Apple Silicon Mac
3. Try `make install` from source
4. Check documentation

---

**Deployment pipeline complete and ready for production.** 🚀
