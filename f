local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Clipboard
local function copyToClipboard(text)
	if setclipboard then
		setclipboard(text)
	elseif toclipboard then
		toclipboard(text)
	else
		warn("❌ Executor does not support clipboard.")
	end
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LIVE_UI_CHANGE_FINDER"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 300)
frame.Position = UDim2.new(0.5, -225, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "LIVE UI CHANGE FINDER (ONLY UPDATING TEXT)"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -10, 1, -50)
list.Position = UDim2.new(0, 5, 0, 45)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.2
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list

local function makePath(obj)
	local path = obj.Name
	local parent = obj.Parent
	while parent and parent ~= game do
		path = parent.Name .. "." .. path
		parent = parent.Parent
	end
	return path
end

local tracked = {}

local function addEntry(obj, oldText, newText)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 45)
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	btn.Font = Enum.Font.Gotham
	btn.TextWrapped = true

	local fullPath = makePath(obj)
	btn.Text = "UPDATED TEXT:\n"..oldText.." ➜ "..newText.."\nCLICK TO COPY PATH"

	btn.MouseButton1Click:Connect(function()
		copyToClipboard(fullPath)
		btn.Text = "✅ COPIED:\n"..fullPath
	end)

	btn.Parent = list
	list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end

-- Watch for text changes
for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
	if gui:IsA("TextLabel") or gui:IsA("TextButton") then
		tracked[gui] = gui.Text

		gui:GetPropertyChangedSignal("Text"):Connect(function()
			local old = tracked[gui]
			local new = gui.Text
			tracked[gui] = new

			-- Only show real numeric changes
			if old ~= new then
				if tonumber((old or ""):gsub(",", "")) or tonumber((new or ""):gsub(",", "")) then
					addEntry(gui, tostring(old), tostring(new))
				end
			end
		end)
	end
end

print("[LIVE UI CHANGE FINDER] Watching for UI that updates (like coins).")
