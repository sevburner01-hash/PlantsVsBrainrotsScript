local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Game-specific: Plants Vs Brainrots remotes (common names; adjust if needed via decompiler)
local remotes = ReplicatedStorage:WaitForChild("Remotes") -- Assuming folder
local plantRemote = remotes:WaitForChild("PlantSeed") -- Plant seed
local sellRemote = remotes:WaitForChild("SellPlant") -- Sell plant
local buyRemote = remotes:WaitForChild("BuySeed") -- Buy seed
local dupeRemote = remotes:WaitForChild("DupeItem") -- If exists; else use buy loop
local collectRemote = remotes:WaitForChild("CollectMoney") -- Collect rewards
local fuseRemote = remotes:WaitForChild("FusePlants") -- Fuse for huge plants

-- Obfuscated vars for anti-cheat
local _farmPos = Vector3.new(0, 5, 0) -- Set to your plot/garden position
local _isFarming = false
local _isDuping = false
local _isSelling = false
local _isBuying = false
local _isFusing = false
local _isRainbow = false
local _dupeAmt = 50
local _buyAmt = 100 -- Amount to buy/dupe per cycle
local _farmConn = nil
local _dupeConn = nil
local _sellConn = nil
local _buyConn = nil
local _fuseConn = nil
local _gui = nil
local _isGuiOpen = true
local _delayMin = 0.2
local _delayMax = 1.0

-- Get held item (seed/plant/brainrot)
local function _getHeldItem()
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    return nil
end

-- Server-synced dupe: Fire buy remote multiple times or exploit dupe if available
local function _dupeItem()
    if _isDuping then return end
    _isDuping = true
    local item = _getHeldItem()
    if item then
        for i = 1, _dupeAmt do
            -- Use buy remote to "dupe" by buying equivalents; or fire dupe if exists
            if dupeRemote then
                dupeRemote:FireServer(item.Name, 1) -- Assume args: itemName, amount
            else
                buyRemote:FireServer(item.Name, 1) -- Buy one each time for effective dupe
            end
            -- Add rainbow to new item if enabled (local visual)
            if _isRainbow then
                task.wait(0.1)
                local newItem = backpack:FindFirstChild(item.Name .. " (Clone)") or backpack:FindFirstChild(item.Name)
                if newItem then
                    local rbScript = Instance.new("LocalScript")
                    rbScript.Name = "RbEff"
                    rbScript.Source = [[
                        local h = script.Parent:FindFirstChild("Handle")
                        if h and h:IsA("BasePart") then
                            while true do
                                h.Color = Color3.fromHSV(tick() % 1, 1, 1)
                                wait(0.1)
                            end
                        end
                    ]]
                    rbScript.Parent = newItem
                end
            end
            task.wait(math.random(_delayMin * 10, _delayMax * 10) / 10) -- Random delay
        end
        -- "Save" by auto-equipping one to persist local state
        if item then humanoid:EquipTool(item) end
    else
        StarterGui:SetCore("SendNotification", {Title = "Dupe Error", Text = "No item to dupe.", Duration = 3})
    end
    _isDuping = false
end

-- Auto-farm: Move to plot, plant, collect, with server fires
local function _autoFarm()
    if _isFarming and character and humanoid.Health > 0 then
        humanoid:MoveTo(_farmPos)
        task.wait(math.random(1, 3))
        local seed = _getHeldItem() or backpack:FindFirstChildOfClass("Tool")
        if seed then
            humanoid:EquipTool(seed)
            task.wait(math.random(_delayMin, _delayMax))
            plantRemote:FireServer(_farmPos, seed.Name) -- Plant at position
        end
        collectRemote:FireServer() -- Collect money
        task.wait(math.random(2, 5))
    end
end

-- Auto-sell: Fire sell remote for all or selected
local function _autoSell()
    if _isSelling then
        sellRemote:FireServer("All") -- Assume "All" arg for inventory
        task.wait(math.random(1, 2))
    end
end

-- Auto-buy: Buy seeds/plants
local function _autoBuy()
    if _isBuying then
        buyRemote:FireServer("CommonSeed", _buyAmt) -- Example seed name
        task.wait(math.random(1, 2))
    end
end

-- Auto-fuse: For huge plants
local function _autoFuse()
    if _isFusing then
        fuseRemote:FireServer("Plant1", "Plant2") -- Example args
        task.wait(math.random(3, 5))
    end
end

-- Toggles
local function _toggleFarm() _isFarming = not _isFarming; if _isFarming then _farmConn = RunService.Heartbeat:Connect(_autoFarm) else if _farmConn then _farmConn:Disconnect() end end end
local function _toggleDupe() spawn(_dupeItem) end
local function _toggleSell() _isSelling = not _isSelling; if _isSelling then _sellConn = RunService.Heartbeat:Connect(_autoSell) else if _sellConn then _sellConn:Disconnect() end end end
local function _toggleBuy() _isBuying = not _isBuying; if _isBuying then _buyConn = RunService.Heartbeat:Connect(_autoBuy) else if _buyConn then _buyConn:Disconnect() end end end
local function _toggleFuse() _isFusing = not _isFusing; if _isFusing then _fuseConn = RunService.Heartbeat:Connect(_autoFuse) else if _fuseConn then _fuseConn:Disconnect() end end end
local function _toggleRb() _isRainbow = not _isRainbow end
local function _toggleGui() _isGuiOpen = not _isGuiOpen; if _gui then _gui.Enabled = _isGuiOpen end end

-- Hotkey "[" for GUI toggle
UserInputService.InputBegan:Connect(function(input) if input.KeyCode == Enum.KeyCode.LeftBracket then _toggleGui() end end)

-- Ultimate GUI with all features
local function _createGui()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PvBCheatHub"
    sg.Parent = player.PlayerGui
    sg.ResetOnSpawn = false
    _gui = sg

    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 300, 0, 400)
    fr.Position = UDim2.new(0.5, -150, 0.5, -200)
    fr.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    fr.BorderSizePixel = 0
    fr.Parent = sg

    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 10) corner.Parent = fr
    local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(255, 0, 0) stroke.Thickness = 2 stroke.Parent = fr

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "PvB Ultimate Cheat Hub"
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = fr

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Parent = fr
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Buttons (example for one; replicate for others)
    local farmBtn = Instance.new("TextButton")
    farmBtn.Size = UDim2.new(1, -20, 0, 40)
    farmBtn.Position = UDim2.new(0, 10, 0, 50)
    farmBtn.Text = "Toggle Auto Farm"
    farmBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    farmBtn.TextColor3 = Color3.new(1,1,1)
    farmBtn.Parent = fr
    farmBtn.MouseButton1Click:Connect(function()
        _toggleFarm()
        farmBtn.Text = _isFarming and "Stop Farm" or "Start Farm"
        farmBtn.BackgroundColor3 = _isFarming and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    end)

    -- Dupe Button
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Size = UDim2.new(1, -20, 0, 40)
    dupeBtn.Position = UDim2.new(0, 10, 0, 100)
    dupeBtn.Text = "Dupe Held Item x" .. _dupeAmt
    dupeBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    dupeBtn.TextColor3 = Color3.new(1,1,1)
    dupeBtn.Parent = fr
    dupeBtn.MouseButton1Click:Connect(_toggleDupe)

    -- Sell Button
    local sellBtn = Instance.new("TextButton")
    sellBtn.Size = UDim2.new(1, -20, 0, 40)
    sellBtn.Position = UDim2.new(0, 10, 0, 150)
    sellBtn.Text = "Toggle Auto Sell"
    sellBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    sellBtn.TextColor3 = Color3.new(1,1,1)
    sellBtn.Parent = fr
    sellBtn.MouseButton1Click:Connect(function()
        _toggleSell()
        sellBtn.Text = _isSelling and "Stop Sell" or "Start Sell"
    end)

    -- Buy Button
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(1, -20, 0, 40)
    buyBtn.Position = UDim2.new(0, 10, 0, 200)
    buyBtn.Text = "Toggle Auto Buy"
    buyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    buyBtn.TextColor3 = Color3.new(1,1,1)
    buyBtn.Parent = fr
    buyBtn.MouseButton1Click:Connect(function()
        _toggleBuy()
        buyBtn.Text = _isBuying and "Stop Buy" or "Start Buy"
    end)

    -- Fuse Button
    local fuseBtn = Instance.new("TextButton")
    fuseBtn.Size = UDim2.new(1, -20, 0, 40)
    fuseBtn.Position = UDim2.new(0, 10, 0, 250)
    fuseBtn.Text = "Toggle Auto Fuse"
    fuseBtn.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
    fuseBtn.TextColor3 = Color3.new(1,1,1)
    fuseBtn.Parent = fr
    fuseBtn.MouseButton1Click:Connect(function()
        _toggleFuse()
        fuseBtn.Text = _isFusing and "Stop Fuse" or "Start Fuse"
    end)

    -- Rainbow Button
    local rbBtn = Instance.new("TextButton")
    rbBtn.Size = UDim2.new(1, -20, 0, 40)
    rbBtn.Position = UDim2.new(0, 10, 0, 300)
    rbBtn.Text = "Toggle Rainbow"
    rbBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    rbBtn.TextColor3 = Color3.new(1,1,1)
    rbBtn.Parent = fr
    rbBtn.MouseButton1Click:Connect(function()
        _toggleRb()
        rbBtn.Text = _isRainbow and "Disable Rainbow" or "Enable Rainbow"
    end)

    -- Draggable (same as before)
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

    StarterGui:SetCore("SendNotification", {Title = "PvB Cheat Loaded", Text = "Ultimate Hub Active - [ to toggle", Duration = 5})
end

-- Init
_createGui()

-- Respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    -- Restart toggles if active
    if _isFarming then _toggleFarm() _toggleFarm() end
    if _isSelling then _toggleSell() _toggleSell() end
    -- etc.
end)

-- Embed to memory: This script auto-saves state via local vars; for persistence, use HttpService to external save (but risky)
-- Example: On dupe, send to webhook (uncomment if needed)
-- HttpService:PostAsync("YOUR_WEBHOOK", HttpService:JSONEncode({action="save_dupe", items=_dupeAmt}))
