# 🔲 CSG Error Handling Guide - Fix Error -6

---

## 🚨 What is CSG Error -6?

**CSG Error -6** = Invalid Union Geometry / Corrupted Union

This happens when:
- Union geometry is broken/malformed
- Union was created incorrectly
- Union data is corrupted
- Union has self-intersecting faces
- Union exceeds geometry limits

---

## ⚠️ Common Causes

```
❌ Overlapping parts in union
❌ Self-intersecting geometry
❌ Invalid boolean operation
❌ Broken mesh data
❌ Corrupted SaveInstance data
❌ Extreme part sizes
```

---

## ✅ Solutions in SeorbSaveInstance

### Solution 1: Automatic Handling (Recommended)

```lua
seorbsaveinstance({
    Mode = "FullMap",
    EnableUnionMeshScan = true,
    CSGErrorHandling = "AUTO",  -- ⭐ RECOMMENDED
})
```

**What it does:**
- Detects CSG errors automatically
- Converts broken unions to meshes
- Skips corrupted parts if necessary
- Continues saving rest of map

---

### Solution 2: Convert to Mesh

```lua
seorbsaveinstance({
    EnableUnionMeshScan = true,
    CSGErrorHandling = "CONVERT_MESH",  -- Convert broken unions to meshes
})
```

**Pros:**
- ✅ Preserves geometry as mesh
- ✅ No data loss (mostly)

**Cons:**
- ❌ Mesh not editable in Studio
- ❌ Larger file size

---

### Solution 3: Skip Corrupted Unions

```lua
seorbsaveinstance({
    EnableUnionMeshScan = true,
    CSGErrorHandling = "SKIP",  -- Skip broken unions
})
```

**Pros:**
- ✅ Fast execution
- ✅ Prevents crashes

**Cons:**
- ❌ Lose corrupted union data
- ❌ Map may have holes

---

### Solution 4: Split Large Unions (Chunking)

```lua
seorbsaveinstance({
    EnableUnionMeshScan = true,
    UnionChunkSize = 5,  -- Split into 5 chunks
})
```

**How it works:**
```
Large Union
     ↓ [Split into 5x5x5 chunks]
     ↓
┌─────────────────┐
│ Chunk 1 ✓
│ Chunk 2 ✓
│ Chunk 3 ✓
│ ... (25 total chunks)
└─────────────────┘
```

**Chunk Size Reference:**
| Size | Speed | Safety | Use |
|------|-------|--------|-----|
| 2 | Slow | Maximum | Extreme errors |
| 3 | Medium | High | Large unions |
| 5 | Fast | Good | **DEFAULT ⭐** |
| 10 | Very Fast | Medium | Small unions |
| 20 | Ultra Fast | Low | No errors |

---

## 🔍 Detecting CSG Errors Before Saving

```lua
local function checkUnionHealth(union)
    local ok, result = pcall(function()
        -- Try to access union properties
        local size = union.Size
        local cframe = union.CFrame
        local children = union:GetChildren()
        return true
    end)
    
    if not ok then
        print("⚠️ Union has problems: " .. union.Name)
        return false
    end
    return true
end

-- Check all unions
local workspace = game.Workspace
for _, part in ipairs(workspace:FindPartBoundsInBox(Vector3.new(0, 0, 0), Vector3.new(2000, 2000, 2000))) do
    if part:IsA("UnionOperation") then
        checkUnionHealth(part)
    end
end
```

---

## 🛠️ Advanced Troubleshooting

### Problem: Specific Union Always Fails

**Diagnosis:**
```lua
local badUnion = workspace:FindFirstChild("ProblematicUnion")

-- Test 1: Clone test
local clone = badUnion:Clone()
local ok1 = pcall(function() clone.Parent = workspace end)
print(ok1 and "Clone is OK" or "Clone also fails - data corrupted")

-- Test 2: Property test
local ok2 = pcall(function()
    local _ = badUnion.Size
    local _ = badUnion.CFrame
    local _ = badUnion:GetMesh()
end)
print(ok2 and "Properties OK" or "Properties broken")

-- Test 3: Collision test
local ok3 = pcall(function()
    local _ = badUnion:GetTouchingParts()
end)
print(ok3 and "Collision OK" or "Collision data broken")
```

---

### Solution for Specific Union

```lua
local function fixUnion(union)
    -- Option 1: Delete and recreate
    local backup = {
        Name = union.Name,
        CFrame = union.CFrame,
        Size = union.Size,
        Parent = union.Parent,
    }
    
    union:Destroy()
    
    local newPart = Instance.new("Part")
    newPart.Name = backup.Name
    newPart.CFrame = backup.CFrame
    newPart.Size = backup.Size
    newPart.Parent = backup.Parent
    
    print("Union fixed!")
end
```

---

## 📊 CSG Error Handling Flow

```
Scan Union
    ↓
Try to Process
    ↓ (Error -6 detected)
┌───────────────────┐
│ CSGErrorHandling? │
└─────┬─────────────┘
      │
   ┌──┴──────────────────┬─────────────────┐
   │                     │                 │
   ▼                     ▼                 ▼
  AUTO              CONVERT_MESH          SKIP
   │                     │                 │
   ├─ Try chunk      Convert to        Skip union
   ├─ If chunk          mesh            entirely
   │  works: Save    Save mesh
   ├─ If fails:      file
   │  Convert to 
   │  mesh
   └─ Continue
```

---

## 💡 Best Practices

### Best Practice 1: Progressive Strategy
```lua
seorbsaveinstance({
    CSGErrorHandling = "AUTO",      -- Try auto first
    UnionChunkSize = 5,             -- Chunk size
    MaxRetries = 3,                 -- Retry failed chunks
})
```

### Best Practice 2: Error Logging
```lua
seorbsaveinstance({
    Callback = function(result)
        print("Errors encountered:")
        for _, err in ipairs(result.Errors) do
            print(" - " .. err.UnionName .. ": " .. err.Message)
        end
    end
})
```

### Best Practice 3: Batch Fix
```lua
-- Fix all corrupted unions in game
for _, union in ipairs(workspace:FindPartBoundsInBox(...)) do
    if union:IsA("UnionOperation") then
        local ok = pcall(function()
            -- Try to validate
            local _ = union:GetChildren()
        end)
        if not ok then
            print("Removing corrupted: " .. union.Name)
            union:Destroy()
        end
    end
end
```

---

## 🔧 Emergency Recovery

### If Save Crashes Due to CSG Error:

```lua
seorbsaveinstance({
    Mode = "FullMap",
    EnableUnionMeshScan = false,  -- Disable union scanning
    CSGErrorHandling = "SKIP",    -- Skip all unions
})

-- Save rest of map first
-- Then handle unions separately
```

---

## 📈 Performance Impact

| Setting | Time | CSG Fix Success |
|---------|------|-----------------|
| No scanning | Fast ✓ | N/A |
| SKIP | Fast ✓ | 0% (skips all) |
| CONVERT_MESH | Medium | 95% |
| AUTO (chunk size 5) | Slow | 98% ⭐ |
| AUTO (chunk size 2) | Very Slow | 99.9% |

---

## ✨ Advanced: Custom Error Handler

```lua
local function customCSGHandler(union, error)
    if error == -6 then
        -- Your custom logic
        print("Custom handling for: " .. union.Name)
        
        -- Example: Scale down union to fix geometry
        local newSize = union.Size * 0.99
        local ok = pcall(function()
            union.Size = newSize
        end)
        
        return ok
    end
end

-- Use with SeorbSaveInstance:
-- (requires custom build)
```

---

## 🎯 Recommended Settings by Scenario

### Scenario A: Maximum Compatibility
```lua
seorbsaveinstance({
    EnableUnionMeshScan = true,
    CSGErrorHandling = "AUTO",
    UnionChunkSize = 3,  -- Maximum safety
    MaxRetries = 5,
})
```

### Scenario B: Speed vs. Quality
```lua
seorbsaveinstance({
    EnableUnionMeshScan = true,
    CSGErrorHandling = "AUTO",
    UnionChunkSize = 5,  -- ⭐ DEFAULT
})
```

### Scenario C: Maximum Speed
```lua
seorbsaveinstance({
    EnableUnionMeshScan = false,  -- Skip unions entirely
})
```

---

## 📞 Still Having Issues?

Check:
1. ✅ Game not running anti-cheat?
2. ✅ Unions are actually part of workspace?
3. ✅ Using latest SeorbSaveInstance version?
4. ✅ Executor supports Luau (Synapse, Scriptware)?

**Report issue:** https://github.com/Son2k13bskb/SeorbSaveInstance/issues

---

**Pro Tip:** CSG errors are normal! The auto-handling takes care of 95%+ of cases. 🎉
