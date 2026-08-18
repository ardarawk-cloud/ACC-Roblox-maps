-- BBYA V6 — AUTOMATIC CLUB ACCENT LIGHTING
-- Crowd-reactive color movement; never toggles critical fill or blacks out the room.

local TweenService=game:GetService("TweenService")
local Players=game:GetService("Players")

local palette={
    Color3.fromRGB(255,38,182),
    Color3.fromRGB(28,218,255),
    Color3.fromRGB(130,65,245),
    Color3.fromRGB(246,243,246),
}

local lenses={}
for _,o in ipairs(workspace:GetDescendants()) do
    if o:IsA("BasePart") and o:GetAttribute("BBYAShowLightLens")==true then table.insert(lenses,o) end
end
table.sort(lenses,function(a,b) return (a:GetAttribute("BBYAShowLightIndex") or 0)<(b:GetAttribute("BBYAShowLightIndex") or 0) end)

local function clubCount()
    local n=0
    for _,p in ipairs(Players:GetPlayers()) do
        local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos=hrp.Position
            if pos.X>=-44 and pos.X<=44 and pos.Z>=64 and pos.Z<=128 and pos.Y>=0 and pos.Y<19 then n+=1 end
        end
    end
    return n
end

local function updateEnergy()
    local n=clubCount()
    local level=n>=10 and 3 or (n>=5 and 2 or (n>=2 and 1 or 0))
    workspace:SetAttribute("BBYAV6ClubCrowdCount",n)
    workspace:SetAttribute("BBYAV6ClubEnergy",level)
    return level
end

task.spawn(function()
    local phase=0
    while true do
        local energy=updateEnergy()
        local transition=energy>=3 and 1.0 or (energy==2 and 1.35 or (energy==1 and 1.8 or 2.4))
        phase+=1
        for i,lens in ipairs(lenses) do
            if lens.Parent then
                local color=palette[((i+phase-2)%#palette)+1]
                TweenService:Create(lens,TweenInfo.new(transition*.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Color=color}):Play()
                local light=lens:FindFirstChildWhichIsA("Light")
                if light then
                    TweenService:Create(light,TweenInfo.new(transition*.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Color=color,Brightness=energy>=2 and 1.35 or 1.05}):Play()
                end
            end
        end
        task.wait(transition)
    end
end)

workspace:SetAttribute("BBYAV6ClubLighting","AUTO_BRIGHT")
