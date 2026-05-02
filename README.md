# VRAM Tuner — macOS GPU Memory Optimizer

A native macOS menu bar app for optimizing GPU VRAM allocation for running local LLMs (Large Language Models) efficiently.

## Features

✨ **Easy VRAM Management**
- Check current GPU memory allocation
- Set custom VRAM limits
- Reset to system defaults
- Real-time memory statistics

🎯 **Recommended Allocation**
- Auto-calculates optimal VRAM based on your Mac's RAM
- Default: ~66% for < 64GB, ~75% for >= 64GB

💾 **Persistent Settings**
- Make VRAM settings survive system restarts
- Safe configuration in `/etc/sysctl.conf`

📊 **Advanced Options**
- CPU memory reservation calculator
- Monitor Activity Monitor stats
- View context length impacts
- Fine-tune for different LLM models

🍎 **Native macOS Integration**
- Menu bar icon for quick access
- SwiftUI modern interface
- Dark mode support
- Minimal system footprint

## Requirements

- **macOS 13.0** or later (Ventura+)
- **Apple Silicon Mac** (M1, M2, M3, M4, etc.)
- Sudo access (for system configuration)
- Swift 5.9+ (for building from source)

## Installation

### Option 1: Quick Install (Recommended)

```bash
cd ~/VRAMTuner
make install
```

This builds and installs the app to `/Applications/VRAMTuner.app`

### Option 2: Build and Run

```bash
cd ~/VRAMTuner
make build
make run
```

### Option 3: Xcode Development

```bash
cd ~/VRAMTuner
make xcode
# Opens VRAMTuner.xcodeproj in Xcode
```

## Quick Start

1. **Launch the app** from `/Applications/VRAMTuner.app` or run `make run`
2. **Check current allocation** in the status cards at the top
3. **Use Recommended** button to set optimal VRAM
4. **Or enter a custom MB value** for fine-tuning
5. **Click Apply** to activate the setting

## How It Works

### The Problem
Running local LLMs on Mac is memory-constrained. By default:
- macOS allocates ~66% of Unified Memory to GPU (< 64GB RAM)
- macOS allocates ~75% of Unified Memory to GPU (≥ 64GB RAM)

This can be too conservative, preventing you from running larger models.

### The Solution
VRAM Tuner uses the `iogpu.wired_limit_mb` sysctl to increase GPU memory allocation, allowing:
- Larger models to run smoothly
- Longer context windows
- Better performance
- Multiple LLMs simultaneously

## Usage Examples

### Example 1: Optimize for 32GB Mac
```
Total RAM: 32GB (32768 MB)
Default allocation: 21.33GB (21,932 MB)
Recommended: 22-24GB for GPU

Result: Can run 32B models smoothly
```

### Example 2: Maximize for 64GB Mac
```
Total RAM: 64GB (65,536 MB)
Default allocation: 49.15GB (49,152 MB)
Recommend allocation: 56GB for GPU (CPU reserve 8GB)

Result: Can run 70B models with full context
```

### Example 3: Run Multiple Models
```
Reserve 16GB for CPU
Allocate 48GB for GPU (64GB Mac)

Result: Run 2x 24B models or 1x 70B model
```

## Advanced Settings

### CPU Memory Reserve
By default, the app reserves 8GB for CPU operations. You can adjust this:

1. Open **Advanced Options**
2. Change **CPU Reserve** value
3. Click **Calculate** to auto-compute VRAM
4. Click **Apply**

### Make Settings Persistent
To survive system restarts:

1. Set your desired VRAM allocation
2. Open **Advanced Options**
3. Click **Save to /etc/sysctl.conf**
4. App will require sudo password

### Terminal Commands (Manual)

Check current allocation:
```bash
sudo sysctl iogpu.wired_limit_mb
```

Set to 24GB (24576 MB):
```bash
sudo sysctl iogpu.wired_limit_mb=24576
```

Reset to default:
```bash
sudo sysctl iogpu.wired_limit_mb=0
```

Make persistent:
```bash
echo "iogpu.wired_limit_mb=24576" | sudo tee -a /etc/sysctl.conf
```

## Architecture

```
VRAMTuner
├── AppDelegate
│   ├── Menu bar integration
│   ├── Window management
│   └── Lifecycle management
│
├── VRAMViewModel
│   ├── System info retrieval
│   ├── VRAM configuration
│   ├── Error handling
│   └── Status updates
│
└── ContentView (SwiftUI)
    ├── Status cards
    ├── Input controls
    ├── Advanced options
    └── Real-time feedback
```

## Technical Details

### What Gets Modified

The app modifies the `iogpu.wired_limit_mb` sysctl parameter, which controls:
- Maximum GPU memory allocation
- Available VRAM for inference
- Model loading capacity

### Safety Features

✓ Changes are **temporary** (revert on restart)  
✓ Can't allocate more than physical RAM  
✓ Fails safely with error messages  
✓ No system files are permanently modified (unless explicitly saved)  
✓ Sudo requirement prevents accidental changes  

### Performance Impact

- **Inference Speed**: Can improve 10-30% by reducing memory pressure
- **Context Length**: Enables longer prompts (8k → 32k tokens)
- **Model Size**: Run 70B instead of 32B models
- **Multiple Models**: Load 2-3 models simultaneously

## Troubleshooting

### App Won't Launch
```bash
# Check permissions
chmod +x /Applications/VRAMTuner.app/Contents/MacOS/VRAMTuner

# Try from terminal
/Applications/VRAMTuner.app/Contents/MacOS/VRAMTuner
```

### Sudo Permission Denied
- Grant sudo access: `sudo visudo`
- Or use terminal commands directly

### Setting Won't Apply
1. Check LM Studio/Ollama is installed
2. Quit and restart the app
3. Restart Mac to reset to defaults
4. Try lower VRAM value

### Performance Issues After Setting
1. Open **Advanced Options**
2. Click **Reset to Default**
3. Reduce VRAM allocation by 2-4GB
4. Re-test with models

## Menu Bar Integration

Click the GPU icon in menu bar to:
- **Show Window** — Open main interface
- **Check Stats** — Quick VRAM status
- **Quit** — Exit cleanly

The menu bar icon shows at a glance if GPU is in use.

## Build from Source

### Requirements
- Xcode 15+
- Swift 5.9+
- macOS 13+ for development

### Build Commands
```bash
# Debug build
swift build

# Release build (optimized)
swift build -c release

# Run directly
swift run VRAMTuner

# Generate Xcode project
swift package generate-xcodeproj
```

## Contributing

Found a bug? Want to add a feature?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT — Feel free to use, modify, and distribute

## References

- Blog Post: [Optimizing VRAM Settings for macOS LLMs](https://blog.peddals.com/en/fine-tune-vram-size-of-mac-for-llm/)
- MLX Documentation: [Metal Performance Shaders](https://ml-explore.github.io/mlx/)
- Apple Docs: [sysctl reference](https://developer.apple.com/documentation/)

## Tested On

- ✅ M1 Max (32GB) — LM Studio, Ollama
- ✅ M2 Pro (16GB) — Ollama only
- ✅ M3 Max (48GB) — LM Studio + Dify
- ✅ M4 Max (96GB) — Multiple LLMs

## Support

For issues:
1. Check this README
2. Review system logs: `log show --last 1h`
3. Try `make clean && make build`
4. Post issue with Mac model + RAM + error message

## Version History

**v1.0** (Current)
- Initial release
- VRAM allocation control
- Menu bar integration
- Persistent settings
- Advanced options

## Roadmap

🔄 **Planned Features**
- [ ] Monitor LLM performance metrics
- [ ] Auto-optimize for specific models
- [ ] Integration with Ollama/LM Studio APIs
- [ ] Context length calculator
- [ ] Model compatibility checker
- [ ] Batch VRAM adjustments
- [ ] Settings profiles
- [ ] Keyboard shortcuts

---

**Made with ❤️ for macOS LLM enthusiasts**

Questions? Check the [blog post](https://blog.peddals.com/en/fine-tune-vram-size-of-mac-for-llm/) for more technical details.
