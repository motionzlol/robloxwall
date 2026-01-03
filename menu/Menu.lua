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
    dragging = false,
    dragOffset = Vector2.new(0, 0)
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
    frame.Size = UDim2.new(0, 180, 0, 130)
    frame.Position = UDim2.new(0.5, -90, 0.5, -65)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 28)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    header.BorderSizePixel = 0
    header.Parent = frame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Text = "ESP"
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 1, -36)
    content.Position = UDim2.new(0, 8, 0, 34)
    content.BackgroundTransparency = 1
    content.Parent = frame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content
    
    local function createToggle(label, featureKey)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 24)
        container.BackgroundTransparency = 1
        container.LayoutOrder = #content:GetChildren()
        container.Parent = content
        
        local labelText = Instance.new("TextLabel")
        labelText.Text = label
        labelText.Size = UDim2.new(1, -30, 1, 0)
        labelText.BackgroundTransparency = 1
        labelText.TextColor3 = Color3.fromRGB(210, 210, 210)
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 11
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 18, 0, 18)
        toggle.Position = UDim2.new(1, -20, 0.5, -9)
        toggle.BackgroundColor3 = Color3.fromRGB(70, 170, 70)
        toggle.Text = ""
        toggle.AutoButtonColor = false
        toggle.Parent = container
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggle
        
        local enabled = Menu.features[featureKey]
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(70, 170, 70) or Color3.fromRGB(60, 60, 65)
        
        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            Menu.features[featureKey] = enabled
            toggle.BackgroundColor3 = enabled and Color3.fromRGB(70, 170, 70) or Color3.fromRGB(60, 60, 65)
        end)
    end
    
    createToggle("Box", "box")
    createToggle("Name", "name")
    createToggle("Health", "health")
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            menuState.dragging = true
            local mouse = Players.LocalPlayer:GetMouse()
            menuState.dragOffset = Vector2.new(frame.AbsolutePosition.X - mouse.X, frame.AbsolutePosition.Y - mouse.Y)
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            menuState.dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if menuState.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = Players.LocalPlayer:GetMouse()
            frame.Position = UDim2.new(0, mouse.X + menuState.dragOffset.X, 0, mouse.Y + menuState.dragOffset.Y)
        end
    end)
    
    menuState.frame = frame
    menuState.screenGui = screenGui
end

function Menu:toggle()
    if not menuState.frame then return end
    menuState.open = not menuState.open
    
    if menuState.open then
        menuState.frame.Visible = true
        menuState.frame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(menuState.frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 180, 0, 130)
        }):Play()
    else
        TweenService:Create(menuState.frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.delay(0.1, function()
            if not menuState.open then
                menuState.frame.Visible = false
            end
        end)
    end
end

function Menu:init()
    self:createGUI()
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            self:toggle()
        end
    end)
end

Menu:init()

_G.Menu = Menu
