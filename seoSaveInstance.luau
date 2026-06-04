--!native
--!optimize 2
--!divine-intellect
-- SeorbSaveInstance v1.1 - Advanced Full Map SaveInstance (True RBXL/RBXLX Exporter)
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
		FilePath = "SeorbSaveInstance_FullMap", -- Tên file xuất ra (.rbxl / .rbxlx)
		
		-- Các thiết lập nâng cao cho SaveInstance thật
		SaveMode = "full",                      -- "full" hoặc "optimized"
		NoScripts = false,                     -- false để giữ lại LocalScript/ModuleScript
		DecompileTimeout = 20,
		
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
	-- FULL MAP SCANNING ENGINE (HIGH SPEED LOGGING)
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
	-- MAIN SAVE FUNCTION (CONVERTED TO RBXL GENERATOR)
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
			print("\n🚀 SeorbSaveInstance v1.1 [RBXL EXPORT MODE]")
			print("📍 Stage 1: Pre-scanning DataModel... \n")
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
		
		-- ========== STAGE 2: Anti-Kick Latency Injection ==========
		status.Stage = "BypassBrakes"
		humanizedWait(antiKickDelay(SeorbConfig.AntiKickLevel))
		
		-- ========== STAGE 3: Invoke RBXL Serializer ==========
		status.Stage = "FileSaving"
		local saveSuccess = false
		local filename = SeorbConfig.FilePath or "SeorbSaveInstance_FullMap"
		
		if SeorbConfig.SaveToExploitWorkspace then
			if options.ShowStatus then
				print("📦 Stage 3: Compressing instances and generating binary map file...")
			end
			
			-- Hướng xử lý 1: Dùng API gốc của Executor (Nhanh & Tối ưu nhất)
			if saveinstance then
				local success, err = pcall(function()
					saveinstance({
						mode = SeorbConfig.SaveMode,
						noscripts = SeorbConfig.NoScripts,
						timeout = SeorbConfig.DecompileTimeout,
						terrain = SeorbConfig.EnableTerrainScan,
						filepath = filename
					})
				end)
				if success then 
					saveSuccess = true 
				else
					warn("⚠️ Native saveinstance gặp lỗi, đang thử giải pháp dự phòng: " .. tostring(err))
				end
			end
			
			-- Hướng xử lý 2: Dự phòng bằng việc mượn lõi UniversalSynSaveInstance dịch chuyển XML (.rbxlx)
			if not saveSuccess then
				local ussiSuccess, USSI = pcall(function()
					return loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/source.luau?t=" .. tick()))()
				end)
				if ussiSuccess and type(USSI) == "function" then
					local runSuccess = pcall(function()
						USSI({
							filepath = filename,
							noscripts = SeorbConfig.NoScripts,
							terrain = SeorbConfig.EnableTerrainScan
						})
					end)
					if runSuccess then
						saveSuccess = true
					end
				end
			end
		end
		
		-- ========== COMPLETION LOGIC FIXED ==========
		local executionTime = tick() - status.StartTime
		if options.ShowStatus then 
			print("\n" .. string.rep("=", 50))
			if saveSuccess then
				print("🎉 MAP SAVE PROCESS SUCCESSFUL!")
				print("   ⏱️ Total Time: " .. string.format("%.2f", executionTime) .. "s")
				print("   ✨ File Output: " .. filename .. " (.rbxl / .rbxlx)")
				print("📂 Hãy kiểm tra thư mục 'workspace' trong Executor của bạn!")
			else
				print("❌ MAP SAVE PROCESS FAILED!")
				print("   ⏱️ Total Time: " .. string.format("%.2f", executionTime) .. "s")
				print("   ⚠️ LÝ DO: Executor của bạn không hỗ trợ hàm saveinstance(),")
				print("      hoặc API chặn tải map. Vui lòng đổi Executor khác mạnh hơn.")
			end
			print(string.rep("=", 50) .. "\n")
		end
		
		return {
			Status = saveSuccess and "Success" or "Failed",
			ExecutionTime = executionTime,
			MapData = mapData,
		}
	end
	
	return function(options)
		return saveInstanceAdvanced(options)
	end
end

return createSeorbSaveInstance()
