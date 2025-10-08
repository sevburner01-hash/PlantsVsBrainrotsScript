local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua", true))() or error("Failed to load Aether UI")
local Window = Library.CreateLib("Aether - Da Hood Elite", "DarkTheme")

getgenv().Enabled = {}
getgenv().Settings = {
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPTransparency = 0.5,
    ESPThickness = 1,
    ESPShowName = true,
    ESPShowHealth = true,
    ESPShowDistance = true,
    AuraColor = Color3.fromRGB(0, 255, 0),
    AuraOpacity = 0.5,
    AuraRadius = 10,
    AuraParticleDensity = 1,
    AuraDamageMultiplier = 1,
    AimbotFOV = 100,
    AimbotHitbox = "Head",
    Prediction = 0.13,
    Smoothness = 0.05,
    TriggerDelay = 0.1,
    NukeIntensity = 10,
    NukeRadius = 5,
    NukeParticleType = "Explosion"
}

local ESPObjects = {}
local ESPTextLabels = {}

function ToggleGodMode()
    Enabled.GodMode = not Enabled.GodMode
    if Enabled.GodMode then
        pcall(function()
            LocalPlayer.Character.Humanoid.Health = math.huge
            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                if v.Name == "Block" then v:Destroy() end
            end
            RunService.Heartbeat:Connect(function()
                if not Enabled.GodMode or not LocalPlayer.Character then return end
                LocalPlayer.Character.Humanoid.Health = math.huge
            end)
        end)
    end
end

function CreateESP(Player)
    if Player == LocalPlayer then return end
    pcall(function()
        local Highlight = Instance.new("Highlight")
        Highlight.Parent = Player.Character
        Highlight.FillColor = Settings.ESPColor
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.FillTransparency = Settings.ESPTransparency
        Highlight.OutlineTransparency = Settings.ESPThickness / 10
        Highlight.Adornee = Player.Character
        ESPObjects[Player] = Highlight

        local Billboard = Instance.new("BillboardGui")
        Billboard.Parent = Player.Character
        Billboard.Adornee = Player.Character
        Billboard.Size = UDim2.new(0, 100, 0, 50)
        Billboard.StudsOffset = Vector3.new(0, 3, 0)
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Parent = Billboard
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextColor3 = Settings.ESPColor
        TextLabel.TextScaled = true
        ESPTextLabels[Player] = {Billboard = Billboard, TextLabel = TextLabel}
    end)
end

function UpdateESP()
    for Player, Data in pairs(ESPTextLabels) do
        pcall(function()
            if not Player.Character or not Data.Billboard.Parent then
                Data.Billboard:Destroy()
                ESPTextLabels[Player] = nil
                return
            end
            local Text = ""
            if Settings.ESPShowName then
                Text = Text .. Player.Name .. "\n"
            end
            if Settings.ESPShowHealth and Player.Character:FindFirstChild("Humanoid") then
                Text = Text .. "Health: " .. math.floor(Player.Character.Humanoid.Health) .. "\n"
            end
            if Settings.ESPShowDistance and LocalPlayer.Character then
                local Dist = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                Text = Text .. "Distance: " .. math.floor(Dist) .. " studs"
            end
            Data.TextLabel.Text = Text
            Data.TextLabel.TextColor3 = Settings.ESPColor
            Data.Billboard.Enabled = Enabled.ESP and (Settings.ESPShowName or Settings.ESPShowHealth or Settings.ESPShowDistance)
        end)
    end
end

for _, Player in pairs(Players:GetPlayers()) do
    if Player.Character then CreateESP(Player) end
end
Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function() CreateESP(Player) end)
end)
RunService.RenderStepped:Connect(function()
    for Player, Highlight in pairs(ESPObjects) do
        pcall(function()
            if Highlight and Highlight.Parent then
                Highlight.FillColor = Settings.ESPColor
                Highlight.FillTransparency = Settings.ESPTransparency
                Highlight.OutlineTransparency = Settings.ESPThickness / 10
            end
        end)
    end
    UpdateESP()
end)

function ToggleKillAura()
    Enabled.KillAura = not Enabled.KillAura
    if Enabled.KillAura then
        RunService.Heartbeat:Connect(function()
            if not Enabled.KillAura then return end
            pcall(function()
                for _, Player in pairs(Players:GetPlayers()) do
                    if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                        if Distance < Settings.AuraRadius then
                            for i = 1, Settings.AuraDamageMultiplier do
                                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/e punch", "All")
                            end
                        end
                    end
                end
            end)
        end)
    end
end

function ToggleFakeMacro()
    Enabled.FakeMacro = not Enabled.FakeMacro
    if Enabled.FakeMacro then
        spawn(function()
            while Enabled.FakeMacro do
                pcall(function()
                    wait(math.random(0.5, 2))
                    keypress(string.char(math.random(97, 100)))
                    wait(0.1)
                    keyrelease(string.char(math.random(97, 100)))
                end)
            end
        end)
    end
end

function GetClosestPlayer()
    local Closest, Distance = nil, math.huge
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Player.Character[Settings.AimbotHitbox].Position)
            local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            if Dist < Settings.AimbotFOV and Dist < Distance and OnScreen then
                Closest = Player
                Distance = Dist
            end
        end
    end
    return Closest
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if Enabled.SilentAim and self.Name == "Hit" and AimingTarget and AimingTarget.Character then
        local TargetPos = AimingTarget.Character[Settings.AimbotHitbox].Position + (AimingTarget.Character[Settings.AimbotHitbox].Velocity * Settings.Prediction)
        args[1] = CFrame.new(TargetPos)
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)
RunService.RenderStepped:Connect(function()
    if Enabled.SilentAim then
        AimingTarget = GetClosestPlayer()
    end
end)

function ToggleCamLock()
    Enabled.CamLock = not Enabled.CamLock
    if Enabled.CamLock then
        RunService.RenderStepped:Connect(function()
            if not Enabled.CamLock or not AimingTarget or not AimingTarget.Character then return end
            pcall(function()
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, AimingTarget.Character[Settings.AimbotHitbox].Position)
            end)
        end)
    end
end

function ToggleCursorLock()
    Enabled.CursorLock = not Enabled.CursorLock
    if Enabled.CursorLock then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        RunService.RenderStepped:Connect(function()
            if not Enabled.CursorLock or not AimingTarget or not AimingTarget.Character then return end
            pcall(function()
                local TargetPos = Camera:WorldToViewportPoint(AimingTarget.Character[Settings.AimbotHitbox].Position)
                mousemoverel((TargetPos.X - Mouse.X) * Settings.Smoothness, (TargetPos.Y - Mouse.Y) * Settings.Smoothness)
            end)
        end)
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

function ToggleTriggerbot()
    Enabled.Triggerbot = not Enabled.Triggerbot
    if Enabled.Triggerbot then
        RunService.Heartbeat:Connect(function()
            if not Enabled.Triggerbot or not AimingTarget or not Mouse.Target or not AimingTarget.Character then return end
            pcall(function()
                if (Mouse.Target.Position - AimingTarget.Character[Settings.AimbotHitbox].Position).Magnitude < 5 then
                    wait(Settings.TriggerDelay)
                    mouse1click()
                end
            end)
        end)
    end
end

function CreateNukeEffect()
    local Effect
    pcall(function()
        if Settings.NukeParticleType == "Explosion" then
            Effect = Instance.new("Explosion")
            Effect.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(
                math.random(-Settings.NukeRadius, Settings.NukeRadius),
                0,
                math.random(-Settings.NukeRadius, Settings.NukeRadius)
            )
        elseif Settings.NukeParticleType == "Spark" then
            Effect = Instance.new("Sparkles")
            Effect.SparkleColor = Settings.AuraColor
            Effect.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(
                math.random(-Settings.NukeRadius, Settings.NukeRadius),
                0,
                math.random(-Settings.NukeRadius, Settings.NukeRadius)
            )
        elseif Settings.NukeParticleType == "Smoke" then
            Effect = Instance.new("Smoke")
            Effect.Color = Settings.AuraColor
            Effect.Opacity = Settings.AuraOpacity
            Effect.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(
                math.random(-Settings.NukeRadius, Settings.NukeRadius),
                0,
                math.random(-Settings.NukeRadius, Settings.NukeRadius)
            )
        end
        Effect.Parent = workspace
        Debris:AddItem(Effect, 1)
    end)
end

function ToggleNuke()
    Enabled.Nuke = not Enabled.Nuke
    if Enabled.Nuke then
        spawn(function()
            while Enabled.Nuke do
                for i = 1, Settings.NukeIntensity do
                    CreateNukeEffect()
                end
                wait(0.5)
            end
        end)
    end
end

local CombatTab = Window:NewTab("Combat")
local VisualsTab = Window:NewTab("Visuals")
local MiscTab = Window:NewTab("Misc")
local CustomTab = Window:NewTab("Customization")

local CombatSection = CombatTab:NewSection("Aimbot & Aura")
CombatTab:NewToggle("Silent Aim", "Invisible aim correction", function(state) Enabled.SilentAim = state end)
CombatTab:NewToggle("Kill Aura", "Auto-damage nearby enemies", function(state) ToggleKillAura() end)
CombatTab:NewToggle("Cam Lock", "Lock camera to target", function(state) ToggleCamLock() end)
CombatTab:NewToggle("Cursor Lock", "Lock mouse to target", function(state) ToggleCursorLock() end)
CombatTab:NewToggle("Triggerbot", "Auto-fire on crosshair", function(state) ToggleTriggerbot() end)

local VisualsSection = VisualsTab:NewSection("ESP")
VisualsTab:NewToggle("Full ESP", "Highlight players", function(state) Enabled.ESP = state end)
VisualsTab:NewToggle("Show Names", "Display player names", function(state) Settings.ESPShowName = state end)
VisualsTab:NewToggle("Show Health", "Display player health", function(state) Settings.ESPShowHealth = state end)
VisualsTab:NewToggle("Show Distance", "Display player distance", function(state) Settings.ESPShowDistance = state end)

local MiscSection = MiscTab:NewSection("God & Chaos")
MiscTab:NewToggle("God Mode", "Invincibility", function(state) ToggleGodMode() end)
MiscTab:NewToggle("Fake Macro", "Simulate legit inputs", function(state) ToggleFakeMacro() end)
MiscTab:NewToggle("Nuke", "Spam chaos effects", function(state) ToggleNuke() end)

local CustomSection = CustomTab:NewSection("Colors & Effects")
CustomTab:NewColorPicker("ESP Color", "ESP highlight color", Settings.ESPColor, function(color) Settings.ESPColor = color end)
CustomTab:NewSlider("ESP Transparency", "ESP opacity", 1, 0, function(value) Settings.ESPTransparency = value end)
CustomTab:NewSlider("ESP Outline Thickness", "ESP outline thickness", 5, 0, function(value) Settings.ESPThickness = value end)
CustomTab:NewToggle("Show ESP Names", "Toggle player names", function(state) Settings.ESPShowName = state end)
CustomTab:NewToggle("Show ESP Health", "Toggle player health", function(state) Settings.ESPShowHealth = state end)
CustomTab:NewToggle("Show ESP Distance", "Toggle player distance", function(state) Settings.ESPShowDistance = state end)
CustomTab:NewColorPicker("Aura Color", "Kill aura glow", Settings.AuraColor, function(color) Settings.AuraColor = color end)
CustomTab:NewSlider("Aura Opacity", "Aura particle opacity", 1, 0, function(value) Settings.AuraOpacity = value end)
CustomTab:NewSlider("Aura Radius", "Kill aura range", 50, 1, function(value) Settings.AuraRadius = value end)
CustomTab:NewSlider("Aura Particle Density", "Aura particle count", 5, 1, function(value) Settings.AuraParticleDensity = value end)
CustomTab:NewSlider("Aura Damage Multiplier", "Aura damage strength", 10, 1, function(value) Settings.AuraDamageMultiplier = value end)
CustomTab:NewDropdown("Aimbot Hitbox", "Target hitbox", {"Head", "Torso"}, function(value) Settings.AimbotHitbox = value end)
CustomTab:NewSlider("Aimbot FOV", "Field of view for aimbot", 500, 10, function(value) Settings.AimbotFOV = value end)
CustomTab:NewSlider("Aim Prediction", "Silent aim prediction", 1, 0, function(value) Settings.Prediction = value/100 end)
CustomTab:NewSlider("Aim Smoothness", "Cursor lock smoothness", 1, 0, function(value) Settings.Smoothness = value/100 end)
CustomTab:NewSlider("Trigger Delay", "Triggerbot fire delay", 1, 0, function(value) Settings.TriggerDelay = value/10 end)
CustomTab:NewSlider("Nuke Intensity", "Effect count per tick", 50, 1, function(value) Settings.NukeIntensity = value end)
CustomTab:NewSlider("Nuke Radius", "Effect spread radius", 20, 1, function(value) Settings.NukeRadius = value end)
CustomTab:NewDropdown("Nuke Particle Type", "Effect type", {"Explosion", "Spark", "Smoke"}, function(value) Settings.NukeParticleType = value end)
CustomTab:NewColorPicker("GUI Theme", "Interface color", Color3.fromRGB(30, 30, 30), function(color) Library:SetTheme(color) end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:ToggleUI()
    end
end)

RunService.RenderStepped:Connect(function()
    if not Enabled.KillAura then return end
    for i = 1, Settings.AuraParticleDensity do
        pcall(function()
            local Aura = Instance.new("Part")
            Aura.Anchored = true
            Aura.CanCollide = false
            Aura.Transparency = Settings.AuraOpacity
            Aura.Color = Settings.AuraColor
            Aura.Shape = Enum.PartType.Ball
            Aura.Size = Vector3.new(Settings.AuraRadius * 2, 1, Settings.AuraRadius * 2)
            Aura.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(
                math.random(-Settings.AuraRadius, Settings.AuraRadius) * 0.5,
                0,
                math.random(-Settings.AuraRadius, Settings.AuraRadius) * 0.5
            )
            Aura.Parent = workspace
            Debris:AddItem(Aura, 0.1)
        end)
    end
end)

local function CreateAuraEffect()
    pcall(function()
        local Aura = Instance.new("Part")
        Aura.Anchored = true
        Aura.CanCollide = false
        Aura.Transparency = Settings.AuraOpacity
        Aura.Color = Settings.AuraColor
        Aura.Shape = Enum.PartType.Ball
        Aura.Size = Vector3.new(Settings.AuraRadius * 2, 1, Settings.AuraRadius * 2)
        Aura.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(
            math.random(-Settings.AuraRadius, Settings.AuraRadius) * 0.5,
            0,
            math.random(-Settings.AuraRadius, Settings.AuraRadius) * 0.5
        )
        Aura.Parent = workspace
        Debris:AddItem(Aura, 0.1)
    end)
end

local function UpdateAuraEffects()
    if not Enabled.KillAura then return end
    for i = 1, Settings.AuraParticleDensity do
        CreateAuraEffect()
    end
end

local function InitializePlayerESP(Player)
    if Player ~= LocalPlayer and Player.Character then
        CreateESP(Player)
    end
end

local function UpdatePlayerESP(Player)
    if ESPObjects[Player] and Player.Character then
        pcall(function()
            ESPObjects[Player].FillColor = Settings.ESPColor
            ESPObjects[Player].FillTransparency = Settings.ESPTransparency
            ESPObjects[Player].OutlineTransparency = Settings.ESPThickness / 10
        end)
    end
end

local function HandlePlayerJoin(Player)
    Player.CharacterAdded:Connect(function()
        InitializePlayerESP(Player)
    end)
end

local function SetupESP()
    for _, Player in pairs(Players:GetPlayers()) do
        InitializePlayerESP(Player)
    end
    Players.PlayerAdded:Connect(HandlePlayerJoin)
end

local function OptimizeAuraLoop()
    RunService.Heartbeat:Connect(function()
        if not Enabled.KillAura then return end
        pcall(function()
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if Distance < Settings.AuraRadius then
                        for i = 1, Settings.AuraDamageMultiplier do
                            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/e punch", "All")
                        end
                    end
                end
            end
        end)
    end)
end

local function OptimizeAimbot()
    RunService.RenderStepped:Connect(function()
        if not Enabled.SilentAim then return end
        AimingTarget = GetClosestPlayer()
    end)
end

local function OptimizeCamLock()
    RunService.RenderStepped:Connect(function()
        if not Enabled.CamLock or not AimingTarget or not AimingTarget.Character then return end
        pcall(function()
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, AimingTarget.Character[Settings.AimbotHitbox].Position)
        end)
    end)
end

local function OptimizeCursorLock()
    RunService.RenderStepped:Connect(function()
        if not Enabled.CursorLock or not AimingTarget or not AimingTarget.Character then return end
        pcall(function()
            local TargetPos = Camera:WorldToViewportPoint(AimingTarget.Character[Settings.AimbotHitbox].Position)
            mousemoverel((TargetPos.X - Mouse.X) * Settings.Smoothness, (TargetPos.Y - Mouse.Y) * Settings.Smoothness)
        end)
    end)
end

local function OptimizeTriggerbot()
    RunService.Heartbeat:Connect(function()
        if not Enabled.Triggerbot or not AimingTarget or not Mouse.Target or not AimingTarget.Character then return end
        pcall(function()
            if (Mouse.Target.Position - AimingTarget.Character[Settings.AimbotHitbox].Position).Magnitude < 5 then
                wait(Settings.TriggerDelay)
                mouse1click()
            end)
        end)
    end)
end

local function OptimizeNuke()
    spawn(function()
        while Enabled.Nuke do
            for i = 1, Settings.NukeIntensity do
                CreateNukeEffect()
            end
            wait(0.5)
        end
    end)
end

local function SetupInitialState()
    Enabled.GodMode = false
    Enabled.SilentAim = false
    Enabled.KillAura = false
    Enabled.CamLock = false
    Enabled.CursorLock = false
    Enabled.Triggerbot = false
    Enabled.FakeMacro = false
    Enabled.Nuke = false
    Enabled.ESP = false
end

local function CreateCombatControls()
    CombatTab:NewToggle("Silent Aim", "Invisible aim correction", function(state) Enabled.SilentAim = state end)
    CombatTab:NewToggle("Kill Aura", "Auto-damage nearby enemies", function(state) ToggleKillAura() end)
    CombatTab:NewToggle("Cam Lock", "Lock camera to target", function(state) ToggleCamLock() end)
    CombatTab:NewToggle("Cursor Lock", "Lock mouse to target", function(state) ToggleCursorLock() end)
    CombatTab:NewToggle("Triggerbot", "Auto-fire on crosshair", function(state) ToggleTriggerbot() end)
end

local function CreateVisualControls()
    VisualsTab:NewToggle("Full ESP", "Highlight players", function(state) Enabled.ESP = state end)
    VisualsTab:NewToggle("Show Names", "Display player names", function(state) Settings.ESPShowName = state end)
    VisualsTab:NewToggle("Show Health", "Display player health", function(state) Settings.ESPShowHealth = state end)
    VisualsTab:NewToggle("Show Distance", "Display player distance", function(state) Settings.ESPShowDistance = state end)
end

local function CreateMiscControls()
    MiscTab:NewToggle("God Mode", "Invincibility", function(state) ToggleGodMode() end)
    MiscTab:NewToggle("Fake Macro", "Simulate legit inputs", function(state) ToggleFakeMacro() end)
    MiscTab:NewToggle("Nuke", "Spam chaos effects", function(state) ToggleNuke() end)
end

local function CreateCustomizationControls()
    CustomTab:NewColorPicker("ESP Color", "ESP highlight color", Settings.ESPColor, function(color) Settings.ESPColor = color end)
    CustomTab:NewSlider("ESP Transparency", "ESP opacity", 1, 0, function(value) Settings.ESPTransparency = value end)
    CustomTab:NewSlider("ESP Outline Thickness", "ESP outline thickness", 5, 0, function(value) Settings.ESPThickness = value end)
    CustomTab:NewToggle("Show ESP Names", "Toggle player names", function(state) Settings.ESPShowName = state end)
    CustomTab:NewToggle("Show ESP Health", "Toggle player health", function(state) Settings.ESPShowHealth = state end)
    CustomTab:NewToggle("Show ESP Distance", "Toggle player distance", function(state) Settings.ESPShowDistance = state end)
    CustomTab:NewColorPicker("Aura Color", "Kill aura glow", Settings.AuraColor, function(color) Settings.AuraColor = color end)
    CustomTab:NewSlider("Aura Opacity", "Aura particle opacity", 1, 0, function(value) Settings.AuraOpacity = value end)
    CustomTab:NewSlider("Aura Radius", "Kill aura range", 50, 1, function(value) Settings.AuraRadius = value end)
    CustomTab:NewSlider("Aura Particle Density", "Aura particle count", 5, 1, function(value) Settings.AuraParticleDensity = value end)
    CustomTab:NewSlider("Aura Damage Multiplier", "Aura damage strength", 10, 1, function(value) Settings.AuraDamageMultiplier = value end)
    CustomTab:NewDropdown("Aimbot Hitbox", "Target hitbox", {"Head", "Torso"}, function(value) Settings.AimbotHitbox = value end)
    CustomTab:NewSlider("Aimbot FOV", "Field of view for aimbot", 500, 10, function(value) Settings.AimbotFOV = value end)
    CustomTab:NewSlider("Aim Prediction", "Silent aim prediction", 1, 0, function(value) Settings.Prediction = value/100 end)
    CustomTab:NewSlider("Aim Smoothness", "Cursor lock smoothness", 1, 0, function(value) Settings.Smoothness = value/100 end)
    CustomTab:NewSlider("Trigger Delay", "Triggerbot fire delay", 1, 0, function(value) Settings.TriggerDelay = value/10 end)
    CustomTab:NewSlider("Nuke Intensity", "Effect count per tick", 50, 1, function(value) Settings.NukeIntensity = value end)
    CustomTab:NewSlider("Nuke Radius", "Effect spread radius", 20, 1, function(value) Settings.NukeRadius = value end)
    CustomTab:NewDropdown("Nuke Particle Type", "Effect type", {"Explosion", "Spark", "Smoke"}, function(value) Settings.NukeParticleType = value end)
    CustomTab:NewColorPicker("GUI Theme", "Interface color", Color3.fromRGB(30, 30, 30), function(color) Library:SetTheme(color) end)
end

SetupInitialState()
SetupESP()
CreateCombatControls()
CreateVisualControls()
CreateMiscControls()
CreateCustomizationControls()

print("Aether Loaded - Xeno Executor (Educational Use Only, 10/07/2025 09:21 PM EDT)")
