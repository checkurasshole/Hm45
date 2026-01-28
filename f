local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisibilityTracker"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(1, -210, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
titleBar.BorderSizePixel = 0
titleBar.Text = "Visibility Tracker"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 12
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -8, 1, -34)
scrollFrame.Position = UDim2.new(0, 4, 0, 32)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
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

local function getAllChildren(instance)
    local children = {}
    
    for _, child in pairs(instance:GetChildren()) do
        table.insert(children, {
            instance = child,
            path = getFullPath(child)
        })
    end
    
    return children
end

local function createChildEntry(parent, childData)
    local childFrame = Instance.new("Frame")
    childFrame.Size = UDim2.new(1, -8, 0, 50)
    childFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    childFrame.BorderSizePixel = 0
    childFrame.Parent = parent
    
    local childCorner = Instance.new("UICorner")
    childCorner.CornerRadius = UDim.new(0, 3)
    childCorner.Parent = childFrame
    
    local childLabel = Instance.new("TextLabel")
    childLabel.Size = UDim2.new(1, -4, 1, -26)
    childLabel.Position = UDim2.new(0, 2, 0, 2)
    childLabel.BackgroundTransparency = 1
    childLabel.Text = childData.path
    childLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    childLabel.Font = Enum.Font.Gotham
    childLabel.TextSize = 8
    childLabel.TextXAlignment = Enum.TextXAlignment.Left
    childLabel.TextYAlignment = Enum.TextYAlignment.Top
    childLabel.TextWrapped = true
    childLabel.Parent = childFrame
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, -6, 0, 20)
    copyBtn.Position = UDim2.new(0, 3, 1, -22)
    copyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 190)
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = "Copy"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 9
    copyBtn.Parent = childFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 3)
    btnCorner.Parent = copyBtn
    
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(childData.path)
        copyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        copyBtn.Text = "Copied!"
        task.wait(0.6)
        copyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 190)
        copyBtn.Text = "Copy"
    end)
    
    return childFrame
end

local function addPathToGui(path, instance)
    if pathElements[path] then return end
    
    local children = getAllChildren(instance)
    
    local pathFrame = Instance.new("Frame")
    pathFrame.Size = UDim2.new(1, -4, 0, 90)
    pathFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pathFrame.BorderSizePixel = 0
    pathFrame.Parent = scrollFrame
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 5)
    frameCorner.Parent = pathFrame
    
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -4, 0, 35)
    pathLabel.Position = UDim2.new(0, 2, 0, 2)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = path
    pathLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    pathLabel.Font = Enum.Font.GothamBold
    pathLabel.TextSize = 9
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextYAlignment = Enum.TextYAlignment.Top
    pathLabel.TextWrapped = true
    pathLabel.Parent = pathFrame
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -8, 0, 22)
    buttonContainer.Position = UDim2.new(0, 4, 0, 38)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = pathFrame
    
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0.48, 0, 1, 0)
    copyButton.Position = UDim2.new(0, 0, 0, 0)
    copyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    copyButton.BorderSizePixel = 0
    copyButton.Text = "Copy"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.Font = Enum.Font.GothamBold
    copyButton.TextSize = 10
    copyButton.Parent = buttonContainer
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 4)
    copyCorner.Parent = copyButton
    
    local expandButton = Instance.new("TextButton")
    expandButton.Size = UDim2.new(0.48, 0, 1, 0)
    expandButton.Position = UDim2.new(0.52, 0, 0, 0)
    expandButton.BackgroundColor3 = Color3.fromRGB(180, 100, 60)
    expandButton.BorderSizePixel = 0
    expandButton.Text = "Children (" .. #children .. ")"
    expandButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    expandButton.Font = Enum.Font.GothamBold
    expandButton.TextSize = 10
    expandButton.Parent = buttonContainer
    
    local expandCorner = Instance.new("UICorner")
    expandCorner.CornerRadius = UDim.new(0, 4)
    expandCorner.Parent = expandButton
    
    local childrenContainer = Instance.new("Frame")
    childrenContainer.Size = UDim2.new(1, -8, 0, 0)
    childrenContainer.Position = UDim2.new(0, 4, 0, 65)
    childrenContainer.BackgroundTransparency = 1
    childrenContainer.Visible = false
    childrenContainer.Parent = pathFrame
    
    local childLayout = Instance.new("UIListLayout")
    childLayout.SortOrder = Enum.SortOrder.LayoutOrder
    childLayout.Padding = UDim.new(0, 3)
    childLayout.Parent = childrenContainer
    
    local copyAllButton = Instance.new("TextButton")
    copyAllButton.Size = UDim2.new(1, 0, 0, 24)
    copyAllButton.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
    copyAllButton.BorderSizePixel = 0
    copyAllButton.Text = "Copy All Children Paths"
    copyAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyAllButton.Font = Enum.Font.GothamBold
    copyAllButton.TextSize = 10
    copyAllButton.Visible = false
    copyAllButton.Parent = childrenContainer
    
    local copyAllCorner = Instance.new("UICorner")
    copyAllCorner.CornerRadius = UDim.new(0, 4)
    copyAllCorner.Parent = copyAllButton
    
    for _, childData in ipairs(children) do
        createChildEntry(childrenContainer, childData)
    end
    
    local expanded = false
    
    expandButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        childrenContainer.Visible = expanded
        copyAllButton.Visible = expanded
        
        if expanded then
            local contentHeight = childLayout.AbsoluteContentSize.Y + 6
            childrenContainer.Size = UDim2.new(1, -8, 0, contentHeight)
            pathFrame.Size = UDim2.new(1, -4, 0, 90 + contentHeight)
            expandButton.BackgroundColor3 = Color3.fromRGB(220, 120, 70)
        else
            childrenContainer.Size = UDim2.new(1, -8, 0, 0)
            pathFrame.Size = UDim2.new(1, -4, 0, 90)
            expandButton.BackgroundColor3 = Color3.fromRGB(180, 100, 60)
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
    end)
    
    copyButton.MouseButton1Click:Connect(function()
        setclipboard(path)
        copyButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        copyButton.Text = "Copied!"
        task.wait(0.8)
        copyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        copyButton.Text = "Copy"
    end)
    
    copyAllButton.MouseButton1Click:Connect(function()
        local allPaths = {}
        for _, childData in ipairs(children) do
            table.insert(allPaths, childData.path)
        end
        setclipboard(table.concat(allPaths, "\n"))
        copyAllButton.BackgroundColor3 = Color3.fromRGB(70, 220, 70)
        copyAllButton.Text = "All Copied!"
        task.wait(0.8)
        copyAllButton.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
        copyAllButton.Text = "Copy All Children Paths"
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
            addPathToGui(path, instance)
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