loadstring(game:HttpGet("https://raw.githubusercontent.com/motionzlol/robloxwall/refs/heads/master/menu/Menu.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local connections = {}

local function createESP(player)
    if player == Players.LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local nameTag = Drawing.new("Text")
    nameTag.Text = player.Name
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.new(0, 0, 0)
    
    local healthBar = Drawing.new("Line")
    local healthBarBg = Drawing.new("Line")
    
    local box = Drawing.new("Quad")
    box.Thickness = 2
    box.Filled = false
    
    local function hideAll()
        nameTag.Visible = false
        box.Visible = false
        box.PointA = Vector2.new(-10000, -10000)
        box.PointB = Vector2.new(-10000, -10000)
        box.PointC = Vector2.new(-10000, -10000)
        box.PointD = Vector2.new(-10000, -10000)
        healthBar.Visible = false
        healthBarBg.Visible = false
    end
    
    local function update()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not player or not player.Character then
                conn:Disconnect()
                nameTag:Remove()
                healthBar:Remove()
                healthBarBg:Remove()
                box:Remove()
                return
            end
            
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
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
            
            local width = math.round(3 * fovScale)
            local height = math.round(5 * fovScale)
            
            if width <= 0 or height <= 0 then
                hideAll()
                return
            end
            
            local center = Vector2.new(math.round(position.X - (width * 0.5)), math.round(position.Y - (height * 0.5)))
            
            local left = center.X
            local right = center.X + width
            local top = center.Y
            local bottom = center.Y + height
            
            local teamColor = player.Team and player.Team.Color or Color3.fromRGB(200, 200, 200)
            
            if Menu and Menu.features and Menu.features.name then
                nameTag.Text = player.Name
                nameTag.Position = Vector2.new(left + width / 2, top - 18)
                nameTag.Color = teamColor
                nameTag.Visible = true
            else
                nameTag.Visible = false
            end
            
            if Menu and Menu.features and Menu.features.box then
                box.Color = teamColor
                box.PointA = Vector2.new(left, top)
                box.PointB = Vector2.new(right, top)
                box.PointC = Vector2.new(right, bottom)
                box.PointD = Vector2.new(left, bottom)
                box.Visible = true
            else
                box.Visible = false
            end
            
            if Menu and Menu.features and Menu.features.health then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local healthColor = Color3.new(1 - healthPercent, healthPercent, 0)
                
                local barWidth = 4
                healthBarBg.From = Vector2.new(left - barWidth - 2, bottom)
                healthBarBg.To = Vector2.new(left - barWidth - 2, top)
                healthBarBg.Color = Color3.new(0.2, 0.2, 0.2)
                healthBarBg.Thickness = 3
                healthBarBg.Visible = true
                
                healthBar.From = Vector2.new(left - barWidth - 2, bottom)
                healthBar.To = Vector2.new(left - barWidth - 2, bottom - math.max(0, math.min(1, healthPercent)) * height)
                healthBar.Color = healthColor
                healthBar.Thickness = 3
                healthBar.Visible = true
            else
                healthBar.Visible = false
                healthBarBg.Visible = false
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
