-- Plants Vs Brainrots Ultimate Cheat GUI - Optimized and Fixed
-- Launches GUI immediately, loads remotes with error handling
-- Features: Auto Farm (plant/collect), Auto Sell, Auto Buy, Auto Fuse, Dupe (via buy loop), Rainbow, Anti-Cheat Evasion
-- Duped items "saved" by server-sync via remotes
-- Hotkey: [ to toggle GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variables
local farmPos = Vector3.new(0, 5, 0) -- Adjust to your plot position
local isFarming = false
local isSelling = false
local isBuying = false
local isFusing = false
local isRainbow = false
local dupeAmt = 50
local buyAmt = 100
local delayMin = 0.2
local delayMax = 1.0
local gui = nil
local isGuiOpen = true
local farmConn = nil
local sellConn = nil
local buyConn = nil
local fuseConn = nil

-- Remote loading with pcall to prevent hanging
local function getRemote(name)
    local success, remote = pcall(function()
        return ReplicatedStorage.Remotes:WaitForChild(name, 5) -- Timeout 5s
    end)
    if success and remote then
        return remote
    else
        StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Remote '" .. name .. "' not found.", Duration = 5})
        return nil
    end
end

-- Get held item
local function getHeldItem()
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then return item end
    end
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then return item end
    end
    return nil
end

-- Dupe via buy loop (server-synced)
local function dupeItem()
    local buyRemote = getRemote("BuySeed")
    if not buyRemote then return end
    local item = getHeldItem()
    if item then
        for i = 1, dupeAmt do
            buyRemote:FireServer(item.Name, 1) -- Buy one at a time
            if isRainbow then
                task.wait(0.1)
                local newItem = backpack:FindFirstChild(item.Name)
                if newItem then
                    local rbScript = Instance.new("LocalScript", newItem)
                    rbScript.Name = "Rainbow"
                    rbScript.Source = "local h = script.Parent.Handle if h then while true do h.Color = Color3.fromHSV(tick()%1,1,1) wait(0.1) end end"
                end
            end
            task.wait(math.random(delayMin, delayMax))
        end
    end
end

-- Auto Farm
local function autoFarm()
    if isFarming and character and humanoid.Health > 0 then
        humanoid:MoveTo(farmPos)
        task.wait(math.random(1, 3))
        local plantRemote = getRemote("PlantSeed")
        local collectRemote = getRemote("CollectMoney")
        if plantRemote then
            local seed = getHeldItem() or backpack:FindFirstChildOfClass("Tool")
            if seed then
                humanoid:EquipTool(seed)
                task.wait(math.random(delayMin, delayMax))
                plantRemote:FireServer(farmPos, seed.Name)
            end
        end
        if collectRemote then collectRemote:FireServer() end
        task.wait(math.random(2, 5))
    end
end

-- Auto Sell
local function autoSell()
    if isSelling then
        local sellRemote = getRemote("SellPlant")
        if sellRemote then
            sellRemote:FireServer("All")
        end
        task.wait(math.random(1, 2))
    end
end

-- Auto Buy
local function autoBuy()
    if isBuying then
        local buyRemote = getRemote("BuySeed")
        if buyRemote then
            buyRemote:FireServer("CommonSeed", buyAmt) -- Adjust seed name
        end
        task.wait(math.random(1, 2))
    end
end

-- Auto Fuse
local function autoFuse()
    if isFusing then
        local fuseRemote = getRemote("FusePlants")
        if fuseRemote then
            fuseRemote:FireServer("Plant1", "Plant2") -- Adjust args
        end
        task.wait(math.random(3, 5))
    end
end

-- Toggles
local function toggleFarm()
    isFarming = not isFarming
    if isFarming then farmConn = RunService.Heartbeat:Connect(autoFarm) else if farmConn then farmConn:Disconnect() end end
end

local function toggleSell()
    isSelling = not isSelling
    if isSelling then sellConn = RunService.Heartbeat:Connect(autoSell) else if sellConn then sellConn:Disconnect() end end
end

local function toggleBuy()
    isBuying = not isBuying
    if isBuying then buyConn = RunService.Heartbeat:Connect(autoBuy) else if buyConn then buyConn:Disconnect() end end
end

local function toggleFuse()
    isFusing = not isFusing
    if isFusing then fuseConn = RunService.Heartbeat:Connect(autoFuse) else if fuseConn then fuseConn:Disconnect() end end
end

local function toggleRainbow()
    isRainbow = not isRainbow
end

local function toggleGui()
    isGuiOpen = not isGuiOpen
    if gui then gui.Enabled = isGuiOpen end
end

-- Hotkey [
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftBracket then toggleGui() end
end)

-- Create GUI first to ensure launch
local function createGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PvBCheat"
    sg.Parent = player.PlayerGui
    sg.ResetOnSpawn = false
    gui = sg

    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 300, 0, 400)
    fr.Position = UDim2.new(0.5, -150, 0.5, -200)
    fr.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    fr.Parent = sg

    Instance.new("UICorner").Parent = fr
    Instance.new("UIStroke").Parent = fr

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "PvB Ultimate Cheat"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.Parent = fr

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 5)
    close.Text = "X"
    close.BackgroundColor3 = Color3.new(1,0,0)
    close.Parent = fr
    close.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Add buttons similarly as before
    local function addButton(pos, text, color, func)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, pos)
        btn.Text = text
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Parent = fr
        btn.MouseButton1Click:Connect(func)
        return btn
    end

    local farmBtn = addButton(50, "Toggle Farm", Color3.fromRGB(0,255,0), function()
        toggleFarm()
        farmBtn.Text = isFarming and "Stop Farm" or "Toggle Farm"
        farmBtn.BackgroundColor3 = isFarming and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
    end)

    local dupeBtn = addButton(100, "Dupe x" .. dupeAmt, Color3.fromRGB(255,165,0), dupeItem)

    local sellBtn = addButton(150, "Toggle Sell", Color3.fromRGB(255,0,0), function()
        toggleSell()
        sellBtn.Text = isSelling and "Stop Sell" or "Toggle Sell"
    end)

    local buyBtn = addButton(200, "Toggle Buy", Color3.fromRGB(0,0,255), function()
        toggleBuy()
        buyBtn.Text = isBuying and "Stop Buy" or "Toggle Buy"
    end)

    local fuseBtn = addButton(250, "Toggle Fuse", Color3.fromRGB(128,0,128), function()
        toggleFuse()
        fuseBtn.Text = isFusing and "Stop Fuse" or "Toggle Fuse"
    end)

    local rbBtn = addButton(300, "Toggle Rainbow", Color3.fromRGB(255,0,255), function()
        toggleRainbow()
        rbBtn.Text = isRainbow and "Disable Rainbow" or "Toggle Rainbow"
    end)

    -- Draggable
    local dragging, dragInput, dragStart, startPos
    fr.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = fr.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    fr.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            fr.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    StarterGui:SetCore("SendNotification", {Title = "Loaded", Text = "PvB Cheat GUI Loaded - [ to toggle", Duration = 5})
end

-- Launch GUI immediately
createGui()

-- Respawn handle
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    if isFarming then toggleFarm() toggleFarm() end
    if isSelling then toggleSell() toggleSell() end
    if isBuying then toggleBuy() toggleBuy() end
    if isFusing then toggleFuse() toggleFuse() end
end)
