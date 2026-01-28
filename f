local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "DynamicCoinTracker"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "DYNAMIC COIN TRACKER"
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

-- Drag support
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

-- Helper to make full path
local function makePath(obj)
	local path = obj.Name
	local parent = obj.Parent
	while parent and parent ~= game do
		path = parent.Name .. "." .. path
		parent = parent.Parent
	end
	return path
end

-- Helper to add entry in GUI
local function addEntry(name)
	local btn = Instance.new("TextLabel")
	btn.Size = UDim2.new(1,-6,0,35)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	btn.Font = Enum.Font.Gotham
	btn.TextWrapped = true
	btn.Text = name
	btn.Parent = list
	list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
	return btn
end

-- Track objects dynamically
local tracked = {}

-- Recursive scan function
local function scanCoins(parent)
	for _, obj in ipairs(parent:GetDescendants()) do
		if tracked[obj] then continue end

		local oldValue

		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			oldValue = obj.Text
			obj:GetPropertyChangedSignal("Text"):Connect(function()
				if obj.Text ~= oldValue then
					if tonumber((obj.Text or ""):gsub(",","")) then
						local btn = tracked[obj] or addEntry(makePath(obj))
						btn.Text = makePath(obj).." | "..oldValue.." → "..obj.Text.." | VISIBLE"
						tracked[obj] = btn
					end
					oldValue = obj.Text
				end
			end)
		elseif obj:IsA("NumberValue") or obj:IsA("IntValue") then
			oldValue = obj.Value
			obj.Changed:Connect(function()
				if obj.Value ~= oldValue then
					local btn = tracked[obj] or addEntry(makePath(obj))
					btn.Text = makePath(obj).." | "..oldValue.." → "..obj.Value.." | VISIBLE"
					tracked[obj] = btn
					oldValue = obj.Value
				end
			end)
		else
			-- watch attributes
			local lastAttrs = obj:GetAttributes()
			obj.AttributeChanged:Connect(function(attr)
				local new = obj:GetAttribute(attr)
				local old = lastAttrs[attr]
				if new ~= old and typeof(new) == "number" then
					local btn = tracked[obj] or addEntry(makePath(obj))
					btn.Text = makePath(obj).." | "..tostring(old).." → "..tostring(new).." | VISIBLE"
					tracked[obj] = btn
					lastAttrs[attr] = new
				end
			end)
		end
	end
end

-- Initial scan
scanCoins(ReplicatedStorage:WaitForChild("MainGUI"))

print("[DYNAMIC COIN TRACKER] Scanning. Collect coins to see them listed.")
