local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

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

local colors = {
    bg = Color3.fromRGB(22, 22, 27),
    header = Color3.fromRGB(32, 32, 40),
    accent = Color3.fromRGB(88, 166, 255),
    text = Color3.fromRGB(235, 235, 235),
    textSec = Color3.fromRGB(160, 160, 160),
    toggleOn = Color3.fromRGB(88, 166, 255),
    toggleOff = Color3.fromRGB(60, 60, 65),
    divider = Color3.fromRGB(40, 40, 48)
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
    frame.Size = UDim2.new(0, 220, 0, 180)
    frame.Position = UDim2.new(0.5, -110, 0.5, -90)
    frame.BackgroundColor3 = colors.bg
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ClipsDescendants = true
    frame.Parent = screenGui
    
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://4616264502"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 0
    shadow.Parent = frame
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = colors.header
    header.BorderSizePixel = 0
    header.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Text = "  ESP"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = colors.text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.AutoButtonColor = false
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, 32)
    divider.BackgroundColor3 = colors.divider
    divider.BorderSizePixel = 0
    divider.Parent = frame
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 1, -48)
    content.Position = UDim2.new(0, 8, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = frame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content
    
    local function createToggle(label, featureKey)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 28)
        container.BackgroundTransparency = 1
        container.LayoutOrder = #content:GetChildren()
        container.Parent = content
        
        local labelText = Instance.new("TextLabel")
        labelText.Text = label
        labelText.Size = UDim2.new(1, -50, 1, 0)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.TextColor3 = colors.text
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 12
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Parent = container
        
        local toggle = Instance.new("Frame")
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -44, 0.5, -10)
        toggle.BackgroundColor3 = colors.toggleOff
        toggle.ClipsDescendants = true
        toggle.Parent = container
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0.5, 0)
        toggleCorner.Parent = toggle
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.Parent = toggle
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(0.5, 0)
        knobCorner.Parent = knob
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = toggle
        
        local enabled = Menu.features[featureKey]
        
        local function updateToggle(animate)
            local targetPos = enabled and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local targetColor = enabled and colors.toggleOn or colors.toggleOff
            
            if animate then
                TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = targetPos
                }):Play()
                TweenService:Create(toggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = targetColor
                }):Play()
            else
                knob.Position = targetPos
                toggle.BackgroundColor3 = targetColor
            end
        end
        
        updateToggle(false)
        
        btn.MouseButton1Click:Connect(function()
            enabled = not enabled
            Menu.features[featureKey] = enabled
            updateToggle(true)
        end)
        
        return container
    end
    
    createToggle("Box ESP", "box")
    createToggle("Name ESP", "name")
    createToggle("Health Bar", "health")
    
    local function onClose()
        self:toggle(false)
    end
    
    closeBtn.MouseButton1Click:Connect(onClose)
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            menuState.dragging = true
            local mouse = Players.LocalPlayer:GetMouse()
            menuState.dragOffset = Vector2.new(
                frame.AbsolutePosition.X - mouse.X,
                frame.AbsolutePosition.Y - mouse.Y
            )
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

function Menu:toggle(animate)
    if not menuState.frame then return end
    menuState.open = not menuState.open
    
    if menuState.open then
        menuState.frame.Visible = true
        menuState.frame.Size = UDim2.new(0, 0, 0, 0)
        if animate ~= false then
            TweenService:Create(menuState.frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 220, 0, 180)
            }):Play()
        else
            menuState.frame.Size = UDim2.new(0, 220, 0, 180)
        end
    else
        if animate ~= false then
            TweenService:Create(menuState.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.delay(0.2, function()
                if not menuState.open then
                    menuState.frame.Visible = false
                end
            end)
        else
            menuState.frame.Size = UDim2.new(0, 0, 0, 0)
            menuState.frame.Visible = false
        end
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
