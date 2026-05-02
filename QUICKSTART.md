# VRAM Tuner — Quick Start Guide

## 30-Second Setup

```bash
cd ~/VRAMTuner
make install
# Open /Applications/VRAMTuner.app
```

## First Launch

1. **Click the GPU icon** in menu bar (top right)
2. **Click "Show Window"** to open the app
3. **Read your current allocation** in the cards at top
4. **Click "Use Recommended"** button
5. **Click "Apply"** — Done! ✓

## Understanding the Numbers

```
Total RAM:      Your Mac's physical memory (e.g., 32GB)
Current VRAM:   What GPU can currently use
Recommended:    Optimal allocation for your Mac
```

### Default Rules
- **< 64GB RAM**: GPU gets ~66% = (RAM × 0.66)
- **≥ 64GB RAM**: GPU gets ~75% = (RAM × 0.75)

### Your Situation

If you have a 32GB Mac:
```
Default GPU allocation: 21.33 GB (66%)
Recommended:           22-24 GB (boost by 2-3 GB)
Can now run:           32B models smoothly
```

If you have a 64GB Mac:
```
Default GPU allocation: 49.15 GB (75%)
Recommended:           56-60 GB (boost by 8-12 GB)
Can now run:           70B models with long context
```

## Three Ways to Set VRAM

### Method 1: Auto (Easiest)
```
1. Click "Use Recommended"
2. Click "Apply"
3. Done!
```

### Method 2: Custom Value
```
1. Enter desired MB value (e.g., 24576 for 24GB)
2. Click "Apply"
3. Done!
```

### Method 3: Advanced Calculator
```
1. Open "Advanced Options"
2. Adjust "CPU Reserve" (8GB default is fine)
3. Click "Calculate"
4. Click "Apply"
5. Done!
```

## Important Notes

⚠️ **Changes reset on Mac restart** unless you save them

To make changes permanent:
1. Open "Advanced Options"
2. Click "Save to /etc/sysctl.conf"
3. App will ask for password
4. Now survives restarts!

## Verify It Worked

### In LM Studio
1. Open LM Studio
2. Press `Cmd + Shift + H`
3. Check "VRAM" shows your new allocation

### In Terminal
```bash
sudo sysctl iogpu.wired_limit_mb
# Should show your value (e.g., 24576)
```

### In Ollama
```bash
grep recommendedMaxWorkingSetSize ~/.ollama/logs/server*.log | tail
# Should show updated MB value
```

## Troubleshooting

### Nothing Changed After Clicking Apply
- App might need password (check system prompt)
- Try restarting the app
- Try from Terminal: `sudo sysctl iogpu.wired_limit_mb=24576`

### Want to Reset Everything
1. Click "Reset to Default"
2. Or from Terminal: `sudo sysctl iogpu.wired_limit_mb=0`

### New VRAM Not Being Used
1. Quit LM Studio or Ollama completely
2. Wait 5 seconds
3. Restart your LLM app
4. Check VRAM allocation again

## Pro Tips

### Tip 1: Find Your Perfect Allocation
```
Start with Recommended value
Monitor with Activity Monitor:
  - Green = Good
  - Yellow = Acceptable
  - Red = Too much, reduce
```

### Tip 2: Reserved Memory Calculator
If you run apps that need RAM:
```
Example: 32GB Mac, want 4GB for Chrome
Total:     32 GB (32768 MB)
Reserve:   4 GB (4096 MB) for apps
VRAM:      28 GB (28,672 MB) for GPU
```

Then in Advanced Options:
- Set CPU Reserve to 4096
- Click Calculate
- Will show 28,672 MB

### Tip 3: Maximum vs Usable
There's a difference:
- **Allocated**: What you set
- **Usable by Model**: Allocated minus OS overhead (~1-2GB)

So if you set 24GB, models might use 22-23GB

### Tip 4: Context Length
Longer context needs more VRAM:
```
Model: 7B Q4
- 4k context: ~4GB
- 8k context: ~6GB
- 32k context: ~12GB

Allocate accordingly!
```

## Common Configurations

### Light Use (16GB Mac)
```
Reserve: 6GB for system
VRAM: 10GB
Models: 7B-13B excellent, 32B possible
```

### Medium Use (32GB Mac)
```
Reserve: 8GB for system + Chrome/VS Code
VRAM: 24GB
Models: 32B excellent, 70B possible
```

### Heavy Use (64GB Mac)
```
Reserve: 8GB for system
VRAM: 56GB
Models: 70B excellent, multiple models
```

### Max Performance (96GB Mac)
```
Reserve: 8GB for system
VRAM: 88GB
Models: Everything, multiple large models
Context: Full 32k+ without slowdown
```

## What Happens

**Before VRAM Tuning:**
- Load 32B model → Works but slow
- Load 70B model → Memory swap → System lag
- Long context → OOM (out of memory)

**After VRAM Tuning:**
- Load 32B model → Blazing fast
- Load 70B model → Works smoothly
- Long context → Works great

## Safety

Changes are **100% reversible**:

1. **Temporary** (default)
   - Set value
   - Restart Mac
   - Reverts automatically

2. **Persistent** (optional)
   - Click "Save to /etc/sysctl.conf"
   - Survives restarts
   - Can undo: Edit `/etc/sysctl.conf` manually

## Next Steps

1. **Set your VRAM** using this guide
2. **Test with your LLM app** (LM Studio/Ollama/etc)
3. **Monitor in Activity Monitor** (Cmd+Space, type "Activity Monitor")
4. **Adjust if needed** — Lower if system lags, raise if performance is low

## Getting Help

**If something goes wrong:**

1. Reset to default: `sudo sysctl iogpu.wired_limit_mb=0`
2. Restart Mac
3. Try a lower value
4. Check the blog post: https://blog.peddals.com/en/fine-tune-vram-size-of-mac-for-llm/

---

**You're ready!** Go tune your VRAM and enjoy faster LLM inference. 🚀
