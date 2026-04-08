local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

print("🚀 FIXED ULTRA FAST Auto Farm Loaded (Autoexec Ready)")

-- ==================== INSTANT TEAM CHANGE ====================
task.spawn(function()
    task.wait(1.5)
    local remoteFolder = ReplicatedStorage:FindFirstChild("Remote")
    if remoteFolder and remoteFolder:FindFirstChild("TeamChange") then
        remoteFolder.TeamChange:InvokeServer(game:GetService("Teams").PATIENT, "Patient")
        print("✅ Team changed to PATIENT")
    end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local player = game.Players.LocalPlayer
local playerInterface = player:WaitForChild("PlayerGui")

local function clearAllGuiElements()
    for _, element in pairs(playerInterface:GetChildren()) do
        if element.Name ~= "TouchGui" then
            element:Destroy()
        end
    end
end

clearAllGuiElements()

-- ====================== MOVEMENT TABLE (required for your fly system) ======================
local movement = {
    w = false, a = false, s = false, d = false,
    space = false, shift = false
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then movement.w = true
    elseif input.KeyCode == Enum.KeyCode.A then movement.a = true
    elseif input.KeyCode == Enum.KeyCode.S then movement.s = true
    elseif input.KeyCode == Enum.KeyCode.D then movement.d = true
    elseif input.KeyCode == Enum.KeyCode.Space then movement.space = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then movement.shift = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then movement.w = false
    elseif input.KeyCode == Enum.KeyCode.A then movement.a = false
    elseif input.KeyCode == Enum.KeyCode.S then movement.s = false
    elseif input.KeyCode == Enum.KeyCode.D then movement.d = false
    elseif input.KeyCode == Enum.KeyCode.Space then movement.space = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then movement.shift = false
    end
end)

-- ====================== YOUR EXACT NOCLIP SYSTEM ======================
local isNoclipping = false
local noclipConnection = nil

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
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ====================== YOUR EXACT FLY SYSTEM ======================
local isFlying = false
local flightConnection = nil
local flightSpeed = 45  -- ← tu peux changer ça quand tu veux (vitesse manuelle)

local function enableFlight()
    if isFlying then return end
    isFlying = true
    Humanoid.PlatformStand = true
    flightConnection = RunService.RenderStepped:Connect(function()
        local root = Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local cam = workspace.CurrentCamera
        local forward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit
        local velocity = Vector3.new(0, 0, 0)
        if movement.w then velocity += forward end
        if movement.s then velocity -= forward end
        if movement.a then velocity -= right end
        if movement.d then velocity += right end
        if movement.space then velocity += Vector3.new(0, 1, 0) end
        if movement.shift then velocity -= Vector3.new(0, 1, 0) end
        if velocity.Magnitude > 0 then
            velocity = velocity.Unit
        end
        root.Velocity = velocity * flightSpeed
        root.RotVelocity = Vector3.new(0, 0, 0)
    end)
end

local function disableFlight()
    isFlying = false
    if flightConnection then
        flightConnection:Disconnect()
        flightConnection = nil
    end
    Humanoid.PlatformStand = false
    if HumanoidRootPart then
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
    end
end

-- ====================== YOUR LATEST 13 WAYPOINTS ======================
local waypoints = {
    Vector3.new(78.26573944091797, 250.9907989501953, -443.4682312011719),
    Vector3.new(119.74543762207031, 264.3464050292969, -385.8945007324219),
    Vector3.new(106.99673461914062, 279.97515869140625, -419.4892272949219),
    Vector3.new(-84.01570129394531, 288.97113037109375, -429.68145751953125),
    Vector3.new(-82.29498291015625, 319.4656982421875, -403.697021484375),
    Vector3.new(-82.4467544555664, 359.478759765625, -404.34747314453125),
    Vector3.new(-82.68521881103516, 399.4999084472656, -403.8938293457031),
    Vector3.new(-82.68280792236328, 439.4856262207031, -403.891357421875),
    Vector3.new(-82.68671417236328, 479.4909973144531, -403.8953857421875),
    Vector3.new(-82.6826171875, 519.4810791015625, -403.8911437988281),
    Vector3.new(30.414682388305664, 519.47412109375, -195.48385620117188),
    Vector3.new(-1.4057538509368896, 519.4698486328125, -151.33213806152344),
    Vector3.new(-7.036159515380859, 518.9686889648438, 392.525146484375)
}

-- ====================== AUTO FLY TO TARGET (vitesse maintenant à 45 par défaut) ======================
local function autoFlyTo(target, speed)
    speed = speed or 45  -- vitesse par défaut = 45
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

-- ====================== SERVERHOP SYSTEM (hop automatique après 60 secondes) ======================
local function serverHop()
    print("🚪 Server hopping to a new server...")
    TeleportService:Teleport(game.PlaceId, player)
end

-- ====================== START THE PATH (vitesse 45 + serverhop après 60s) ======================
local function startPath()
    print("🚀 Starting auto noclip path with your exact systems... (vitesse 45)")
    enableNoclip()   -- ton noclip original uniquement
    
    for i, target in ipairs(waypoints) do
        print("➜ STEP " .. i .. "/13 → " .. tostring(target))
        autoFlyTo(target, 45)   -- ← CHANGÉ : maintenant 45
        task.wait(0.4)
    end
    
    disableNoclip()
    print("✅ Path completed! Noclip disabled.")
    print("   → Tu peux maintenant faire enableFlight() dans la console pour voler manuellement")
    
    -- Serverhop system : attend 60 secondes puis change de serveur automatiquement
    print("⏳ Serverhop system activated → hopping in 60 seconds...")
    task.wait(25)
    serverHop()
end

-- Respawn protection
player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    task.wait(1)
    startPath()
end)

-- RUN IT
startPath()
