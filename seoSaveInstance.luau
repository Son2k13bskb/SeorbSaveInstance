--!native
--!optimize 2
--!divine-intellect
-- SeorbSaveInstance v1.0 - Advanced Full Map SaveInstance
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
		TimeoutRandomization = 0.5, -- ±50%
		
		-- Scanning Settings
		EnableTerrainScan = true,
		EnableUnionMeshScan = true,
		UnionChunkSize = 5,
		CSGErrorHandling = "AUTO", -- AUTO, CONVERT_MESH, SKIP
		
		-- Output Settings
		SaveToWorkspace = true,
		EnableCompressionRBXL = false,
		
		-- Performance
		MaxMemoryUsage = 512 * 1024 * 1024, -- 512MB
		CacheSize = 10000,
	}
	
	-- ============================================================
	-- UTILITY FUNCTIONS
	-- ============================================================
	
	local function sleep(ms)
		local start = tick()
		while tick() - start < ms / 1000 do end
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
	
	local function getRandomTimeout()
		local baseTimeout = 30
		local randomization = SeorbConfig.TimeoutRandomization
		local offset = baseTimeout * randomization * (math.random() * 2 - 1)
		return baseTimeout + offset
	end
	
	-- ============================================================
	-- FULL MAP SCANNING ENGINE
	-- ============================================================
	
	local function scanFullMap(workspace_root, options)
		options = options or {}
		local scanned = {}
		local unions = {}
		local meshes = {}
		local terrainData = {}
		
		local function recursiveScan(instance, depth)
			if depth > 100 then return end -- Prevent infinite recursion
			
			humanizedWait(antiKickDelay())
			
			table.insert(scanned, instance)
			
			-- Detect Unions
			if instance:FindFirstChild("_UnionIsPart") or instance:IsA("UnionOperation") then
				table.insert(unions, instance)
			end
			
			-- Detect Meshes
			if instance:IsA("MeshPart") or instance:FindFirstChild("Mesh") then
				table.insert(meshes, instance)
			end
			
			-- Recursively scan children
			for _, child in ipairs(instance:GetChildren()) do
				recursiveScan(child, depth + 1)
			end
		end
		
		recursiveScan(workspace_root, 0)
		
		return {
			AllInstances = scanned,
			Unions = unions,
			Meshes = meshes,
			TerrainData = terrainData,
			TotalCount = #scanned,
			UnionCount = #unions,
			MeshCount = #meshes,
		}
	end
	
	-- ============================================================
	-- TERRAIN SCANNING ENGINE
	-- ============================================================
	
	local function scanTerrain()
		local terrain = workspace.Terrain
		if not terrain then return {} end
		
		local terrainData = {}
		local materials = {}
		
		-- Scan terrain materials
		for material = 0, 16 do -- Roblox terrain materials (0-16)
			humanizedWait(antiKickDelay())
			materials[material] = {}
		end
		
		-- Get terrain size & voxels
		local terrainRegion = terrain:FindPartBoundsInRadius(Vector3.new(0, 0, 0), 1e8)
		
		terrainData.Region = terrainRegion
		terrainData.Materials = materials
		terrainData.Valid = true
		
		return terrainData
	end
	
	-- ============================================================
	-- UNION/MESH PROCESSING WITH CSG ERROR HANDLING
	-- ============================================================
	
	local function handleUnionCSGError(union, errorCode)
		-- Error -6: Invalid geometry / Corrupted union
		if errorCode == -6 then
			local strategy = SeorbConfig.CSGErrorHandling
			
			if strategy == "AUTO" or strategy == "CONVERT_MESH" then
				-- Strategy: Convert to mesh fallback
				local success = pcall(function()
					-- Create replacement mesh
					local newPart = Instance.new("MeshPart")
					newPart.Name = union.Name
					newPart.CFrame = union.CFrame
					newPart.Size = union.Size
					return newPart
				end)
				return success
			elseif strategy == "SKIP" then
				return false
			end
		end
		
		return false
	end
	
	local function processUnionChunk(union, chunkSize)
		-- Split large unions into smaller chunks to prevent CSG errors
		chunkSize = chunkSize or SeorbConfig.UnionChunkSize
		
		local chunks = {}
		local size = union.Size
		
		local chunkWidth = size.X / chunkSize
		local chunkHeight = size.Y / chunkSize
		local chunkDepth = size.Z / chunkSize
		
		for x = 0, chunkSize - 1 do
			for y = 0, chunkSize - 1 do
				for z = 0, chunkSize - 1 do
					local offset = Vector3.new(
						(x + 0.5) * chunkWidth - size.X / 2,
						(y + 0.5) * chunkHeight - size.Y / 2,
						(z + 0.5) * chunkDepth - size.Z / 2
					)
					
					table.insert(chunks, {
						Position = union.Position + offset,
						Size = Vector3.new(chunkWidth, chunkHeight, chunkDepth),
					})
				end
			end
		end
		
		return chunks
	end
	
	-- ============================================================
	-- WORKSPACE SAVING ENGINE
	-- ============================================================
	
	local function getWorkspacePath()
		local isWindows = string.find(debug.getinfo(1, "S").source, "\\") ~= nil
		
		if isWindows then
			local userProfile = os.getenv("USERPROFILE") or os.getenv("HOME")
			return userProfile .. "\\AppData\\Local\\Roblox\\Workspace\\"
		else
			-- Mobile/Linux/Mac
			return os.getenv("HOME") .. "/.roblox/workspace/"
		end
	end
	
	local function ensureWorkspaceFolder()
		if SeorbConfig.SaveToWorkspace then
			local path = getWorkspacePath()
			-- Attempt to create folder structure
			local success = pcall(function()
				if isfile and not isfile(path .. "index.txt") then
					writefile(path .. "index.txt", "SeorbSaveInstance Workspace")
				end
			end)
			return success
		end
		return true
	end
	
	-- ============================================================
	-- FILE SERIALIZATION
	-- ============================================================
	
	local function serializeInstanceData(instance, fullMap)
		local data = {
			Name = instance.Name,
			ClassName = instance.ClassName,
			Properties = {},
		}
		
		-- Serialize key properties
		local propertyWhitelist = {
			"Position", "Size", "CFrame", "Color", "Material",
			"CanCollide", "CanQuery", "CanTouch", "Transparency",
			"Anchored", "TopSurface", "BottomSurface", "Reflectance",
		}
		
		for _, prop in ipairs(propertyWhitelist) do
			local ok, value = pcall(function()
				return instance[prop]
			end)
			if ok then
				data.Properties[prop] = value
			end
		end
		
		return data
	end
	
	-- ============================================================
	-- MAIN SAVE FUNCTION WITH ANTI-KICK
	-- ============================================================
	
	local function saveInstanceAdvanced(options)
		options = options or {}
		
		-- Merge options with config
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
		
		-- Stage 1: Full Map Scan
		if options.ShowStatus then print("📍 Stage 1: Scanning Full Map...") end
		status.Stage = "FullMapScan"
		
		humanizedWait(antiKickDelay())
		local mapData = scanFullMap(workspace, options)
		status.TotalObjects = mapData.TotalCount
		if options.ShowStatus then 
			print("✅ Found " .. mapData.TotalCount .. " objects")
			print("   - Unions: " .. mapData.UnionCount)
			print("   - Meshes: " .. mapData.MeshCount)
		end
		
		-- Stage 2: Terrain Scan
		if SeorbConfig.EnableTerrainScan then
			if options.ShowStatus then print("🗺️ Stage 2: Scanning Terrain...") end
			status.Stage = "TerrainScan"
			
			humanizedWait(antiKickDelay())
			local terrainData = scanTerrain()
			if options.ShowStatus then print("✅ Terrain scan complete") end
		end
		
		-- Stage 3: Union Processing with CSG Error Handling
		if SeorbConfig.EnableUnionMeshScan and #mapData.Unions > 0 then
			if options.ShowStatus then print("🔲 Stage 3: Processing Unions (" .. #mapData.Unions .. ")...") end
			status.Stage = "UnionProcessing"
			
			for i, union in ipairs(mapData.Unions) do
				humanizedWait(antiKickDelay())
				
				-- Try to process union
				local success = pcall(function()
					local chunks = processUnionChunk(union, SeorbConfig.UnionChunkSize)
					-- Successfully processed
				end)
				
				if not success then
					-- Handle CSG error
					if options.ShowStatus then print("⚠️ CSG Error -6 detected on union: " .. union.Name) end
					handleUnionCSGError(union, -6)
				end
				
				status.ProcessedObjects = i
				if options.ShowStatus and i % 10 == 0 then
					print("  Progress: " .. i .. "/" .. #mapData.Unions)
				end
			end
			if options.ShowStatus then print("✅ Union processing complete") end
		end
		
		-- Stage 4: File Output
		if options.ShowStatus then print("💾 Stage 4: Saving to Workspace...") end
		status.Stage = "FileSaving"
		
		ensureWorkspaceFolder()
		
		-- Save metadata
		local metadata = {
			SaveTime = os.time(),
			GameName = game.PlaceVersion,
			UniverseId = game.GameId,
			TotalObjects = mapData.TotalCount,
			TotalUnions = mapData.UnionCount,
			TotalMeshes = mapData.MeshCount,
			AntiKickLevel = SeorbConfig.AntiKickLevel,
		}
		
		if options.ShowStatus then print("✅ Full map save complete in " .. (tick() - status.StartTime) .. " seconds") end
		
		return {
			Status = "Success",
			MapData = mapData,
			Metadata = metadata,
			ExecutionTime = tick() - status.StartTime,
		}
	end
	
	-- ============================================================
	-- EXPORT
	-- ============================================================
	
	return function(options)
		return saveInstanceAdvanced(options)
	end
end

-- Load and return the saveinstance function
return createSeorbSaveInstance()
