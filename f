local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Visibility Tracker",
    Footer = "v1.0",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("Tracker", "eye"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local player = game:GetService("Players").LocalPlayer
local targetPaths = {
    "EmptyBagIcon",
    "CurrencyFrame",
    "Full",
    "FullBagIcon"
}

local basePath = player.PlayerGui.MainGUI.Lobby.Dock.CoinBags.Container.Coin
local trackedObjects = {}
local pathLabels = {}

local MainGroup = Tabs.Main:AddLeftGroupbox("Monitored Paths", "folder")

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

local function formatValue(value)
    if type(value) == "boolean" then
        return tostring(value)
    elseif type(value) == "string" then
        return value
    elseif type(value) == "number" then
        return tostring(value)
    elseif typeof(value) == "Color3" then
        return string.format("RGB(%d, %d, %d)", value.R * 255, value.G * 255, value.B * 255)
    else
        return tostring(value)
    end
end

local function updatePathLabel(name, propertyName, value, isVisible)
    local key = name .. "_" .. propertyName
    
    if pathLabels[key] then
        local statusText = isVisible and "[VISIBLE]" or "[HIDDEN]"
        local valueText = propertyName .. ": " .. formatValue(value)
        pathLabels[key]:SetText(statusText .. " " .. valueText)
    end
end

local function monitorPath(name, instance)
    if not instance then return end
    
    local fullPath = getFullPath(instance)
    
    MainGroup:AddLabel(name .. " Path", true, name .. "_PathLabel")
    Options[name .. "_PathLabel"]:SetText(fullPath)
    
    MainGroup:AddButton({
        Text = "Copy " .. name .. " Path",
        Func = function()
            setclipboard(fullPath)
            Library:Notify({
                Title = "Copied!",
                Description = "Path copied to clipboard",
                Time = 2,
            })
        end,
    })
    
    if instance:IsA("GuiObject") then
        local visLabel = MainGroup:AddLabel(name .. " Visibility", true, name .. "_Visibility")
        pathLabels[name .. "_Visible"] = visLabel
        
        local initialVis = instance.Visible
        updatePathLabel(name, "Visible", initialVis, initialVis)
        
        instance:GetPropertyChangedSignal("Visible"):Connect(function()
            updatePathLabel(name, "Visible", instance.Visible, instance.Visible)
            
            local status = instance.Visible and "VISIBLE" or "HIDDEN"
            Library:Notify({
                Title = name,
                Description = "Status: " .. status,
                Time = 3,
            })
        end)
    end
    
    if instance:IsA("TextLabel") or instance:IsA("TextBox") or instance:IsA("TextButton") then
        local textLabel = MainGroup:AddLabel(name .. " Text", true, name .. "_Text")
        pathLabels[name .. "_Text"] = textLabel
        updatePathLabel(name, "Text", instance.Text, instance.Visible)
        
        instance:GetPropertyChangedSignal("Text"):Connect(function()
            updatePathLabel(name, "Text", instance.Text, instance.Visible)
            
            Library:Notify({
                Title = name .. " - Text Changed",
                Description = "New: " .. instance.Text,
                Time = 3,
            })
        end)
    end
    
    if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
        local imageLabel = MainGroup:AddLabel(name .. " Image", true, name .. "_Image")
        pathLabels[name .. "_Image"] = imageLabel
        updatePathLabel(name, "Image", instance.Image, instance.Visible)
        
        instance:GetPropertyChangedSignal("Image"):Connect(function()
            updatePathLabel(name, "Image", instance.Image, instance.Visible)
            
            Library:Notify({
                Title = name .. " - Image Changed",
                Description = "Image updated",
                Time = 3,
            })
        end)
    end
    
    for attrName, attrValue in pairs(instance:GetAttributes()) do
        local attrLabel = MainGroup:AddLabel(name .. " [" .. attrName .. "]", true, name .. "_" .. attrName)
        pathLabels[name .. "_" .. attrName] = attrLabel
        updatePathLabel(name, attrName, attrValue, instance.Visible)
        
        instance:GetAttributeChangedSignal(attrName):Connect(function()
            local newValue = instance:GetAttribute(attrName)
            updatePathLabel(name, attrName, newValue, instance.Visible)
            
            Library:Notify({
                Title = name .. " - Attribute Changed",
                Description = attrName .. ": " .. formatValue(newValue),
                Time = 3,
            })
        end)
    end
    
    MainGroup:AddDivider()
end

for _, pathName in ipairs(targetPaths) do
    local instance = basePath:FindFirstChild(pathName)
    if instance then
        monitorPath(pathName, instance)
    else
        MainGroup:AddLabel(pathName .. " - NOT FOUND", true)
        MainGroup:AddDivider()
    end
end

local InfoGroup = Tabs.Main:AddRightGroupbox("Information", "info")
InfoGroup:AddLabel("Monitoring 4 specific paths", true)
InfoGroup:AddLabel("Updates show in real-time", true)
InfoGroup:AddLabel("Notifications on changes", true)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { 
    Default = "RightShift", 
    NoUI = true, 
    Text = "Menu keybind" 
})

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("VisibilityTracker")
SaveManager:SetFolder("VisibilityTracker/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:OnUnload(function()
    print("Visibility Tracker Unloaded")
end)