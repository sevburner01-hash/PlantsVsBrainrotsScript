-- Ensure entire script is wrapped in pcall
local success, errorMsg = pcall(function()
    -- Services
    local P, R, U, S, RS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("StarterGui"), game:GetService("ReplicatedStorage")
    local plr = P.LocalPlayer
    local bp = plr:WaitForChild("Backpack", 10) -- Increased timeout
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char and char:WaitForChild("Humanoid", 10) or nil

    -- Config
    local farmPos = Vector3.new(0, 5, 0) -- Set to your plot center
    local isFarm, isSell, isBuy, isFuse, isRb, isGui, isInfMoney, isGod, isUpgPlant, isUpgTower, isRebirth, isUnlockRows, isKillAura, isFPSBoost, isRedeem = false, false, false, false, false, true, false, false, false, false, false, false, false, false, false
    local dupeAmt, buyAmt, delayMin, delayMax, walkSpeed = 50, 100, 0.5, 1.5, 100 -- Adjusted delays to avoid anti-cheat
    local farmC, sellC, buyC, fuseC, infMoneyC, upgPlantC, upgTowerC, rebirthC, unlockC, killC, gui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    local connections = {} -- Store connections for cleanup

    -- Plants & Brainrots (verify these match your game)
    local plants = {"Peashooter", "Strawberry", "Cactus", "Pumpkin", "Sunflower", "Dragon Fruit", "Eggplant", "Watermelon", "Grape", "Cocotank", "Carnivorous Plant", "Mr Carrot", "Tomatrio", "Shroombino", "CommonSeed", "RareSeed", "EpicSeed", "LegendarySeed", "BrainrotSeed"}
    local brainrots = {"Boneca Ambalabu", "Fluri Flura", "Trulimero Trulicina", "Lirili Larila", "Noobini Bananini", "Orangutini Ananassini", "Pipi Kiwi", "Noobini Cactusini", "Orangutini Strawberrini", "Espresso Signora", "Tim Cheese", "Agarrini La Palini", "Bombini Crostini", "Alessio", "Bandito Bobrito", "Trippi Troppi", "Brr Brr Patapim", "Cappuccino Assasino", "Svinino Bombondino", "Brr Brr Sunflowerim", "Svinino Pumpkinino", "Orcalero Orcala", "Las Tralaleritas", "Ballerina Cappuccina", "Bananita Dolphinita", "Burbaloni Lulliloli", "Elefanto Cocofanto", "Gangster Footera", "Madung", "Dragonfrutina Dolphinita", "Eggplantini Burbalonini", "Bombini Gussini", "Frigo Camelo", "Bombardilo Watermelondrilo", "Bombardiro Crocodilo", "Giraffa Celeste", "Matteo", "Odin Din Din Dun", "Tralalelo Tralala", "Cocotanko Giraffanto", "Carnivourita Tralalerita", "Vacca Saturno Saturnita", "Garamararam", "Los Tralaleritos", "Los Mr Carrotitos", "Blueberrinni Octopussini", "Pot Hotspot", "Brri Brri Bicus Dicus Bombicus", "Crazylone Pizalone"}
    local selectedPlant, selectedBrainrot = plants[1], brainrots[1]

    -- Redeemable Codes
    local codes = {"STACKS", "frozen", "based", "latest!"}

    -- Debug Notification
    local function notify(title, text, dur)
        pcall(function()
            S:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 5})
        end)
    end

    -- Get Remote (more robust search)
    local function getR(name)
        local names = {name, name .. "Remote", name .. "Event", name:lower(), name:upper(), "Remote" .. name, "Event" .. name}
        for _, n in ipairs(names) do
            local success, remote = pcall(function()
                for _, obj in ipairs(RS:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        if obj.Name:lower() == n:lower() then
                            return obj
                        end
                    end
                end
                return nil
            end)
            if success and remote then
                return remote
            end
        end
        notify("Debug", "Remote '" .. name .. "' not found. Use RemoteSpy.", 5)
        return nil
    end

    -- Get Item
    local function getItem()
        local success, item = pcall(function()
            for _, i in ipairs(char:GetChildren()) do
                if i:IsA("Tool") then return i end
            end
            for _, i in ipairs(bp:GetChildren()) do
                if i:IsA("Tool") then return i end
            end
            return nil
        end)
        if not success or not item then
            notify("Debug", "No tool found in character or backpack", 5)
        end
        return success and item or nil
    end

    -- Dupe (safer, with validation)
    local function dupeItem()
        local buyR = getR("BuyPlant") or getR("BuySeed") or getR("PurchaseItem")
        if not buyR then
            notify("Error", "Buy remote not found", 5)
            return
        end
        local item = getItem() or {Name = selectedPlant}
        if not item then
            notify("Error", "No item to dupe", 5)
            return
        end
        -- Limit dupeAmt to prevent crashes
        local safeDupeAmt = math.min(dupeAmt, 100)
        for i = 1, safeDupeAmt do
            local success, err = pcall(function()
                buyR:FireServer(item.Name, 1)
            end)
            if not success then
                notify("Debug", "Dupe failed: " .. tostring(err), 5)
                break
            end
            if isRb then
                task.spawn(function()
                    local newI = bp:WaitForChild(item.Name, 2) or bp:WaitForChild(item.Name .. " (Clone)", 2)
                    if newI then
                        local success, err = pcall(function()
                            local handle = newI:FindFirstChild("Handle")
                            if handle then
                                while isRb and newI.Parent do
                                    handle.Color = Color3.fromHSV(tick() % 1, 1, 1)
                                    task.wait(0.1)
                                end
                            end
                        end)
                        if not success then
                            notify("Debug", "Rainbow effect failed: " .. tostring(err), 5)
                        end
                    end
                end)
            end
            task.wait(math.random(delayMin * 100, delayMax * 100) / 100)
        end
        notify("Success", "Duplicated " .. item.Name .. " x" .. safeDupeAmt, 5)
    end

    -- Auto Farm (safer movement and checks)
    local function autoFarm()
        if isFarm and char and hum and hum.Health > 0 then
            local success, err = pcall(function()
                hum.WalkSpeed = walkSpeed -- Ensure speed is applied
                hum:MoveTo(farmPos)
            end)
            if not success then
                notify("Debug", "MoveTo failed: " .. tostring(err), 5)
                return
            end
            task.wait(math.random(1, 2))
            local plantR = getR("PlantSeed") or getR("Plant")
            local colR = getR("CollectMoney") or getR("Collect")
            if plantR then
                local seed = getItem() or bp:FindFirstChildOfClass("Tool")
                if seed then
                    pcall(function()
                        hum:EquipTool(seed)
                        task.wait(math.random(delayMin, delayMax))
                        plantR:FireServer(farmPos, seed.Name)
                    end)
                end
            end
            if colR then
                pcall(function() colR:FireServer() end)
            end
            task.wait(math.random(2, 4))
        end
    end

    -- Auto Functions (with connection cleanup)
    local function autoSell()
        if isSell then
            local r = getR("SellPlant")
            if r then
                pcall(function() r:FireServer("All") end)
            end
            task.wait(math.random(1, 2))
        end
    end
    local function autoBuy()
        if isBuy then
            local r = getR("BuyPlant") or getR("BuySeed")
            if r then
                pcall(function() r:FireServer(selectedPlant, buyAmt) end)
            end
            task.wait(math.random(1, 2))
        end
    end
    local function autoFuse()
        if isFuse then
            local r = getR("Fuse")
            if r then
                pcall(function() r:FireServer(selectedBrainrot, selectedPlant) end)
            end
            task.wait(math.random(3, 4))
        end
    end
    local function autoUpgPlant()
        if isUpgPlant then
            local r = getR("UpgradePlant")
            if r then
                pcall(function() r:FireServer() end)
            end
            task.wait(3)
        end
    end
    local function autoUpgTower()
        if isUpgTower then
            local r = getR("UpgradeTower")
            if r then
                pcall(function() r:FireServer() end)
            end
            task.wait(3)
        end
    end
    local function autoRebirth()
        if isRebirth then
            local r = getR("Rebirth")
            if r then
                pcall(function() r:FireServer() end)
            end
            task.wait(5)
        end
    end
    local function autoUnlockRows()
        if isUnlockRows then
            local r = getR("UnlockRow") or getR("UnlockRows")
            if r then
                pcall(function() r:FireServer() end)
            end
            task.wait(5)
        end
    end
    local function killAura()
        if isKillAura then
            local success, enemies = pcall(function()
                return workspace:FindFirstChild("Brainrots", true):GetChildren()
            end)
            if success and enemies then
                local r = getR("Attack")
                if r then
                    for _, enemy in ipairs(enemies) do
                        pcall(function() r:FireServer(enemy) end)
                    end
                end
            end
            task.wait(0.5)
        end
    end
    local function autoRedeem()
        if isRedeem then
            local r = getR("RedeemCode") or getR("Code")
            for _, code in ipairs(codes) do
                if r then
                    pcall(function() r:FireServer(code) end)
                end
                task.wait(1)
            end
        end
    end

    -- Infinite Money (safer approach)
    local function hookInfMoney()
        local success, stats = pcall(function()
            return plr:FindFirstChild("leaderstats")
        end)
        if success and stats then
            local money = stats:FindFirstChild("Money") or stats:FindFirstChild("Coins") or stats:FindFirstChild("Currency")
            if money then
                pcall(function()
                    money:GetPropertyChangedSignal("Value"):Connect(function()
                        money.Value = 999999999
                    end)
                end)
            else
                notify("Debug", "Money stat not found", 5)
            end
        end
        local colR = getR("CollectMoney") or getR("Collect")
        if colR then
            pcall(function() colR:FireServer(1000000) end) -- Avoid math.huge
        end
    end

    -- FPS Boost (optimized)
    local function fpsBoost()
        if isFPSBoost then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "Terrain" then
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                    end
                end
            end)
        end
    end

    -- Toggle Functions (with connection cleanup)
    local function tFarm()
        isFarm = not isFarm
        if farmC then farmC:Disconnect() farmC = nil end
        if isFarm then
            farmC = R.Heartbeat:Connect(autoFarm)
            connections[#connections + 1] = farmC
        end
    end
    local function tSell()
        isSell = not isSell
        if sellC then sellC:Disconnect() sellC = nil end
        if isSell then
            sellC = R.Heartbeat:Connect(autoSell)
            connections[#connections + 1] = sellC
        end
    end
    local function tBuy()
        isBuy = not isBuy
        if buyC then buyC:Disconnect() buyC = nil end
        if isBuy then
            buyC = R.Heartbeat:Connect(autoBuy)
            connections[#connections + 1] = buyC
        end
    end
    local function tFuse()
        isFuse = not isFuse
        if fuseC then fuseC:Disconnect() fuseC = nil end
        if isFuse then
            fuseC = R.Heartbeat:Connect(autoFuse)
            connections[#connections + 1] = fuseC
        end
    end
    local function tRb()
        isRb = not isRb
    end
    local function tGui()
        isGui = not isGui
        if gui then
            pcall(function() gui.Enabled = isGui end)
        end
    end
    local function tInfMoney()
        isInfMoney = not isInfMoney
        if infMoneyC then infMoneyC:Disconnect() infMoneyC = nil end
        if isInfMoney then
            hookInfMoney()
            infMoneyC = R.Heartbeat:Connect(hookInfMoney)
            connections[#connections + 1] = infMoneyC
        end
    end
    local function tGod()
        isGod = not isGod
        if hum then
            pcall(function()
                hum.MaxHealth = isGod and math.huge or 100
                hum.Health = isGod and math.huge or 100
            end)
        end
    end
    local function tUpgPlant()
        isUpgPlant = not isUpgPlant
        if upgPlantC then upgPlantC:Disconnect() upgPlantC = nil end
        if isUpgPlant then
            upgPlantC = R.Heartbeat:Connect(autoUpgPlant)
            connections[#connections + 1] = upgPlantC
        end
    end
    local function tUpgTower()
        isUpgTower = not isUpgTower
        if upgTowerC then upgTowerC:Disconnect() upgTowerC = nil end
        if isUpgTower then
            upgTowerC = R.Heartbeat:Connect(autoUpgTower)
            connections[#connections + 1] = upgTowerC
        end
    end
    local function tRebirth()
        isRebirth = not isRebirth
        if rebirthC then rebirthC:Disconnect() rebirthC = nil end
        if isRebirth then
            rebirthC = R.Heartbeat:Connect(autoRebirth)
            connections[#connections + 1] = rebirthC
        end
    end
    local function tUnlockRows()
        isUnlockRows = not isUnlockRows
        if unlockC then unlockC:Disconnect() unlockC = nil end
        if isUnlockRows then
            unlockC = R.Heartbeat:Connect(autoUnlockRows)
            connections[#connections + 1] = unlockC
        end
    end
    local function tKillAura()
        isKillAura = not isKillAura
        if killC then killC:Disconnect() killC = nil end
        if isKillAura then
            killC = R.Heartbeat:Connect(killAura)
            connections[#connections + 1] = killC
        end
    end
    local function tFPSBoost()
        isFPSBoost = not isFPSBoost
        if isFPSBoost then fpsBoost() end
    end
    local function tRedeem()
        isRedeem = not isRedeem
        if isRedeem then autoRedeem() end
    end

    -- Hotkey
    local inputConn
    inputConn = U.InputBegan:Connect(function(i, p)
        if not p and i.KeyCode == Enum.KeyCode.LeftBracket then
            tGui()
        end
    end)
    connections[#connections + 1] = inputConn

    -- GUI (optimized with cleanup)
    local function createGui()
        local success, err = pcall(function()
            gui = Instance.new("ScreenGui")
            gui.Name = "PvBUltimate"
            gui.Parent = plr.PlayerGui or game:GetService("CoreGui")
            gui.ResetOnSpawn = false
            gui.Enabled = isGui
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            local fr = Instance.new("Frame", gui)
            fr.Size = UDim2.new(0, 320, 0, 600)
            fr.Position = UDim2.new(0.5, -160, 0.5, -300)
            fr.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            fr.BorderSizePixel = 0

            local cr = Instance.new("UICorner", fr)
            cr.CornerRadius = UDim.new(0, 10)
            local st = Instance.new("UIStroke", fr)
            st.Color = Color3.fromRGB(100, 100, 100)
            st.Thickness = 1

            local t = Instance.new("TextLabel", fr)
            t.Size = UDim2.new(1, 0, 0, 30)
            t.Position = UDim2.new(0, 0, 0, 5)
            t.Text = "PvB Nuked Ultimate"
            t.TextColor3 = Color3.new(1, 1, 1)
            t.BackgroundTransparency = 1
            t.Font = Enum.Font.GothamBold
            t.TextSize = 20

            local cl = Instance.new("TextButton", fr)
            cl.Size = UDim2.new(0, 30, 0, 30)
            cl.Position = UDim2.new(1, -35, 0, 5)
            cl.Text = "X"
            cl.BackgroundColor3 = Color3.new(200, 0, 0)
            cl.TextColor3 = Color3.new(1, 1, 1)
            cl.Font = Enum.Font.Gotham
            cl.TextSize = 16
            cl.MouseButton1Click:Connect(function()
                pcall(function()
                    for _, conn in ipairs(connections) do
                        if conn then conn:Disconnect() end
                    end
                    connections = {}
                    gui:Destroy()
                    gui = nil
                end)
            end)
            Instance.new("UICorner", cl)

            -- Button helper
            local function btn(pos, txt, col, fn)
                local b = Instance.new("TextButton", fr)
                b.Size = UDim2.new(1, -10, 0, 40)
                b.Position = UDim2.new(0, 5, 0, pos)
                b.Text = txt
                b.BackgroundColor3 = col
                b.TextColor3 = Color3.new(1, 1, 1)
                b.Font = Enum.Font.Gotham
                b.TextSize = 16
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
                b.MouseButton1Click:Connect(fn)
                return b
            end

            local farmB = btn(80, "Auto Farm", Color3.fromRGB(0, 200, 0), function()
                tFarm()
                farmB.Text = isFarm and "Stop Farm" or "Auto Farm"
                farmB.BackgroundColor3 = isFarm and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 200, 0)
            end)
            local dupeB = btn(130, "Dupe x" .. dupeAmt, Color3.fromRGB(255, 165, 0), dupeItem)
            local sellB = btn(180, "Auto Sell", Color3.fromRGB(200, 0, 0), function()
                tSell()
                sellB.Text = isSell and "Stop Sell" or "Auto Sell"
            end)
            local buyB = btn(230, "Auto Buy", Color3.fromRGB(0, 0, 200), function()
                tBuy()
                buyB.Text = isBuy and "Stop Buy" or "Auto Buy"
            end)
            local fuseB = btn(280, "Auto Fuse", Color3.fromRGB(128, 0, 128), function()
                tFuse()
                fuseB.Text = isFuse and "Stop Fuse" or "Auto Fuse"
            end)
            local rbB = btn(330, "Rainbow", Color3.fromRGB(200, 0, 200), function()
                tRb()
                rbB.Text = isRb and "No Rainbow" or "Rainbow"
            end)
            local infB = btn(380, "Inf Money", Color3.fromRGB(255, 215, 0), function()
                tInfMoney()
                infB.Text = isInfMoney and "Stop Inf" or "Inf Money"
            end)
            local godB = btn(430, "God Mode", Color3.fromRGB(0, 200, 200), function()
                tGod()
                godB.Text = isGod and "No God" or "God Mode"
            end)
            local upgPlantB = btn(480, "Auto Upg Plants", Color3.fromRGB(100, 200, 100), function()
                tUpgPlant()
                upgPlantB.Text = isUpgPlant and "Stop Upg P" or "Auto Upg Plants"
            end)
            local upgTowerB = btn(530, "Auto Upg Towers", Color3.fromRGB(100, 100, 200), function()
                tUpgTower()
                upgTowerB.Text = isUpgTower and "Stop Upg T" or "Auto Upg Towers"
            end)
            local rebirthB = btn(580, "Auto Rebirth", Color3.fromRGB(200, 0, 100), function()
                tRebirth()
                rebirthB.Text = isRebirth and "Stop Rebirth" or "Auto Rebirth"
            end)
            local unlockB = btn(630, "Auto Unlock Rows", Color3.fromRGB(0, 100, 200), function()
                tUnlockRows()
                unlockB.Text = isUnlockRows and "Stop Unlock" or "Auto Unlock Rows"
            end)
            local killB = btn(680, "Kill Aura", Color3.fromRGB(200, 50, 50), function()
                tKillAura()
                killB.Text = isKillAura and "Stop Kill Aura" or "Kill Aura"
            end)
            local fpsB = btn(730, "FPS Boost", Color3.fromRGB(0, 150, 0), function()
                tFPSBoost()
                fpsB.Text = isFPSBoost and "FPS Boost On" or "FPS Boost"
            end)
            local redeemB = btn(780, "Auto Redeem", Color3.fromRGB(200, 200, 0), function()
                tRedeem()
                redeemB.Text = isRedeem and "Redeem Done" or "Auto Redeem"
            end)

            -- Dropdown helper (optimized for large lists)
            local function dd(pos, list, sel, fn)
                local d = Instance.new("TextButton", fr)
                d.Size = UDim2.new(0.5, -5, 0, 30)
                d.Position = UDim2.new(pos > 40 and 0.5 or 0, 5, 0, pos)
                d.Text = sel
                d.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                d.TextColor3 = Color3.new(1, 1, 1)
                d.Font = Enum.Font.Gotham
                d.TextSize = 14
                local dl = Instance.new("Frame", fr)
                dl.Size = UDim2.new(0.5, -5, 0, math.min(#list * 30, 150))
                dl.Position = UDim2.new(pos > 40 and 0.5 or 0, 5, 0, pos + 30)
                dl.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                dl.Visible = false
                Instance.new("UICorner", dl).CornerRadius = UDim.new(0, 5)
                local ls = Instance.new("UIListLayout", dl)
                ls.SortOrder = Enum.SortOrder.LayoutOrder
                local scroll = Instance.new("UIScrollingFrame", dl)
                scroll.Size = UDim2.new(1, 0, 1, 0)
                scroll.CanvasSize = UDim2.new(0, 0, 0, #list * 30)
                scroll.ScrollingDirection = Enum.ScrollingDirection.Y
                scroll.ScrollBarThickness = 5
                ls.Parent = scroll
                for i, v in ipairs(list) do
                    local o = Instance.new("TextButton", scroll)
                    o.Size = UDim2.new(1, 0, 0, 30)
                    o.Text = v
                    o.TextColor3 = Color3.new(1, 1, 1)
                    o.Font = Enum.Font.Gotham
                    o.TextSize = 14
                    o.LayoutOrder = i
                    o.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    Instance.new("UICorner", o).CornerRadius = UDim.new(0, 5)
                    o.MouseButton1Click:Connect(function()
                        fn(v)
                        d.Text = v
                        dl.Visible = false
                    end)
                end
                d.MouseButton1Click:Connect(function()
                    dl.Visible = not dl.Visible
                end)
                return d
            end

            dd(40, plants, selectedPlant, function(v) selectedPlant = v end)
            dd(40 + 160, brainrots, selectedBrainrot, function(v) selectedBrainrot = v end)

            -- Speed TextBox
            local speedTB = Instance.new("TextBox", fr)
            speedTB.Size = UDim2.new(1, -10, 0, 30)
            speedTB.Position = UDim2.new(0, 5, 0, 820)
            speedTB.Text = tostring(walkSpeed)
            speedTB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            speedTB.TextColor3 = Color3.new(1, 1, 1)
            speedTB.Font = Enum.Font.Gotham
            speedTB.TextSize = 14
            speedTB.FocusLost:Connect(function()
                walkSpeed = tonumber(speedTB.Text) or 16
                if hum then
                    pcall(function() hum.WalkSpeed = walkSpeed end)
                end
            end)
            Instance.new("UICorner", speedTB).CornerRadius = UDim.new(0, 5)

            -- Draggable
            local dragging, dragI, dragS, startP
            fr.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging, dragS, startP = true, i.Position, fr.Position
                    i.Changed:Connect(function()
                        if i.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            fr.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    dragI = i
                end
            end)
            U.InputChanged:Connect(function(i)
                if i == dragI and dragging then
                    local d = i.Position - dragS
                    fr.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
                end
            end)

            notify("Loaded", "PvB Nuked Ultimate - [ to toggle", 5)
        end)
        if not success then
            notify("Error", "GUI failed: " .. tostring(err), 10)
        end
    end

    -- Init
    createGui()

    -- Respawn & Speed/God
    local charConn
    charConn = plr.CharacterAdded:Connect(function(c)
        char = c
        hum = c:WaitForChild("Humanoid", 10)
        if hum then
            pcall(function() hum.WalkSpeed = walkSpeed end)
            if isGod then tGod() end
            if isFarm then tFarm() end
            if isSell then tSell() end
            if isBuy then tBuy() end
            if isFuse then tFuse() end
            if isUpgPlant then tUpgPlant() end
            if isUpgTower then tUpgTower() end
            if isRebirth then tRebirth() end
            if isUnlockRows then tUnlockRows() end
            if isKillAura then tKillAura() end
        end
    end)
    connections[#connections + 1] = charConn

    -- Anti-AFK (with fallback)
    local afkConn
    local success, vu = pcall(function() return game:GetService("VirtualUser") end)
    if success and vu then
        afkConn = P.Player.Idled:Connect(function()
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end)
        connections[#connections + 1] = afkConn
    else
        notify("Debug", "VirtualUser not available, anti-AFK disabled", 5)
    end

    -- Final error check
    if not gui then
        notify("Error", "GUI failed to load. Try re-injecting or check executor.", 10)
    end
end)

if not success then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error",
            Text = "Script failed: " .. tostring(errorMsg),
            Duration = 15
        })
    end)
end
