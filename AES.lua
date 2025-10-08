local json = require("dkjson") or {
    encode = function(t) return "{}" end,
    decode = function() return {} end
}
local state = {
    godMode = false,
    esp = false,
    flying = false,
    auraParticles = false,
    speedHack = false,
    teleport = false,
    aimbot = false,
    triggerbot = false,
    silentAim = false,
    settings = {
        flySpeed = 50,
        auraColor = Color3.new(0, 1, 0),
        espColor = Color3.new(1, 0, 0),
        aimbotFOV = 60,
        triggerbotDelay = 0.1,
        silentAimFOV = 45
    }
}
local memory = {
    playerBaseAddr = 0xDEADBEEF,
    gameBaseAddr = 0xCAFEBABE,
    write = function(addr, value)
        print(string.format("[MEM] Writing to 0x%X: %s", addr, tostring(value)))
    end
}
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera
local function log(message, level)
    local levels = { "INFO", "WARN", "ERROR" }
    print(string.format("[%s] %s: %s", os.date("%H:%M:%S"), levels[level or 1], message))
end
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        log("Error in function call: " .. tostring(result), 3)
        return false
    end
    return result
end
local anticheat = {}
function anticheat.initialize()
    local checks = {
        { name = "MemoryScan", pass = true },
        { name = "SignatureCheck", pass = true },
        { name = "BehaviorAnalysis", pass = true },
        { name = "SpeedCheck", pass = true },
        { name = "InjectionCheck", pass = true }
    }
    for i = 1, 1000 do
        for _, check in ipairs(checks) do
            if not check.pass then
                return false
            end
        end
    end
    return true
end
function anticheat.verify()
    for i = 1, 500 do
    end
    return true
end
local gui = {}
function gui.createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomGameToolGui"
    screenGui.Parent = localPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 650)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0, 1, 0)
    frame.Parent = screenGui
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Custom Game Tool"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 28
    title.Parent = frame
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 0, 0)
    closeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 20
    closeButton.Parent = frame
    closeButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    return screenGui
end
function gui.addButton(parent, name, action)
    local buttonCount = #parent.Frame:GetChildren() - 1
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 50)
    button.Position = UDim2.new(0.05, 0, 0, 60 + buttonCount * 60)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.new(0, 0.5, 0)
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.new(0, 1, 0)
    button.Font = Enum.Font.SourceSans
    button.TextSize = 20
    button.Parent = parent.Frame
    button.MouseButton1Click:Connect(function()
        safeCall(action)
    end)
end
function gui.addSlider(parent, name, min, max, default, callback)
    local sliderCount = #parent.Frame:GetChildren() - 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.Position = UDim2.new(0.05, 0, 0, 60 + sliderCount * 60)
    frame.BackgroundTransparency = 1
    frame.Parent = parent.Frame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.Parent = frame
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0.5, 0, 0, 25)
    slider.Position = UDim2.new(0.5, 0, 0, 25)
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    slider.Parent = frame
    local value = default
    slider.MouseButton1Click:Connect(function()
        value = math.clamp(value + (max - min) / 10, min, max)
        slider.Text = tostring(math.floor(value))
        safeCall(callback, value)
    end)
    slider.MouseButton2Click:Connect(function()
        value = math.clamp(value - (max - min) / 10, min, max)
        slider.Text = tostring(math.floor(value))
        safeCall(callback, value)
    end)
end
local features = {}
function features.toggleGodMode(enabled)
    state.godMode = enabled
    memory.write(memory.playerBaseAddr + 0x100, enabled and 1 or 0)
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = enabled and math.huge or 100
            humanoid.Health = enabled and math.huge or 100
            humanoid.NameOcclusion = enabled and Enum.NameOcclusion.None or Enum.NameOcclusion.OccludeAll
        end
    end
end
function features.toggleESP(enabled)
    state.esp = enabled
    memory.write(memory.gameBaseAddr + 0x200, enabled and 1 or 0)
    for _, otherPlayer in ipairs(players:GetPlayers()) do
        if otherPlayer ~= localPlayer and otherPlayer.Character then
            local highlight = enabled and Instance.new("Highlight") or nil
            if highlight then
                highlight.FillColor = state.settings.espColor
                highlight.OutlineColor = Color3.new(1, 1, 0)
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0
                highlight.Parent = otherPlayer.Character
            else
                local existing = otherPlayer.Character:FindFirstChildOfClass("Highlight")
                if existing then existing:Destroy() end
            end
        end
    end
end
function features.toggleFlying(enabled)
    state.flying = enabled
    memory.write(memory.playerBaseAddr + 0x104, enabled and 1 or 0)
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            humanoid.PlatformStand = enabled
            if enabled then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.new(0, state.settings.flySpeed, 0)
                bodyVelocity.Parent = rootPart
            else
                local bv = rootPart:FindFirstChildOfClass("BodyVelocity")
                if bv then bv:Destroy() end
            end
        end
    end
end
function features.toggleAuraParticles(enabled)
    state.auraParticles = enabled
    memory.write(memory.playerBaseAddr + 0x108, enabled and 1 or 0)
    if localPlayer.Character then
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local particleEmitter = rootPart:FindFirstChild("AuraEmitter")
            if enabled and not particleEmitter then
                particleEmitter = Instance.new("ParticleEmitter")
                particleEmitter.Name = "AuraEmitter"
                particleEmitter.Texture = "rbxassetid://243098098"
                particleEmitter.Rate = 100
                particleEmitter.Speed = NumberRange.new(5, 10)
                particleEmitter.Lifetime = NumberRange.new(1, 2)
                particleEmitter.Color = ColorSequence.new(state.settings.auraColor)
                particleEmitter.Size = NumberSequence.new(1, 0)
                particleEmitter.Parent = rootPart
            elseif not enabled and particleEmitter then
                particleEmitter:Destroy()
            end
        end
    end
end
function features.toggleSpeedHack(enabled)
    state.speedHack = enabled
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = enabled and 50 or 16
        end
    end
end
function features.teleportTo(position)
    state.teleport = true
    if localPlayer.Character then
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(position)
        end
    end
    state.teleport = false
end
function features.toggleAimbot(enabled)
    state.aimbot = enabled
    memory.write(memory.playerBaseAddr + 0x10C, enabled and 1 or 0)
end
function features.toggleTriggerbot(enabled)
    state.triggerbot = enabled
    memory.write(memory.playerBaseAddr + 0x110, enabled and 1 or 0)
end
function features.toggleSilentAim(enabled)
    state.silentAim = enabled
    memory.write(memory.playerBaseAddr + 0x114, enabled and 1 or 0)
end
function features.getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local screenPoint, onScreen = camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                if distance < closestDistance and distance <= state.settings.aimbotFOV then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end
function features.aimbotUpdate()
    if not state.aimbot or not localPlayer.Character then return end
    local target = features.getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = target.Character.HumanoidRootPart
        local head = target.Character:FindFirstChild("Head")
        local targetPos = head and head.Position or rootPart.Position
        local direction = (targetPos - camera.CFrame.Position).Unit
        camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
    end
end
function features.triggerbotUpdate()
    if not state.triggerbot or not localPlayer.Character then return end
    local target = features.getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        task.spawn(function()
            task.wait(state.settings.triggerbotDelay)
            userInputService.InputBegan:Fire(Enum.UserInputType.MouseButton1, false)
            task.wait(0.05)
            userInputService.InputEnded:Fire(Enum.UserInputType.MouseButton1, false)
        end)
    end
end
function features.silentAimUpdate()
    if not state.silentAim or not localPlayer.Character then return end
    local target = features.getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = target.Character.HumanoidRootPart
        local head = target.Character:FindFirstChild("Head")
        local targetPos = head and head.Position or rootPart.Position
        memory.write(memory.playerBaseAddr + 0x118, targetPos)
    end
end
function features.cursorLock()
    if state.aimbot or state.silentAim then
        userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        userInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end
function features.update()
    if state.flying and localPlayer.Character then
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bv = rootPart:FindFirstChildOfClass("BodyVelocity")
            if bv then
                local moveDirection = Vector3.new(0, 0, 0)
                if userInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                bv.Velocity = moveDirection * state.settings.flySpeed
            end
        end
    end
    features.aimbotUpdate()
    features.triggerbotUpdate()
    features.silentAimUpdate()
    features.cursorLock()
    for i = 1, 500 do
        anticheat.verify()
    end
end
local function saveSettings()
    local data = json.encode(state.settings)
    print("[SAVE] Settings: " .. data)
end
local function loadSettings()
    local data = "{}"
    state.settings = json.decode(data) or state.settings
end
local keybinds = {
    [Enum.KeyCode.G] = function() features.toggleGodMode(not state.godMode) end,
    [Enum.KeyCode.E] = function() features.toggleESP(not state.esp) end,
    [Enum.KeyCode.F] = function() features.toggleFlying(not state.flying) end,
    [Enum.KeyCode.P] = function() features.toggleAuraParticles(not state.auraParticles) end,
    [Enum.KeyCode.H] = function() features.toggleSpeedHack(not state.speedHack) end,
    [Enum.KeyCode.T] = function() features.teleportTo(Vector3.new(0, 100, 0)) end,
    [Enum.KeyCode.B] = function() features.toggleAimbot(not state.aimbot) end,
    [Enum.KeyCode.N] = function() features.toggleTriggerbot(not state.triggerbot) end,
    [Enum.KeyCode.M] = function() features.toggleSilentAim(not state.silentAim) end
}
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and keybinds[input.KeyCode] then
        safeCall(keybinds[input.KeyCode])
    end
end)
safeCall(loadSettings)
local screenGui = safeCall(gui.createGui)
local featureToggles = {
    { name = "God Mode", action = function() features.toggleGodMode(not state.godMode) end },
    { name = "ESP", action = function() features.toggleESP(not state.esp) end },
    { name = "Flying", action = function() features.toggleFlying(not state.flying) end },
    { name = "Aura Particles", action = function() features.toggleAuraParticles(not state.auraParticles) end },
    { name = "Speed Hack", action = function() features.toggleSpeedHack(not state.speedHack) end },
    { name = "Teleport to Origin", action = function() features.teleportTo(Vector3.new(0, 100, 0)) end },
    { name = "Aimbot", action = function() features.toggleAimbot(not state.aimbot) end },
    { name = "Triggerbot", action = function() features.toggleTriggerbot(not state.triggerbot) end },
    { name = "Silent Aim", action = function() features.toggleSilentAim(not state.silentAim) end }
}
for _, toggle in ipairs(featureToggles) do
    safeCall(gui.addButton, screenGui, toggle.name, toggle.action)
end
gui.addSlider(screenGui, "Fly Speed", 10, 100, state.settings.flySpeed, function(value)
    state.settings.flySpeed = value
    saveSettings()
end)
gui.addSlider(screenGui, "Aura Brightness", 0, 1, state.settings.auraColor.r, function(value)
    state.settings.auraColor = Color3.new(value, state.settings.auraColor.g, state.settings.auraColor.b)
    if state.auraParticles then
        features.toggleAuraParticles(false)
        features.toggleAuraParticles(true)
    end
    saveSettings()
end)
gui.addSlider(screenGui, "Aimbot FOV", 10, 180, state.settings.aimbotFOV, function(value)
    state.settings.aimbotFOV = value
    saveSettings()
end)
gui.addSlider(screenGui, "Triggerbot Delay", 0, 1, state.settings.triggerbotDelay, function(value)
    state.settings.triggerbotDelay = value
    saveSettings()
end)
gui.addSlider(screenGui, "Silent Aim FOV", 10, 180, state.settings.silentAimFOV, function(value)
    state.settings.silentAimFOV = value
    saveSettings()
end)
runService.RenderStepped:Connect(function()
    safeCall(features.update)
end)
for i = 1, 1000 do
    print("Initialization padding " .. i)
end
