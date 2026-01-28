local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Paths to coin objects
local coinsData = {
    Egg = {
        obj = ReplicatedStorage:WaitForChild("MainGUI")
            :WaitForChild("Lobby")
            :WaitForChild("Dock")
            :WaitForChild("CoinBags")
            :WaitForChild("Container")
            :WaitForChild("Egg")
            :WaitForChild("CurrencyFrame")
            :WaitForChild("Icon")
            :WaitForChild("Coins")
    },
    SnowToken = {
        obj = ReplicatedStorage:WaitForChild("MainGUI")
            :WaitForChild("Lobby")
            :WaitForChild("Dock")
            :WaitForChild("CoinBags")
            :WaitForChild("Container")
            :WaitForChild("SnowToken")
            :WaitForChild("CurrencyFrame")
            :WaitForChild("Icon")
    }
}

-- GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "MobileCoinTracker"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 260, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "COIN TRACKER"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local function createLabel(parent, yPos)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1,0,0,40)
    lbl.Position = UDim2.new(0,0,0,yPos)
    lbl.BackgroundColor3 = Color3.fromRGB(40,40,40)
    lbl.BorderSizePixel = 0
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.Gotham
    return lbl
end

local eggLabel = createLabel(frame, 25)
local snowLabel = createLabel(frame, 70)

-- Drag
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Helper to get number from text
local function getCoinAmount(obj)
	if obj:IsA("TextLabel") or obj:IsA("TextButton") then
		local num = tonumber((obj.Text or ""):gsub(",", ""))
		return num or 0
	end
	return 0
end

-- Heartbeat loop
RunService.Heartbeat:Connect(function()
    -- Egg
    local eggObj = coinsData.Egg.obj
    local eggVisible = eggObj.Parent.Visible
    local eggAmount = getCoinAmount(eggObj)
    eggLabel.Text = ("EGG: %d  |  %s"):format(eggAmount, eggVisible and "VISIBLE" or "HIDDEN")
    eggLabel.BackgroundColor3 = eggVisible and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
    
    -- SnowToken
    local snowObj = coinsData.SnowToken.obj
    local snowVisible = snowObj.Parent.Visible
    local snowAmount = getCoinAmount(snowObj)
    snowLabel.Text = ("SNOW: %d  |  %s"):format(snowAmount, snowVisible and "VISIBLE" or "HIDDEN")
    snowLabel.BackgroundColor3 = snowVisible and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
end)
