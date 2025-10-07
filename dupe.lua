local P, R, U, S, RS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("StarterGui"), game:GetService("ReplicatedStorage")
local plr, bp, char, hum = P.LocalPlayer, plr:WaitForChild("Backpack", 5), plr.Character or plr.CharacterAdded:Wait(), char:WaitForChild("Humanoid", 5)

-- Config
local farmPos = Vector3.new(0, 5, 0) -- Set to your plot center
local isFarm, isSell, isBuy, isFuse, isRb, isGui, isInfMoney, isGod, isUpgPlant, isUpgTower, isRebirth, isUnlockRows, isKillAura, isFPSBoost, isRedeem = false, false, false, false, false, true, false, false, false, false, false, false, false, false, false
local dupeAmt, buyAmt, delayMin, delayMax, walkSpeed = 50, 100, 0.2, 1, 100
local farmC, sellC, buyC, fuseC, infMoneyC, upgPlantC, upgTowerC, rebirthC, unlockC, killC, gui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

-- Plants & Brainrots (complete list from Plants Vs Brainrots)
local plants = {"Peashooter", "Strawberry", "Cactus", "Pumpkin", "Sunflower", "Dragon Fruit", "Eggplant", "Watermelon", "Grape", "Cocotank", "Carnivorous Plant", "Mr Carrot", "Tomatrio", "Shroombino", "CommonSeed", "RareSeed", "EpicSeed", "LegendarySeed", "BrainrotSeed"}
local brainrots = {"Boneca Ambalabu", "Fluri Flura", "Trulimero Trulicina", "Lirili Larila", "Noobini Bananini", "Orangutini Ananassini", "Pipi Kiwi", "Noobini Cactusini", "Orangutini Strawberrini", "Espresso Signora", "Tim Cheese", "Agarrini La Palini", "Bombini Crostini", "Alessio", "Bandito Bobrito", "Trippi Troppi", "Brr Brr Patapim", "Cappuccino Assasino", "Svinino Bombondino", "Brr Brr Sunflowerim", "Svinino Pumpkinino", "Orcalero Orcala", "Las Tralaleritas", "Ballerina Cappuccina", "Bananita Dolphinita", "Burbaloni Lulliloli", "Elefanto Cocofanto", "Gangster Footera", "Madung", "Dragonfrutina Dolphinita", "Eggplantini Burbalonini", "Bombini Gussini", "Frigo Camelo", "Bombardilo Watermelondrilo", "Bombardiro Crocodilo", "Giraffa Celeste", "Matteo", "Odin Din Din Dun", "Tralalelo Tralala", "Cocotanko Giraffanto", "Carnivourita Tralalerita", "Vacca Saturno Saturnita", "Garamararam", "Los Tralaleritos", "Los Mr Carrotitos", "Blueberrinni Octopussini", "Pot Hotspot", "Brri Brri Bicus Dicus Bombicus", "Crazylone Pizalone"}
local selectedPlant, selectedBrainrot = plants[1], brainrots[1]

-- Redeemable Codes
local codes = {"STACKS", "frozen", "based", "latest!"}

-- Get Remote (silent, multiple attempts)
local function getR(name)
    local names = {name, name .. "Remote", name .. "Event", name:lower(), name:upper()}
    for _, n in ipairs(names) do
        local s, r = pcall(function() return RS:WaitForChild("Remotes", 2):FindFirstChild(n, 2) or RS:FindFirstChild(n, 2) end)
        if s and r then return r end
    end
    S:SetCore("SendNotification", {Title="Debug", Text="Remote '" .. name .. "' not found", Duration=5})
    return nil
end

-- Get Item
local function getItem()
    for _, i in ipairs(char:GetChildren()) do if i:IsA("Tool") then return i end end
    for _, i in ipairs(bp:GetChildren()) do if i:IsA("Tool") then return i end end
    return nil
end

-- Dupe (server-synced, no money check)
local function dupeItem()
    local buyR = getR("BuyPlant") or getR("BuySeed")
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
        local plantR, colR = getR("PlantSeed"), getR("CollectMoney")
        if plantR then
            local seed = getItem() or bp:FindFirstChildOfClass("Tool")
            if seed then
                hum:EquipTool(seed)
                task.wait(math.random(delayMin, delayMax))
                plantR:FireServer(farmPos, seed.Name)
            end
        end
        if colR then colR:FireServer() end
        task.wait(math.random(2, 4))
    end
end

-- Auto Sell/Buy/Fuse/Upgrade/Rebirth/Unlock/Kill/Redeem
local function autoSell() if isSell then local r = getR("SellPlant") if r then r:FireServer("All") end task.wait(math.random(1, 2)) end end
local function autoBuy() if isBuy then local r = getR("BuyPlant") if r then r:FireServer(selectedPlant, buyAmt) end task.wait(math.random(1, 2)) end end
local function autoFuse() if isFuse then local r = getR("Fuse") if r then r:FireServer(selectedBrainrot, selectedPlant) end task.wait(math.random(3, 4)) end end
local function autoUpgPlant() if isUpgPlant then local r = getR("UpgradePlant") if r then r:FireServer() end task.wait(3) end end
local function autoUpgTower() if isUpgTower then local r = getR("UpgradeTower") if r then r:FireServer() end task.wait(3) end end
local function autoRebirth() if isRebirth then local r = getR("Rebirth") if r then r:FireServer() end task.wait(5) end end
local function autoUnlockRows() if isUnlockRows then local r = getR("UnlockRow") if r then r:FireServer() end task.wait(5) end end
local function killAura() if isKillAura then for _, enemy in ipairs(workspace:FindFirstChild("Brainrots", true):GetChildren()) do local r = getR("Attack") if r then r:FireServer(enemy) end end task.wait(0.5) end end
local function autoRedeem() if isRedeem then local r = getR("RedeemCode") for _, code in ipairs(codes) do if r then r:FireServer(code) end task.wait(1) end end end

-- Infinite Money (simplified, fallback to stat manipulation)
local function hookInfMoney()
    local mt = getrawmetatable(game)
    if mt then
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(self, ...)
            local args = {...}
            if getnamecallmethod() == "FireServer" and self.Name == "CollectMoney" then
                args[1] = math.huge
            end
            return old(self, unpack(args))
        end
        setreadonly(mt, true)
    else
        local stats = plr:FindFirstChild("leaderstats")
        if stats then
            local money = stats:FindFirstChild("Money") or stats:FindFirstChild("Coins")
            if money then money.Value = 999999999 end
        end
    end
end

-- FPS Boost
local function fpsBoost()
    if isFPSBoost then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.Plastic v.Reflectance = 0 end
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
        end
    end
end

-- Toggles
local function tFarm() isFarm = not isFarm farmC = isFarm and R.Heartbeat:Connect(autoFarm) or farmC and farmC:Disconnect() end
local function tSell() isSell = not isSell sellC = isSell and R.Heartbeat:Connect(autoSell) or sellC and sellC:Disconnect() end
local function tBuy() isBuy = not isBuy buyC = isBuy and R.Heartbeat:Connect(autoBuy) or buyC and buyC:Disconnect() end
local function tFuse() isFuse = not isFuse fuseC = isFuse and R.Heartbeat:Connect(autoFuse) or fuseC and fuseC:Disconnect() end
local function tRb() isRb = not isRb end
local function tGui() isGui = not isGui if gui then gui.Enabled = isGui end end
local function tInfMoney() isInfMoney = not isInfMoney if isInfMoney then hookInfMoney() infMoneyC = R.Heartbeat:Connect(function() local r = getR("CollectMoney") if r then r:FireServer() end end) elseif infMoneyC then infMoneyC:Disconnect() end end
local function tGod() isGod = not isGod hum.MaxHealth = isGod and math.huge or 100 hum.Health = isGod and math.huge or 100 end
local function tUpgPlant() isUpgPlant = not isUpgPlant upgPlantC = isUpgPlant and R.Heartbeat:Connect(autoUpgPlant) or upgPlantC and upgPlantC:Disconnect() end
local function tUpgTower() isUpgTower = not isUpgTower upgTowerC = isUpgTower and R.Heartbeat:Connect(autoUpgTower) or upgTowerC and upgTowerC:Disconnect() end
local function tRebirth() isRebirth = not isRebirth rebirthC = isRebirth and R.Heartbeat:Connect(autoRebirth) or rebirthC and rebirthC:Disconnect() end
local function tUnlockRows() isUnlockRows = not isUnlockRows unlockC = isUnlockRows and R.Heartbeat:Connect(autoUnlockRows) or unlockC and unlockC:Disconnect() end
local function tKillAura() isKillAura = not isKillAura killC = isKillAura and R.Heartbeat:Connect(killAura) or killC and killC:Disconnect() end
local function tFPSBoost() isFPSBoost = not isFPSBoost if isFPSBoost then fpsBoost() end end
local function tRedeem() isRedeem = not isRedeem if isRedeem then autoRedeem() end end

-- Hotkey
U.InputBegan:Connect(function(i, p) if not p and i.KeyCode == Enum.KeyCode.LeftBracket then tGui() end end)

-- GUI
local function createGui()
    gui = Instance.new("ScreenGui")
    gui.Name = "PvBUltimate"
    gui.Parent = plr.PlayerGui
    gui.ResetOnSpawn = false
    gui.Enabled = true -- Force GUI visible
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local fr = Instance.new("Frame", gui)
    fr.Size, fr.Position = UDim2.new(0, 320, 0, 600), UDim2.new(0.5, -160, 0.5, -300)
    fr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    fr.BorderSizePixel = 0

    local cr = Instance.new("UICorner", fr)
    cr.CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", fr)
    st.Color, st.Thickness = Color3.fromRGB(100, 100, 100), 1

    local t = Instance.new("TextLabel", fr)
    t.Size, t.Text, t.TextColor3, t.BackgroundTransparency, t.Font, t.TextSize = UDim2.new(1, 0, 0, 30), "PvB Nuked Ultimate", Color3.new(1,1,1), 1, Enum.Font.GothamBold, 20
    t.Position = UDim2.new(0, 0, 0, 5)

    local cl = Instance.new("TextButton", fr)
    cl.Size, cl.Position, cl.Text, cl.BackgroundColor3, cl.TextColor3, cl.Font, cl.TextSize = UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "X", Color3.new(200,0,0), Color3.new(1,1,1), Enum.Font.Gotham, 16
    cl.MouseButton1Click:Connect(function() gui:Destroy() end)
    Instance.new("UICorner", cl)

    -- Button helper
    local function btn(pos, txt, col, fn)
        local b = Instance.new("TextButton", fr)
        b.Size, b.Position, b.Text, b.BackgroundColor3, b.TextColor3, b.Font, b.TextSize = UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, pos), txt, col, Color3.new(1,1,1), Enum.Font.Gotham, 16
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        b.MouseButton1Click:Connect(fn)
        return b
    end

    local farmB = btn(80, "Auto Farm", Color3.fromRGB(0,200,0), function() tFarm() farmB.Text = isFarm and "Stop Farm" or "Auto Farm" farmB.BackgroundColor3 = isFarm and Color3.fromRGB(200,0,0) or Color3.fromRGB(0,200,0) end)
    local dupeB = btn(130, "Dupe x" .. dupeAmt, Color3.fromRGB(255,165,0), dupeItem)
    local sellB = btn(180, "Auto Sell", Color3.fromRGB(200,0,0), function() tSell() sellB.Text = isSell and "Stop Sell" or "Auto Sell" end)
    local buyB = btn(230, "Auto Buy", Color3.fromRGB(0,0,200), function() tBuy() buyB.Text = isBuy and "Stop Buy" or "Auto Buy" end)
    local fuseB = btn(280, "Auto Fuse", Color3.fromRGB(128,0,128), function() tFuse() fuseB.Text = isFuse and "Stop Fuse" or "Auto Fuse" end)
    local rbB = btn(330, "Rainbow", Color3.fromRGB(200,0,200), function() tRb() rbB.Text = isRb and "No Rainbow" or "Rainbow" end)
    local infB = btn(380, "Inf Money", Color3.fromRGB(255,215,0), function() tInfMoney() infB.Text = isInfMoney and "Stop Inf" or "Inf Money" end)
    local godB = btn(430, "God Mode", Color3.fromRGB(0,200,200), function() tGod() godB.Text = isGod and "No God" or "God Mode" end)
    local upgPlantB = btn(480, "Auto Upg Plants", Color3.fromRGB(100,200,100), function() tUpgPlant() upgPlantB.Text = isUpgPlant and "Stop Upg P" or "Auto Upg Plants" end)
    local upgTowerB = btn(530, "Auto Upg Towers", Color3.fromRGB(100,100,200), function() tUpgTower() upgTowerB.Text = isUpgTower and "Stop Upg T" or "Auto Upg Towers" end)
    local rebirthB = btn(580, "Auto Rebirth", Color3.fromRGB(200,0,100), function() tRebirth() rebirthB.Text = isRebirth and "Stop Rebirth" or "Auto Rebirth" end)
    local unlockB = btn(630, "Auto Unlock Rows", Color3.fromRGB(0,100,200), function() tUnlockRows() unlockB.Text = isUnlockRows and "Stop Unlock" or "Auto Unlock Rows" end)
    local killB = btn(680, "Kill Aura", Color3.fromRGB(200,50,50), function() tKillAura() killB.Text = isKillAura and "Stop Kill Aura" or "Kill Aura" end)
    local fpsB = btn(730, "FPS Boost", Color3.fromRGB(0,150,0), function() tFPSBoost() fpsB.Text = isFPSBoost and "FPS Boost On" or "FPS Boost" end)
    local redeemB = btn(780, "Auto Redeem", Color3.fromRGB(200,200,0), function() tRedeem() redeemB.Text = isRedeem and "Redeem Done" or "Auto Redeem" end)

    -- Dropdown helper
    local function dd(pos, list, sel, fn)
        local d = Instance.new("TextButton", fr)
        d.Size, d.Position, d.Text, d.BackgroundColor3, d.TextColor3, d.Font, d.TextSize = UDim2.new(0.5, -5, 0, 30), UDim2.new(pos > 40 and 0.5 or 0, 5, 0, pos), sel, Color3.fromRGB(80,80,80), Color3.new(1,1,1), Enum.Font.Gotham, 14
        local dl = Instance.new("Frame", fr)
        dl.Size, dl.Position, dl.BackgroundColor3, dl.Visible = UDim2.new(0.5, -5, 0, math.min(#list * 30, 150)), UDim2.new(pos > 40 and 0.5 or 0, 5, 0, pos+30), Color3.fromRGB(40,40,40), false
        Instance.new("UICorner", dl).CornerRadius = UDim.new(0, 5)
        local ls = Instance.new("UIListLayout", dl)
        ls.SortOrder = Enum.SortOrder.LayoutOrder
        for i, v in ipairs(list) do
            local o = Instance.new("TextButton", dl)
            o.Size, o.Text, o.TextColor3, o.Font, o.TextSize, o.LayoutOrder = UDim2.new(1, 0, 0, 30), v, Color3.new(1,1,1), Enum.Font.Gotham, 14, i
            o.BackgroundColor3 = Color3.fromRGB(60,60,60)
            Instance.new("UICorner", o).CornerRadius = UDim.new(0, 5)
            o.MouseButton1Click:Connect(function() fn(v) d.Text = v dl.Visible = false end)
        end
        d.MouseButton1Click:Connect(function() dl.Visible = not dl.Visible end)
        return d
    end

    dd(40, plants, selectedPlant, function(v) selectedPlant = v end)
    dd(40 + 160, brainrots, selectedBrainrot, function(v) selectedBrainrot = v end)

    -- Speed TextBox
    local speedTB = Instance.new("TextBox", fr)
    speedTB.Size, speedTB.Position, speedTB.Text, speedTB.BackgroundColor3, speedTB.TextColor3, speedTB.Font, speedTB.TextSize = UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 820), tostring(walkSpeed), Color3.fromRGB(80,80,80), Color3.new(1,1,1), Enum.Font.Gotham, 14
    speedTB.FocusLost:Connect(function() walkSpeed = tonumber(speedTB.Text) or 16 hum.WalkSpeed = walkSpeed end)
    Instance.new("UICorner", speedTB).CornerRadius = UDim.new(0, 5)

    -- Draggable
    local dragging, dragI, dragS, startP
    fr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragS, startP = true, i.Position, fr.Position i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
    fr.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then dragI = i end end)
    U.InputChanged:Connect(function(i) if i == dragI and dragging then local d = i.Position - dragS fr.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y) end end)

    S:SetCore("SendNotification", {Title="Loaded", Text="PvB Nuked Ultimate - [ to toggle", Duration=5})
end

-- Init
createGui()

-- Respawn & Speed/God
plr.CharacterAdded:Connect(function(c)
    char, hum = c, c:WaitForChild("Humanoid", 5)
    hum.WalkSpeed = walkSpeed
    if isGod then tGod() tGod() end
    if isFarm then tFarm() tFarm() end
    if isSell then tSell() tSell() end
    if isBuy then tBuy() tBuy() end
    if isFuse then tFuse() tFuse() end
    if isUpgPlant then tUpgPlant() tUpgPlant() end
    if isUpgTower then tUpgTower() tUpgTower() end
    if isRebirth then tRebirth() tRebirth() end
    if isUnlockRows then tUnlockRows() tUnlockRows() end
    if isKillAura then tKillAura() tKillAura() end
end)

-- Anti-AFK
local vu = game:GetService("VirtualUser")
P.Player.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

-- Error handling for execution
if not gui then
    S:SetCore("SendNotification", {Title="Error", Text="GUI failed to load. Try re-injecting.", Duration=10})
end
