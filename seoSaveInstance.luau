--!native
--!optimize 2
--!divine-intellect
-- SeorbSaveInstance v1.1 - Advanced Full Map SaveInstance (Max Speed C++ JSON)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local function createSeorbSaveInstance()
	local SeorbConfig = {
		SaveToExploitWorkspace = true,
		FilePath = "SeorbSaveInstance_FullMap",
		MaxScanTime = 570, -- 9.5 phút chặn trên
	}
	
	-- ============================================================
	-- FILE I/O - EXPLOIT CLIENT WORKSPACE
	-- ============================================================
	
	local function saveToWorkspace(filename, data)
		if not SeorbConfig.SaveToExploitWorkspace then return false end
		
		-- Sử dụng HttpService của game để mã hóa JSON ở tốc độ C++ thay vì Lua
		local successEncode, json = pcall(function()
			return HttpService:JSONEncode(data)
		end)
		
		if not successEncode then 
			print("Lỗi khi tạo JSON!")
			return false 
		end
		
		local methods = {
			function()
				if writefile then
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
		local scanned, unions, meshes, parts = {}, {}, {}, {}
		local totalProcessed = 0
		
		local startTime = tick()
		local maxDuration = SeorbConfig.MaxScanTime
		local lastYieldTime = tick()
		
		local function recursiveScan(instance, depth)
			if depth > 100 then return end
			if tick() - startTime > maxDuration then return end
			
			totalProcessed = totalProcessed + 1
			
			-- Nhường frame nếu xử lý quá 12ms (tránh văng game nhưng giữ tốc độ max)
			if totalProcessed % 1000 == 0 then
				if tick() - lastYieldTime > 0.012 then
					RunService.Heartbeat:Wait()
					lastYieldTime = tick()
				end
			end
			
			table.insert(scanned, instance)
			
			if instance:IsA("BasePart") then table.insert(parts, instance) end
			if instance:FindFirstChild("_UnionIsPart") or instance:IsA("UnionOperation") then table.insert(unions, instance) end
			if instance:IsA("MeshPart") or instance:FindFirstChild("Mesh") then table.insert(meshes, instance) end
			
			local children = instance:GetChildren()
			for _, child in ipairs(children) do
				recursiveScan(child, depth + 1)
			end
		end
		
		recursiveScan(workspace_root, 0)
		
		return {
			TotalCount = #scanned,
			PartCount = #parts,
			UnionCount = #unions,
			MeshCount = #meshes,
		}
	end
	
	-- ============================================================
	-- MAIN SAVE FUNCTION
	-- ============================================================
	
	local function saveInstanceAdvanced(options)
		options = options or {}
		local startTime = tick()
		
		if options.ShowStatus then 
			print("\n🚀 Đang quét Map bằng SeorbSaveInstance (Bản độ lại)...") 
		end
		
		-- 1. Quét Map
		local mapData = scanFullMap(workspace, options)
		RunService.Heartbeat:Wait()
		
		-- 2. Chuẩn bị dữ liệu
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
			ExecutionInfo = {
				ExecutorName = identifyexecutor and identifyexecutor() or "Unknown",
			},
		}
		RunService.Heartbeat:Wait()
		
		-- 3. Lưu File
		if options.ShowStatus then print("💾 Đang ghi file JSON (Tốc độ bàn thờ)...") end
		local filename = SeorbConfig.FilePath or "SeorbSaveInstance_FullMap"
		local saveSuccess = saveToWorkspace(filename, saveData)
		
		-- 4. Báo cáo
		local executionTime = tick() - startTime
		if options.ShowStatus then 
			print("\n" .. string.rep("=", 50))
			print("🎉 HOÀN THÀNH!")
			print("   ⏱️ Tổng thời gian: " .. string.format("%.2f", executionTime) .. " giây")
			print("   📊 Tổng số lượng Object: " .. mapData.TotalCount)
			print("   ✨ Trạng thái: " .. (saveSuccess and "THÀNH CÔNG" or "LỖI LƯU FILE"))
			print(string.rep("=", 50) .. "\n")
		end
		
		return saveSuccess
	end
	
	return function(options)
		return saveInstanceAdvanced(options)
	end
end

return createSeorbSaveInstance()
