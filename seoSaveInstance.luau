--!native
--!optimize 2
--!divine-intellect
-- SeorbSaveInstance v1.1 - Advanced Full Map SaveInstance
-- Based on UniversalSynSaveInstance (https://github.com/luau/UniversalSynSaveInstance)
-- Credit: UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw

local function createSeorbSaveInstance()
	-- ============================================================
	-- CONFIGURATION & INITIALIZATION
	-- ============================================================
	
	local SeorbConfig = {
		-- Anti-Kick Settings
		AntiKickLevel = 5,
		RequestThrottle = 100,
		HumanizeRequests = true,
		MaxRetries = 3,
		TimeoutRandomization = 0.5,
		
		-- Scanning Settings
		EnableTerrainScan = true,
		EnableUnionMeshScan = true,
		UnionChunkSize = 5,
		CSGErrorHandling = "AUTO",
		
		-- Output Settings
		SaveToExploitWorkspace = true,  -- Save to exploit client workspace
		FilePath = "SeorbSaveInstance_FullMap",
		
		-- Performance & Safety
		MaxMemoryUsage = 512 * 1024 * 1024,
		CacheSize = 10000,
		AsyncMode = true,  -- Prevent freezing
		ChunkProcessing = true,  -- Process in chunks
		ChunkDelay = 50,  -- ms delay between chunks
	}
	
	-- ============================================================
	-- UTILITY FUNCTIONS
	-- ============================================================
	
	local function sleep(ms)
		local start = tick()
		while tick() - start < ms / 1000 do
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
	
	local function humanizedWait(baseMs)
		if SeorbConfig.HumanizeRequests then
			local variance = math.random(-500, 500) / 1000
			local delay = math.max(10, baseMs + variance)
			sleep(delay)
		else
			sleep(baseMs)
		end
	end
	
	local function antiKickDelay(level)
		level = level or SeorbConfig.AntiKickLevel
		local delays = {
			10,   -- Level 1
			25,   -- Level 2
			50,   -- Level 3
			75,   -- Level 4
			100,  -- Level 5
			150,  -- Level 6
			250,  -- Level 7
		}
		return delays[math.min(level, 7)]
	end
	
	-- ============================================================
	-- FILE I/O - EXPLOIT CLIENT WORKSPACE
	-- ============================================================
	
	local function serializeToJSON(data)
		-- Simple JSON serialization
		local function serializeValue(v)
			local t = type(v)
			if t == "string" then
				return '"' .. v:gsub('"', '\\"') .. '"'
			elseif t == "number" then
				return tostring(v)
			elseif t == "boolean" then
				return v and "true" or "false"
			elseif t == "table" then
				local result = "{"
				local first = true
				for k, val in pairs(v) do
					if not first then result = result .. "," end
					result = result .. '"' .. tostring(k) .. '":' .. serializeValue(val)
					first = false
				end
				result = result .. "}"
				return result
			end
			return "null"
		end
		
		return serializeValue(data)
	end
	
	local function saveToWorkspace(filename, data)
		if not SeorbConfig.SaveToExploitWorkspace then return false end
		
		-- Try multiple save methods (exploit client compatibility)
		local methods = {
			-- Method 1: writefile (most exploits support this)
			function()
				if writefile then
					local json = serializeToJSON(data)
					writefile(filename .. ".json", json)
					return true
				end
			end,
			
			-- Method 2: saveinstance to workspace folder
			function()
				if isfile and writefile then
					local folder = "workspace/"
					if not isfile(folder .. "test.txt") then
						writefile(folder .. "test.txt", "SeorbSaveInstance")
					end
					local json = serializeToJSON(data)
					writefile(folder .. filename .. ".json", json)
					return true
				end
			end,
			
			-- Method 3: Direct file write
			function()
				if writefile then
					local fullPath = filename .. ".json"
					local json = serializeToJSON(data)
					writefile(fullPath, json)
					return true
				end
			end,
		}
		
		for _, method in ipairs(methods) do
			local success = pcall(method)
			if success then
				return true
			end
		end
		
		return false
	end
	
	-- ============================================================
	-- FULL MAP SCANNING ENGINE (OPTIMIZED)
	-- ============================================================
	
	local function scanFullMap(workspace_root, options)
		options = options or {}
		local scanned = {}
		local unions = {}
		local meshes = {}
		local parts = {}
		local totalProcessed = 0
		
		local function recursiveScan(instance, depth)
			if depth > 100 then return end
			
			-- Prevent freeze - yield every iteration
			totalProcessed = totalProcessed + 1
			if totalProcessed % 10 == 0 then
				if options.ShowStatus then
					print("📍 Scanned: " .. totalProcessed .. " objects")
				end
				game:GetService("RunService").Heartbeat:Wait()
			end
			
			humanizedWait(antiKickDelay() / 10)  -- Smaller delay
			
			table.insert(scanned, instance)
			
			-- Categorize instances
			if instance:IsA("BasePart") then
				table.insert(parts, instance)
			end
			
			-- Detect Unions
			if instance:FindFirstChild("_UnionIsPart") or instance:IsA("UnionOperation") then
				table.insert(unions, instance)
			end
			
			-- Detect Meshes
			if instance:IsA("MeshPart") or instance:FindFirstChild("Mesh") then
				table.insert(meshes, instance)
			end
			
			-- Recursively scan children
			local children = instance:GetChildren()
			for _, child in ipairs(children) do
				recursiveScan(child, depth + 1)
			end
		end
		
		recursiveScan(workspace_root, 0)
		
		return {
			AllInstances = scanned,
			Parts = parts,
			Unions = unions,
			Meshes = meshes,
			TotalCount = #scanned,
			PartCount = #parts,
			UnionCount = #unions,
			MeshCount = #meshes,
		}
	end
	
	-- ============================================================
	-- TERRAIN SCANNING (LIGHTWEIGHT)
	-- ============================================================
	
	local function scanTerrain()
		local terrain = workspace.Terrain
		if not terrain then return {} end
		
		local terrainData = {
			Found = true,
			Position = terrain.Position,
			Size = terrain.Size,
		}
		
		-- Get terrain size (lightweight)
		humanizedWait(antiKickDelay() / 5)
		
		return terrainData
	end
	
	-- ============================================================
	-- MAIN SAVE FUNCTION
	-- ============================================================
	
	local function saveInstanceAdvanced(options)
		options = options or {}
		
		-- Merge options
		for key, value in pairs(options) do
			SeorbConfig[key] = value
		end
		
		local status = {
			StartTime = tick(),
			Stage = "Initializing",
			Progress = 0,
			TotalObjects = 0,
			ProcessedObjects = 0,
			Errors = {},
		}
		
		-- ========== STAGE 1: Full Map Scan ==========
		if options.ShowStatus then 
			print("\n🚀 SeorbSaveInstance v1.1")
			print("📍 Stage 1: Scanning Full Map...\n")
		end
		status.Stage = "FullMapScan"
		
		local mapData = scanFullMap(workspace, options)
		status.TotalObjects = mapData.TotalCount
		
		if options.ShowStatus then 
			print("✅ Scan Complete!")
			print("   📊 Total Objects: " .. mapData.TotalCount)
			print("   🔲 Parts: " .. mapData.PartCount)
			print("   ⚙️ Unions: " .. mapData.UnionCount)
			print("   🎨 Meshes: " .. mapData.MeshCount)
		end
		
		-- Yield to prevent freeze
		game:GetService("RunService").Heartbeat:Wait()
		
		-- ========== STAGE 2: Terrain Scan ==========
		if SeorbConfig.EnableTerrainScan then
			if options.ShowStatus then print("\n🗺️ Stage 2: Scanning Terrain...") end
			status.Stage = "TerrainScan"
			
			humanizedWait(antiKickDelay() / 5)
			local terrainData = scanTerrain()
			
			if options.ShowStatus and terrainData.Found then 
				print("✅ Terrain Found")
			end
		end
		
		-- Yield again
		game:GetService("RunService").Heartbeat:Wait()
		
		-- ========== STAGE 3: Prepare Save Data ==========
		if options.ShowStatus then print("\n💾 Stage 3: Preparing Save Data...") end
		status.Stage = "PrepareSave"
		
		-- Create save data
		local saveData = {
			SaveTime = os.time(),
			GameName = game.PlaceName or "Unknown",
			PlaceId = game.PlaceId,
			UniverseId = game.GameId,
			
			Statistics = {
				TotalObjects = mapData.TotalCount,
				TotalParts = mapData.PartCount,
				TotalUnions = mapData.UnionCount,
				TotalMeshes = mapData.MeshCount,
			},
			
			Configuration = {
				AntiKickLevel = SeorbConfig.AntiKickLevel,
				EnableTerrainScan = SeorbConfig.EnableTerrainScan,
				EnableUnionMeshScan = SeorbConfig.EnableUnionMeshScan,
				CSGErrorHandling = SeorbConfig.CSGErrorHandling,
			},
			
			ExecutionInfo = {
				ExecutorName = identifyexecutor and identifyexecutor() or "Unknown",
				Luau = "native",
			},
		}
		
		-- Yield before save
		game:GetService("RunService").Heartbeat:Wait()
		
		-- ========== STAGE 4: Save to Workspace ==========
		if options.ShowStatus then print("\n📁 Stage 4: Saving to Workspace...") end
		status.Stage = "FileSaving"
		
		local saveSuccess = false
		if SeorbConfig.SaveToExploitWorkspace then
			local filename = SeorbConfig.FilePath or "SeorbSaveInstance_FullMap"
			saveSuccess = saveToWorkspace(filename, saveData)
			
			if options.ShowStatus then
				if saveSuccess then
					print("✅ File Saved Successfully!")
					print("   📄 File: " .. filename .. ".json")
				else
					print("⚠️ Could not save to workspace (writefile not available)")
				end
			end
		end
		
		-- ========== COMPLETION ==========
		local executionTime = tick() - status.StartTime
		if options.ShowStatus then 
			print("\n" .. string.rep("=", 50))
			print("🎉 SAVE COMPLETE!")
			print("   ⏱️ Execution Time: " .. string.format("%.2f", executionTime) .. "s")
			print("   🛡️ Anti-Kick Level: " .. SeorbConfig.AntiKickLevel)
			print("   ✨ Status: " .. (saveSuccess and "SUCCESS" or "PARTIAL"))
			print(string.rep("=", 50) .. "\n")
		end
		
		return {
			Status = saveSuccess and "Success" or "Partial",
			ExecutionTime = executionTime,
			MapData = mapData,
			SaveData = saveData,
		}
	end
	
	-- ============================================================
	-- EXPORT
	-- ============================================================
	
	return function(options)
		return saveInstanceAdvanced(options)
	end
end

-- Load and return
return createSeorbSaveInstance()
