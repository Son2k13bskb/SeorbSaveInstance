# 🛡️ Anti-Kick Security Guide - Level 1-7

---

## 📊 Quick Comparison

```
Level 1 | Basic        | ████░░░░░░ | Detection Risk: VERY HIGH
Level 2 | Enhanced     | ██████░░░░ | Detection Risk: HIGH
Level 3 | Advanced     | ████████░░ | Detection Risk: MEDIUM
Level 4 | Professional | ██████████ | Detection Risk: MEDIUM-LOW
Level 5 | Expert       | ██████████ | Detection Risk: LOW ✓
Level 6 | Ultra        | ██████████ | Detection Risk: VERY LOW
Level 7 | Maximum      | ██████████ | Detection Risk: MINIMUM ⭐
```

---

## 🔍 What Each Level Does

### **Level 1: Basic**
- Standard request timing
- No throttling
- No obfuscation

```lua
seorbsaveinstance({ AntiKickLevel = 1 })
```

**Use Case:** Small private games / Testing  
**Detection Risk:** 🔴 Very High  
**Recommended:** NO - Only for testing

---

### **Level 2: Enhanced**
- Basic request throttling (25ms)
- Minimal delays between requests

```lua
seorbsaveinstance({ AntiKickLevel = 2 })
```

**Included Features:**
- Request delays
- Basic randomization

**Use Case:** Small games with lenient servers  
**Detection Risk:** 🔴 High  
**Recommended:** Only for small maps

---

### **Level 3: Advanced**
- Request throttling (50ms)
- Basic humanization

```lua
seorbsaveinstance({ AntiKickLevel = 3 })
```

**Included Features:**
- 50ms delays between requests
- Request pattern randomization
- Variance in timing (±500ms)

**Use Case:** Medium games / Semi-private  
**Detection Risk:** 🟡 Medium  
**Recommended:** For most users

---

### **Level 4: Professional**
- Request throttling (75ms)
- Connection pooling
- Request spoofing

```lua
seorbsaveinstance({ AntiKickLevel = 4 })
```

**Included Features:**
- Advanced throttling
- Connection obfuscation
- Request ID randomization
- User-agent spoofing (basic)

**Use Case:** Large games / Public games  
**Detection Risk:** 🟡 Medium-Low  
**Recommended:** For larger maps

---

### **Level 5: Expert** ⭐ (RECOMMENDED)
- Request throttling (100ms)
- Advanced humanization
- Full request spoofing
- Connection pooling

```lua
seorbsaveinstance({ AntiKickLevel = 5 })
```

**Included Features:**
- All Level 4 features +
- Advanced humanization patterns
- Memory cleaning between requests
- Thread rotation
- Request signature spoofing

**Use Case:** Most games / Standard security  
**Detection Risk:** 🟢 Low  
**Recommended:** **YES - Default choice**

---

### **Level 6: Ultra**
- Request throttling (150ms)
- Enhanced obfuscation
- Behavioral randomization

```lua
seorbsaveinstance({ AntiKickLevel = 6 })
```

**Included Features:**
- All Level 5 features +
- Detection bypass patterns
- Enhanced timeout randomization (±50%)
- Noise injection
- Request batching

**Use Case:** High-security games / Anti-cheat detection  
**Detection Risk:** 🟢 Very Low  
**Recommended:** For high-security servers

---

### **Level 7: Maximum** 🔒 (PARANOID MODE)
- Request throttling (250ms)
- Maximum obfuscation
- Complete behavioral randomization

```lua
seorbsaveinstance({ AntiKickLevel = 7 })
```

**Included Features:**
- All Level 6 features +
- Maximum timeout randomization (±70%)
- Request header obfuscation
- Connection signature spoofing
- Advanced memory cleanup
- Rate limiting simulation
- Server fingerprint evasion
- Behavioral AI patterns

**Use Case:** Extreme security games / Long-term operations  
**Detection Risk:** 🔴 Minimum  
**Speed:** 🐢 Very Slow (5-10x slower)  
**Recommended:** For high-risk games ONLY

---

## ⚙️ Configuration Details

### Custom Anti-Kick Settings

```lua
seorbsaveinstance({
    AntiKickLevel = 5,
    RequestThrottle = 100,              -- Base delay (ms)
    HumanizeRequests = true,            -- Randomize patterns
    TimeoutRandomization = 0.5,         -- ±50%
    MaxRetries = 3,                     -- Retry failed requests
    EnableConnectionPooling = true,     -- Parallel requests
    EnableRequestSpoofing = true,       -- Fake user agents
    EnableMemoryCleaning = true,        -- Clear memory between ops
})
```

### Request Throttle Values by Level

| Level | Base Delay | + Humanization | Total Range |
|-------|-----------|----------------|-------------|
| 1 | 10ms | ±0% | 10ms |
| 2 | 25ms | ±5% | 24-26ms |
| 3 | 50ms | ±10% | 45-55ms |
| 4 | 75ms | ±15% | 64-86ms |
| 5 | 100ms | ±20% | 80-120ms |
| 6 | 150ms | ±35% | 98-203ms |
| 7 | 250ms | ±70% | 75-425ms |

---

## 🎯 Choosing Your Level

### Quick Decision Tree

```
START
├─ Private Game?
│  └─ YES → Use Level 1-3
│
├─ Semi-Public Game?
│  └─ YES → Use Level 5 ⭐ (RECOMMENDED)
│
├─ Public Game with Anti-Cheat?
│  └─ YES → Use Level 6-7
│
├─ Extremely Strict Server?
│  └─ YES → Use Level 7
│
└─ Not Sure?
   └─ Use Level 5 (Balanced & Safe)
```

---

## 📈 Performance vs. Security

```
              SPEED (Execution Time)
                    ↑
                    |
         Level 1    | ████ 5 seconds
         Level 2    | █████ 10 seconds
         Level 3    | ██████ 15 seconds
         Level 4    | ███████ 25 seconds
         Level 5    | ████████ 35 seconds ⭐ BEST
         Level 6    | █████████ 50 seconds
         Level 7    | ██████████████ 90+ seconds
                    |_______________________________________
                    SECURITY (Detection Avoidance) →
```

---

## 🚨 Common Mistakes

### ❌ Mistake 1: Too Aggressive (Level 1 on Public Game)
```lua
-- BAD ❌
seorbsaveinstance({ AntiKickLevel = 1 })  -- TOO FAST!
```
**Result:** Kicked immediately

```lua
-- GOOD ✅
seorbsaveinstance({ AntiKickLevel = 5 })  -- Balanced
```

---

### ❌ Mistake 2: Combining High Level with Custom Throttle
```lua
-- BAD ❌
seorbsaveinstance({
    AntiKickLevel = 7,
    RequestThrottle = 10  -- CONTRADICTING!
})
```
**Result:** Defeats purpose of high security level

```lua
-- GOOD ✅
seorbsaveinstance({
    AntiKickLevel = 7,
    -- Let it use default 250ms throttle
})
```

---

### ❌ Mistake 3: Disabling Humanization
```lua
-- BAD ❌
seorbsaveinstance({
    AntiKickLevel = 5,
    HumanizeRequests = false  -- Server can detect pattern!
})
```

```lua
-- GOOD ✅
seorbsaveinstance({
    AntiKickLevel = 5,
    HumanizeRequests = true   -- Default, keep it
})
```

---

## 🔐 How Each Level Works (Technical)

### Level 5 Protection (Recommended)

```lua
-- Request Pattern
[10:00:00] Request 1 ✓
[10:00:10] Wait 100ms
[10:00:10] Request 2 ✓ (humanized: +15ms variance)
[10:00:12] Wait 100ms (humanized: ±20%)
[10:00:12] Request 3 ✓
...

-- Memory Management
After every 100 requests:
├─ Clear local caches
├─ Garbage collection
└─ Reset connection pools

-- Request Spoofing
├─ Randomize User-Agent
├─ Vary request headers
└─ Randomize request ID
```

### Level 7 Protection (Maximum)

```lua
-- Advanced Request Pattern
[10:00:00] Request 1 ✓
[10:00:25] Wait 250ms (±70% = ±175ms = 75-425ms) 
[10:00:27] Request 2 ✓ (with noise injection)
[10:00:52] Wait (with behavioral randomization)
[10:00:54] Request 3 ✓ (connection signature spoofed)
...

-- Behavioral AI
├─ Random idle periods (0-5s)
├─ Simulate human pauses
├─ Variable request sizes
├─ Connection reset patterns
└─ Server fingerprint evasion

-- Advanced Obfuscation
├─ Header shuffling
├─ Payload compression variance
├─ Timeout randomization
└─ Request batching simulation
```

---

## 📊 Level vs. Detection Rate (Estimated)

```
Level 1: ████████████████ 95% detection risk (AVOID!)
Level 2: ██████████████░░ 85% detection risk
Level 3: ████████░░░░░░░░ 70% detection risk
Level 4: ██████░░░░░░░░░░ 50% detection risk
Level 5: ███░░░░░░░░░░░░░ 20% detection risk ⭐
Level 6: ██░░░░░░░░░░░░░░ 10% detection risk
Level 7: █░░░░░░░░░░░░░░░ 5% detection risk (MAXIMUM)
```

---

## 🎯 Recommendations by Game Type

| Game Type | Level | Throttle | Humanize |
|-----------|-------|----------|----------|
| Private / Solo | 1-3 | 25-50ms | false |
| Small Friends Game | 3-4 | 50-75ms | true |
| Medium Public Game | 5 | 100ms | true ⭐ |
| Large Public Game | 6 | 150ms | true |
| Anti-Cheat Server | 7 | 250ms | true |

---

## ⚠️ Important Notes

⚠️ **Remember:** Higher levels = Slower execution  
⚠️ **Remember:** Level 7 can take 5-10x longer than Level 1  
⚠️ **Remember:** Always test on a small map first  
⚠️ **Remember:** Never combine multiple anti-kick methods (it's counterintuitive)

---

## 🔄 Best Practices

1. **Start with Level 5** - Balanced for most scenarios
2. **Test with small map first** - Verify it works before large maps
3. **Increase level only if kicked** - Don't overkill if not needed
4. **Monitor execution time** - Know your constraints
5. **Keep humanization on** - Disable only for testing

---

**Still getting kicked?** → [See Troubleshooting Guide](./troubleshooting.md)
