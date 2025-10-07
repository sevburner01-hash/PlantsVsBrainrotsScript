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
    local farmC, sellC, buyC, fuseC, infMoneyC, upgPlantC, upgTowerC, rebirthC, unlockC, killC, harvestC, placeC, espC, flyC, noClipC, infJumpC, unlockAllC, autoFuseC, antiLagC, gui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    local connections = {} -- Store connections for cleanup
    local espInstances = {} -- Store ESP instances
    local webhookUrl = "" -- Set to your Discord webhook for notifications
    local gameRemotes = RS:WaitForChild("Remotes", 10) -- Direct reference to Remotes folder based on game structure

    -- Plants & Brainrots (expanded list based on game data)
    local plants = {"Peashooter", "Strawberry", "Cactus", "Pumpkin", "Sunflower", "Dragon Fruit", "Eggplant", "Watermelon", "Grape", "Cocotank", "Carnivorous Plant", "Mr Carrot", "Tomatrio", "Shroombino", "Common Seed", "Rare Seed", "Epic Seed", "Legendary Seed", "Brainrot Seed", "Delta Plant", "Omega Seed", "Mythic Vine", "Legendary Lotus"}
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

    -- Get Remote (updated with actual game remote names and direct lookup in Remotes folder)
    local function getR(name)
        local possibleNames = {
            "BuySeed", "PlantSeed", "Collect", "Sell", "Fuse", "UpgradePlant", "UpgradeTower", "Rebirth", "UnlockRow", "RedeemCode", "Damage", "Harvest", "Deploy", "Unlock", "Attack", "SellBrainrot", "BuyPlant", "CollectMoney", "CollectCash", "SellPlant"
        }
        for _, n in ipairs(possibleNames) do
            local remote = gameRemotes:FindFirstChild(n)
            if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                return remote
            end
        end
        notify("Debug", "Remote for '" .. name .. "' not found. Check game updates.", 5)
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

    -- Dupe (enhanced with multi-dupe modes, using BuySeed)
    local function dupeItem()
        local buyR = getR("BuySeed") or getR("BuyPlant")
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
                buyR:FireServer(item.Name)
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

    -- Auto Farm (using PlantSeed and Collect)
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
            local colR = getR("Collect") or getR("CollectMoney") or getR("CollectCash")
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

    -- Auto Harvest (using Harvest)
    local function autoHarvest()
        if isAutoHarvest then
            local harvestR = getR("Harvest") or getR("HarvestPlant")
            if harvestR then
                local success, plantsFolder = pcall(function() return workspace:FindFirstChild("Plants", true):GetChildren() end)
                if success then
                    for _, plant in ipairs(plantsFolder) do
                        if plant:IsA("Model") and plant:FindFirstChild("Maturity") and plant.Maturity.Value >= 1 then
                            pcall(function() harvestR:FireServer(plant) end)
                        end
                    end
                end
            end
            task.wait(1)
        end
    end

    -- Auto Place Brainrots (using Deploy or PlaceBrainrot)
    local function autoPlace()
        if isAutoPlace then
            local placeR = getR("Deploy") or getR("PlaceBrainrot")
            if placeR then
                local brainrot = getItem("Tool") or bp:FindFirstChild(selectedBrainrot)
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

    -- Unlock All (using Unlock)
    local function unlockAll()
        if isUnlockAll then
            local unlockR = getR("Unlock") or getR("UnlockRow")
            if unlockR then
                pcall(function() unlockR:FireServer() end)
            end
            task.wait(5)
        end
    end

    -- Auto Fuse Best (using Fuse)
    local function autoFuseBest()
        if isAutoFuseBest then
            local fuseR = getR("Fuse")
            if fuseR then
                -- Cycle through top plants/brainrots
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

    -- Auto Sell/Buy/Fuse/Upgrade/Rebirth/Unlock/Kill/Redeem (updated with correct remotes)
    local function autoSell() 
        if isSell then 
            local r = getR("Sell") or getR("SellBrainrot") or getR("SellPlant")
            if r then 
                pcall(function() r:FireServer("All") end) 
            end 
            task.wait(math.random(1, 2)) 
        end 
    end
    local function autoBuy() 
        if isBuy then 
            local r = getR("BuySeed") or getR("BuyPlant")
            if r then 
                pcall(function() r:FireServer(selectedPlant) end) 
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
                local r = getR("Damage") or getR("Attack") 
                if r then 
                    for _, enemy in ipairs(enemies) do 
                        pcall(function() r:FireServer(enemy, "Basic") end) 
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
        local colR = getR("Collect") or getR("CollectMoney") or getR("CollectCash")
        if colR then
            pcall(function() colR:FireServer() end) -- Updated args if needed
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

    -- GUI (Larger, better, easier to use, polished like Matrix - dark theme, sleek, added tabs simulation with sections, hover effects via mouse enter/leave)
    local function createGui()
        local success, err = pcall(function()
            gui = Instance.new("ScreenGui")
            gui.Name = "PvBNukedUltimate"
            gui.Parent = plr.PlayerGui or game:GetService("CoreGui")
            gui.ResetOnSpawn = false
            gui.Enabled = isGui
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            local mainFrame = Instance.new("Frame", gui)
            mainFrame.Size = UDim2.new(0, 400, 0, 500) -- Larger size
            mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
            mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Darker theme like Matrix
            mainFrame.BorderSizePixel = 0
            local corner = Instance.new("UICorner", mainFrame)
            corner.CornerRadius = UDim.new(0, 15) -- Smoother corners
            local stroke = Instance.new("UIStroke", mainFrame)
            stroke.Color = Color3.fromRGB(0, 255, 0) -- Green stroke like Matrix
            stroke.Thickness = 2
            local gradient = Instance.new("UIGradient", mainFrame)
            gradient.Color = ColorSequence.new(Color3.fromRGB(20,20,20), Color3.fromRGB(40,40,40))
            gradient.Rotation = 90

            local title = Instance.new("TextLabel", mainFrame)
            title.Size = UDim2.new(1, 0, 0, 50)
            title.Position = UDim2.new(0, 0, 0, 0)
            title.Text = "PvB Nuked Ultimate v2.1"
            title.TextColor3 = Color3.fromRGB(0, 255, 0) -- Matrix green
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.Code -- Code font for Matrix feel
            title.TextSize = 24

            local closeBtn = Instance.new("TextButton", mainFrame)
            closeBtn.Size = UDim2.new(0, 40, 0, 40)
            closeBtn.Position = UDim2.new(1, -45, 0, 5)
            closeBtn.Text = "X"
            closeBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
            closeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
            closeBtn.Font = Enum.Font.Code
            closeBtn.TextSize = 20
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
            Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
            closeBtn.MouseEnter:Connect(function()
                closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
            end)
            closeBtn.MouseLeave:Connect(function()
                closeBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
            end)

            -- Scrolling Frame for content
            local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
            scrollFrame.Size = UDim2.new(1, -20, 1, -60)
            scrollFrame.Position = UDim2.new(0, 10, 0, 55)
            scrollFrame.BackgroundTransparency = 0.5
            scrollFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1500) -- Larger canvas
            scrollFrame.ScrollBarThickness = 8
            scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
            Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)

            local listLayout = Instance.new("UIListLayout", scrollFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 8)

            -- Button helper (compact buttons with hover)
            local function btn(parent, txt, col, fn, order)
                local b = Instance.new("TextButton", parent)
                b.Size = UDim2.new(1, 0, 0, 35) -- Slightly taller for ease
                b.Text = txt
                b.BackgroundColor3 = col
                b.TextColor3 = Color3.fromRGB(0, 255, 0) -- Matrix green text
                b.Font = Enum.Font.Code
                b.TextSize = 16
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
                b.MouseButton1Click:Connect(fn)
                b.LayoutOrder = order or 0
                b.MouseEnter:Connect(function()
                    b.BackgroundColor3 = col + Color3.fromRGB(50, 50, 50)
                end)
                b.MouseLeave:Connect(function()
                    b.BackgroundColor3 = col
                end)
                return b
            end

            -- Section headers (polished)
            local function sectionHeader(parent, text, order)
                local label = Instance.new("TextLabel", parent)
                label.Size = UDim2.new(1, 0, 0, 30)
                label.Text = text
                label.BackgroundColor3 = Color3.fromRGB(0, 50, 0) -- Dark green
                label.TextColor3 = Color3.fromRGB(0, 255, 0)
                label.Font = Enum.Font.Code
                label.TextSize = 18
                Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)
                label.LayoutOrder = order or 0
                return label
            end

            -- Farm Section
            sectionHeader(scrollFrame, "Farm Features", 1)
            local farmB = btn(scrollFrame, "Auto Farm", Color3.fromRGB(0,100,0), function()
                tFarm()
                farmB.Text = isFarm and "Stop Farm" or "Auto Farm"
                farmB.BackgroundColor3 = isFarm and Color3.fromRGB(100,0,0) or Color3.fromRGB(0,100,0)
            end, 2)
            local harvestB = btn(scrollFrame, "Auto Harvest", Color3.fromRGB(0,80,0), function()
                tAutoHarvest()
                harvestB.Text = isAutoHarvest and "Stop Harvest" or "Auto Harvest"
                harvestB.BackgroundColor3 = isAutoHarvest and Color3.fromRGB(100,0,0) or Color3.fromRGB(0,80,0)
            end, 3)
            local placeB = btn(scrollFrame, "Auto Place Brainrots", Color3.fromRGB(0,60,0), function()
                tAutoPlace()
                placeB.Text = isAutoPlace and "Stop Place" or "Auto Place Brainrots"
                placeB.BackgroundColor3 = isAutoPlace and Color3.fromRGB(100,0,0) or Color3.fromRGB(0,60,0)
            end, 4)
            local sellB = btn(scrollFrame, "Auto Sell", Color3.fromRGB(100,0,0), function()
                tSell()
                sellB.Text = isSell and "Stop Sell" or "Auto Sell"
            end, 5)
            local buyB = btn(scrollFrame, "Auto Buy", Color3.fromRGB(0,0,100), function()
                tBuy()
                buyB.Text = isBuy and "Stop Buy" or "Auto Buy"
            end, 6)

            -- Combat Section
            sectionHeader(scrollFrame, "Combat Features", 7)
            local killB = btn(scrollFrame, "Kill Aura", Color3.fromRGB(100,25,25), function()
                tKillAura()
                killB.Text = isKillAura and "Stop Kill Aura" or "Kill Aura"
            end, 8)
            local godB = btn(scrollFrame, "God Mode", Color3.fromRGB(0,100,100), function()
                tGod()
                godB.Text = isGod and "No God" or "God Mode"
            end, 9)
            local espB = btn(scrollFrame, "ESP (Brainrots)", Color3.fromRGB(125,0,0), function()
                tESP()
                espB.Text = isESP and "Disable ESP" or "ESP (Brainrots)"
            end, 10)

            -- Upgrade Section
            sectionHeader(scrollFrame, "Upgrade Features", 11)
            local upgPlantB = btn(scrollFrame, "Auto Upg Plants", Color3.fromRGB(50,100,50), function()
                tUpgPlant()
                upgPlantB.Text = isUpgPlant and "Stop Upg P" or "Auto Upg Plants"
            end, 12)
            local upgTowerB = btn(scrollFrame, "Auto Upg Towers", Color3.fromRGB(50,50,100), function()
                tUpgTower()
                upgTowerB.Text = isUpgTower and "Stop Upg T" or "Auto Upg Towers"
            end, 13)
            local rebirthB = btn(scrollFrame, "Auto Rebirth", Color3.fromRGB(100,0,50), function()
                tRebirth()
                rebirthB.Text = isRebirth and "Stop Rebirth" or "Auto Rebirth"
            end, 14)
            local unlockB = btn(scrollFrame, "Auto Unlock Rows", Color3.fromRGB(0,50,100), function()
                tUnlockRows()
                unlockB.Text = isUnlockRows and "Stop Unlock" or "Auto Unlock Rows"
            end, 15)
            local unlockAllB = btn(scrollFrame, "Unlock All", Color3.fromRGB(0,100,50), function()
                tUnlockAll()
                unlockAllB.Text = isUnlockAll and "Stop Unlock All" or "Unlock All"
            end, 16)

            -- Misc Section
            sectionHeader(scrollFrame, "Misc Features", 17)
            local dupeB = btn(scrollFrame, "Dupe x" .. dupeAmt, Color3.fromRGB(125,82,0), dupeItem, 18)
            local fuseB = btn(scrollFrame, "Auto Fuse", Color3.fromRGB(64,0,64), function()
                tFuse()
                fuseB.Text = isFuse and "Stop Fuse" or "Auto Fuse"
            end, 19)
            local autoFuseBestB = btn(scrollFrame, "Auto Fuse Best", Color3.fromRGB(100,0,64), function()
                tAutoFuseBest()
                autoFuseBestB.Text = isAutoFuseBest and "Stop Fuse Best" or "Auto Fuse Best"
            end, 20)
            local infB = btn(scrollFrame, "Inf Money", Color3.fromRGB(125,107,0), function()
                tInfMoney()
                infB.Text = isInfMoney and "Stop Inf" or "Inf Money"
            end, 21)
            local redeemB = btn(scrollFrame, "Auto Redeem", Color3.fromRGB(100,100,0), function()
                tRedeem()
                redeemB.Text = isRedeem and "Redeem Done" or "Auto Redeem"
            end, 22)
            local rbB = btn(scrollFrame, "Rainbow Items", Color3.fromRGB(100,0,100), function()
                tRb()
                rbB.Text = isRb and "No Rainbow" or "Rainbow Items"
            end, 23)

            -- Movement Section
            sectionHeader(scrollFrame, "Movement Features", 24)
            local flyB = btn(scrollFrame, "Fly", Color3.fromRGB(0,125,125), function()
                tFly()
                flyB.Text = isFly and "Stop Fly" or "Fly"
            end, 25)
            local noClipB = btn(scrollFrame, "NoClip", Color3.fromRGB(125,125,0), function()
                tNoClip()
                noClipB.Text = isNoClip and "Stop NoClip" or "NoClip"
            end, 26)
            local infJumpB = btn(scrollFrame, "Inf Jump", Color3.fromRGB(125,50,0), function()
                tInfJump()
                infJumpB.Text = isInfJump and "Stop Inf Jump" or "Inf Jump"
            end, 27)
            local tpB = btn(scrollFrame, "Teleport to Shop", Color3.fromRGB(50,125,50), tTeleport, 28)

            -- Performance Section
            sectionHeader(scrollFrame, "Performance Features", 29)
            local fpsB = btn(scrollFrame, "FPS Boost", Color3.fromRGB(0,75,0), function()
                tFPSBoost()
                fpsB.Text = isFPSBoost and "FPS Boost On" or "FPS Boost"
            end, 30)
            local antiLagB = btn(scrollFrame, "Anti-Lag", Color3.fromRGB(0,50,0), function()
                tAntiLag()
                antiLagB.Text = isAntiLag and "Stop Anti-Lag" or "Anti-Lag"
            end, 31)

            -- Notification Section
            sectionHeader(scrollFrame, "Notification Features", 32)
            local webhookB = btn(scrollFrame, "Webhook Notify", Color3.fromRGB(50,50,125), function()
                tWebhookNotify()
                webhookB.Text = isWebhookNotify and "Disable Webhook" or "Webhook Notify"
            end, 33)

            -- Config Section
            sectionHeader(scrollFrame, "Configs", 34)
            dd(scrollFrame, 0, plants, selectedPlant, function(v) selectedPlant = v end, 35)
            dd(scrollFrame, 0, brainrots, selectedBrainrot, function(v) selectedBrainrot = v end, 36)

            -- TextBoxes for values (with labels for ease)
            local configFrame = Instance.new("Frame", scrollFrame)
            configFrame.Size = UDim2.new(1, 0, 0, 150)
            configFrame.BackgroundTransparency = 1
            configFrame.LayoutOrder = 37
            local configList = Instance.new("UIListLayout", configFrame)
            configList.SortOrder = Enum.SortOrder.LayoutOrder
            configList.Padding = UDim.new(0, 5)

            local function addTextBox(parent, labelText, defaultValue, callback)
                local container = Instance.new("Frame", parent)
                container.Size = UDim2.new(1, 0, 0, 35)
                container.BackgroundTransparency = 1

                local label = Instance.new("TextLabel", container)
                label.Size = UDim2.new(0.4, 0, 1, 0)
                label.Text = labelText
                label.TextColor3 = Color3.fromRGB(0, 255, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Code
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left

                local tb = Instance.new("TextBox", container)
                tb.Size = UDim2.new(0.6, 0, 1, 0)
                tb.Position = UDim2.new(0.4, 0, 0, 0)
                tb.Text = tostring(defaultValue)
                tb.BackgroundColor3 = Color3.fromRGB(40,40,40)
                tb.TextColor3 = Color3.fromRGB(0,255,0)
                tb.Font = Enum.Font.Code
                tb.TextSize = 14
                tb.FocusLost:Connect(callback)
                Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
            end

            addTextBox(configFrame, "WalkSpeed:", walkSpeed, function()
                walkSpeed = tonumber(tb.Text) or 100
                if hum then pcall(function() hum.WalkSpeed = walkSpeed end) end
            end)
            addTextBox(configFrame, "JumpPower:", jumpPower, function()
                jumpPower = tonumber(tb.Text) or 200
                if hum then pcall(function() hum.JumpPower = jumpPower end) end
            end)
            addTextBox(configFrame, "FlySpeed:", flySpeed, function()
                flySpeed = tonumber(tb.Text) or 50
            end)
            addTextBox(configFrame, "DupeAmt:", dupeAmt, function()
                dupeAmt = tonumber(tb.Text) or 50
            end)
            addTextBox(configFrame, "Webhook URL:", webhookUrl, function()
                webhookUrl = tb.Text
            end)

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

            notify("Loaded", "PvB Nuked Ultimate v2.1 - [ to toggle", 5)
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
