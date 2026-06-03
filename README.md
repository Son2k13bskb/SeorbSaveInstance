# 🌍 SeorbSaveInstance - Advanced Full Map SaveInstance

<p align="center">
  <img src="https://img.shields.io/badge/Language-Luau-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Status-Production%20Ready-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Anti--Kick-Level%207-red?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" />
</p>

---

## 📋 About

**SeorbSaveInstance** is an advanced, full-map saveinstance tool for Roblox that extends **[UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance)** with:

✅ **100% Full Map Scanning** - Every object, terrain, union, and mesh  
✅ **Anti-Kick Levels 1-7** - Customize security vs. speed  
✅ **CSG Error -6 Auto-Fix** - Corrupted unions handled automatically  
✅ **Terrain Full Support** - Complete voxel scanning  
✅ **Multi-Platform** - PC, Mobile, Web support  
✅ **Production Ready** - Professional-grade code  

---

## 🚀 Quick Start (30 seconds)

```lua
local seorbsaveinstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/Son2k13bskb/SeorbSaveInstance/main/seoSaveInstance.luau", true), "SeorbSaveInstance")()

seorbsaveinstance({
    Mode = "FullMap",
    AntiKickLevel = 7,
    ShowStatus = true,
})
```

✅ **Done!** Your map will be saved to your workspace folder.

---

## 🎯 Key Features

### 1. Full Map Scanning (100%)
- 🔍 Scans entire workspace recursively
- 🗺️ Includes all instances: parts, models, services
- ⚡ Optimized traversal with anti-kick delays
- 📊 Progress tracking & status updates

### 2. Terrain Scanning
- 🌱 Full terrain voxel detection
- 🎨 Material & size capture
- 📦 Terrain serialization
- 🔄 Automatic workspace saving

### 3. Union & Mesh Processing
- 🔲 Union operation detection
- 🎯 Mesh scanning
- 🛠️ CSG -6 error handling
- ✂️ Automatic union chunking

### 4. Anti-Kick Security (Levels 1-7)
```
Level 1: Basic       (⚡ Fast, but High Detection Risk)
Level 5: Expert      (✓ Recommended, Balanced)
Level 7: Maximum     (🔒 Maximum Stealth, Slow)
```

### 5. Multi-Platform Support
- 💻 **Windows:** `C:\Users\[User]\AppData\Local\Roblox\Workspace\`
- 📱 **Mobile:** `/storage/emulated/0/Roblox/Workspace/`
- 🌐 **Web:** IndexedDB / LocalStorage

### 6. Error Handling
- 🆘 CSG -6 corruption detection
- 🔧 Auto-fix with 3 strategies
- 📋 Detailed error logging
- 🔄 Retry mechanisms

---

## 📖 Documentation

| Guide | Purpose | Time |
|-------|---------|------|
| [Quick Start](./docs/quick-start.md) | 30-second setup | ⚡ 5 min |
| [Anti-Kick Guide](./docs/anti-kick-guide.md) | Security levels 1-7 | 📖 10 min |
| [CSG Errors](./docs/csg-error-handling.md) | Fix corrupted unions | 🔧 15 min |
| [Changelog](./CHANGELOG.md) | Version history | 📋 5 min |

---

## ⚙️ Configuration

### Minimal Setup
```lua
seorbsaveinstance({
    Mode = "FullMap",
})
```

### Full Configuration
```lua
seorbsaveinstance({
    -- Scanning
    Mode = "FullMap",                  -- FullMap, TerrainOnly, UnionOnly
    EnableTerrainScan = true,
    EnableUnionMeshScan = true,
    
    -- Anti-Kick
    AntiKickLevel = 5,                 -- 1-7 (default: 5)
    RequestThrottle = 100,             -- ms between requests
    HumanizeRequests = true,
    
    -- Output
    FilePath = "FullMap_Export",
    SaveToWorkspace = true,
    
    -- Other
    ShowStatus = true,
    RemovePlayerCharacters = true,
    UnionChunkSize = 5,                -- Smaller = safer
    CSGErrorHandling = "AUTO",         -- AUTO, CONVERT_MESH, SKIP
})
```

---

## 🛡️ Anti-Kick Levels

### Quick Comparison

| Level | Throttle | Safety | Use Case |
|-------|----------|--------|----------|
| **1** | 10ms | Low ❌ | Testing |
| **3** | 50ms | Medium ⚠️ | Small maps |
| **5** | 100ms | High ✓ | Recommended |
| **7** | 250ms | Maximum 🔒 | High security |

**Recommendation:** Use Level 5 for most games, Level 7 for strict servers.

### How Anti-Kick Works

```
Level 5 includes:
├─ Request throttling (100ms base)
├─ Humanized delays (±20% variance)
├─ Connection pooling
├─ Request spoofing
├─ Memory cleaning
└─ Timeout randomization
```

---

## 🔲 CSG Error Handling

### What is CSG Error -6?
Corrupted union geometry that can't be processed.

### How SeorbSaveInstance Handles It

```lua
-- Automatic (Recommended)
seorbsaveinstance({
    CSGErrorHandling = "AUTO",      -- Tries all strategies
})

-- Convert to Mesh
seorbsaveinstance({
    CSGErrorHandling = "CONVERT_MESH", -- Fallback to mesh
})

-- Skip
seorbsaveinstance({
    CSGErrorHandling = "SKIP",      -- Skip corrupted unions
})
```

**[Full CSG Guide →](./docs/csg-error-handling.md)**

---

## 📊 Performance

| Map Size | Scan Time | Level 5 | Level 7 |
|----------|-----------|---------|---------|
| Small (1K objects) | 5s | 10s | 25s |
| Medium (10K objects) | 15s | 35s | 90s |
| Large (50K+ objects) | 45s | 150s+ | 500s+ |

---

## 🎓 Common Use Cases

### Scenario A: Save Full Map Safely
```lua
seorbsaveinstance({
    Mode = "FullMap",
    AntiKickLevel = 5,
    ShowStatus = true,
})
```

### Scenario B: Maximum Security
```lua
seorbsaveinstance({
    Mode = "FullMap",
    AntiKickLevel = 7,
    RequestThrottle = 300,
    HumanizeRequests = true,
})
```

### Scenario C: Terrain Only
```lua
seorbsaveinstance({
    Mode = "TerrainOnly",
    EnableTerrainScan = true,
    EnableUnionMeshScan = false,
})
```

### Scenario D: Fix Corrupted Map
```lua
seorbsaveinstance({
    EnableUnionMeshScan = true,
    CSGErrorHandling = "AUTO",
    UnionChunkSize = 3,  -- Extra safe
})
```

---

## ⚠️ Important Disclaimers

### License & Attribution
> **You MUST include this credit:**  
> `SeorbSaveInstance https://github.com/Son2k13bskb/SeorbSaveInstance`  
> `(Based on UniversalSynSaveInstance https://github.com/luau/UniversalSynSaveInstance)`  
> `UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw`

### Terms of Use
This tool is for:
✅ Development & debugging  
✅ Archival & research  
✅ Personal learning  

NOT for:
❌ Violating Roblox ToS  
❌ Stealing assets  
❌ Unauthorized access  

**Users are responsible for compliance with Roblox's Terms of Use.**

---

## 🚀 Installation

### Method 1: Copy-Paste (Easiest)
Just copy the loadstring from above and paste into any Roblox executor!

### Method 2: Manual Download
1. Download `seoSaveInstance.luau`
2. Load it in your executor
3. Call the function with options

---

## 📞 Support & Issues

- 🐛 **Found a bug?** [Report it on GitHub](https://github.com/Son2k13bskb/SeorbSaveInstance/issues)
- 💬 **Need help?** Check the [documentation](./docs/)
- 📚 **Want details?** Read the [guides](./docs/)

---

## 🔗 Related Projects

- **UniversalSynSaveInstance** - Base project: https://github.com/luau/UniversalSynSaveInstance
- **Synapse X** - Original inspiration: https://github.com/Acrillis/SynapseX
- **Roblox Format Specs** - Technical reference: https://github.com/RobloxAPI/spec/

---

## 📜 License

This project is licensed under **MIT License** with **USSI Attribution**.

**Important:** You must always include proper attribution to:
- UniversalSynSaveInstance (Original)
- SeorbSaveInstance (This Fork)

See [LICENSE](./LICENSE) for details.

---

## ✨ Credits

### Original (UniversalSynSaveInstance)
- **Creator:** luau Organization
- **Contributors:** Anaminus, Dekkonot, mblouka, Acrillis
- **Inspiration:** Moon/LorekeeperZinnia (Original saveinstance)

### This Fork (SeorbSaveInstance)
- **Author:** Son2k13bskb
- **Enhancements:** Full map scanning, Anti-kick L1-7, CSG error handling

---

## 🎉 Getting Started

**New to SeorbSaveInstance?**

1. ⚡ **Start here:** [Quick Start Guide](./docs/quick-start.md)
2. 🛡️ **Understand security:** [Anti-Kick Guide](./docs/anti-kick-guide.md)
3. 🔧 **Handle errors:** [CSG Error Guide](./docs/csg-error-handling.md)
4. 📋 **See what's new:** [Changelog](./CHANGELOG.md)

---

**⭐ If this tool helps you, please star the repository! It helps others find this project!**

---

**Status:** 🟢 Production Ready | **Version:** 1.0.0 | **Last Updated:** 2026-06-03
