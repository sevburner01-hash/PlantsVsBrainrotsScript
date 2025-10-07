local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Cache frequently accessed services and objects
local farmLocation = Vector3.new(100, 5, 100) -- Replace with actual farming location
local isAutoFarming = false
local duplicationCount = 50 -- Configurable duplication amount
local autoFarmConnection = nil

-- Function to get the held (equipped) tool
local function getHeldTool()
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil -- No held tool found
end

-- Optimized duplication: Duplicate the held item if available
local function duplicateItem()
    local tool = getHeldTool()
    if tool then
        for _ = 1, duplicationCount do
            local clone = tool:Clone()
            clone.Parent = backpack -- Place clones in backpack
            task.wait() -- Yield briefly per clone to prevent freezing
        end
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Duplication Error",
            Text = "No held tool found to duplicate.",
            Duration = 5
        })
    end
end

-- Optimized auto-farm: Use Heartbeat for less frequent updates
local function autoFarm()
    if isAutoFarming and character and humanoid.Health > 0 then
        -- Smooth movement towards farm location using TweenService
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local goal = {CFrame = CFrame.new(farmLocation)}
        local tween = TweenService:Create(character.PrimaryPart, tweenInfo, goal)
        tween:Play()
        tween.Completed:Wait()
        
        -- Add your resource collection logic here
        wait(1) -- Cooldown
    end
end

-- Toggle auto-farming
local function toggleAutoFarm()
    isAutoFarming = not isAutoFarming
    if isAutoFarming then
        if autoFarmConnection then
            autoFarmConnection:Disconnect()
        end
        autoFarmConnection = RunService.Heartbeat:Connect(autoFarm)
    else
        if autoFarmConnection then
            autoFarmConnection:Disconnect()
            autoFarmConnection = nil
        end
    end
end

-- Create a polished GUI menu
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OptimizationMenu"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 200)
    frame.Position = UDim2.new(0.5, -125, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = frame

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
    }
    uiGradient.Parent = frame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 2
    uiStroke.Color = Color3.fromRGB(100, 100, 100)
    uiStroke.Transparency = 0.5
    uiStroke.Parent = frame

    -- Title label
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "Optimization Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = frame

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Text = "X"
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.Gotham
    closeButton.TextSize = 18
    closeButton.Parent = frame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Duplicate button
    local duplicateButton = Instance.new("TextButton")
    duplicateButton.Size = UDim2.new(1, -20, 0, 50)
    duplicateButton.Position = UDim2.new(0, 10, 0, 50)
    duplicateButton.Text = "Duplicate Held Item (x50)"
    duplicateButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    duplicateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    duplicateButton.Font = Enum.Font.GothamSemibold
    duplicateButton.TextSize = 18
    duplicateButton.Parent = frame

    local duplicateCorner = Instance.new("UICorner")
    duplicateCorner.CornerRadius = UDim.new(0, 8)
    duplicateCorner.Parent = duplicateButton

    local duplicateGradient = Instance.new("UIGradient")
    duplicateGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 149, 237)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 130, 180))
    }
    duplicateGradient.Parent = duplicateButton

    duplicateButton.MouseButton1Click:Connect(duplicateItem)

    -- Auto-farm toggle button
    local autoFarmButton = Instance.new("TextButton")
    autoFarmButton.Size = UDim2.new(1, -20, 0, 50)
    autoFarmButton.Position = UDim2.new(0, 10, 0, 110)
    autoFarmButton.Text = "Toggle Auto-Farm"
    autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
    autoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoFarmButton.Font = Enum.Font.GothamSemibold
    autoFarmButton.TextSize = 18
    autoFarmButton.Parent = frame

    local autoFarmCorner = Instance.new("UICorner")
    autoFarmCorner.CornerRadius = UDim.new(0, 8)
    autoFarmCorner.Parent = autoFarmButton

    local autoFarmGradient = Instance.new("UIGradient")
    autoFarmGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 238, 144)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 179, 113))
    }
    autoFarmGradient.Parent = autoFarmButton

    autoFarmButton.MouseButton1Click:Connect(function()
        toggleAutoFarm()
        autoFarmButton.Text = isAutoFarming and "Stop Auto-Farm" or "Start Auto-Farm"
        autoFarmButton.BackgroundColor3 = isAutoFarming and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 179, 113)
        autoFarmGradient.Color = isAutoFarming and ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 99, 71)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 50))
        } or ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 238, 144)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 179, 113))
        }
    end)

    -- Make GUI draggable
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Notification on load
    StarterGui:SetCore("SendNotification", {
        Title = "Menu Loaded",
        Text = "Polished Optimization Menu is now available.",
        Duration = 5
    })
end

-- Initialize GUI on script load
createGui()

-- Handle character respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    if isAutoFarming then
        toggleAutoFarm() -- Restart if active
        toggleAutoFarm()
    end
end)
