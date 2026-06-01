local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
getgenv().SecureMode = true

local HitboxEnabled = false
local HitboxSize = 20
local HitboxTransparency = 0.7

local EspEnabled = false
local EspHighlights = false
local EspTracers = false

local function GetPlayerColor(player)
    if player.Team then
        return player.TeamColor.Color
    end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateHighlight(player)
    if not EspHighlights or not EspEnabled then return end
    if player == game:GetService("Players").LocalPlayer then return end
    
    local character = player.Character
    if character and not character:FindFirstChild("HubHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "HubHighlight"
        highlight.FillColor = GetPlayerColor(player)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
    elseif character and character:FindFirstChild("HubHighlight") then
        character.HubHighlight.FillColor = GetPlayerColor(player)
    end
end

local function ClearHighlights()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HubHighlight") then
            player.Character.HubHighlight:Destroy()
        end
    end
end

local function CreateTracer(player)
    if not EspTracers or not EspEnabled then return nil end
    if player == game:GetService("Players").LocalPlayer then return nil end

    local line = Drawing.new("Line")
    line.Visible = false
    line.Thickness = 1
    line.Transparency = 1
    return line
end

local ActiveTracers = {}

local function CleanupTracers()
    for player, tracer in pairs(ActiveTracers) do
        if not game:GetService("Players"):FindFirstChild(player.Name) or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not EspTracers or not EspEnabled then
            if tracer then
                tracer.Visible = false
                tracer:Remove()
            end
            ActiveTracers[player] = nil
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    local localPlayer = game:GetService("Players").LocalPlayer
    local camera = workspace.CurrentCamera

    CleanupTracers()

    if EspEnabled and EspTracers then
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if rootPart and humanoid and humanoid.Health > 0 then
                    if HitboxEnabled then
                        rootPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        rootPart.Color = Color3.fromRGB(101, 67, 33)
                        rootPart.Transparency = HitboxTransparency
                        rootPart.Material = Enum.Material.SmoothPlastic
                        rootPart.CanCollide = false
                    end

                    if EspHighlights then
                        CreateHighlight(player)
                    end

                    if not ActiveTracers[player] then
                        ActiveTracers[player] = CreateTracer(player)
                    end
                    
                    local tracer = ActiveTracers[player]
                    if tracer then
                        local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                        tracer.Color = GetPlayerColor(player)
                        if onScreen then
                            tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                            tracer.Visible = true
                        else
                            tracer.Visible = false
                        end
                    end
                end
            end
        end
    else
        for player, tracer in pairs(ActiveTracers) do
            if tracer then
                tracer.Visible = false
                tracer:Remove()
            end
        end
        ActiveTracers = {}
    end
end)

local Window = Rayfield:CreateWindow({
    Name = "Universal Hub | Developer: 4xfuz",
    LoadingTitle = "Universal Hub",
    LoadingSubtitle = "by 4xfuz",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local Tab1 = Window:CreateTab("Hitbox Engine")
local Tab2 = Window:CreateTab("ESP Settings")
local Tab3 = Window:CreateTab("Settings")

Tab1:CreateToggle({
    Name = "Hit Box Toggle",
    CurrentValue = false,
    Callback = function(Value) HitboxEnabled = Value end,
})

Tab1:CreateSlider({
    Name = "Hit Box Size",
    Range = {0, 50},
    Increment = 1,
    CurrentValue = 20,
    Callback = function(Value) HitboxSize = Value end,
})

Tab1:CreateSlider({
    Name = "Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.7,
    Callback = function(Value) HitboxTransparency = Value end,
})

Tab2:CreateToggle({
    Name = "ESP Master Toggle",
    CurrentValue = false,
    Callback = function(Value)
        EspEnabled = Value
        if not Value then ClearHighlights() end
    end,
})

Tab2:CreateToggle({
    Name = "Team Colored Highlights",
    CurrentValue = false,
    Callback = function(Value) EspHighlights = Value end,
})

Tab2:CreateToggle({
    Name = "Team Colored Tracers",
    CurrentValue = false,
    Callback = function(Value) EspTracers = Value end,
})

Tab3:CreateParagraph({Title = "Developer", Content = "4xfuz"})
Tab3:CreateParagraph({Title = "Discord Username", Content = "wxcr15"})
