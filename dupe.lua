-- Ensure entire script is wrapped in pcall
local success, errorMsg = pcall(function()
    -- Services
    local P, R, U, S, RS, TS, VPS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("StarterGui"), game:GetService("ReplicatedStorage"), game:GetService("TweenService"), game:GetService("VirtualInputManager")
    local plr = P.LocalPlayer
    local bp = plr:WaitForChild("Backpack", 10) -- Increased timeout
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char and char:WaitForChild("Humanoid", 10) or nil
    local hrp = char and char:WaitForChild("HumanoidRootPart", 10) or nil

    -- Config
    local farmPos = Vector3.new(0, 5, 0) -- Set to your plot center
    local shopPos = Vector3.new(50, 5, 50) -- Example shop position; adjust as needed
    local isFarm, isSell, isBuy, isFuse, isRb, isGui, isInfMoney, isGod, isUpgPlant, isUpgTower, isRebirth, isUnlockRows, isKillAura, isFPSBoost, isRedeem = false, false, false, false, false, true, false, false, false, false, false, false, false, false, false
    local isAutoHarvest, isAutoPlace, isTeleport, isESP, isFly, isNoClip, isInfJump, isUnlockAll, isAutoFuseBest, isAntiLag, isWebhookNotify = false, false, false, false, false, false, false, false, false, false, false
    local dupeAmt, buyAmt, delayMin, delayMax, walkSpeed, jumpPower, flySpeed = 50, 100, 0.5, 1.5, 100, 200, 50
    local farmC, sellC, buyC, fuseC, infMoneyC, upgPlantC, upgTowerC, rebirthC, unlockC, killC, harvestC, placeC, espC, flyC, noClipC, infJumpC, unlockAllC, autoFuseC, antiLagC, gui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    local connections = {} -- Store connections for cleanup
    local espInstances = {} -- Store ESP instances
    local webhookUrl = "" -- Set to your Discord webhook for notifications

    -- Plants & Brainrots (expanded list based on game data)
    local plants = {"Peashooter", "Strawberry", "Cactus", "Pumpkin", "Sunflower", "Dragon Fruit", "Eggplant", "Watermelon", "Grape", "Cocotank", "Carnivorous Plant", "Mr Carrot", "Tomatrio", "Shroombino", "CommonSeed", "RareSeed", "EpicSeed", "LegendarySeed", "BrainrotSeed", "Delta Plant", "Omega Seed", "Mythic Vine", "Legendary Lotus"}
    local brainrots = {"Boneca Ambalabu", "Fluri Flura", "Trulimero Trulicina", "Lirili Larila", "Noobini Bananini", "Orangutini Ananassini", "Pipi Kiwi", "Noobini Cactusini", "Orangutini Strawberrini", "Espresso Signora", "Tim Cheese", "Agarrini La Palini", "Bombini Crostini", "Alessio", "Bandito Bobrito", "Trippi Troppi", "Brr Brr Patapim", "Cappuccino Assasino", "Svinino Bombondino", "Brr Brr Sunflowerim", "Svinino Pumpkinino", "Orcalero Orcala", "Las Tralaleritas", "Ballerina Cappuccina", "Bananita Dolphinita", "Burbaloni Lulliloli", "Elefanto Cocofanto", "Gangster Footera", "Madung", "Dragonfrutina Dolphinita", "Eggplantini Burbalonini", "Bombini Gussini", "Frigo Camelo", "Bombardilo Watermelondrilo", "Bombardiro Crocodilo", "Giraffa Celeste", "Matteo", "Odin Din Din Dun", "Tralalelo Tralala", "Cocotanko Giraffanto", "Carnivourita Tralalerita", "Vacca Saturno Saturnita", "Garamararam", "Los Tralaleritos", "Los Mr Carrotitos", "Blueberrinni Octopussini", "Pot Hotspot", "Brri Brri Bicus Dicus Bombicus", "Crazylone Pizalone", "Ultra Brainrot", "Mega Cappuccino", "Shadow Noobini", "Eternal Trulimero"}
    local selectedPlant, selectedBrainrot = plants[1], brainrots[1]

    -- Redeemable Codes (updated October 2025)
    local codes = {"STACKS", "frozen", "based", "latest!", "BASED", "FROZEN", "UPDATE1", "BRAINROT2025", "PVBBOOST"}

    -- Debug Notification
    local function notify(title, text, dur)
        pcall(function()
            S:SetCore("SendNotification", {Title = title, Text = text, Duration = dur or 5})
        end)
    end

    -- Webhook Notification (for rare events)
    local function sendWebhook(message)
        if webhookUrl ~= "" then
            local http = game:GetService("HttpService")
            local data = {content = message}
            pcall(function()
                http:PostAsync(webhookUrl, http:JSONEncode(data))
            end)
        end
    end

    -- Get Remote (even more robust, checks all services)
    local function getR(name)
        local names = {name, name .. "Remote", name .. "Event", name:lower(), name:upper(), "Remote" .. name, "Event" .. name}
        local services = {RS, workspace, game:GetService("ServerScriptService"), game:GetService("ReplicatedFirst")}
        for _, service in ipairs(services) do
            for _, n in ipairs(names) do
                local success, remote = pcall(function()
                    for _, obj in ipairs(service:GetDescendants()) do
                        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and obj.Name:lower() == n:lower() then
                            return obj
                        end
                    end
                    return nil
                end)
                if success and remote then
                    return remote
                end
            end
        end
        notify("Debug", "Remote '" .. name .. "' not found. Use RemoteSpy.", 5)
        return nil
    end

    -- Get Item
    local function getItem(class)
        local success, item = pcall(function()
            for _, i in ipairs(char:GetChildren()) do
                if i:IsA(class or "Tool") then return i end
            end
            for _, i in ipairs(bp:GetChildren()) do
                if i:IsA(class or "Tool") then return i end
            end
            return nil
        end)
        if not success or not item then
            notify("Debug", "No item found in character or backpack", 5)
        end
        return success and item or nil
    end

    -- Dupe (enhanced with multi-dupe modes)
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
        local safeDupeAmt = math.min(dupeAmt, 200) -- Increased limit
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
                    local newI = bp:WaitForChild(item.Name, 3) or bp:WaitForChild(item.Name .. " (Clone)", 3)
                    if newI then
                        local success, err = pcall(function()
                            local handle = newI:FindFirstChild("Handle", true)
                            if handle then
                                while isRb and newI.Parent do
                                    handle.Color = Color3.fromHSV(tick() % 1, 1, 1)
                                    task.wait(0.05) -- Faster rainbow
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
        if isWebhookNotify then
            sendWebhook("Duplicated " .. item.Name .. " x" .. safeDupeAmt .. " by " .. plr.Name)
        end
    end

    -- Auto Farm (enhanced with pathfinding if available)
    local function autoFarm()
        if isFarm and char and hum and hum.Health > 0 then
            local success, err = pcall(function()
                hum.WalkSpeed = walkSpeed
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

    -- Auto Harvest (new feature)
    local function autoHarvest()
        if isAutoHarvest then
            local harvestR = getR("HarvestPlant") or getR("Harvest")
            if harvestR then
                local success, plantsFolder = pcall(function() return workspace:FindFirstChild("Plants", true):GetChildren() end)
                if success then
                    for _, plant in ipairs(plantsFolder) do
                        if plant:IsA("Model") and plant:FindFirstChild("Maturity") and plant.Maturity.Value >= 1 then -- Assume maturity property
                            pcall(function() harvestR:FireServer(plant) end)
                        end
                    end
                end
            end
            task.wait(1)
        end
    end

    -- Auto Place Brainrots (new feature)
    local function autoPlace()
        if isAutoPlace then
            local placeR = getR("PlaceBrainrot") or getR("Deploy")
            if placeR then
                local brainrot = getItem("BrainrotTool") or bp:FindFirstChild(selectedBrainrot)
                if brainrot then
                    pcall(function()
                        hum:EquipTool(brainrot)
                        placeR:FireServer(farmPos + Vector3.new(math.random(-5,5), 0, math.random(-5,5)), brainrot.Name)
                    end)
                end
            end
            task.wait(2)
        end
    end

    -- Teleport (new feature)
    local function teleportTo(pos)
        if isTeleport and hrp then
            pcall(function()
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
                TS:Create(hrp, tweenInfo, {CFrame = CFrame.new(pos)}):Play()
            end)
        end
    end

    -- ESP (new feature, for brainrots)
    local function createESP(instance, color)
        local bb = Instance.new("BillboardGui", instance)
        bb.Adornee = instance
        bb.Size = UDim2.new(0, 100, 0, 50)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local frame = Instance.new("Frame", bb)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.5
        frame.BackgroundColor3 = color
        local text = Instance.new("TextLabel", frame)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.Text = instance.Name
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.new(1,1,1)
        table.insert(espInstances, bb)
    end

    local function espLoop()
        if isESP then
            local success, enemies = pcall(function() return workspace:FindFirstChild("Brainrots", true):GetChildren() end)
            if success then
                for _, enemy in ipairs(enemies) do
                    if not enemy:FindFirstChild("BillboardGui") then
                        createESP(enemy, Color3.fromRGB(255, 0, 0))
                    end
                end
            end
            task.wait(0.5)
        end
    end

    -- Fly (new feature)
    local flyVelocity
    local function flyLoop()
        if isFly and hrp then
            if not flyVelocity then
                flyVelocity = Instance.new("BodyVelocity", hrp)
                flyVelocity.Velocity = Vector3.new(0,0,0)
                flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            end
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0,0,0)
            if U:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if U:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if U:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if U:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if U:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if U:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
            flyVelocity.Velocity = moveDir * flySpeed
        elseif flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end

    -- NoClip (new feature)
    local function noClipLoop()
        if isNoClip and char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            task.wait(0.1)
        end
    end

    -- Infinite Jump (new feature)
    local function infJumpLoop()
        if isInfJump then
            U.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space and hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end

    -- Unlock All (new feature)
    local function unlockAll()
        if isUnlockAll then
            local unlockR = getR("UnlockAll") or getR("Unlock")
            if unlockR then
                pcall(function() unlockR:FireServer() end)
            end
            task.wait(5)
        end
    end

    -- Auto Fuse Best (new feature)
    local function autoFuseBest()
        if isAutoFuseBest then
            local fuseR = getR("Fuse")
            if fuseR then
                -- Assume best combo logic; cycle through top plants/brainrots
                for i = #plants, #plants - 5, -1 do
                    for j = #brainrots, #brainrots - 5, -1 do
                        pcall(function() fuseR:FireServer(brainrots[j], plants[i]) end)
                        task.wait(1)
                    end
                end
            end
            task.wait(10)
        end
    end

    -- Anti-Lag (new feature, advanced optimizations)
    local function antiLag()
        if isAntiLag then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
                game.Lighting.GlobalShadows = false
                game.Lighting.Brightness = 0
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "Terrain" then
                        v.CastShadow = false
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                        v.Transparency = v.Transparency > 0.5 and 1 or v.Transparency
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Enabled = false
                    end
                end
            end)
            task.wait(5)
        end
    end

    -- Auto Sell/Buy/Fuse/Upgrade/Rebirth/Unlock/Kill/Redeem (existing, enhanced)
    local function autoSell() 
        if isSell then 
            local r = getR("SellPlant") or getR("SellBrainrot")
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

    -- Infinite Money (enhanced with multiple methods)
    local function hookInfMoney()
        local success, stats = pcall(function()
            return plr:FindFirstChild("leaderstats")
        end)
        if success and stats then
            local money = stats:FindFirstChild("Money") or stats:FindFirstChild("Coins") or stats:FindFirstChild("Currency")
            if money then
                pcall(function()
                    money:GetPropertyChangedSignal("Value"):Connect(function()
                        money.Value = 9999999999 -- Increased amount
                    end)
                end)
            else
                notify("Debug", "Money stat not found", 5)
            end
        end
        local colR = getR("CollectMoney") or getR("Collect")
        if colR then
            pcall(function() colR:FireServer(10000000) end) -- Increased safe value
        end
    end

    -- FPS Boost (enhanced)
    local function fpsBoost()
        if isFPSBoost then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name ~= "Terrain" then
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") then
                        v.Lifetime = NumberRange.new(0)
                    end
                end
            end)
        end
    end

    -- Toggle Functions (expanded)
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
    local function tAutoHarvest()
        isAutoHarvest = not isAutoHarvest
        if harvestC then harvestC:Disconnect() harvestC = nil end
        if isAutoHarvest then
            harvestC = R.Heartbeat:Connect(autoHarvest)
            connections[#connections + 1] = harvestC
        end
    end
    local function tAutoPlace()
        isAutoPlace = not isAutoPlace
        if placeC then placeC:Disconnect() placeC = nil end
        if isAutoPlace then
            placeC = R.Heartbeat:Connect(autoPlace)
            connections[#connections + 1] = placeC
        end
    end
    local function tTeleport()
        isTeleport = not isTeleport
        if isTeleport then
            teleportTo(shopPos) -- Example to shop
        end
    end
    local function tESP()
        isESP = not isESP
        if espC then espC:Disconnect() espC = nil end
        if isESP then
            espC = R.Heartbeat:Connect(espLoop)
            connections[#connections + 1] = espC
        else
            for _, esp in ipairs(espInstances) do
                esp:Destroy()
            end
            espInstances = {}
        end
    end
    local function tFly()
        isFly = not isFly
        if flyC then flyC:Disconnect() flyC = nil end
        if isFly then
            flyC = R.RenderStepped:Connect(flyLoop)
            connections[#connections + 1] = flyC
        end
    end
    local function tNoClip()
        isNoClip = not isNoClip
        if noClipC then noClipC:Disconnect() noClipC = nil end
        if isNoClip then
            noClipC = R.Stepped:Connect(noClipLoop)
            connections[#connections + 1] = noClipC
        end
    end
    local function tInfJump()
        isInfJump = not isInfJump
        if infJumpC then infJumpC:Disconnect() infJumpC = nil end
        if isInfJump then
            infJumpC = U.InputBegan:Connect(infJumpLoop)
            connections[#connections + 1] = infJumpC
        end
    end
    local function tUnlockAll()
        isUnlockAll = not isUnlockAll
        if unlockAllC then unlockAllC:Disconnect() unlockAllC = nil end
        if isUnlockAll then
            unlockAllC = R.Heartbeat:Connect(unlockAll)
            connections[#connections + 1] = unlockAllC
        end
    end
    local function tAutoFuseBest()
        isAutoFuseBest = not isAutoFuseBest
        if autoFuseC then autoFuseC:Disconnect() autoFuseC = nil end
        if isAutoFuseBest then
            autoFuseC = R.Heartbeat:Connect(autoFuseBest)
            connections[#connections + 1] = autoFuseC
        end
    end
    local function tAntiLag()
        isAntiLag = not isAntiLag
        if antiLagC then antiLagC:Disconnect() antiLagC = nil end
        if isAntiLag then
            antiLagC = R.Heartbeat:Connect(antiLag)
            connections[#connections + 1] = antiLagC
        end
    end
    local function tWebhookNotify()
        isWebhookNotify = not isWebhookNotify
    end

    -- Hotkey (enhanced with more keys)
    local inputConn
    inputConn = U.InputBegan:Connect(function(i, p)
        if not p then
            if i.KeyCode == Enum.KeyCode.LeftBracket then tGui() end
            if i.KeyCode == Enum.KeyCode.F then tFly() end
            if i.KeyCode == Enum.KeyCode.N then tNoClip() end
            if i.KeyCode == Enum.KeyCode.J then tInfJump() end
        end
    end)
    connections[#connections + 1] = inputConn

    -- GUI (Scrollable, Compact, Polished)
    local function createGui()
        local success, err = pcall(function()
            gui = Instance.new("ScreenGui")
            gui.Name = "PvBNukedUltimate"
            gui.Parent = plr.PlayerGui or game:GetService("CoreGui")
            gui.ResetOnSpawn = false
            gui.Enabled = isGui
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            local mainFrame = Instance.new("Frame", gui)
            mainFrame.Size = UDim2.new(0, 300, 0, 400) -- Compact size
            mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
            mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            mainFrame.BorderSizePixel = 0
            local corner = Instance.new("UICorner", mainFrame)
            corner.CornerRadius = UDim.new(0, 12)
            local stroke = Instance.new("UIStroke", mainFrame)
            stroke.Color = Color3.fromRGB(100, 100, 100)
            stroke.Thickness = 1.5
            local gradient = Instance.new("UIGradient", mainFrame)
            gradient.Color = ColorSequence.new(Color3.fromRGB(30,30,30), Color3.fromRGB(50,50,50))

            local title = Instance.new("TextLabel", mainFrame)
            title.Size = UDim2.new(1, 0, 0, 40)
            title.Position = UDim2.new(0, 0, 0, 0)
            title.Text = "PvB Nuked Ultimate v2.0"
            title.TextColor3 = Color3.new(1,1,1)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.TextSize = 18

            local closeBtn = Instance.new("TextButton", mainFrame)
            closeBtn.Size = UDim2.new(0, 30, 0, 30)
            closeBtn.Position = UDim2.new(1, -35, 0, 5)
            closeBtn.Text = "X"
            closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            closeBtn.TextColor3 = Color3.new(1,1,1)
            closeBtn.Font = Enum.Font.Gotham
            closeBtn.TextSize = 16
            closeBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    for _, conn in ipairs(connections) do
                        if conn then conn:Disconnect() end
                    end
                    connections = {}
                    gui:Destroy()
                    gui = nil
                end)
            end)
            Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

            -- Scrolling Frame for content
            local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
            scrollFrame.Size = UDim2.new(1, -10, 1, -50)
            scrollFrame.Position = UDim2.new(0, 5, 0, 45)
            scrollFrame.BackgroundTransparency = 1
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200) -- Expanded for more features
            scrollFrame.ScrollBarThickness = 6
            scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y

            local listLayout = Instance.new("UIListLayout", scrollFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 5)

            -- Button helper (compact buttons)
            local function btn(parent, txt, col, fn, order)
                local b = Instance.new("TextButton", parent)
                b.Size = UDim2.new(1, 0, 0, 30) -- Compact height
                b.Text = txt
                b.BackgroundColor3 = col
                b.TextColor3 = Color3.new(1,1,1)
                b.Font = Enum.Font.Gotham
                b.TextSize = 14
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
                b.MouseButton1Click:Connect(fn)
                b.LayoutOrder = order or 0
                return b
            end

            -- Section headers
            local function sectionHeader(parent, text, order)
                local label = Instance.new("TextLabel", parent)
                label.Size = UDim2.new(1, 0, 0, 25)
                label.Text = text
                label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                label.TextColor3 = Color3.new(1,1,1)
                label.Font = Enum.Font.GothamBold
                label.TextSize = 16
                Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
                label.LayoutOrder = order or 0
                return label
            end

            -- Farm Section
            sectionHeader(scrollFrame, "Farm Features", 1)
            local farmB = btn(scrollFrame, "Auto Farm", Color3.fromRGB(0,200,0), function()
                tFarm()
                farmB.Text = isFarm and "Stop Farm" or "Auto Farm"
                farmB.BackgroundColor3 = isFarm and Color3.fromRGB(200,0,0) or Color3.fromRGB(0,200,0)
            end, 2)
            local harvestB = btn(scrollFrame, "Auto Harvest", Color3.fromRGB(0,150,0), function()
                tAutoHarvest()
                harvestB.Text = isAutoHarvest and "Stop Harvest" or "Auto Harvest"
                harvestB.BackgroundColor3 = isAutoHarvest and Color3.fromRGB(200,0,0) or Color3.fromRGB(0,150,0)
            end, 3)
            local placeB = btn(scrollFrame, "Auto Place Brainrots", Color3.fromRGB(0,100,0), function()
                tAutoPlace()
                placeB.Text = isAutoPlace and "Stop Place" or "Auto Place Brainrots"
                placeB.BackgroundColor3 = isAutoPlace and Color3.fromRGB(200,0,0) or Color3.fromRGB(0,100,0)
            end, 4)
            local sellB = btn(scrollFrame, "Auto Sell", Color3.fromRGB(200,0,0), function()
                tSell()
                sellB.Text = isSell and "Stop Sell" or "Auto Sell"
            end, 5)
            local buyB = btn(scrollFrame, "Auto Buy", Color3.fromRGB(0,0,200), function()
                tBuy()
                buyB.Text = isBuy and "Stop Buy" or "Auto Buy"
            end, 6)

            -- Combat Section
            sectionHeader(scrollFrame, "Combat Features", 7)
            local killB = btn(scrollFrame, "Kill Aura", Color3.fromRGB(200,50,50), function()
                tKillAura()
                killB.Text = isKillAura and "Stop Kill Aura" or "Kill Aura"
            end, 8)
            local godB = btn(scrollFrame, "God Mode", Color3.fromRGB(0,200,200), function()
                tGod()
                godB.Text = isGod and "No God" or "God Mode"
            end, 9)
            local espB = btn(scrollFrame, "ESP (Brainrots)", Color3.fromRGB(255,0,0), function()
                tESP()
                espB.Text = isESP and "Disable ESP" or "ESP (Brainrots)"
            end, 10)

            -- Upgrade Section
            sectionHeader(scrollFrame, "Upgrade Features", 11)
            local upgPlantB = btn(scrollFrame, "Auto Upg Plants", Color3.fromRGB(100,200,100), function()
                tUpgPlant()
                upgPlantB.Text = isUpgPlant and "Stop Upg P" or "Auto Upg Plants"
            end, 12)
            local upgTowerB = btn(scrollFrame, "Auto Upg Towers", Color3.fromRGB(100,100,200), function()
                tUpgTower()
                upgTowerB.Text = isUpgTower and "Stop Upg T" or "Auto Upg Towers"
            end, 13)
            local rebirthB = btn(scrollFrame, "Auto Rebirth", Color3.fromRGB(200,0,100), function()
                tRebirth()
                rebirthB.Text = isRebirth and "Stop Rebirth" or "Auto Rebirth"
            end, 14)
            local unlockB = btn(scrollFrame, "Auto Unlock Rows", Color3.fromRGB(0,100,200), function()
                tUnlockRows()
                unlockB.Text = isUnlockRows and "Stop Unlock" or "Auto Unlock Rows"
            end, 15)
            local unlockAllB = btn(scrollFrame, "Unlock All", Color3.fromRGB(0,200,100), function()
                tUnlockAll()
                unlockAllB.Text = isUnlockAll and "Stop Unlock All" or "Unlock All"
            end, 16)

            -- Misc Section
            sectionHeader(scrollFrame, "Misc Features", 17)
            local dupeB = btn(scrollFrame, "Dupe x" .. dupeAmt, Color3.fromRGB(255,165,0), dupeItem, 18)
            local fuseB = btn(scrollFrame, "Auto Fuse", Color3.fromRGB(128,0,128), function()
                tFuse()
                fuseB.Text = isFuse and "Stop Fuse" or "Auto Fuse"
            end, 19)
            local autoFuseBestB = btn(scrollFrame, "Auto Fuse Best", Color3.fromRGB(200,0,128), function()
                tAutoFuseBest()
                autoFuseBestB.Text = isAutoFuseBest and "Stop Fuse Best" or "Auto Fuse Best"
            end, 20)
            local infB = btn(scrollFrame, "Inf Money", Color3.fromRGB(255,215,0), function()
                tInfMoney()
                infB.Text = isInfMoney and "Stop Inf" or "Inf Money"
            end, 21)
            local redeemB = btn(scrollFrame, "Auto Redeem", Color3.fromRGB(200,200,0), function()
                tRedeem()
                redeemB.Text = isRedeem and "Redeem Done" or "Auto Redeem"
            end, 22)
            local rbB = btn(scrollFrame, "Rainbow Items", Color3.fromRGB(200,0,200), function()
                tRb()
                rbB.Text = isRb and "No Rainbow" or "Rainbow Items"
            end, 23)

            -- Movement Section
            sectionHeader(scrollFrame, "Movement Features", 24)
            local flyB = btn(scrollFrame, "Fly", Color3.fromRGB(0,255,255), function()
                tFly()
                flyB.Text = isFly and "Stop Fly" or "Fly"
            end, 25)
            local noClipB = btn(scrollFrame, "NoClip", Color3.fromRGB(255,255,0), function()
                tNoClip()
                noClipB.Text = isNoClip and "Stop NoClip" or "NoClip"
            end, 26)
            local infJumpB = btn(scrollFrame, "Inf Jump", Color3.fromRGB(255,100,0), function()
                tInfJump()
                infJumpB.Text = isInfJump and "Stop Inf Jump" or "Inf Jump"
            end, 27)
            local tpB = btn(scrollFrame, "Teleport to Shop", Color3.fromRGB(100,255,100), tTeleport, 28)

            -- Performance Section
            sectionHeader(scrollFrame, "Performance Features", 29)
            local fpsB = btn(scrollFrame, "FPS Boost", Color3.fromRGB(0,150,0), function()
                tFPSBoost()
                fpsB.Text = isFPSBoost and "FPS Boost On" or "FPS Boost"
            end, 30)
            local antiLagB = btn(scrollFrame, "Anti-Lag", Color3.fromRGB(0,100,0), function()
                tAntiLag()
                antiLagB.Text = isAntiLag and "Stop Anti-Lag" or "Anti-Lag"
            end, 31)

            -- Notification Section
            sectionHeader(scrollFrame, "Notification Features", 32)
            local webhookB = btn(scrollFrame, "Webhook Notify", Color3.fromRGB(100,100,255), function()
                tWebhookNotify()
                webhookB.Text = isWebhookNotify and "Disable Webhook" or "Webhook Notify"
            end, 33)

            -- Dropdowns (compact)
            local function dd(parent, pos, list, sel, fn, order)
                local d = Instance.new("TextButton", parent)
                d.Size = UDim2.new(0.5, -5, 0, 25) -- Compact
                d.LayoutOrder = order or 0
                d.Text = sel
                d.BackgroundColor3 = Color3.fromRGB(80,80,80)
                d.TextColor3 = Color3.new(1,1,1)
                d.Font = Enum.Font.Gotham
                d.TextSize = 12
                local dl = Instance.new("Frame", parent)
                dl.Size = UDim2.new(0.5, -5, 0, 100)
                dl.BackgroundColor3 = Color3.fromRGB(40,40,40)
                dl.Visible = false
                Instance.new("UICorner", dl).CornerRadius = UDim.new(0, 5)
                local scroll = Instance.new("ScrollingFrame", dl)
                scroll.Size = UDim2.new(1, 0, 1, 0)
                scroll.CanvasSize = UDim2.new(0, 0, 0, #list * 25)
                scroll.ScrollingDirection = Enum.ScrollingDirection.Y
                scroll.ScrollBarThickness = 4
                local ls = Instance.new("UIListLayout", scroll)
                ls.SortOrder = Enum.SortOrder.LayoutOrder
                for i, v in ipairs(list) do
                    local o = Instance.new("TextButton", scroll)
                    o.Size = UDim2.new(1, 0, 0, 25)
                    o.Text = v
                    o.TextColor3 = Color3.new(1,1,1)
                    o.Font = Enum.Font.Gotham
                    o.TextSize = 12
                    o.LayoutOrder = i
                    o.BackgroundColor3 = Color3.fromRGB(60,60,60)
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

            -- Config Section
            sectionHeader(scrollFrame, "Configs", 34)
            dd(scrollFrame, 0, plants, selectedPlant, function(v) selectedPlant = v end, 35)
            dd(scrollFrame, 0, brainrots, selectedBrainrot, function(v) selectedBrainrot = v end, 36)

            -- TextBoxes for values
            local speedTB = Instance.new("TextBox", scrollFrame)
            speedTB.Size = UDim2.new(1, 0, 0, 25)
            speedTB.LayoutOrder = 37
            speedTB.Text = "WalkSpeed: " .. tostring(walkSpeed)
            speedTB.BackgroundColor3 = Color3.fromRGB(80,80,80)
            speedTB.TextColor3 = Color3.new(1,1,1)
            speedTB.Font = Enum.Font.Gotham
            speedTB.TextSize = 12
            speedTB.FocusLost:Connect(function()
                walkSpeed = tonumber(speedTB.Text:match("%d+")) or 16
                if hum then pcall(function() hum.WalkSpeed = walkSpeed end) end
            end)
            Instance.new("UICorner", speedTB).CornerRadius = UDim.new(0, 6)

            local jumpTB = Instance.new("TextBox", scrollFrame)
            jumpTB.Size = UDim2.new(1, 0, 0, 25)
            jumpTB.LayoutOrder = 38
            jumpTB.Text = "JumpPower: " .. tostring(jumpPower)
            jumpTB.BackgroundColor3 = Color3.fromRGB(80,80,80)
            jumpTB.TextColor3 = Color3.new(1,1,1)
            jumpTB.Font = Enum.Font.Gotham
            jumpTB.TextSize = 12
            jumpTB.FocusLost:Connect(function()
                jumpPower = tonumber(jumpTB.Text:match("%d+")) or 50
                if hum then pcall(function() hum.JumpPower = jumpPower end) end
            end)
            Instance.new("UICorner", jumpTB).CornerRadius = UDim.new(0, 6)

            local flyTB = Instance.new("TextBox", scrollFrame)
            flyTB.Size = UDim2.new(1, 0, 0, 25)
            flyTB.LayoutOrder = 39
            flyTB.Text = "FlySpeed: " .. tostring(flySpeed)
            flyTB.BackgroundColor3 = Color3.fromRGB(80,80,80)
            flyTB.TextColor3 = Color3.new(1,1,1)
            flyTB.Font = Enum.Font.Gotham
            flyTB.TextSize = 12
            flyTB.FocusLost:Connect(function()
                flySpeed = tonumber(flyTB.Text:match("%d+")) or 50
            end)
            Instance.new("UICorner", flyTB).CornerRadius = UDim.new(0, 6)

            local dupeTB = Instance.new("TextBox", scrollFrame)
            dupeTB.Size = UDim2.new(1, 0, 0, 25)
            dupeTB.LayoutOrder = 40
            dupeTB.Text = "DupeAmt: " .. tostring(dupeAmt)
            dupeTB.BackgroundColor3 = Color3.fromRGB(80,80,80)
            dupeTB.TextColor3 = Color3.new(1,1,1)
            dupeTB.Font = Enum.Font.Gotham
            dupeTB.TextSize = 12
            dupeTB.FocusLost:Connect(function()
                dupeAmt = tonumber(dupeTB.Text:match("%d+")) or 50
            end)
            Instance.new("UICorner", dupeTB).CornerRadius = UDim.new(0, 6)

            local webhookTB = Instance.new("TextBox", scrollFrame)
            webhookTB.Size = UDim2.new(1, 0, 0, 25)
            webhookTB.LayoutOrder = 41
            webhookTB.Text = "Webhook URL"
            webhookTB.BackgroundColor3 = Color3.fromRGB(80,80,80)
            webhookTB.TextColor3 = Color3.new(1,1,1)
            webhookTB.Font = Enum.Font.Gotham
            webhookTB.TextSize = 12
            webhookTB.FocusLost:Connect(function()
                webhookUrl = webhookTB.Text
            end)
            Instance.new("UICorner", webhookTB).CornerRadius = UDim.new(0, 6)

            -- Draggable (polished)
            local dragging, dragI, dragS, startP
            mainFrame.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging, dragS, startP = true, i.Position, mainFrame.Position
                    i.Changed:Connect(function()
                        if i.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)
            mainFrame.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseMovement then
                    dragI = i
                end
            end)
            U.InputChanged:Connect(function(i)
                if i == dragI and dragging then
                    local d = i.Position - dragS
                    mainFrame.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
                end
            end)

            notify("Loaded", "PvB Nuked Ultimate v2.0 - [ to toggle", 5)
        end)
        if not success then
            notify("Error", "GUI failed: " .. tostring(err), 10)
        end
    end

    -- Init
    createGui()

    -- Respawn & Speed/God/Jump (enhanced)
    local charConn
    charConn = plr.CharacterAdded:Connect(function(c)
        char = c
        hum = c:WaitForChild("Humanoid", 10)
        hrp = c:WaitForChild("HumanoidRootPart", 10)
        if hum then
            pcall(function() 
                hum.WalkSpeed = walkSpeed 
                hum.JumpPower = jumpPower
            end)
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
            if isAutoHarvest then tAutoHarvest() end
            if isAutoPlace then tAutoPlace() end
            if isESP then tESP() end
            if isFly then tFly() end
            if isNoClip then tNoClip() end
            if isInfJump then tInfJump() end
            if isUnlockAll then tUnlockAll() end
            if isAutoFuseBest then tAutoFuseBest() end
            if isAntiLag then tAntiLag() end
        end
    end)
    connections[#connections + 1] = charConn

    -- Anti-AFK (enhanced with mouse movement)
    local afkConn
    local success, vu = pcall(function() return game:GetService("VirtualUser") end)
    if success and vu then
        afkConn = P.Player.Idled:Connect(function()
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
                VPS:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.1)
                VPS:SendKeyEvent(false, Enum.KeyCode.W, false, game)
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
