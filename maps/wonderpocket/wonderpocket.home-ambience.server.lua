-- WONDERPOCKET Personal Pocket Home Ambience v1.0
local Lighting = game:GetService("Lighting")

local homes = workspace:WaitForChild("WONDERPOCKET_PlotHomes", 20)
if not homes then return end

local NIGHT_START = 18.5
local NIGHT_END = 6.5
local bound = {}

local function isNight()
    local clock = Lighting.ClockTime
    return clock >= NIGHT_START or clock < NIGHT_END
end

local function ensureLamp(home)
    if not home or not home:IsA("Model") then return nil end
    local lamp = home:FindFirstChild("PocketLamp")
    if not lamp or not lamp:IsA("BasePart") then return nil end

    local light = lamp:FindFirstChild("PocketGlow")
    if not light then
        light = Instance.new("PointLight")
        light.Name = "PocketGlow"
        light.Color = Color3.fromRGB(255, 222, 145)
        light.Brightness = .9
        light.Range = 12
        light.Shadows = false
        light.Parent = lamp
    end
    return lamp, light
end

local function applyHome(home, night)
    local lamp, light = ensureLamp(home)
    if not lamp or not light then return end
    light.Enabled = night
    lamp.Material = night and Enum.Material.Neon or Enum.Material.SmoothPlastic
    lamp.Transparency = night and 0 or .18
    lamp.Color = night and Color3.fromRGB(255,235,145) or Color3.fromRGB(242,218,150)
    home:SetAttribute("WP_NightLampOn", night)
end

local function bindHome(home)
    if bound[home] then return end
    bound[home] = true
    task.defer(function()
        if home.Parent then applyHome(home, isNight()) end
    end)
    home.AncestryChanged:Connect(function(_, parent)
        if parent == nil then bound[home] = nil end
    end)
end

for _, home in ipairs(homes:GetChildren()) do bindHome(home) end
homes.ChildAdded:Connect(bindHome)

-- Lighting advances every two seconds; a five-second home update keeps the
-- ambience responsive without adding per-frame work for up to twelve cottages.
task.spawn(function()
    local lastNight
    while homes.Parent do
        local night = isNight()
        if night ~= lastNight then
            lastNight = night
            for _, home in ipairs(homes:GetChildren()) do
                applyHome(home, night)
            end
        end
        task.wait(5)
    end
end)

print("[WONDERPOCKET] day-night personal cottage lamps loaded")
