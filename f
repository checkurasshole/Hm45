local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Base coin container
local coinContainer = player:WaitForChild("PlayerGui")
    :WaitForChild("MainGUI")
    :WaitForChild("Lobby")
    :WaitForChild("Dock")
    :WaitForChild("CoinBags")
    :WaitForChild("Container")
    :WaitForChild("Coin")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DynamicCoinTracker"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "COIN CHILD TRACKER"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local list = Instance.new("ScrollingFrame", frame)
list.Position = UDim2.new(0,5,0,30)
list.Size = UDim2.new(1,-10,1,-35)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.3
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,4)

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
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- Helper to get numeric value from TextLabel or NumberValue
local function getNumeric(obj)
	if obj:IsA("TextLabel") or obj:IsA("TextButton") then
		return tonumber((obj.Text or ""):gsub(",", "")) or 0
	elseif obj:IsA("NumberValue") or obj:IsA("IntValue") then
		return obj.Value
	end
	return nil
end

-- Track children
local tracked = {}
for _, child in ipairs(coinContainer:GetDescendants()) do
	local old = getNumeric(child)
	if old == nil then continue end
	tracked[child] = old
end

-- Heartbeat loop
RunService.Heartbeat:Connect(function()
	for child, old in pairs(tracked) do
		local val = getNumeric(child)
		if val ~= nil and val ~= old then
			local visible = child.Visible ~= false
			tracked[child] = val
			-- Update GUI entry
			local label = child:FindFirstChild("_TrackerLabel")
			if not label then
				label = Instance.new("TextLabel")
				label.Name = "_TrackerLabel"
				label.Size = UDim2.new(1,-6,0,30)
				label.BackgroundColor3 = Color3.fromRGB(40,40,40)
				label.BorderSizePixel = 0
				label.TextColor3 = Color3.new(1,1,1)
				label.TextScaled = true
				label.Font = Enum.Font.Gotham
				label.TextWrapped = true
				label.Parent = list
			end
			label.Text = ("%s | %d → %d | %s"):format(child.Name, old, val, visible and "VISIBLE" or "HIDDEN")
			label.BackgroundColor3 = visible and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
			list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
		end
	end
end)
