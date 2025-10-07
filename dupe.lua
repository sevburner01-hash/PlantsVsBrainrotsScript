local P, R, U, S, RS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("StarterGui"), game:GetService("ReplicatedStorage")
local plr, bp, char, hum = P.LocalPlayer, plr:WaitForChild("Backpack"), plr.Character or plr.CharacterAdded:Wait(), char:WaitForChild("Humanoid")

-- Config
local farmPos = Vector3.new(0, 5, 0) -- Your plot center
local isFarm, isSell, isBuy, isFuse, isRb, isGui, isInfMoney, isGod, isUpgPlant, isUpgTower = false, false, false, false, false, true, false, false, false, false
local dupeAmt, buyAmt, delayMin, delayMax, walkSpeed = 50, 100, 0.2, 1, 100
local farmC, sellC, buyC, fuseC, infMoneyC, upgPlantC, upgTowerC, gui = nil, nil, nil, nil, nil, nil, nil, nil

-- Plants & Brainrots (full list based on game recipes)
local plants = {"Peashooter", "Strawberry", "Cactus", "Pumpkin", "Sunflower", "Dragon Fruit", "Eggplant", "Watermelon", "Cocotank", "Carnivorous Plant", "Mr Carrot", "CommonSeed", "RareSeed", "EpicSeed", "LegendarySeed", "BrainrotSeed"}
local brainrots = {"Orangutini Ananassini", "Noobini Bananini", "Svinino Bombondino", "Brr Brr Patapim", "Bananita Dolphinita", "Burbaloni Lulliloli", "Bombardilo Crocodilo", "Girafa Celeste", "Tralalero Tralala", "Los Tralaleritos"}
local selectedPlant, selectedBrainrot = plants[1], brainrots[1]

-- Get Remote (silent fail)
local function getR(name)
    local s, r = pcall(function() return RS:WaitForChild("Remotes"):WaitForChild(name, 3) end)
    return s and r or nil
end

-- Get Item
local function getItem()
    for _, i in ipairs(char:GetChildren()) do if i:IsA("Tool") then return i end end
    for _, i in ipairs(bp:GetChildren()) do if i:IsA("Tool") then return i end end
    return nil
end

-- Dupe (server-synced, bypass money if possible)
local function dupeItem()
    local buyR = getR("BuyPlantRemote") or getR("BuySeed")
    if not buyR then return end
    local item = getItem() or {Name = selectedPlant}
    for i = 1, dupeAmt do
        buyR:FireServer(item.Name, 1)
        if isRb then
            task.wait(0.1)
            local newI = bp:FindFirstChild(item.Name) or bp:FindFirstChild(item.Name .. " (Clone)")
            if newI then
                local rb = Instance.new("LocalScript", newI)
                rb.Name = "Rb"
                rb.Source = "local h=script.Parent:FindFirstChild('Handle') if h then while true do h.Color=Color3.fromHSV(tick()%1,1,1) wait(0.1) end end"
            end
        end
        task.wait(math.random(delayMin * 10, delayMax * 10)/10)
    end
end

-- Auto Farm
local function autoFarm()
    if isFarm and char and hum.Health > 0 then
        hum:MoveTo(farmPos)
        task.wait(math.random(1, 2))
        local placeR, colR = getR("PlacePlantRemote"), getR("CollectCoinsRemote")
        if placeR then
            local seed = getItem() or bp:FindFirstChildOfClass("Tool")
            if seed then
                hum:EquipTool(seed)
                task.wait(math.random(delayMin, delayMax))
                placeR:FireServer(farmPos, seed.Name)
            end
        end
        if colR then colR:FireServer() end
        task.wait(math.random(2, 4))
    end
end

-- Auto Sell/Buy/Fuse/Upgrade
local function autoSell() if isSell then local r = getR("SellPlantRemote") if r then r:FireServer("All") end task.wait(math.random(1, 2)) end end
local function autoBuy() if isBuy then local r = getR("BuyPlantRemote") if r then r:FireServer(selectedPlant, buyAmt) end task.wait(math.random(1, 2)) end end
local function autoFuse() if isFuse then local r = getR("FuseRemote") or getR("FuseBrainrot") if r then r:FireServer(selectedBrainrot, selectedPlant) end task.wait(math.random(3, 4)) end end
local function autoUpgPlant() if isUpgPlant then local r = getR("UpgradePlantRemote") if r then r:FireServer() end task.wait(3) end end
local function autoUpgTower() if isUpgTower then local r = getR("UpgradeTowerRemote") if r then r:FireServer() end task.wait(3) end end

-- Infinite Money (hook FireServer)
local function hookInfMoney()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        if getnamecallmethod() == "FireServer" and self.Name == "CollectCoinsRemote" then
            args[1] = math.huge
        end
        return old(self, unpack(args))
    end)
    setreadonly(mt, true)
end

-- Toggles
local function tFarm() isFarm = not isFarm farmC = isFarm and R.Heartbeat:Connect(autoFarm) or farmC and farmC:Disconnect() end
local function tSell() isSell = not isSell sellC = isSell and R.Heartbeat:Connect(autoSell) or sellC and sellC:Disconnect() end
local function tBuy() isBuy = not isBuy buyC = isBuy and R.Heartbeat:Connect(autoBuy) or buyC and buyC:Disconnect() end
local function tFuse() isFuse = not isFuse fuseC = isFuse and R.Heartbeat:Connect(autoFuse) or fuseC and fuseC:Disconnect() end
local function tRb() isRb = not isRb end
local function tGui() isGui = not isGui if gui then gui.Enabled = isGui end end
local function tInfMoney() isInfMoney = not isInfMoney if isInfMoney then hookInfMoney() infMoneyC = R.Heartbeat:Connect(function() local r = getR("CollectCoinsRemote") if r then r:FireServer() end end) elseif infMoneyC then infMoneyC:Disconnect() end end
local function tGod() isGod = not isGod hum.MaxHealth = isGod and math.huge or 100 hum.Health = isGod and math.huge or 100 end
local function tUpgPlant() isUpgPlant = not isUpgPlant upgPlantC = isUpgPlant and R.Heartbeat:Connect(autoUpgPlant) or upgPlantC and upgPlantC:Disconnect() end
local function tUpgTower() isUpgTower = not isUpgTower upgTowerC = isUpgTower and R.Heartbeat:Connect(autoUpgTower) or upgTowerC and upgTowerC:Disconnect() end

-- Hotkey [
U.InputBegan:Connect(function(i, p) if not p and i.KeyCode == Enum.KeyCode.LeftBracket then tGui() end end)

-- GUI
local function createGui()
    gui = Instance.new("ScreenGui", plr.PlayerGui)
    gui.Name = "PvB"
    gui.ResetOnSpawn = false

    local fr = Instance.new("Frame", gui)
    fr.Size, fr.Position = UDim2.new(0, 300, 0, 450), UDim2.new(0.5, -150, 0.5, -225)
    fr.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    Instance.new("UICorner", fr)
    Instance.new("UIStroke", fr)

    local t = Instance.new("TextLabel", fr)
    t.Size, t.Text, t.TextColor3, t.BackgroundTransparency = UDim2.new(1, 0, 0, 30), "PvB Ultimate Cheat", Color3.new(1,1,1), 1

    local cl = Instance.new("TextButton", fr)
    cl.Size, cl.Position, cl.Text, cl.BackgroundColor3 = UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "X", Color3.new(1,0,0)
    cl.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Button helper
    local function btn(pos, txt, col, fn)
        local b = Instance.new("TextButton", fr)
        b.Size, b.Position, b.Text, b.BackgroundColor3, b.TextColor3 = UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, pos), txt, col, Color3.new(1,1,1)
        b.MouseButton1Click:Connect(fn)
        return b
    end

    local farmB = btn(80, "Farm", Color3.fromRGB(0,255,0), function() tFarm() farmB.Text = isFarm and "Stop Farm" or "Farm" farmB.BackgroundColor3 = isFarm and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0) end)
    local dupeB = btn(130, "Dupe x" .. dupeAmt, Color3.fromRGB(255,165,0), dupeItem)
    local sellB = btn(180, "Sell", Color3.fromRGB(255,0,0), function() tSell() sellB.Text = isSell and "Stop Sell" or "Sell" end)
    local buyB = btn(230, "Buy", Color3.fromRGB(0,0,255), function() tBuy() buyB.Text = isBuy and "Stop Buy" or "Buy" end)
    local fuseB = btn(280, "Fuse", Color3.fromRGB(128,0,128), function() tFuse() fuseB.Text = isFuse and "Stop Fuse" or "Fuse" end)
    local rbB = btn(330, "Rainbow", Color3.fromRGB(255,0,255), function() tRb() rbB.Text = isRb and "No Rainbow" or "Rainbow" end)
    local infB = btn(380, "Inf Money", Color3.fromRGB(255,215,0), function() tInfMoney() infB.Text = isInfMoney and "Stop Inf" or "Inf Money" end)
    local godB = btn(430, "God Mode", Color3.fromRGB(0,255,255), function() tGod() godB.Text = isGod and "No God" or "God Mode" end)
    local upgPlantB = btn(480, "Upg Plants", Color3.fromRGB(100,255,100), function() tUpgPlant() upgPlantB.Text = isUpgPlant and "Stop Upg P" or "Upg Plants" end)
    local upgTowerB = btn(530, "Upg Towers", Color3.fromRGB(100,100,255), function() tUpgTower() upgTowerB.Text = isUpgTower and "Stop Upg T" or "Upg Towers" end)

    -- Dropdown helper
    local function dd(pos, list, sel, fn)
        local d = Instance.new("TextButton", fr)
        d.Size, d.Position, d.Text, d.BackgroundColor3 = UDim2.new(0.5, -5, 0, 30), UDim2.new(pos > 40 and 0.5 or 0, 5, 0, pos), sel, Color3.fromRGB(100,100,100)
        local dl = Instance.new("Frame", fr)
        dl.Size, dl.Position, dl.BackgroundColor3, dl.Visible = UDim2.new(0.5, -5, 0, math.min(#list * 30, 150)), UDim2.new(pos > 40 and 0.5 or 0, 5, 0, pos+30), Color3.fromRGB(50,50,50), false
        Instance.new("UICorner", dl)
        local ls = Instance.new("UIListLayout", dl)
        ls.SortOrder = Enum.SortOrder.LayoutOrder
        for i, v in ipairs(list) do
            local o = Instance.new("TextButton", dl)
            o.Size, o.Text, o.TextColor3, o.LayoutOrder = UDim2.new(1, 0, 0, 30), v, Color3.new(1,1,1), i
            o.MouseButton1Click:Connect(function() fn(v) d.Text = v dl.Visible = false end)
        end
        d.MouseButton1Click:Connect(function() dl.Visible = not dl.Visible end)
        return d
    end

    dd(40, plants, selectedPlant, function(v) selectedPlant = v end)
    dd(40 + 150, brainrots, selectedBrainrot, function(v) selectedBrainrot = v end)

    -- Speed TextBox
    local speedTB = Instance.new("TextBox", fr)
    speedTB.Size, speedTB.Position, speedTB.Text, speedTB.BackgroundColor3 = UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 570), tostring(walkSpeed), Color3.fromRGB(80,80,80)
    speedTB.FocusLost:Connect(function() walkSpeed = tonumber(speedTB.Text) or 16 hum.WalkSpeed = walkSpeed end)

    -- Draggable
    local dragging, dragI, dragS, startP
    fr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragS, startP = true, i.Position, fr.Position i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    fr.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then dragI = i end end)
    U.InputChanged:Connect(function(i) if i == dragI and dragging then local d = i.Position - dragS fr.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y) end end)

    S:SetCore("SendNotification", {Title="Loaded", Text="PvB Ultimate Cheat - [ to toggle", Duration=3})
end

-- Init
createGui()

-- Respawn & Speed/God
plr.CharacterAdded:Connect(function(c)
    char, hum = c, c:WaitForChild("Humanoid")
    hum.WalkSpeed = walkSpeed
    if isGod then tGod() tGod() end
    if isFarm then tFarm() tFarm() end
    if isSell then tSell() tSell() end
    if isBuy then tBuy() tBuy() end
    if isFuse then tFuse() tFuse() end
    if isUpgPlant then tUpgPlant() tUpgPlant() end
    if isUpgTower then tUpgTower() tUpgTower() end
end)
