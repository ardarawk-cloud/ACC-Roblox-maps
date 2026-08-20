-- Mountain Social Adventure performance guard
-- Mobile-first adaptive effects. Does not alter gameplay/progression.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local samples = {}
local elapsed = 0
local lowMode = false

local function avgFps()
    local total = 0
    for _,v in ipairs(samples) do total += v end
    return #samples > 0 and total/#samples or 60
end

local function setLowMode(enabled)
    if enabled == lowMode then return end
    lowMode = enabled
    player:SetAttribute("ACC_LowFX", enabled)

    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere and enabled then
        atmosphere.Glare = math.min(atmosphere.Glare, 0.05)
    end

    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") and string.find(obj.Name, "ACC_") then
            local base = obj:GetAttribute("ACC_BaseRate")
            if base == nil then
                obj:SetAttribute("ACC_BaseRate", obj.Rate)
                base = obj.Rate
            end
            obj.Rate = enabled and math.floor(base*0.45) or base
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
    elapsed += dt
    if dt > 0 then
        table.insert(samples, math.min(120, 1/dt))
        if #samples > 90 then table.remove(samples,1) end
    end
    if elapsed >= 4 then
        elapsed = 0
        local fps = avgFps()
        if fps < 38 then
            setLowMode(true)
        elseif fps > 50 then
            setLowMode(false)
        end
    end
end)
