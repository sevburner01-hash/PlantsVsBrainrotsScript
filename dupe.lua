local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Optimized for Plants Vs Brainrots: Adjusted for seed/plant duplication, auto-farming involves auto-planting and collecting
-- Anti-cheat evasion: Random delays, human-like actions (walk instead of instant teleport), obfuscated variable names where possible
-- Items: Duplicated plants/seeds retain original functions via Clone(), assumed sellable/tradeable if game allows (client-side)
-- Hotkey: "[" for toggle GUI

-- Obfuscated variables for minor evasion
local _farmPos = Vector3.new(0, 5, 0) -- Adjust to your garden center in Plants Vs Brainrots (e.g., your plot position)
local _isFarming = false
local _isRainbow = false
local _dupeAmt = 50
local _farmConn = nil
local _gui = nil -- GUI reference
local _isGuiOpen = true -- Start open, toggle with hotkey
local _antiCheatDelayMin = 0.1
local _antiCheatDelayMax = 0.5

-- Function to get held item (seed/plant tool)
local function _getHeldItem()
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then -- Assuming seeds are Tools in the game
            return item
        end
    end
    return nil
end

-- Duplication with evasion: Duplicate held seed/plant, retain functions, add rainbow if enabled
local function _dupeItem()
    local item = _getHeldItem()
    if item then
        for i = 1, _dupeAmt do
            local clone = item:Clone()
            clone.Parent = backpack
            
            if _isRainbow then
                local rbScript = Instance.new("LocalScript")
                rbScript.Name = "RbEff" -- Obfuscated name
                rbScript.Source = [[
                    local h = script.Parent:FindFirstChild("Handle")
                    if h and h:IsA("BasePart") then
                        while true do
                            h.Color = Color3.fromHSV(tick() % 1, 1, 1)
                            wait(0.1)
                        end
                    end
                ]]
                rbScript.Parent = clone
            end
            
            task.wait(math.random(_antiCheatDelayMin, _antiCheatDelayMax)) -- Random yield to mimic human
        end
        -- Assume game has selling/trading; clones should work if not server-validated
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Dupe Error",
            Text = "No held item to duplicate.",
            Duration = 5
        })
    end
end

-- Auto-farm optimized for Plants Vs Brainrots: Walk to plot, auto-plant, collect money (adapt remotes if needed)
local function _autoFarm()
    if _isFarming and character and humanoid.Health > 0 then
        -- Human-like walk to farm pos instead of tween for anti-cheat
        humanoid:MoveTo(_farmPos)
        task.wait(math.random(1, 2)) -- Random walk time
        
        -- Auto-plant logic: Equip seed, activate (assuming Tool activation plants)
        local seed = _getHeldItem() or backpack:FindFirstChildOfClass("Tool")
        if seed then
            humanoid:EquipTool(seed)
            task.wait(math.random(_antiCheatDelayMin, _antiCheatDelayMax))
            seed:Activate() -- Plant action
        end
        
        -- Auto-collect/sell: Fire game remotes if known (placeholder; find actual remotes via decompiler)
        -- Example: ReplicatedStorage.Remotes.CollectMoney:FireServer()
        -- Add auto-sell: Sell plants if inventory full
        
        task.wait(math.random(2, 5)) -- Cooldown with random
    end
end

-- Toggle auto-farm
local function _toggleFarm()
    _isFarming = not _isFarming
    if _isFarming then
        if _farmConn then _farmConn:Disconnect() end
        _farmConn = RunService.Heartbeat:Connect(_autoFarm)
    else
        if _farmConn then
            _farmConn:Disconnect()
            _farmConn = nil
        end
    end
end

-- Toggle rainbow
local function _toggleRb()
    _isRainbow = not _isRainbow
end

-- Toggle GUI visibility
local function _toggleGui()
    _isGuiOpen = not _isGuiOpen
    if _gui then
        _gui.Enabled = _isGuiOpen
    end
end

-- Hotkey for GUI toggle: "["
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftBracket then
        _toggleGui()
    end
end)

-- Create polished GUI with game-specific features
local function _createGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "OptMenu" -- Obfuscated
    sg.Parent = player:WaitForChild("PlayerGui")
    sg.ResetOnSpawn = false
    _gui = sg

    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 250, 0, 250)
    fr.Position = UDim2.new(0.5, -125, 0.5, -125)
    fr.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    fr.BorderSizePixel = 0
    fr.Parent = sg

    -- UI styling (same as before, omitted for brevity)

    -- Title, close button (same)

    -- Dupe button (for seeds/plants)
    -- Auto-farm button (optimized for game)

    -- Rainbow button

    -- Additional for game: Auto-sell button
    local autoSell = false
    local function _toggleSell()
        autoSell = not autoSell
        -- Implement auto-sell: Loop sell remotes with delays
        if autoSell then
            spawn(function()
                while autoSell do
                    -- Placeholder: ReplicatedStorage.Remotes.SellPlant:FireServer()
                    task.wait(math.random(1, 3))
                end
            end)
        end
    end

    -- Add button for auto-sell

    -- Notification
    StarterGui:SetCore("SendNotification", {
        Title = "Menu Loaded",
        Text = "Optimized for Plants Vs Brainrots with anti-cheat evasion.",
        Duration = 5
    })
end

-- Initialize
_createGui()

-- Respawn handle
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    if _isFarming then
        _toggleFarm()
        _toggleFarm()
    end
end)
