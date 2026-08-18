-- BBYA V6 — ADAPTIVE CLIENT PERFORMANCE
-- Mobile may reduce decorative lights only. Critical avatar/show-off fills are never disabled here.

local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local camera=workspace.CurrentCamera

local function isMobile()
    local v=camera.ViewportSize
    return UIS.TouchEnabled or v.X<850
end

local function decorativeLight(lightObj)
    if not lightObj:IsA("Light") then return false end
    local parent=lightObj.Parent
    return parent and parent:GetAttribute("BBYADecorativeLight")==true and parent:GetAttribute("BBYACriticalFill")~=true
end

local function allDecorative()
    local list={}
    for _,o in ipairs(workspace:GetDescendants()) do
        if decorativeLight(o) then table.insert(list,o) end
    end
    table.sort(list,function(a,b) return a:GetFullName()<b:GetFullName() end)
    return list
end

local function applyProfile()
    local mobile=isMobile()
    local list=allDecorative()
    for i,l in ipairs(list) do
        l.Shadows=false
        if mobile then
            -- Keep alternating ambience while cutting decorative-light cost.
            l.Enabled=(i%2==1)
            l.Brightness=math.min(l.Brightness,0.8)
            l.Range=math.min(l.Range,11)
        else
            l.Enabled=true
        end
    end

    -- Bloom may exist now or in a later finish pass. Cap it; never raise it.
    for _,o in ipairs(Lighting:GetChildren()) do
        if o:IsA("BloomEffect") and mobile then
            o.Intensity=math.min(o.Intensity,.32)
            o.Size=math.min(o.Size,32)
        end
    end

    player:SetAttribute("BBYAV6PerformanceProfile",mobile and "MOBILE_SAFE" or "DESKTOP_FULL")
    player:SetAttribute("BBYAV6DecorativeLightCount",#list)
end

applyProfile()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyProfile)

-- Future finish modules may add tagged decorative lights after client startup.
workspace.DescendantAdded:Connect(function(o)
    if o:IsA("Light") then task.defer(applyProfile) end
end)

-- Confirm that critical fills remain enabled client-side.
task.delay(4,function()
    local critical=0
    local disabledCritical=0
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Light") and o.Parent and o.Parent:GetAttribute("BBYACriticalFill")==true then
            critical+=1
            if not o.Enabled then disabledCritical+=1 end
        end
    end
    player:SetAttribute("BBYAV6ClientCriticalFillCount",critical)
    player:SetAttribute("BBYAV6ClientDisabledCriticalFill",disabledCritical)
end)
