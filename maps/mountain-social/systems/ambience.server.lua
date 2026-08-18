local Lighting = game:GetService("Lighting")

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "ACC_MountainAtmosphere"
atmosphere.Parent = Lighting
atmosphere.Density = 0.28
atmosphere.Haze = 1.4
atmosphere.Glare = 0.08

Lighting.Brightness = 2
Lighting.EnvironmentDiffuseScale = 0.35
Lighting.EnvironmentSpecularScale = 0.35
Lighting.GlobalShadows = true

local cycleMinutes = 32
local weather = "CLEAR"
local weatherEndsAt = 0

local function applyWeather(mode)
    weather = mode
    if mode == "FOG" then
        atmosphere.Density = 0.5
        atmosphere.Haze = 2.2
    elseif mode == "RAIN" then
        atmosphere.Density = 0.38
        atmosphere.Haze = 1.8
    else
        atmosphere.Density = 0.28
        atmosphere.Haze = 1.4
    end
    workspace:SetAttribute("ACC_Weather", mode)
end

applyWeather("CLEAR")

local started = os.clock()
task.spawn(function()
    while true do
        local elapsed = os.clock() - started
        Lighting.ClockTime = ((elapsed / 60) / cycleMinutes * 24 + 5.25) % 24
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        local now = os.clock()
        if now >= weatherEndsAt then
            local roll = math.random()
            if roll < 0.18 then
                applyWeather("RAIN")
                weatherEndsAt = now + math.random(120, 240)
            elseif roll < 0.42 then
                applyWeather("FOG")
                weatherEndsAt = now + math.random(150, 300)
            else
                applyWeather("CLEAR")
                weatherEndsAt = now + math.random(180, 360)
            end
        end
        task.wait(20)
    end
end)
