local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

print("🚀 ULTRA FAST Auto Escape Loaded (GUI Click + New Waypoints)")

-- ====================== INSTANT TEAM CHANGE VIA GUI CLICK ======================
task.spawn(function()
    task.wait(1.2)
    
    local teamGui = player:WaitForChild("PlayerGui"):WaitForChild("team")
    local background = teamGui:WaitForChild("Background")
    
    -- First button
    local mainJoin = background:FindFirstChild("MainBody", true) and background.MainBody:FindFirstChild("PATIENT") and background.MainBody.PATIENT:FindFirstChild("Join")
    if mainJoin and mainJoin:IsA("TextButton") then
        mainJoin.Activated:Fire()  -- or mainJoin:Activate()
        print("✅ Clicked MainBody PATIENT Join")
    end
    
    task.wait(0.5)
    
    -- Second button (SubTeams)
    local subJoin = background:FindFirstChild("SubTeamsBody", true) and background.SubTeamsBody:FindFirstChild("Patient") and background.SubTeamsBody.Patient:FindFirstChild("Join")
    if subJoin and subJoin:IsA("TextButton") then
        subJoin.Activated:Fire()
        print("✅ Clicked SubTeams Patient Join")
    end
end)

-- Clear GUI (optional)
local function clearAllGuiElements()
    for _, element in pairs(player:WaitForChild("PlayerGui"):GetChildren()) do
        if element.Name ~= "TouchGui" then
            element:Destroy()
        end
    end
end
-- clearAllGuiElements()  -- Uncomment if you want to hide everything

-- ====================== MOVEMENT + NOCLIP + WAYPOINTS ======================
local movement = {w = false, a = false, s = false, d = false, space = false, shift = false}

-- Input handling (same as before)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then movement.w = true
    elseif k == Enum.KeyCode.A then movement.a = true
    elseif k == Enum.KeyCode.S then movement.s = true
    elseif k == Enum.KeyCode.D then movement.d = true
    elseif k == Enum.KeyCode.Space then movement.space = true
    elseif k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift then movement.shift = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local k = input.KeyCode
    if k == Enum.KeyCode.W then movement.w = false
    elseif k == Enum.KeyCode.A then movement.a = false
    elseif k == Enum.KeyCode.S then movement.s = false
    elseif k == Enum.KeyCode.D then movement.d = false
    elseif k == Enum.KeyCode.Space then movement.space = false
    elseif k == Enum.KeyCode.LeftShift or k == Enum.KeyCode.RightShift then movement.shift = false
    end
end)

-- Noclip
local isNoclipping = false
local noclipConnection
local function enableNoclip()
    if isNoclipping then return end
    isNoclipping = true
    noclipConnection = RunService.Heartbeat:Connect(function()
        if Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    isNoclipping = false
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- Waypoints (your current ones)
local waypoints = {
    Vector3.new(180.77767944335938, 279.8816833496094, -480.2005310058594),
    Vector3.new(14.035196304321289, 287.36865234375, -420.35418701171875),
    Vector3.new(-82.18074798583984, 291.15850830078125, -420.96453857421875),
    Vector3.new(-76.2624740600586, 292.92645263671875, -399.64434814453125),
    Vector3.new(-76.2624740600586, 524.6904907226562, -399.64434814453125),
    Vector3.new(2.3468916416168213, 520.1138305664062, -271.34210205078125),
    Vector3.new(0.6772763133049011, 525.689208984375, 400.3138122558594)
}

local function autoFlyTo(target, speed)
    speed = speed or 45
    local arrived = false
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local root = Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local direction = (target - root.Position)
        local distance = direction.Magnitude
        
        if distance < 5 then
            arrived = true
            root.Velocity = Vector3.new(0, 0, 0)
            connection:Disconnect()
            return
        end
        
        direction = direction.Unit
        root.Velocity = direction * speed
        root.RotVelocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.lookAt(root.Position, target)
    end)
    
    while not arrived do task.wait(0.05) end
end

local function serverHop()
    print("🚪 Server hopping...")
    TeleportService:Teleport(game.PlaceId, player)
end

local function startPath()
    print("🚀 Starting ULTRA FAST escape...")
    enableNoclip()
    
    for i, target in ipairs(waypoints) do
        print("➜ Step " .. i .. "/" .. #waypoints)
        autoFlyTo(target, 45)
        task.wait(0.05)
    end
    
    disableNoclip()
    print("✅ Escape path completed!")
    
    task.wait(18)
    serverHop()
end

-- Respawn handler
player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    task.wait(1)
    startPath()
end)

-- RUN
startPath()
