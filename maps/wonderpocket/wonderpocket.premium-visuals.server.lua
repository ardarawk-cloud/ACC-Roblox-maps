local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

Lighting.Brightness = 2.5
Lighting.ClockTime = 9.5
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.35
Lighting.EnvironmentDiffuseScale = 0.45
Lighting.EnvironmentSpecularScale = 0.75
Lighting.ExposureCompensation = 0.15

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.28
atmosphere.Offset = 0.1
atmosphere.Glare = 0.15
atmosphere.Haze = 1.1
atmosphere.Parent = Lighting

local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
bloom.Intensity = 0.25
bloom.Size = 28
bloom.Threshold = 1.4
bloom.Parent = Lighting

local color = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect")
color.Brightness = 0.03
color.Contrast = 0.08
color.Saturation = 0.08
color.TintColor = Color3.fromRGB(255, 248, 238)
color.Parent = Lighting

local rays = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect")
rays.Intensity = 0.05
rays.Spread = 0.65
rays.Parent = Lighting

local dayLength = 18 * 60
local startClock = os.clock()

task.spawn(function()
    while true do
        local elapsed = (os.clock() - startClock) % dayLength
        local normalized = elapsed / dayLength
        Lighting.ClockTime = (6 + normalized * 24) % 24
        task.wait(2)
    end
end)

local root = workspace:FindFirstChild("WonderPocket_Ambience") or Instance.new("Folder")
root.Name = "WonderPocket_Ambience"
root.Parent = workspace

if #root:GetChildren() == 0 then
    for i = 1, 18 do
        local orb = Instance.new("Part")
        orb.Name = "AmbientSparkle"
        orb.Shape = Enum.PartType.Ball
        orb.Size = Vector3.new(0.18,0.18,0.18)
        orb.Material = Enum.Material.Neon
        orb.Color = Color3.fromRGB(255, 241, 133)
        orb.Anchored = true
        orb.CanCollide = false
        orb.CanQuery = false
        orb.Transparency = 0.15
        local angle = (i / 18) * math.pi * 2
        orb.Position = Vector3.new(math.cos(angle)*38, 6 + (i%5)*2, math.sin(angle)*38)
        orb.Parent = root

        task.spawn(function()
            while orb.Parent do
                local target = orb.Position + Vector3.new(0, 2.5, 0)
                local tween = TweenService:Create(orb, TweenInfo.new(2.5 + (i%4)*0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position=target, Transparency=0.65})
                tween:Play()
                tween.Completed:Wait()
            end
        end)
    end
end

print("[WONDERPOCKET] Premium lighting and ambience loaded")
