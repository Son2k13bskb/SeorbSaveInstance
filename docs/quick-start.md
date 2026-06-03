# 🚀 Quick Start Guide - SeorbSaveInstance

## 1️⃣ Basic Usage (30 seconds)

Copy & paste this into any Roblox executor:

```lua
local seorbsaveinstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/Son2k13bskb/SeorbSaveInstance/main/seoSaveInstance.luau", true), "SeorbSaveInstance")()

seorbsaveinstance({
    Mode = "FullMap",
    ShowStatus = true,
})
```

✅ Done! Your map will be saved to workspace.

---

## 2️⃣ Options Explained

### Minimal Configuration
```lua
seorbsaveinstance({
    FilePath = "MyGame",
    AntiKickLevel = 7,  -- Maximum security
})
```

### Full Configuration
```lua
seorbsaveinstance({
    -- Scanning
    Mode = "FullMap",              -- What to scan: FullMap, TerrainOnly, UnionOnly
    EnableTerrainScan = true,      -- Scan terrain
    EnableUnionMeshScan = true,    -- Scan unions & meshes
    
    -- Anti-Kick
    AntiKickLevel = 7,             -- 1-7 (7 = maximum)
    RequestThrottle = 150,         -- Milliseconds between requests
    HumanizeRequests = true,       -- Randomize request patterns
    
    -- Output
    FilePath = "FullMap_Export",   -- Save file name
    SaveToWorkspace = true,        -- Auto-save to workspace
    
    -- Other
    ShowStatus = true,             -- Show progress
    RemovePlayerCharacters = true, -- Remove players
})
```

---

## 3️⃣ Anti-Kick Levels Explained

| Level | Safety | Speed | Use Case |
|-------|--------|-------|----------|
| **1** | Low | Fast ⚡ | Testing only |
| **3** | Medium | Normal | Small maps |
| **5** | High | Slow 🐢 | Medium maps |
| **7** | Maximum | Very Slow | Large maps / High security |

**Recommendation:** Use Level 7 for big games!

---

## 4️⃣ Common Scenarios

### Scenario A: Save Only Terrain
```lua
seorbsaveinstance({
    Mode = "TerrainOnly",
    EnableTerrainScan = true,
    EnableUnionMeshScan = false,
    FilePath = "Terrain_Only",
})
```

### Scenario B: Full Map (Safe Mode)
```lua
seorbsaveinstance({
    Mode = "FullMap",
    AntiKickLevel = 7,
    RequestThrottle = 200,  -- Extra safe
    ShowStatus = true,
})
```

### Scenario C: Fix Corrupted Unions
```lua
seorbsaveinstance({
    Mode = "FullMap",
    EnableUnionMeshScan = true,
    UnionChunkSize = 10,  -- Smaller chunks = safer
    CSGErrorHandling = "AUTO",  -- Auto-fix CSG -6
})
```

### Scenario D: Silent Mode (No Output)
```lua
seorbsaveinstance({
    Mode = "FullMap",
    ShowStatus = false,  -- Silent
    AntiKickLevel = 7,
})
```

---

## 5️⃣ Troubleshooting

### ❌ Script Errors
**Solution:** Make sure you're using a **Luau-compatible executor** (Synapse X, Scriptware, etc.)

### ❌ "Connection Timeout"
**Solution:** Increase `RequestThrottle`:
```lua
seorbsaveinstance({ RequestThrottle = 300 })  -- 300ms
```

### ❌ Kicked by Server
**Solution:** Increase `AntiKickLevel`:
```lua
seorbsaveinstance({ AntiKickLevel = 7 })  -- Maximum
```

### ❌ Union Not Saving (CSG -6 Error)
**Solution:** Enable union fix:
```lua
seorbsaveinstance({
    EnableUnionMeshScan = true,
    CSGErrorHandling = "AUTO",
})
```

### ❌ File Not Saving to Workspace
**Solution:** Check your executor file permissions or use:
```lua
seorbsaveinstance({ SaveToWorkspace = true })
```

---

## 6️⃣ File Output

After running, your files are saved to:

**Windows:**
```
C:\Users\[YourUsername]\AppData\Local\Roblox\Workspace\
```

**Mobile/Mac:**
```
~/.roblox/workspace/
```

Files created:
- `SeorbSaveInstance_FullMap.rbxlx` (Main map)
- `SeorbSaveInstance_FullMap_Metadata.json` (Info)
- `terrain_data.json` (Terrain only)

---

## 7️⃣ Performance Tips

| Setting | Faster ⚡ | Safer 🛡️ |
|---------|----------|----------|
| AntiKickLevel | 1-3 | 5-7 |
| RequestThrottle | 50ms | 200-300ms |
| UnionChunkSize | 20+ | 2-5 |
| HumanizeRequests | false | true |

---

## 8️⃣ Advanced: Custom Callback

```lua
seorbsaveinstance({
    Mode = "FullMap",
    Callback = function(data)
        print("Scan complete!")
        print("Objects found: " .. data.TotalObjects)
        print("Execution time: " .. data.ExecutionTime .. "s")
    end
})
```

---

## 🎯 Next Steps

- ✅ Explore [Full Documentation](./full-documentation.md)
- ✅ Check [Advanced Options](./advanced-options.md)
- ✅ Read [Troubleshooting Guide](./troubleshooting.md)

---

**Need help?** Open an issue on GitHub: https://github.com/Son2k13bskb/SeorbSaveInstance/issues
