loadstring(game:HttpGet("https://raw.githubusercontent.com/motionzlol/robloxwall/refs/heads/master/menu/Menu.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local connections = {}

local colors = {
    enemy = Color3.fromRGB(255, 50, 50),
    ally = Color3.fromRGB(50, 255, 50),
    neutral = Color3.fromRGB(255, 255, 50),
    healthHigh = Color3.fromRGB(50, 255, 50),
    healthMed = Color3.fromRGB(255, 255, 50),
    healthLow = Color3.fromRGB(255, 50, 50)
}

local function getHealthColor(percent)
    if percent > 0.5 then
        return colors.healthHigh:Lerp(colors.healthMed, (1 - percent) * 2)
    else
        return colors.healthMed:Lerp(colors.healthLow, (0.5 - percent) * 2)
    end
end

local function createESP(player)
    if player == Players.LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local teamColor = player.Team and player.Team.Color or Color3.fromRGB(200, 200, 200)
    local fillColor = Color3.new(teamColor.R, teamColor.G, teamColor.B)
    fillColor = Color3.new(fillColor.R * 0.15, fillColor.G * 0.15, fillColor.B * 0.15)
    
    local nameTag = Drawing.new("Text")
    nameTag.Text = player.Name
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.new(0, 0, 0)
    nameTag.Font = 2
    
    local healthBarBg = Drawing.new("Line")
    local healthBar = Drawing.new("Line")
    local healthText = Drawing.new("Text")
    healthText.Size = 10
    healthText.Center = false
    healthText.Outline = true
    healthText.OutlineColor = Color3.new(0, 0, 0)
    healthText.Font = 2
    
    local box = Drawing.new("Quad")
    box.Thickness = 2
    box.Filled = false
    
    local boxFill = Drawing.new("Quad")
    boxFill.Thickness = 1
    boxFill.Filled = true
    boxFill.Transparency = 0.7
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Transparency = 0.6
    
    local head = Drawing.new("Circle")
    head.Thickness = 2
    head.NumSides = 16
    
    local function hideAll()
        nameTag.Visible = false
        box.Visible = false
        box.PointA = Vector2.new(-10000, -10000)
        box.PointB = Vector2.new(-10000, -10000)
        box.PointC = Vector2.new(-10000, -10000)
        box.PointD = Vector2.new(-10000, -10000)
        boxFill.Visible = false
        boxFill.PointA = Vector2.new(-10000, -10000)
        boxFill.PointB = Vector2.new(-10000, -10000)
        boxFill.PointC = Vector2.new(-10000, -10000)
        boxFill.PointD = Vector2.new(-10000, -10000)
        healthBar.Visible = false
        healthBarBg.Visible = false
        healthText.Visible = false
        tracer.Visible = false
        head.Visible = false
    end
    
    local function update()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not player or not player.Character then
                conn:Disconnect()
                nameTag:Remove()
                healthBar:Remove()
                healthBarBg:Remove()
                healthText:Remove()
                box:Remove()
                boxFill:Remove()
                tracer:Remove()
                head:Remove()
                return
            end
            
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local headPart = player.Character:FindFirstChild("Head")
            
            if not hrp or not humanoid then 
                hideAll()
                return 
            end
            
            local position, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if not onScreen then
                hideAll()
                return
            end
            
            local distance = position.Z
            
            if distance <= 0 then
                hideAll()
                return
            end
            
            local fovScale = (2 * Camera.ViewportSize.Y) / ((2 * distance * math.tan(math.rad(Camera.FieldOfView) * 0.5)) * 1.5)
            
            local width = math.round(3.5 * fovScale)
            local height = math.round(5.5 * fovScale)
            
            if width <= 0 or height <= 0 then
                hideAll()
                return
            end
            
            local center = Vector2.new(math.round(position.X - (width * 0.5)), math.round(position.Y - (height * 0.5)))
            
            local left = center.X
            local right = center.X + width
            local top = center.Y
            local bottom = center.Y + height
            
            local isEnemy = player.Neutral or (player.Team and player.Team ~= Players.LocalPlayer.Team)
            local displayColor = isEnemy and colors.enemy or (player.Team and Colors.ally or colors.neutral)
            displayColor = teamColor
            
            local barWidth = 3
            
            if _G.Menu and _G.Menu.features and _G.Menu.features.box then
                box.Color = displayColor
                box.PointA = Vector2.new(left, top)
                box.PointB = Vector2.new(right, top)
                box.PointC = Vector2.new(right, bottom)
                box.PointD = Vector2.new(left, bottom)
                box.Visible = true
                
                boxFill.Color = fillColor
                boxFill.PointA = Vector2.new(left, top)
                boxFill.PointB = Vector2.new(right, top)
                boxFill.PointC = Vector2.new(right, bottom)
                boxFill.PointD = Vector2.new(left, bottom)
                boxFill.Visible = true
                
                local bottomCenter = Vector2.new(left + width / 2, bottom + 2)
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = bottomCenter
                tracer.Color = displayColor
                tracer.Visible = true
            else
                box.Visible = false
                boxFill.Visible = false
                tracer.Visible = false
            end
            
            if _G.Menu and _G.Menu.features and _G.Menu.features.name then
                nameTag.Text = player.Name
                nameTag.Position = Vector2.new(left + width / 2, top - 16)
                nameTag.Color = displayColor
                nameTag.Visible = true
            else
                nameTag.Visible = false
            end
            
            if _G.Menu and _G.Menu.features and _G.Menu.features.health then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthColor = getHealthColor(healthPercent)
                
                healthBarBg.From = Vector2.new(left - barWidth - 4, bottom)
                healthBarBg.To = Vector2.new(left - barWidth - 4, top)
                healthBarBg.Color = Color3.new(0.15, 0.15, 0.15)
                healthBarBg.Thickness = 4
                healthBarBg.Visible = true
                
                local barHeight = math.max(0, math.min(1, healthPercent)) * height
                healthBar.From = Vector2.new(left - barWidth - 4, bottom)
                healthBar.To = Vector2.new(left - barWidth - 4, bottom - barHeight)
                healthBar.Color = healthColor
                healthBar.Thickness = 4
                healthBar.Visible = true
                
                healthText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                healthText.Position = Vector2.new(left - barWidth - 48, top + height / 2 - 6)
                healthText.Color = healthColor
                healthText.Visible = true
            else
                healthBar.Visible = false
                healthBarBg.Visible = false
                healthText.Visible = false
            end
            
            if headPart then
                local headPos, headOnScreen = Camera:WorldToViewportPoint(headPart.Position)
                if headOnScreen then
                    local headRadius = math.round(0.4 * fovScale)
                    head.Position = Vector2.new(headPos.X, headPos.Y)
                    head.Radius = headRadius
                    head.Color = displayColor
                    head.Visible = true
                else
                    head.Visible = false
                end
            else
                head.Visible = false
            end
        end)
        table.insert(connections, conn)
    end
    
    character.AncestryChanged:Connect(function()
        if character.Parent then
            update()
        end
    end)
    
    if character.Parent then
        update()
    end
end

Players.PlayerAdded:Connect(function(player)
    if player.Character then
        createESP(player)
    end
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createESP(player)
    end
end
