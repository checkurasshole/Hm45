local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PathScanner"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderSizePixel = 0
titleBar.Text = "Number Path Scanner"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 16
titleBar.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

local trackedPaths = {}
local pathElements = {}

local function getFullPath(instance)
    local path = instance.Name
    local parent = instance.Parent
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    return "game:GetService(\"" .. instance:GetFullName():match("^([^.]+)") .. "\")." .. instance:GetFullName():match("%.(.+)")
end

local function isNumber(value)
    return type(value) == "number" or (type(value) == "string" and tonumber(value) ~= nil)
end

local function addPathToGui(path)
    if pathElements[path] then return end
    
    local pathFrame = Instance.new("Frame")
    pathFrame.Size = UDim2.new(1, -10, 0, 50)
    pathFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    pathFrame.BorderSizePixel = 0
    pathFrame.Parent = scrollFrame
    
    local pathLabel = Instance.new("TextLabel")
    pathLabel.Size = UDim2.new(1, -60, 1, 0)
    pathLabel.Position = UDim2.new(0, 5, 0, 0)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = path
    pathLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    pathLabel.Font = Enum.Font.SourceSans
    pathLabel.TextSize = 12
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextWrapped = true
    pathLabel.Parent = pathFrame
    
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0, 50, 0, 30)
    copyButton.Position = UDim2.new(1, -55, 0.5, -15)
    copyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    copyButton.BorderSizePixel = 0
    copyButton.Text = "Copy"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.Font = Enum.Font.SourceSansBold
    copyButton.TextSize = 12
    copyButton.Parent = pathFrame
    
    copyButton.MouseButton1Click:Connect(function()
        setclipboard(path)
        copyButton.Text = "Copied!"
        wait(1)
        copyButton.Text = "Copy"
    end)
    
    pathElements[path] = pathFrame
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

local function scanInstance(instance)
    if instance:IsA("TextLabel") or instance:IsA("TextBox") or instance:IsA("TextButton") then
        local fullPath = getFullPath(instance)
        
        if not trackedPaths[fullPath] then
            trackedPaths[fullPath] = {
                instance = instance,
                lastValue = instance.Text,
                propertyName = "Text"
            }
        end
    end
    
    for _, attribute in pairs(instance:GetAttributes()) do
        if isNumber(attribute) then
            local fullPath = getFullPath(instance)
            local attrName = _
            
            if not trackedPaths[fullPath .. "." .. attrName] then
                trackedPaths[fullPath .. "." .. attrName] = {
                    instance = instance,
                    lastValue = attribute,
                    propertyName = attrName,
                    isAttribute = true
                }
            end
        end
    end
    
    for _, child in pairs(instance:GetChildren()) do
        scanInstance(child)
    end
end

local function startMonitoring()
    for path, data in pairs(trackedPaths) do
        task.spawn(function()
            while true do
                wait(0.1)
                
                if not data.instance or not data.instance.Parent then
                    trackedPaths[path] = nil
                    if pathElements[path] then
                        pathElements[path]:Destroy()
                        pathElements[path] = nil
                    end
                    break
                end
                
                local currentValue
                if data.isAttribute then
                    currentValue = data.instance:GetAttribute(data.propertyName)
                else
                    currentValue = data.instance[data.propertyName]
                end
                
                if isNumber(currentValue) and currentValue ~= data.lastValue then
                    addPathToGui(path)
                    data.lastValue = currentValue
                end
            end
        end)
    end
end

scanInstance(game)

game.DescendantAdded:Connect(function(descendant)
    scanInstance(descendant)
end)

startMonitoring()

local dragging = false
local dragInput, mousePos, framePos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)