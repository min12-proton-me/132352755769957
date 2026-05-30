-- Contraband ESP Handler
-- Dynamically monitors all contraband items in workspace.Ignored.ContrabandSpawners
-- Activates ESP and displays "Found [Item Name]" when ProximityPrompt is enabled and player is within range

local MAX_ESP_DISTANCE = 50 -- Studs - adjust this value to change ESP visibility range
local function setupContrabandHighlight(contrabandPart)
	if not contrabandPart then return end
	
	-- Find the proximity prompt
	local promptPosition = contrabandPart:FindFirstChild("PromptPosition")
	if not promptPosition then return end
	
	local proximityPrompt = promptPosition:FindFirstChild("ContrabandPrompt")
	if not proximityPrompt or not proximityPrompt:IsA("ProximityPrompt") then return end
	
	-- Find the highlight
	local primaryModel = contrabandPart:FindFirstChild("Primary")
	if not primaryModel then return end
	
	local highlight = primaryModel:FindFirstChild("ContrabandHighlight")
	if not highlight or not highlight:IsA("Highlight") then return end
	
	-- Create Billboard GUI for text label (but keep it hidden initially)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Adornee = contrabandPart
	billboardGui.Size = UDim2.new(4, 0, 1.5, 0)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.MaxDistance = MAX_ESP_DISTANCE -- Distance-based visibility
	billboardGui.AlwaysOnTop = true -- ESP styling
	billboardGui.Enabled = false -- Start disabled
	billboardGui.Parent = contrabandPart
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = "Found " .. contrabandPart.Name
	textLabel.TextSize = 18
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	textLabel.TextScaled = true
	textLabel.TextWrapped = false
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui
	
	-- Configure highlight (but keep it disabled initially)
	pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
	pcall(function() highlight.Enabled = false end) -- Start disabled
	pcall(function() highlight.FillTransparency = 0.3 end)
	pcall(function() highlight.OutlineTransparency = 0.2 end)
	pcall(function() highlight.FillColor = Color3.fromRGB(0, 255, 100) end)
	
	-- Function to check if player is within range
	local function isPlayerInRange()
		local player = game:GetService("Players").LocalPlayer
		if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			return false
		end
		
		local playerPos = player.Character.HumanoidRootPart.Position
		local contrabandPos = contrabandPart.Position
		local distance = (playerPos - contrabandPos).Magnitude
		
		return distance <= MAX_ESP_DISTANCE
	end
	
	-- Function to update ESP visibility based on prompt state and player distance
	local function updateESPVisibility()
		local promptEnabled = proximityPrompt.Enabled
		local inRange = isPlayerInRange()
		local shouldShow = promptEnabled and inRange
		
		pcall(function() highlight.Enabled = shouldShow end)
		billboardGui.Enabled = shouldShow
	end
	
	-- Monitor ProximityPrompt's Enabled property
	proximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
		updateESPVisibility()
	end)
	
	-- Periodically check distance to handle player movement
	local updateConnection
	updateConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not contrabandPart.Parent then
			updateConnection:Disconnect()
			return
		end
		updateESPVisibility()
	end)
	
	-- Set initial state
	updateESPVisibility()
end

-- Find all contraband items and setup highlighting
local function initializeAllContrabands()
	local rootParent = workspace
	pcall(function() rootParent = workspace.Ignored.ContrabandSpawners end)
	
	for _, part in pairs(rootParent:GetChildren()) do
		if part:IsA("Part") or part:IsA("Model") then
			setupContrabandHighlight(part)
		end
	end
end

-- Initialize on startup
initializeAllContrabands()

-- Also watch for new items being added
local rootParent = workspace
pcall(function() rootParent = workspace.Ignored.ContrabandSpawners end)

rootParent.ChildAdded:Connect(function(child)
	task.wait(0.1) -- Small delay to ensure object is fully loaded
	setupContrabandHighlight(child)
end)
