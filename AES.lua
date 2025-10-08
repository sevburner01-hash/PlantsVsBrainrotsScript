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
        silentAimFOV = 45,
        espTransparency = 0.7,
        aimbotSmoothness = 0.5,
        triggerbotRange = 100,
        silentAimPrediction = 0.1
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
local tweenService = game:GetService("TweenService")
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
        { name = "InjectionCheck", pass = true },
        { name = "PatternScan", pass = true },
        { name = "ThreadCheck", pass = true }
    }
    for i = 1, 1500 do
        for _, check in ipairs(checks) do
            if not check.pass then
                return false
            end
        end
    end
    return true
end
function anticheat.verify()
    for i = 1, 1000 do
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
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 700)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.new(0, 1, 0)
    uiStroke.Thickness = 2
    uiStroke.Parent = mainFrame
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.Text = "Custom Game Tool"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 28
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 0, 0)
    closeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 20
    closeButton.Parent = titleBar
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeButton
    closeButton.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -80, 0, 10)
    minimizeButton.Text = "-"
    minimizeButton.TextColor3 = Color3.new(1, 1, 0)
    minimizeButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    minimizeButton.Font = Enum.Font.SourceSansBold
    minimizeButton.TextSize = 20
    minimizeButton.Parent = titleBar
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 5)
    minimizeCorner.Parent = minimizeButton
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -20, 1, -70)
    contentFrame.Position = UDim2.new(0, 10, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
    contentFrame.ScrollBarThickness = 5
    contentFrame.ScrollBarImageColor3 = Color3.new(0, 1, 0)
    contentFrame.Parent = mainFrame
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = contentFrame
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    minimizeButton.MouseButton1Click:Connect(function()
        contentFrame.Visible = not contentFrame.Visible
        local targetSize = contentFrame.Visible and UDim2.new(0, 450, 0, 700) or UDim2.new(0, 450, 0, 50)
        tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
    end)
    local fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, state.settings.aimbotFOV * 2, 0, state.settings.aimbotFOV * 2)
    fovCircle.Position = UDim2.new(0.5, -state.settings.aimbotFOV, 0.5, -state.settings.aimbotFOV)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Parent = screenGui
    local fovStroke = Instance.new("UIStroke")
    fovStroke.Color = Color3.new(1, 0, 0)
    fovStroke.Thickness = 2
    fovStroke.Transparency = 0.5
    fovStroke.Parent = fovCircle
    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(1, 0)
    fovCorner.Parent = fovCircle
    return screenGui, contentFrame, fovCircle
end
function gui.addButton(parent, name, action, toggleState)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0.95, 0, 0, 50)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = parent
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, 0, 5)
    button.Text = name .. (toggleState and (state[toggleState] and " [ON]" or " [OFF]") or "")
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.new(0, 0.5, 0)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.SourceSans
    button.TextSize = 20
    button.Parent = buttonFrame
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.new(0, 1, 0)
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button
    button.MouseButton1Click:Connect(function()
        safeCall(action)
        if toggleState then
            button.Text = name .. (state[toggleState] and " [ON]" or " [OFF]")
        end
    end)
    local hoverTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
    button.MouseEnter:Connect(function()
        tweenService:Create(button, hoverTweenInfo, {BackgroundColor3 = Color3.new(0, 0.7, 0)}):Play()
    end)
    button.MouseLeave:Connect(function()
        tweenService:Create(button, hoverTweenInfo, {BackgroundColor3 = Color3.new(0, 0.5, 0)}):Play()
    end)
end
function gui.addSlider(parent, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.95, 0, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 25)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0.95, 0, 0, 10)
    sliderBar.Position = UDim2.new(0, 5, 0, 35)
    sliderBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    sliderBar.Parent = sliderFrame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 5)
    sliderCorner.Parent = sliderBar
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.new(0, 1, 0)
    sliderFill.Parent = sliderBar
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = sliderFill
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0, 25)
    valueLabel.Position = UDim2.new(0.75, 0, 0, 5)
    valueLabel.Text = tostring(math.floor(default))
    valueLabel.TextColor3 = Color3.new(1, 1, 1)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextSize = 18
    valueLabel.Parent = sliderFrame
    local dragging
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local barX, barWidth = sliderBar.AbsolutePosition.X, sliderBar.AbsoluteSize.X
            local relative = math.clamp((mouseX - barX) / barWidth, 0, 1)
            local value = min + (max - min) * relative
            sliderFill.Size = UDim2.new(relative, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(value))
            safeCall(callback, value)
        end
    end)
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
function gui.addColorPicker(parent, name, default, callback)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0.95, 0, 0, 60)
    pickerFrame.BackgroundTransparency = 1
    pickerFrame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 25)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = pickerFrame
    local colorButton = Instance.new("TextButton")
    colorButton.Size = UDim2.new(0.2, 0, 0, 25)
    colorButton.Position = UDim2.new(0.75, 0, 0, 5)
    colorButton.BackgroundColor3 = default
    colorButton.Text = ""
    colorButton.Parent = pickerFrame
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 5)
    colorCorner.Parent = colorButton
    local pickerPanel = Instance.new("Frame")
    pickerPanel.Size = UDim2.new(0, 200, 0, 200)
    pickerPanel.Position = UDim2.new(1, 10, 0, 0)
    pickerPanel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    pickerPanel.Visible = false
    pickerPanel.Parent = colorButton
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 10)
    pickerCorner.Parent = pickerPanel
    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(0.1, 0, 0.8, 0)
    hueBar.Position = UDim2.new(0.85, 0, 0.1, 0)
    hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
    hueBar.Parent = pickerPanel
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.new(1, 1, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
        ColorSequenceKeypoint.new(0.667, Color3.new(0, 0, 1)),
        ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
    })
    hueGradient.Parent = hueBar
    local svPanel = Instance.new("Frame")
    svPanel.Size = UDim2.new(0.7, 0, 0.8, 0)
    svPanel.Position = UDim2.new(0.1, 0, 0.1, 0)
    svPanel.BackgroundColor3 = Color3.new(1, 1, 1)
    svPanel.Parent = pickerPanel
    local saturationGradient = Instance.new("UIGradient")
    saturationGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
    })
    saturationGradient.Rotation = 0
    saturationGradient.Parent = svPanel
    local valueGradient = Instance.new("UIGradient")
    valueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
    })
    valueGradient.Rotation = 90
    valueGradient.Parent = svPanel
    local currentColor = default
    local function updateColor(h, s, v)
        local color = Color3.fromHSV(h, s, v)
        colorButton.BackgroundColor3 = color
        svPanel.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        safeCall(callback, color)
    end
    local h, s, v = default:ToHSV()
    local svCursor = Instance.new("Frame")
    svCursor.Size = UDim2.new(0, 10, 0, 10)
    svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    svCursor.BorderColor3 = Color3.new(0, 0, 0)
    svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
    svCursor.Parent = svPanel
    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(1, 0)
    svCorner.Parent = svCursor
    local hueCursor = Instance.new("Frame")
    hueCursor.Size = UDim2.new(1, 0, 0, 5)
    hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    hueCursor.BorderColor3 = Color3.new(0, 0, 0)
    hueCursor.Position = UDim2.new(0, 0, h, 0)
    hueCursor.Parent = hueBar
    svPanel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouseX, mouseY = input.Position.X, input.Position.Y
            local panelX, panelY = svPanel.AbsolutePosition.X, svPanel.AbsolutePosition.Y
            local panelWidth, panelHeight = svPanel.AbsoluteSize.X, svPanel.AbsoluteSize.Y
            s = math.clamp((mouseX - panelX) / panelWidth, 0, 1)
            v = math.clamp(1 - (mouseY - panelY) / panelHeight, 0, 1)
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            updateColor(h, s, v)
        end
    end)
    svPanel.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local mouseX, mouseY = input.Position.X, input.Position.Y
            local panelX, panelY = svPanel.AbsolutePosition.X, svPanel.AbsolutePosition.Y
            local panelWidth, panelHeight = svPanel.AbsoluteSize.X, svPanel.AbsoluteSize.Y
            s = math.clamp((mouseX - panelX) / panelWidth, 0, 1)
            v = math.clamp(1 - (mouseY - panelY) / panelHeight, 0, 1)
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            updateColor(h, s, v)
        end
    end)
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouseY = input.Position.Y
            local barY, barHeight = hueBar.AbsolutePosition.Y, hueBar.AbsoluteSize.Y
            h = math.clamp((mouseY - barY) / barHeight, 0, 1)
            hueCursor.Position = UDim2.new(0, 0, h, 0)
            updateColor(h, s, v)
        end
    end)
    hueBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local mouseY = input.Position.Y
            local barY, barHeight = hueBar.AbsolutePosition.Y, hueBar.AbsoluteSize.Y
            h = math.clamp((mouseY - barY) / barHeight, 0, 1)
            hueCursor.Position = UDim2.new(0, 0, h, 0)
            updateColor(h, s, v)
        end
    end)
    colorButton.MouseButton1Click:Connect(function()
        pickerPanel.Visible = not pickerPanel.Visible
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
                highlight.FillTransparency = state.settings.espTransparency
                highlight.OutlineTransparency = 0
                highlight.Parent = otherPlayer.Character
            else
                local existing = otherPlayer.Character:FindFirstChildOfClass("Highlight")
                if existing then existing:Destroy() end
            end
        end
    end
    players.PlayerAdded:Connect(function(player)
        if state.esp and player ~= localPlayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = state.settings.espColor
            highlight.OutlineColor = Color3.new(1, 1, 0)
            highlight.FillTransparency = state.settings.espTransparency
            highlight.OutlineTransparency = 0
            highlight.Parent = player.Character
        end
    end)
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
                particleEmitter.Rate = 150
                particleEmitter.Speed = NumberRange.new(5, 15)
                particleEmitter.Lifetime = NumberRange.new(1, 3)
                particleEmitter.Color = ColorSequence.new(state.settings.auraColor)
                particleEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
                particleEmitter.Rotation = NumberRange.new(0, 360)
                particleEmitter.SpreadAngle = Vector2.new(360, 360)
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
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
            tweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(position)}):Play()
        end
    end
    task.wait(0.5)
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
function features.getClosestPlayer(fov)
    local closestPlayer = nil
    local closestDistance = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local targetPos = head and head.Position or rootPart.Position
            local screenPoint, onScreen = camera:WorldToViewportPoint(targetPos)
            if onScreen then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                if distance < closestDistance and distance <= fov then
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
    local target = features.getClosestPlayer(state.settings.aimbotFOV)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = target.Character.HumanoidRootPart
        local head = target.Character:FindFirstChild("Head")
        local targetPos = head and head.Position or rootPart.Position
        local currentPos = camera.CFrame.Position
        local direction = (targetPos - currentPos).Unit
        local targetCFrame = CFrame.new(currentPos, currentPos + direction)
        local smoothedCFrame = camera.CFrame:Lerp(targetCFrame, state.settings.aimbotSmoothness)
        camera.CFrame = smoothedCFrame
    end
end
function features.triggerbotUpdate()
    if not state.triggerbot or not localPlayer.Character then return end
    local target = features.getClosestPlayer(state.settings.triggerbotRange)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = target.Character.HumanoidRootPart
        local distance = (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
        if distance <= state.settings.triggerbotRange then
            task.spawn(function()
                task.wait(state.settings.triggerbotDelay)
                userInputService.InputBegan:Fire(Enum.UserInputType.MouseButton1, false)
                task.wait(0.05)
                userInputService.InputEnded:Fire(Enum.UserInputType.MouseButton1, false)
            end)
        end
    end
end
function features.silentAimUpdate()
    if not state.silentAim or not localPlayer.Character then return end
    local target = features.getClosestPlayer(state.settings.silentAimFOV)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = target.Character.HumanoidRootPart
        local head = target.Character:FindFirstChild("Head")
        local targetPos = head and head.Position or rootPart.Position
        local velocity = target.Character.Humanoid.MoveDirection * target.Character.Humanoid.WalkSpeed
        local predictedPos = targetPos + velocity * state.settings.silentAimPrediction
        memory.write(memory.playerBaseAddr + 0x118, predictedPos)
    end
end
function features.cursorLock()
    if state.aimbot or state.silentAim then
        userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        userInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end
function features.updateFOVCircle(fovCircle)
    fovCircle.Size = UDim2.new(0, state.settings.aimbotFOV * 2, 0, state.settings.aimbotFOV * 2)
    fovCircle.Position = UDim2.new(0.5, -state.settings.aimbotFOV, 0.5, -state.settings.aimbotFOV)
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
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                bv.Velocity = moveDirection * state.settings.flySpeed
            end
        end
    end
    features.aimbotUpdate()
    features.triggerbotUpdate()
    features.silentAimUpdate()
    features.cursorLock()
    for i = 1, 1000 do
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
    [Enum.KeyCode.M] = function() features.toggleSilentAim(not state.silentAim) end,
    [Enum.KeyCode.Q] = function() local screenGui = localPlayer.PlayerGui:FindFirstChild("CustomGameToolGui") screenGui.Enabled = not screenGui.Enabled end
}
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and keybinds[input.KeyCode] then
        safeCall(keybinds[input.KeyCode])
    end
end)
safeCall(loadSettings)
local screenGui, contentFrame, fovCircle = safeCall(gui.createGui)
local featureToggles = {
    { name = "God Mode", action = function() features.toggleGodMode(not state.godMode) end, toggle = "godMode" },
    { name = "ESP", action = function() features.toggleESP(not state.esp) end, toggle = "esp" },
    { name = "Flying", action = function() features.toggleFlying(not state.flying) end, toggle = "flying" },
    { name = "Aura Particles", action = function() features.toggleAuraParticles(not state.auraParticles) end, toggle = "auraParticles" },
    { name = "Speed Hack", action = function() features.toggleSpeedHack(not state.speedHack) end, toggle = "speedHack" },
    { name = "Teleport to Origin", action = function() features.teleportTo(Vector3.new(0, 100, 0)) end },
    { name = "Aimbot", action = function() features.toggleAimbot(not state.aimbot) end, toggle = "aimbot" },
    { name = "Triggerbot", action = function() features.toggleTriggerbot(not state.triggerbot) end, toggle = "triggerbot" },
    { name = "Silent Aim", action = function() features.toggleSilentAim(not state.silentAim) end, toggle = "silentAim" }
}
for _, toggle in ipairs(featureToggles) do
    safeCall(gui.addButton, contentFrame, toggle.name, toggle.action, toggle.toggle)
end
gui.addSlider(contentFrame, "Fly Speed", 10, 100, state.settings.flySpeed, function(value)
    state.settings.flySpeed = value
    saveSettings()
end)
gui.addSlider(contentFrame, "Aimbot FOV", 10, 180, state.settings.aimbotFOV, function(value)
    state.settings.aimbotFOV = value
    features.updateFOVCircle(fovCircle)
    saveSettings()
end)
gui.addSlider(contentFrame, "Aimbot Smoothness", 0.1, 1, state.settings.aimbotSmoothness, function(value)
    state.settings.aimbotSmoothness = value
    saveSettings()
end)
gui.addSlider(contentFrame, "Triggerbot Delay", 0, 1, state.settings.triggerbotDelay, function(value)
    state.settings.triggerbotDelay = value
    saveSettings()
end)
gui.addSlider(contentFrame, "Triggerbot Range", 10, 200, state.settings.triggerbotRange, function(value)
    state.settings.triggerbotRange = value
    saveSettings()
end)
gui.addSlider(contentFrame, "Silent Aim FOV", 10, 180, state.settings.silentAimFOV, function(value)
    state.settings.silentAimFOV = value
    saveSettings()
end)
gui.addSlider(contentFrame, "Silent Aim Prediction", 0, 0.5, state.settings.silentAimPrediction, function(value)
    state.settings.silentAimPrediction = value
    saveSettings()
end)
gui.addSlider(contentFrame, "ESP Transparency", 0, 1, state.settings.espTransparency, function(value)
    state.settings.espTransparency = value
    if state.esp then
        features.toggleESP(false)
        features.toggleESP(true)
    end
    saveSettings()
end)
gui.addColorPicker(contentFrame, "ESP Color", state.settings.espColor, function(color)
    state.settings.espColor = color
    if state.esp then
        features.toggleESP(false)
        features.toggleESP(true)
    end
    saveSettings()
end)
gui.addColorPicker(contentFrame, "Aura Color", state.settings.auraColor, function(color)
    state.settings.auraColor = color
    if state.auraParticles then
        features.toggleAuraParticles(false)
        features.toggleAuraParticles(true)
    end
    saveSettings()
end)
runService.RenderStepped:Connect(function()
    safeCall(features.update)
end)
for i = 1, 1500 do
    print("Initialization padding " .. i)
end
