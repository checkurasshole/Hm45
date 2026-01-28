-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

-- Objects to track
local trackedObjects = {
    guiParent.MainGUI.Lobby.Dock.CoinBags.Container.Coin.EmptyBagIcon,
    guiParent.MainGUI.Lobby.Dock.CoinBags.Container.Coin.CurrencyFrame,
    guiParent.MainGUI.Lobby.Dock.CoinBags.Container.Coin.Full,
    guiParent.MainGUI.Lobby.Dock.CoinBags.Container.Coin.FullBagIcon,
}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoinTrackerGUI"
ScreenGui.Parent = guiParent
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 180)
Frame.Position = UDim2.new(0.7, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- UIListLayout for labels
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.Parent = Frame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.Parent = Frame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Make Frame draggable (works on mobile)
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Labels for tracked objects
local objectLabels = {}

for _, obj in ipairs(trackedObjects) do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 30)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = "" -- start empty
    label.Parent = Frame
    objectLabels[obj] = label
end

-- Function to check if string is a number
local function isNumber(str)
    if tonumber(str) then
        return true
    else
        return false
    end
end

-- Update function
local function updateLabels()
    for obj, label in pairs(objectLabels) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local text = obj.Text or ""
            if isNumber(text) then
                if label.Text ~= text then
                    label.Text = text
                end
            else
                label.Text = "" -- ignore non-numbers like "FULL"
            end
        end
    end
end

-- RenderStepped loop
RunService.RenderStepped:Connect(updateLabels)
