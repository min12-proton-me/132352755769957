-- Contraband Autofarm - FASTER CYCLE + PERMANENT NOCLIP + CAMERA LOCK + AUTO RE-EXECUTE ON DEATH
-- • DELETED ESP TAB (no more ESP code or tab)
-- • Auto Farm now detects "Plate Box" ANYWHERE in workspace (even if not in Ignored.ContrabandSpawners)
-- • Everything else unchanged + faster cycle
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Contraband Autofarm - ASYLUM CRY",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "ASYLUM CRY",
    ConfigurationSaving = { Enabled = false }
})
local Tab = Window:CreateTab("Main", 4483362458)

local farmToggle = Tab:CreateToggle({
    Name = "Auto Farm Contraband (Fast Cycle + Noclip)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        getgenv().AutoFarmContraband = Value
    end
})
local safeFlyToggle = Tab:CreateToggle({
    Name = "Safe Fly Mode (No Player Can Attack You)",
    CurrentValue = false,
    Flag = "SafeFly",
    Callback = function(Value)
        getgenv().SafeFly = Value
        Rayfield:Notify({
            Title = Value and "✅ Safe Fly ENABLED" or "❌ Safe Fly DISABLED",
            Content = Value and "You are now ghosted (invisible + no hitbox to players)" or "Normal visibility restored",
            Duration = 3
        })
    end
})
local cameraLockToggle = Tab:CreateToggle({
    Name = "Fix Camera to Contraband (Aimbot Camera)",
    CurrentValue = false,
    Flag = "CameraLock",
    Callback = function(Value)
        getgenv().CameraLockContraband = Value
        Rayfield:Notify({
            Title = Value and "✅ Camera Lock ENABLED" or "❌ Camera Lock DISABLED",
            Content = Value and "Camera now fixed/locked onto Contraband targets while autofarming" or "Camera lock disabled",
            Duration = 3
        })
    end
})

-- Initialize globals
getgenv().AutoFarmContraband = false
getgenv().SafeFly = false
getgenv().CameraLockContraband = false
getgenv().CameraTarget = nil

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local spawnersFolder = workspace:WaitForChild("Ignored"):WaitForChild("ContrabandSpawners")
local charactersFolder = workspace:WaitForChild("Characters")

-- === CUSTOM SELL POSITION ===
local sellPosition = Vector3.new(49.08184051513672, 255.96910095214844, -697.1757202148438)
local sellArgs = {
    [1] = workspace.Shopkeepers.PatientShopkeeper.John,
    [2] = "Sell",
    [3] = "Item",
    [4] = "Contraband"
}
local flightSpeed = 35
local isFlying = false
local flightConnection = nil
local autoTarget = nil
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Movement table
local movement = {w = false, a = false, s = false, d = false, space = false, shift = false}
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode.W then movement.w = true
    elseif kc == Enum.KeyCode.A then movement.a = true
    elseif kc == Enum.KeyCode.S then movement.s = true
    elseif kc == Enum.KeyCode.D then movement.d = true
    elseif kc == Enum.KeyCode.Space then movement.space = true
    elseif kc == Enum.KeyCode.LeftShift then movement.shift = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode.W then movement.w = false
    elseif kc == Enum.KeyCode.A then movement.a = false
    elseif kc == Enum.KeyCode.S then movement.s = false
    elseif kc == Enum.KeyCode.D then movement.d = false
    elseif kc == Enum.KeyCode.Space then movement.space = false
    elseif kc == Enum.KeyCode.LeftShift then movement.shift = false
    end
end)

-- =============================================
-- PERMANENT NOCLIP + SAFE FLY
-- =============================================
local function enableNoclip(char)
    RunService.Stepped:Connect(function()
        if char and char.Parent then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    if getgenv().SafeFly then
                        part.Transparency = 1
                        part.CanTouch = false
                        part.CanQuery = false
                    else
                        part.Transparency = 0
                        part.CanTouch = true
                        part.CanQuery = true
                    end
                end
            end
        end
    end)
end
local function setupCharacter(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    print("✅ Character loaded - All systems ready")
    enableNoclip(character)
    if getgenv().AutoFarmContraband then
        task.spawn(function()
            task.wait(1)
            if getgenv().AutoFarmContraband then startFlight() end
        end)
    end
    humanoid.Died:Connect(function()
        Rayfield:Notify({Title = "💀 Died - Auto Re-Executing", Content = "Farm restarting...", Duration = 3})
        if isFlying then stopFlight() end
    end)
end
if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)
player.CharacterRemoving:Connect(function() if isFlying then stopFlight() end end)
print("🚀 Permanent Noclip + Safe Fly + Auto Respawn + Faster Farm Enabled")

-- === PURE VELOCITY FLY (faster) ===
local function startFlight()
    if isFlying then return end
    isFlying = true
    humanoid.PlatformStand = true
    flightConnection = RunService.RenderStepped:Connect(function()
        local moveDir = Vector3.new(0, 0, 0)
        if getgenv().AutoFarmContraband and autoTarget and hrp and hrp.Parent then
            local dir = (autoTarget - hrp.Position)
            if dir.Magnitude > 0 then moveDir = dir.Unit end
        else
            local look = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            if movement.w then moveDir += Vector3.new(look.X, 0, look.Z).Unit end
            if movement.s then moveDir -= Vector3.new(look.X, 0, look.Z).Unit end
            if movement.a then moveDir -= Vector3.new(right.X, 0, right.Z).Unit end
            if movement.d then moveDir += Vector3.new(right.X, 0, right.Z).Unit end
            if movement.space then moveDir += Vector3.new(0, 1, 0) end
            if movement.shift then moveDir -= Vector3.new(0, 1, 0) end
        end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        hrp.Velocity = moveDir * flightSpeed
        hrp.RotVelocity = Vector3.zero
        if getgenv().CameraLockContraband and getgenv().CameraTarget and hrp and hrp.Parent then
            local camPos = camera.CFrame.Position
            camera.CFrame = CFrame.lookAt(camPos, getgenv().CameraTarget)
        end
    end)
end
local function stopFlight()
    if not isFlying then return end
    isFlying = false
    if flightConnection then flightConnection:Disconnect() end
    if humanoid then humanoid.PlatformStand = false end
    if hrp then hrp.Velocity = Vector3.zero end
    autoTarget = nil
    getgenv().CameraTarget = nil
end

-- === PROXIMITY + E PRESS ===
for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("ProximityPrompt") then
        v.HoldDuration = 0
        v.RequiresLineOfSight = false
        v.MaxActivationDistance = 10
    end
end
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") then
        v.HoldDuration = 0
        v.RequiresLineOfSight = false
        v.MaxActivationDistance = 10
    end
end)
local function pressEAt(target)
    local prompt = target:FindFirstChildWhichIsA("ProximityPrompt") or target:FindFirstChild("ProximityPrompt", true)
    if prompt then
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
    end
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.03)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end
local function getContrabandCount()
    local count = 0
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if item.Name:lower():find("contraband") then count += 1 end
    end
    local char = player.Character
    if char then
        local tool = char:FindFirstChildWhichIsA("Tool")
        if tool and tool.Name:lower():find("contraband") then count += 1 end
    end
    return count
end

-- === SELL 5x FAST SPAM ===
local function sellContraband()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if (root.Position - sellPosition).Magnitude < 25 then
        pcall(function()
            for i = 1, 5 do
                game:GetService("ReplicatedStorage").Remote.ShopInteract:InvokeServer(unpack(sellArgs))
                task.wait(0.04)
            end
        end)
        task.wait(0.4)
    else
        task.wait(0.4)
    end
end

-- === FLY TO TARGET (FASTER CYCLE) ===
local function flyToAndWait(target)
    if not target or not hrp then return end
   
    local targetPos
    if typeof(target) == "Vector3" then
        targetPos = target
        getgenv().CameraTarget = nil
    elseif typeof(target) == "Instance" then
        local part = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart") or target:FindFirstChild("HumanoidRootPart")
        if part then
            targetPos = part.Position + Vector3.new(0, 2, 0)
            getgenv().CameraTarget = targetPos
        end
    end
    if not targetPos then return end
    autoTarget = targetPos
    while getgenv().AutoFarmContraband and autoTarget and (hrp.Position - autoTarget).Magnitude > 3 do
        task.wait(0.08)
    end
    autoTarget = nil
    getgenv().CameraTarget = nil
    task.wait(0.3)
    if typeof(target) == "Instance" then pressEAt(target) end
    task.wait(1.2)
end

-- Main FASTER Farm Loop (now detects Plate Box anywhere)
task.spawn(function()
    while true do
        task.wait(0.1)
        if not getgenv().AutoFarmContraband then continue end
       
        local count = getContrabandCount()
       
        if count >= 2 then
            flyToAndWait(sellPosition)
            sellContraband()
            task.wait(0.8)
        else
            local targets = {}
            -- Original spawners folder
            for _, crate in ipairs(spawnersFolder:GetChildren()) do
                if crate.Name == "Plate Box" or crate:IsA("Model") or crate:IsA("Folder") then
                    table.insert(targets, crate)
                end
            end
            -- NEW: Detect Plate Box anywhere in workspace (even if not in ContrabandSpawners)
            local plateBoxAnywhere = workspace:FindFirstChild("Plate Box", true)
            if plateBoxAnywhere then
                local alreadyIncluded = false
                for _, t in ipairs(targets) do
                    if t == plateBoxAnywhere then
                        alreadyIncluded = true
                        break
                    end
                end
                if not alreadyIncluded then
                    table.insert(targets, plateBoxAnywhere)
                end
            end
            -- Farm all valid targets
            for _, crate in ipairs(targets) do
                if not getgenv().AutoFarmContraband then break end
                if getContrabandCount() >= 2 then break end
                flyToAndWait(crate)
            end
        end
    end
end)

farmToggle.Callback = function(Value)
    getgenv().AutoFarmContraband = Value
    if Value then
        startFlight()
    else
        stopFlight()
    end
end

Rayfield:Notify({
    Title = "✅ UPDATED & LOADED - NO ESP VERSION",
    Content = "• ESP tab completely deleted\n• Auto Farm now detects Plate Box ANYWHERE in workspace\n• Faster cycle + all other features unchanged",
    Duration = 8
})
