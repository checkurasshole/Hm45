local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Clipboard
local function copyToClipboard(text)
	if setclipboard then
		setclipboard(text)
	elseif toclipboard then
		toclipboard(text)
	else
		warn("❌ No clipboard support.")
	end
end

-- GUI (SMALL + DRAGGABLE)
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "COIN_SOURCE_FINDER"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 320, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "COIN CHANGE DETECTOR"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local list = Instance.new("ScrollingFrame", frame)
list.Position = UDim2.new(0, 5, 0, 35)
list.Size = UDim2.new(1, -10, 1, -40)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.3

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 6)

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

local function makePath(obj)
	local path = obj.Name
	local p = obj.Parent
	while p and p ~= game do
		path = p.Name .. "." .. path
		p = p.Parent
	end
	return path
end

local function addEntry(obj, old, new)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	btn.Font = Enum.Font.Gotham
	btn.TextWrapped = true

	local path = makePath(obj)
	btn.Text = tostring(obj.ClassName)..": "..tostring(old).." ➜ "..tostring(new).."\nTAP TO COPY"

	btn.MouseButton1Click:Connect(function()
		copyToClipboard(path)
		btn.Text = "✅ COPIED:\n"..path
	end)

	btn.Parent = list
	task.wait()
	list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end

-- 1) Watch TEXT changes
for _, d in ipairs(player.PlayerGui:GetDescendants()) do
	if d:IsA("TextLabel") or d:IsA("TextButton") then
		local last = d.Text
		d:GetPropertyChangedSignal("Text"):Connect(function()
			if d.Text ~= last then
				if tonumber((d.Text or ""):gsub(",", "")) or tonumber((last or ""):gsub(",", "")) then
					addEntry(d, last, d.Text)
				end
				last = d.Text
			end
		end)
	end
end

-- 2) Watch NumberValue / IntValue (COMMON FOR MOBILE)
for _, d in ipairs(player:GetDescendants()) do
	if d:IsA("NumberValue") or d:IsA("IntValue") then
		local last = d.Value
		d.Changed:Connect(function()
			if d.Value ~= last then
				addEntry(d, last, d.Value)
				last = d.Value
			end
		end)
	end
end

-- 3) Watch Attributes (HIDDEN COIN STORAGE)
local function watchAttributes(obj)
	local lastAttrs = obj:GetAttributes()
	obj.AttributeChanged:Connect(function(attr)
		local new = obj:GetAttribute(attr)
		local old = lastAttrs[attr]
		if new ~= old then
			if typeof(new) == "number" then
				addEntry(obj, old, new)
			end
			lastAttrs[attr] = new
		end
	end)
end

for _, d in ipairs(player:GetDescendants()) do
	watchAttributes(d)
end

print("[COIN SOURCE FINDER] Collect coins now. Real source WILL show.")
