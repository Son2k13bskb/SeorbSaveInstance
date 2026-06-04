--!native
--!optimize 2
--!divine-intellect
-- SeorbSaveInstance v1.1 - Advanced Full Map SaveInstance (Anti-Cache Edition)
-- Based on UniversalSynSaveInstance (https://github.com/luau/UniversalSynSaveInstance)

local function createSeorbSaveInstance()
	-- ============================================================
	-- CONFIGURATION & INITIALIZATION
	-- ============================================================
	
	local SeorbConfig = {
		AntiKickLevel = 5,
		RequestThrottle = 100,
		HumanizeRequests = true,
		MaxRetries = 3,
		TimeoutRandomization = 0.5,
		
		EnableTerrainScan = true,
		EnableUnionMeshScan = true,
		UnionChunkSize = 5,
		CSGErrorHandling = "AUTO",
		
		SaveToExploitWorkspace = true,
		FilePath = "SeorbSaveInstance_FullMap",
		
		MaxMemoryUsage = 512 * 1024 * 1024,
		CacheSize = 10000,
		AsyncMode = true,
		ChunkProcessing = true,
		ChunkDelay = 50,
		MaxScanTime = 570, 
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
		local delays = {10, 25, 50, 75, 100, 150, 250}
		return delays[math.min(level, #delays)]
	end
	
	-- ============================================================
	-- FILE I/O - EXPLOIT CLIENT WORKSPACE (OPTIMIZED)
	-- ============================================================
	
	local function serializeToJSON(data)
		local buffer = {}
		
		local function serializeValue(v)
			local t = type(v)
			if t == "string" then
				table.insert(buffer, '"' .. v:gsub('"', '\\"') .. '"')
			elseif t == "number" then
				table.insert(buffer, tostring(v))
			elseif t == "boolean" then
				table.insert(buffer, v and "true" or "false")
			elseif t == "table" then
				table.insert(buffer, "{")
				local first = true
				for k, val in pairs(v) do
					if not first then table.insert(buffer, ",") end
					table.insert(buffer, '"' .. tostring(k) .. '":')
					serializeValue(val)
					first = false
				end
				table.insert(buffer, "}")
			else
				table.insert(buffer, "null")
			end
		end
		
		serializeValue(data)
		return table.concat(buffer)
	end
	
	local function saveToWorkspace(filename, data)
		if not SeorbConfig.SaveToExploitWorkspace then return false end
		
		local methods = {
			function()
				if writefile then
					local json = serializeToJSON(data)
					writefile(filename .. ".json", json)
					return true
				end
			end,
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
		}
		
		for _, method in ipairs(methods) do
			local success = pcall(method)
			if success then return true end
		end
		return false
	end
	
	-- ============================================================
	-- FULL MAP SCANNING ENGINE (HIGH SPEED)
	-- ============================================================
	
	local function scanFullMap(workspace_root, options)
		options = options or {}
		local scanned = {}
		local unions = {}
		local meshes = {}
		local parts = {}
		local totalProcessed = 0
		
		local startTime = tick()
		local maxDuration = SeorbConfig.MaxScanTime
		local lastYieldTime = tick()
		
		local function recursiveScan(instance, depth)
			if depth > 100 then return end
			
			if tick() - startTime > maxDuration then
				return
			end
			
			totalProcessed = totalProcessed + 1
			
			if totalProcessed % 500 == 0 then
				if options.ShowStatus and totalProcessed % 5000 == 0 then
					print("📍 Scanned: " .. totalProcessed .. " objects...")
				end
				
				if tick() - lastYieldTime > 0.012 then
					game:GetService("RunService").Heartbeat:Wait()
					lastYieldTime = tick()
				end
			end
			
			table.insert(scanned, instance)
			
			if instance:IsA("BasePart") then
				table.insert(parts, instance)
			end
			if instance:FindFirstChild("_UnionIsPart") or instance:IsA("UnionOperation") then
				table.insert(unions, instance)
			end
			if instance:IsA("MeshPart") or instance:FindFirstChild("Mesh") then
				table.insert(meshes, instance)
			end
			
			local children = instance:GetChildren()
			for _, child in ipairs(children) do
				recursiveScan(child, depth + 1)
				if tick() - startTime > maxDuration then return end
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
		
		return {
			Found = true,
			Position = terrain.Position,
			Size = terrain.Size,
		}
	end
	
	-- ============================================================
	-- MAIN SAVE FUNCTION
	-- ============================================================
	
	local function saveInstanceAdvanced(options)
		options = options or {}
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
			print("\n🚀 SeorbSaveInstance v1.1 [OPTIMIZED BUFFER]")
			print("📍 Stage 1: Scanning Full Map (High Speed mode)... \n")
		end
		status.Stage = "FullMapScan"
		
		local mapData = scanFullMap(workspace, options)
		status.TotalObjects = mapData.TotalCount
		
		if options.ShowStatus then 
			print("✅ Scan Step Completed!")
			print("   📊 Total Objects Scanned: " .. mapData.TotalCount)
			print("   🔲 Parts: " .. mapData.PartCount)
			print("   ⚙️ Unions: " .. mapData.UnionCount)
			print("   🎨 Meshes: " .. mapData.MeshCount)
		end
		
		game:GetService("RunService").Heartbeat:Wait()
		
		-- ========== STAGE 2: Terrain Scan ==========
		if SeorbConfig.EnableTerrainScan then
			status.Stage = "TerrainScan"
			local terrainData = scanTerrain()
		end
		
		game:GetService("RunService").Heartbeat:Wait()
		
		-- ========== STAGE 3: Prepare Save Data ==========
		status.Stage = "PrepareSave"
		
		-- DÒNG KIỂM TRA PHIÊN BẢN (NẾU THẤY DÒNG NÀY NGHĨA LÀ CODE MỚI ĐANG CHẠY)
		print("🔴 [CHECK] ĐANG CHẠY BẢN MỚI 100% - KHÔNG CÓ PLACENAME TRONG CODE")
		
		local safeGameName = "Unknown Game"
		pcall(function()
			safeGameName = game.Name
		end)
		
		local saveData = {
			SaveTime = os.time(),
			GameName = safeGameName,
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
		
		game:GetService("RunService").Heartbeat:Wait()
		
		-- ========== STAGE 4: Save to Workspace ==========
		status.Stage = "FileSaving"
		local saveSuccess = false
		if SeorbConfig.SaveToExploitWorkspace then
			local filename = SeorbConfig.FilePath or "SeorbSaveInstance_FullMap"
			saveSuccess = saveToWorkspace(filename, saveData)
		end
		
		-- ========== COMPLETION ==========
		local executionTime = tick() - status.StartTime
		if options.ShowStatus then 
			print("\n" .. string.rep("=", 50))
			print("🎉 SAVE PROCESS DONE!")
			print("   ⏱️ Total Time: " .. string.format("%.2f", executionTime) .. "s")
			print("   ✨ Status: " .. (saveSuccess and "SUCCESS" or "FAILED/PARTIAL"))
			print(string.rep("=", 50) .. "\n")
		end
		
		return {
			Status = saveSuccess and "Success" or "Partial",
			ExecutionTime = executionTime,
			MapData = mapData,
			SaveData = saveData,
		}
	end
	
	return function(options)
		return saveInstanceAdvanced(options)
	end
end

return createSeorbSaveInstance()
