local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Get your coin object
local coinsObj = ReplicatedStorage:WaitForChild("MainGUI")
	:WaitForChild("Lobby")
	:WaitForChild("Dock")
	:WaitForChild("CoinBags")
	:WaitForChild("Container")
	:WaitForChild("Egg")
	:WaitForChild("CurrencyFrame")
	:WaitForChild("Icon")
	:WaitForChild("Coins")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileCoinCounter"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local coinLabel = Instance.new("TextLabel")
coinLabel.Size = UDim2.new(0, 180, 0, 50)
coinLabel.Position = UDim2.new(0, 20, 0, 100)
coinLabel.BackgroundColor3 = Color3.fromRGB(25,25,25)
coinLabel.BorderSizePixel = 0
coinLabel.TextColor3 = Color3.new(1,1,1)
coinLabel.TextScaled = true
coinLabel.Font = Enum.Font.GothamBold
coinLabel.Text = "COINS: 0"
coinLabel.Parent = screenGui

-- Drag support
local dragging, dragStart, startPos
coinLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = coinLabel.Position
	end
end)
coinLabel.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		coinLabel.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Function to get numeric coin amount
local function getCoinAmount(obj)
	local text = obj.Text or ""
	local num = tonumber(text:gsub(",", ""))
	if num then return num end
	return 0
end

-- Heartbeat loop for live updates
RunService.Heartbeat:Connect(function()
	local amount = getCoinAmount(coinsObj)
	coinLabel.Text = "COINS: "..amount
end)
