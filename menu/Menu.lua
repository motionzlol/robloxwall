local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Menu = {}
Menu.features = {
    box = true,
    name = true,
    health = true
}

local menuState = {
    open = false,
    frame = nil
}

function Menu:createGUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPMenu"
    screenGui.IgnoreGuiInset = false
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "MenuFrame"
    frame.Size = UDim2.new(0, 180, 0, 140)
    frame.Position = UDim2.new(0.5, -90, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Text = "ESP Menu"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = title
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 2)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = frame
    
    menuState.frame = frame
    menuState.screenGui = screenGui
end

function Menu:addToggle(text, featureKey)
    if not menuState.frame then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -12, 0, 26)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #menuState.frame:GetChildren()
    container.Parent = menuState.frame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 16, 0, 16)
    checkbox.Position = UDim2.new(0, 6, 0.5, -8)
    checkbox.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    checkbox.AutoButtonColor = false
    checkbox.Text = ""
    checkbox.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 28, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local enabled = Menu.features[featureKey]
    checkbox.BackgroundColor3 = enabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(60, 60, 60)
    
    checkbox.MouseButton1Click:Connect(function()
        enabled = not enabled
        Menu.features[featureKey] = enabled
        checkbox.BackgroundColor3 = enabled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(60, 60, 60)
    end)
end

function Menu:toggle()
    if not menuState.frame then return end
    menuState.open = not menuState.open
    
    if menuState.open then
        menuState.frame.Visible = true
        menuState.frame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(menuState.frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 180, 0, 140)
        }):Play()
    else
        TweenService:Create(menuState.frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.delay(0.12, function()
            if not menuState.open then
                menuState.frame.Visible = false
            end
        end)
    end
end

function Menu:init()
    self:createGUI()
    self:addToggle("Box ESP", "box")
    self:addToggle("Name ESP", "name")
    self:addToggle("Health Bar", "health")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            self:toggle()
        end
    end)
end

Menu:init()
