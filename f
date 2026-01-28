local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisibilityTracker"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 250)
mainFrame.Position = UDim2.new(1, -190, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 25)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleBar.BorderSizePixel = 0
titleBar.Text = "Visibility Tracker"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 11
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -8, 1, -30)
scrollFrame.Position = UDim2.new(0, 4, 0, 28)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = scrollFrame

local pathElements = {}
local trackedObjects = {}

local function getFullPath(instance)
    local parts = {}
    local current = instance
    
    while current and current ~= game do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end
    
    if #parts > 0 then
        local service = instance:GetFullName():match("^([^.]+)")
        return 'game:GetService("' .. service .. '").' .. table.concat(parts, ".", 2)
    end
    
    return instance:GetFullName()
end

local function addPathToGui(path)
    if pathElements[path] then return end
    
    local pathFrame = Instance.new("Frame")
    pathFrame.Size = UDim2.new(1, -4, 0, 60)
    pathFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    pathFrame.BorderSizePixel = 0
    pathFrame.Parent = scrollFrame
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 4)
    frameCorner.Parent = pathFrame
    
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -4, 1, -28)
    pathLabel.Position = UDim2.new(0, 2, 0, 2)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = path
    pathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    pathLabel.Font = Enum.Font.Gotham
    pathLabel.TextSize = 9
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextYAlignment = Enum.TextYAlignment.Top
    pathLabel.TextWrapped = true
    pathLabel.Parent = pathFrame
    
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(1, -8, 0, 22)
    copyButton.Position = UDim2.new(0, 4, 1, -24)
    copyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    copyButton.BorderSizePixel = 0
    copyButton.Text = "Copy"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.Font = Enum.Font.GothamBold
    copyButton.TextSize = 10
    copyButton.Parent = pathFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = copyButton
    
    copyButton.MouseButton1Click:Connect(function()
        setclipboard(path)
        copyButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        copyButton.Text = "Copied!"
        task.wait(0.8)
        copyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        copyButton.Text = "Copy"
    end)
    
    pathElements[path] = pathFrame
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
end

local function isGuiObject(instance)
    return instance:IsA("GuiObject")
end

local function monitorVisibility(instance)
    if not isGuiObject(instance) then return end
    
    local path = getFullPath(instance)
    if trackedObjects[path] then return end
    
    trackedObjects[path] = {
        instance = instance,
        wasVisible = instance.Visible
    }
    
    instance:GetPropertyChangedSignal("Visible"):Connect(function()
        if not instance or not instance.Parent then
            trackedObjects[path] = nil
            return
        end
        
        local data = trackedObjects[path]
        if not data then return end
        
        if not data.wasVisible and instance.Visible then
            addPathToGui(path)
        end
        
        data.wasVisible = instance.Visible
    end)
end

local function scanInstance(instance)
    monitorVisibility(instance)
    
    for _, child in pairs(instance:GetChildren()) do
        scanInstance(child)
    end
end

scanInstance(game)

game.DescendantAdded:Connect(function(descendant)
    task.wait()
    monitorVisibility(descendant)
end)

local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)