-- BBYA V5.2 MODULAR ARCHITECTURE CORE
-- This file is concatenated first by scripts/inject-bbya.js.
-- Every physical object must belong to exactly one coded zone.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA V5.2 MODULAR GREYBOX"

-- Hard reset: V5 owns venue geometry. Preserve only Terrain/Camera/player characters.
for _, obj in ipairs(workspace:GetChildren()) do
    local preserve = obj:IsA("Terrain") or obj.Name == "Camera"
    if obj:IsA("Model") and Players:GetPlayerFromCharacter(obj) then preserve = true end
    if not preserve and (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Sound")) then
        obj:Destroy()
    end
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local zoneIndex = Instance.new("Folder")
zoneIndex.Name = "BBYA ZONE INDEX"
zoneIndex.Parent = root

local C = {
    floor = Color3.fromRGB(108,108,114), floor2 = Color3.fromRGB(132,132,138),
    wall = Color3.fromRGB(66,66,73), wall2 = Color3.fromRGB(82,82,90),
    stair = Color3.fromRGB(96,96,104), pink = Color3.fromRGB(255,90,205),
    cyan = Color3.fromRGB(75,220,255), gold = Color3.fromRGB(255,205,100),
    green = Color3.fromRGB(110,225,150), blue = Color3.fromRGB(100,145,255),
    service = Color3.fromRGB(190,150,85), pool = Color3.fromRGB(70,160,210),
    warm = Color3.fromRGB(205,170,120), neutral = Color3.fromRGB(165,165,170),
}

local function registerZone(code, name, level, center, size)
    local f = Instance.new("Folder")
    f.Name = string.format("[%s] %s", code, name)
    f:SetAttribute("BBYAZoneCode", code)
    f:SetAttribute("BBYAZoneName", name)
    f:SetAttribute("BBYALevel", level)
    f:SetAttribute("BBYACenterX", center.X); f:SetAttribute("BBYACenterY", center.Y); f:SetAttribute("BBYACenterZ", center.Z)
    f:SetAttribute("BBYASizeX", size.X); f:SetAttribute("BBYASizeY", size.Y); f:SetAttribute("BBYASizeZ", size.Z)
    f.Parent = root

    local v = Instance.new("StringValue")
    v.Name = code
    v.Value = string.format("%s | L%s | center %.1f,%.1f,%.1f | size %.1f,%.1f,%.1f", name, tostring(level), center.X,center.Y,center.Z,size.X,size.Y,size.Z)
    v.Parent = zoneIndex
    return f
end

local function tagObject(obj, zone)
    if zone and zone:GetAttribute("BBYAZoneCode") then
        obj:SetAttribute("BBYAZoneCode", zone:GetAttribute("BBYAZoneCode"))
        obj:SetAttribute("BBYAZoneName", zone:GetAttribute("BBYAZoneName"))
    end
    return obj
end

local function part(zone, name, size, cf, color, material, transparency, collide)
    local p = Instance.new("Part")
    local code = zone and zone:GetAttribute("BBYAZoneCode") or "CORE"
    p.Name = string.format("%s | %s", code, name)
    p.Size = size; p.CFrame = cf; p.Anchored = true
    p.CanCollide = collide ~= false; p.CanTouch = false
    p.Material = material or Enum.Material.Concrete
    p.Color = color or C.wall; p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = zone or root
    return tagObject(p, zone)
end

local function label(zone, name, text, cf, size, color, face)
    local p = part(zone, name, size, cf, Color3.fromRGB(38,38,44), Enum.Material.SmoothPlastic, 0, false)
    local gui = Instance.new("SurfaceGui")
    gui.Face = face or Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 28; gui.LightInfluence = 0; gui.Parent = p
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 1
    t.Text = text; t.TextColor3 = color or C.pink
    t.Font = Enum.Font.GothamBlack; t.TextScaled = true; t.TextWrapped = true; t.Parent = gui
    return p
end

local function zoneStamp(zone, cf, size, color, face)
    local code = zone:GetAttribute("BBYAZoneCode")
    local name = zone:GetAttribute("BBYAZoneName")
    return label(zone, "INSPECTION TAG", string.format("[%s] %s", code, name), cf, size or Vector3.new(26,4,.25), color or C.green, face)
end

local function program(zone, name, size2, position, color)
    local p = part(zone, name, Vector3.new(size2.X,.14,size2.Y), CFrame.new(position), color or C.neutral, Enum.Material.SmoothPlastic, .48, false)
    p.CanQuery = false
    return p
end

local function landing(zone, name, position, color)
    return program(zone, name, Vector2.new(9,9), position, color or C.green)
end

local function wallZ(zone, name, x, z1, z2, y, h, thickness)
    local len = math.abs(z2-z1)
    return part(zone, name, Vector3.new(thickness or 3,h,len), CFrame.new(x,y,(z1+z2)/2), C.wall2, Enum.Material.Concrete, 0, true)
end

local function wallX(zone, name, z, x1, x2, y, h, thickness)
    local len = math.abs(x2-x1)
    return part(zone, name, Vector3.new(len,h,thickness or 3), CFrame.new((x1+x2)/2,y,z), C.wall2, Enum.Material.Concrete, 0, true)
end

local function straightFlight(zone, name, startCF, steps, width, rise, run)
    for i=0,steps-1 do
        part(zone, name.." STEP "..i, Vector3.new(width,rise+.12,run+.06), startCF*CFrame.new(0,rise*i,-run*i), C.stair, Enum.Material.Concrete, 0, true)
    end
end

local function uStair(zone, name, centerX, centerZ, fromY)
    local width, rise, run, steps = 9, .75, 1.4, 12
    local flightRun = run*(steps-1)
    straightFlight(zone,name.." FLIGHT A",CFrame.new(centerX-5.2,fromY+.45,centerZ+8),steps,width,rise,run)
    part(zone,name.." MID LANDING",Vector3.new(11,.8,11),CFrame.new(centerX-5.2,fromY+9,centerZ+8-flightRun-4.5),C.floor2,Enum.Material.Concrete,0,true)
    straightFlight(zone,name.." FLIGHT B",CFrame.new(centerX+5.2,fromY+9.45,centerZ+8-flightRun-9)*CFrame.Angles(0,math.rad(180),0),steps,width,rise,run)
    part(zone,name.." TOP LANDING",Vector3.new(23,.8,12),CFrame.new(centerX,fromY+18,centerZ+7),C.floor2,Enum.Material.Concrete,0,true)
    part(zone,name.." CORE WEST",Vector3.new(2,18,39),CFrame.new(centerX-12,fromY+9,centerZ-1),C.wall,Enum.Material.Concrete,0,true)
    part(zone,name.." CORE EAST",Vector3.new(2,18,39),CFrame.new(centerX+12,fromY+9,centerZ-1),C.wall,Enum.Material.Concrete,0,true)
end

-- Neutral review lighting. Mood/decor comes only after architecture approval.
Lighting.ClockTime = 18.2; Lighting.Brightness = 2.7; Lighting.ExposureCompensation = .12
Lighting.Ambient = Color3.fromRGB(108,108,118); Lighting.OutdoorAmbient = Color3.fromRGB(88,90,100)
Lighting.FogStart = 1800; Lighting.FogEnd = 4000
for _,e in ipairs(Lighting:GetChildren()) do
    if e:IsA("BloomEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("Atmosphere") then e:Destroy() end
end

workspace:SetAttribute("BBYAV5ArchitectureMode","MODULAR_GREYBOX")
workspace:SetAttribute("BBYAV5ZoneSchema","A1-A6/B1-B3/C1-C3/D1-D6/S1")
