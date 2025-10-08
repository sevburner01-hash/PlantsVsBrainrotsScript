local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Load UI Library with error handling
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua", true))() or error("Failed to load Kavo UI library")
local Window = Library.CreateLib("GrokHub - Da Hood Elite", "DarkTheme") -- MatrixHub-inspired dark theme

-- Global settings and toggles
getgenv().Enabled = {}
getgenv().Settings = {
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPTransparency = 0.5,
    AuraColor = Color3.fromRGB(0, 255, 0),
    AuraOpacity = 0.5,
    AuraRadius = 10,
    Prediction = 0.13,
    Smoothness = 0.05,
    TriggerDelay = 0.1,
    NukeIntensity = 10
}

-- God Mode (V3 Skinny God-inspired)
Enabled.GodMode = false
function ToggleGodMode()
    Enabled.GodMode = not Enabled.GodMode
    if Enabled.GodMode then
        LocalPlayer.Character.Humanoid.Health = math.huge
        LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v.Name == "Block" then v:Destroy() end
        end
        RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = math.huge
            end
        end)
    end
end

-- ESP (Faded/SwagMode-inspired)
local ESPObjects = {}
function CreateESP(Player)
    if Player == LocalPlayer then return end
    local Highlight = Instance.new("Highlight")
    Highlight.Parent = Player.Character
    Highlight.FillColor = Settings.ESPColor
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    Highlight.FillTransparency = Settings.ESPTransparency
    ESPObjects[Player] = Highlight
end
for _, Player in pairs(Players:GetPlayers()) do
    if Player.Character then CreateESP(Player) end
end
Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function() CreateESP(Player) end)
end)
RunService.RenderStepped:Connect(function()
    for Player, Highlight in pairs(ESPObjects) do
        if Highlight and Highlight.Parent then
            Highlight.FillColor = Settings.ESPColor
            Highlight.FillTransparency = Settings.ESPTransparency
        end
    end
end)

-- Kill Aura (SwagMode-inspired)
Enabled.KillAura = false
function ToggleKillAura()
    Enabled.KillAura = not Enabled.KillAura
    if Enabled.KillAura then
        RunService.Heartbeat:Connect(function()
            if not Enabled.KillAura then return end
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if Distance < Settings.AuraRadius then
                        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/e punch", "All")
                    end
                end
            end
        end)
    end
end

-- Fake Macro (NukerMode-inspired)
Enabled.FakeMacro = false
function ToggleFakeMacro()
    Enabled.FakeMacro = not Enabled.FakeMacro
    if Enabled.FakeMacro then
        spawn(function()
            while Enabled.FakeMacro do
                wait(math.random(0.5, 2))
                keypress(string.char(math.random(97, 100)))
                wait(0.1)
                keyrelease(string.char(math.random(97, 100)))
            end
        end)
    end
end

-- Silent Aim (Juju/Stefanuk12-inspired)
Enabled.SilentAim = false
local AimingTarget = nil
function GetClosestPlayer()
    local Closest, Distance = nil, math.huge
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Dist = (Player.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
            if Dist < Distance then
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
    if Enabled.SilentAim and self.Name == "Hit" and AimingTarget then
        args[1] = CFrame.new(AimingTarget.Character.Head.Position + (AimingTarget.Character.Head.Velocity * Settings.Prediction))
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)
RunService.RenderStepped:Connect(function()
    if Enabled.SilentAim then
        AimingTarget = GetClosestPlayer()
    end
end)

-- Cam Lock
Enabled.CamLock = false
function ToggleCamLock()
    Enabled.CamLock = not Enabled.CamLock
    if Enabled.CamLock then
        RunService.RenderStepped:Connect(function()
            if AimingTarget and AimingTarget.Character then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, AimingTarget.Character.Head.Position)
            end
        end)
    end
end

-- Cursor Lock
Enabled.CursorLock = false
function ToggleCursorLock()
    Enabled.CursorLock = not Enabled.CursorLock
    if Enabled.CursorLock then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        RunService.RenderStepped:Connect(function()
            if AimingTarget then
                mousemoverel((AimingTarget.Character.Head.Position - Mouse.Hit.Position).Magnitude * Settings.Smoothness)
            end
        end)
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- Triggerbot
Enabled.Triggerbot = false
function ToggleTriggerbot()
    Enabled.Triggerbot = not Enabled.Triggerbot
    if Enabled.Triggerbot then
        RunService.Heartbeat:Connect(function()
            if AimingTarget and Mouse.Target and (Mouse.Target.Position - AimingTarget.Character.Head.Position).Magnitude < 5 then
                wait(Settings.TriggerDelay)
                mouse1click()
            end
        end)
    end
end

-- Nuke (Juju/NukerMode-inspired)
Enabled.Nuke = false
function ToggleNuke()
    Enabled.Nuke = not Enabled.Nuke
    if Enabled.Nuke then
        spawn(function()
            while Enabled.Nuke do
                for i = 1, Settings.NukeIntensity do
                    local Effect = Instance.new("Explosion")
                    Effect.Position = LocalPlayer.Character.HumanoidRootPart.Position
                    Effect.Parent = workspace
                end
                wait(0.5)
            end
        end)
    end
end

-- GUI Tabs
local CombatTab = Window:NewTab("Combat")
local VisualsTab = Window:NewTab("Visuals")
local MiscTab = Window:NewTab("Misc")
local CustomTab = Window:NewTab("Customization")

-- Combat Section
local CombatSection = CombatTab:NewSection("Aimbot & Aura")
CombatTab:NewToggle("Silent Aim", "Invisible aim correction", function(state) Enabled.SilentAim = state end)
CombatTab:NewToggle("Kill Aura", "Auto-damage nearby enemies", function(state) ToggleKillAura() end)
CombatTab:NewToggle("Cam Lock", "Lock camera to target", function(state) ToggleCamLock() end)
CombatTab:NewToggle("Cursor Lock", "Lock mouse to target", function(state) ToggleCursorLock() end)
CombatTab:NewToggle("Triggerbot", "Auto-fire on crosshair", function(state) ToggleTriggerbot() end)

-- Visuals Section
local VisualsSection = VisualsTab:NewSection("ESP")
VisualsTab:NewToggle("Full ESP", "Highlight players", function(state)
    for _, Highlight in pairs(ESPObjects) do Highlight.Enabled = state end
end)

-- Misc Section
local MiscSection = MiscTab:NewSection("God & Chaos")
MiscTab:NewToggle("God Mode", "Invincibility", function(state) ToggleGodMode() end)
MiscTab:NewToggle("Fake Macro", "Simulate legit inputs", function(state) ToggleFakeMacro() end)
MiscTab:NewToggle("Nuke", "Spam chaos effects", function(state) ToggleNuke() end)

-- Customization Section (All sliders for live updates)
local CustomSection = CustomTab:NewSection("Colors & Effects")
CustomTab:NewColorPicker("ESP Color", "ESP highlight color", Settings.ESPColor, function(color) Settings.ESPColor = color end)
CustomTab:NewSlider("ESP Transparency", "ESP opacity", 1, 0, function(value) Settings.ESPTransparency = value end)
CustomTab:NewColorPicker("Aura Color", "Kill aura glow", Settings.AuraColor, function(color) Settings.AuraColor = color end)
CustomTab:NewSlider("Aura Opacity", "Aura particle opacity", 1, 0, function(value) Settings.AuraOpacity = value end)
CustomTab:NewSlider("Aura Radius", "Kill aura range", 50, 1, function(value) Settings.AuraRadius = value end)
CustomTab:NewSlider("Aim Prediction", "Silent aim prediction", 1, 0, function(value) Settings.Prediction = value/100 end)
CustomTab:NewSlider("Aim Smoothness", "Cursor lock smoothness", 1, 0, function(value) Settings.Smoothness = value/100 end)
CustomTab:NewSlider("Trigger Delay", "Triggerbot fire delay", 1, 0, function(value) Settings.TriggerDelay = value/10 end)
CustomTab:NewSlider("Nuke Intensity", "Explosion count per tick", 50, 1, function(value) Settings.NukeIntensity = value end)
CustomTab:NewColorPicker("GUI Theme", "Interface color", Color3.fromRGB(30, 30, 30), function(color) Library:SetTheme(color) end)

-- GUI Toggle Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Library:ToggleUI()
    end
end)

-- Aura Visual Effect (Live updates with sliders)
RunService.RenderStepped:Connect(function()
    if Enabled.KillAura then
        local Aura = Instance.new("Part")
        Aura.Anchored = true
        Aura.CanCollide = false
        Aura.Transparency = Settings.AuraOpacity
        Aura.Color = Settings.AuraColor
        Aura.Shape = Enum.PartType.Ball
        Aura.Size = Vector3.new(Settings.AuraRadius * 2, 1, Settings.AuraRadius * 2)
        Aura.Position = LocalPlayer.Character.HumanoidRootPart.Position
        Aura.Parent = workspace
        Debris:AddItem(Aura, 0.1)
    end
end)

print("GrokHub Loaded - Xeno Executor (Educational Use Only)")
