local Players = game:GetService("Players")
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function getTool()
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            return tool
        end
    end
    return nil
end

local function duplicateItem()
    local tool = getTool()
    if tool then
        for _ = 1, 50 do
            local clone = tool:Clone()
            clone.Parent = backpack
        end
    end
end

local function autoFarm()
    -- Example auto farming logic: move to a specific location and collect resources
    local farmLocation = Vector3.new(100, 5, 100) -- Replace with actual farming location
    character:SetPrimaryPartCFrame(CFrame.new(farmLocation))
    wait(1) -- Wait for a second to ensure movement
    -- Add additional farming logic here, such as interacting with objects
end

local function onRenderStepped()
    duplicateItem()
    autoFarm()
end

game:GetService("RunService").RenderStepped:Connect(onRenderStepped)
