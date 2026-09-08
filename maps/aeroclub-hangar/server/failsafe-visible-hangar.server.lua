-- AEROCLUB HANGAR — VISIBLE FAILSAFE v1
-- MAIN HANGAR rescue authority. Ensures the map is NEVER blank/void while static mesh loading is investigated.
-- This is a deterministic visible fallback, NOT the final full-mesh art.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

Workspace:SetAttribute("AeroClubVisibleFailsafe", "V1_BOOTING")

local old = Workspace:FindFirstChild("AeroClubVisibleFailsafeModel")
if old then old:Destroy() end

local model = Instance.new("Model")
model.Name = "AeroClubVisibleFailsafeModel"
model.Parent = Workspace

local function part(name, size, cf, color, material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = true
    p.CanTouch = false
    p.CanQuery = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or Color3.fromRGB(60,64,74)
    p.Material = material or Enum.Material.Metal
    p.Transparency = transparency or 0
    p.Parent = model
    return p
end

local function beamBetween(name, a, b, thickness)
    local mid = (a+b)/2
    local len = (b-a).Magnitude
    local p = part(name, Vector3.new(thickness, thickness, len), CFrame.lookAt(mid,b), Color3.fromRGB(72,78,92), Enum.Material.Metal, 0)
    return p
end

-- Core dimensions locked to AeroClub layout.
local W, D, WALL_H, CROWN_H = 390, 340, 92, 142
local FRONT, BACK = -170, 170

-- Outdoor apron + indoor polished floor.
part("OutdoorApron", Vector3.new(382,2,164), CFrame.new(0,-1,-252), Color3.fromRGB(46,49,57), Enum.Material.Concrete, 0)
part("HangarFloor", Vector3.new(382,2,332), CFrame.new(0,-1,0), Color3.fromRGB(74,77,84), Enum.Material.SmoothPlastic, 0)
part("DanceFloor", Vector3.new(156,0.6,100), CFrame.new(0,0.3,-20), Color3.fromRGB(20,27,36), Enum.Material.SmoothPlastic, 0)

-- Structural envelope.
part("LeftWall", Vector3.new(6,WALL_H,D), CFrame.new(-195,WALL_H/2,0), Color3.fromRGB(48,53,64), Enum.Material.Metal, 0)
part("RightWall", Vector3.new(6,WALL_H,D), CFrame.new(195,WALL_H/2,0), Color3.fromRGB(48,53,64), Enum.Material.Metal, 0)
part("BackWall", Vector3.new(W,WALL_H,6), CFrame.new(0,WALL_H/2,BACK), Color3.fromRGB(43,47,58), Enum.Material.Metal, 0)
part("FrontLeft", Vector3.new(80,90,6), CFrame.new(-155,45,FRONT), Color3.fromRGB(43,47,58), Enum.Material.Metal, 0)
part("FrontRight", Vector3.new(80,90,6), CFrame.new(155,45,FRONT), Color3.fromRGB(43,47,58), Enum.Material.Metal, 0)
part("FrontHeader", Vector3.new(230,24,6), CFrame.new(0,130,FRONT), Color3.fromRGB(43,47,58), Enum.Material.Metal, 0)

-- Arched portal frames and roof ribs.
for r=0,14 do
    local z = FRONT + 14 + (r/14)*(D-28)
    part("ColumnL"..r, Vector3.new(5,WALL_H,5), CFrame.new(-183,WALL_H/2,z), Color3.fromRGB(62,68,82), Enum.Material.Metal, 0)
    part("ColumnR"..r, Vector3.new(5,WALL_H,5), CFrame.new(183,WALL_H/2,z), Color3.fromRGB(62,68,82), Enum.Material.Metal, 0)
    local last = nil
    for s=0,24 do
        local t = s/24
        local x = -183 + t*366
        local y = WALL_H + math.sin(t*math.pi)*(CROWN_H-WALL_H) - 6
        local pos = Vector3.new(x,y,z)
        if last then beamBetween("RoofRib", last, pos, 3.2) end
        last = pos
    end
end

-- Solid roof panels so sky cannot look like an empty world when standing inside.
for s=0,23 do
    local t0, t1 = s/24, (s+1)/24
    local x0 = -195 + t0*390
    local x1 = -195 + t1*390
    local y0 = WALL_H + math.sin(t0*math.pi)*(CROWN_H-WALL_H)
    local y1 = WALL_H + math.sin(t1*math.pi)*(CROWN_H-WALL_H)
    local mid = Vector3.new((x0+x1)/2,(y0+y1)/2,0)
    local dx, dy = x1-x0, y1-y0
    local width = math.sqrt(dx*dx+dy*dy)+1
    local angle = math.atan2(dy,dx)
    local roof = part("RoofPanel"..s, Vector3.new(width,2,D+4), CFrame.new(mid)*CFrame.Angles(0,0,angle), Color3.fromRGB(37,41,50), Enum.Material.Metal, 0)
    roof.CanCollide = true
end

-- Donor gate / entrance read.
part("DonorGateTop", Vector3.new(170,8,6), CFrame.new(0,34,-174), Color3.fromRGB(34,38,48), Enum.Material.Metal, 0)
part("DonorBoard", Vector3.new(130,18,3), CFrame.new(0,47,-174), Color3.fromRGB(12,18,24), Enum.Material.SmoothPlastic, 0)
for _,x in ipairs({-34,0,34}) do
    part("Pedestal", Vector3.new(20,8,20), CFrame.new(x,4,-150), Color3.fromRGB(68,62,50), Enum.Material.Metal, 0)
end

-- Center jet silhouette: fuselage + wings + tail. No cockpit box.
local fuselage = part("JetFuselage", Vector3.new(18,18,100), CFrame.new(0,15,58), Color3.fromRGB(190,196,207), Enum.Material.Metal, 0)
fuselage.Shape = Enum.PartType.Cylinder
fuselage.CFrame = CFrame.new(0,15,58)*CFrame.Angles(0,0,math.rad(90))
part("JetWingL", Vector3.new(65,2.5,26), CFrame.new(-36,13,58)*CFrame.Angles(0,math.rad(-8),0), Color3.fromRGB(176,183,195), Enum.Material.Metal, 0)
part("JetWingR", Vector3.new(65,2.5,26), CFrame.new(36,13,58)*CFrame.Angles(0,math.rad(8),0), Color3.fromRGB(176,183,195), Enum.Material.Metal, 0)
part("JetTail", Vector3.new(5,28,18), CFrame.new(0,29,99), Color3.fromRGB(170,177,190), Enum.Material.Metal, 0)
local nose = Instance.new("Part")
nose.Name = "JetNose"
nose.Shape = Enum.PartType.Ball
nose.Size = Vector3.new(17,15,20)
nose.Anchored = true
nose.CanCollide = false
nose.Color = Color3.fromRGB(184,191,203)
nose.Material = Enum.Material.Metal
nose.CFrame = CFrame.new(0,15,4)
nose.Parent = model
local glass = Instance.new("Part")
glass.Name = "JetCockpitGlass"
glass.Shape = Enum.PartType.Ball
glass.Size = Vector3.new(12,7,8)
glass.Anchored = true
glass.CanCollide = false
glass.Color = Color3.fromRGB(18,42,58)
glass.Material = Enum.Material.Glass
glass.Transparency = 0.18
glass.CFrame = CFrame.new(0,18,7)
glass.Parent = model

-- Wing-use zones.
part("DJWingStage", Vector3.new(42,2,20), CFrame.new(-35,10,56), Color3.fromRGB(12,18,24), Enum.Material.Metal, 0)
part("LeadWingStage", Vector3.new(42,2,20), CFrame.new(35,10,56), Color3.fromRGB(20,12,22), Enum.Material.Metal, 0)

-- Readable zone blockout: baggage, shop, photo booths, car pads.
part("BaggageClaim", Vector3.new(92,5,34), CFrame.new(-125,2.5,-66), Color3.fromRGB(74,63,48), Enum.Material.Metal, 0)
part("PhotoIndoor", Vector3.new(58,2,52), CFrame.new(134,1,-60), Color3.fromRGB(20,52,58), Enum.Material.SmoothPlastic, 0)
part("CornerShop", Vector3.new(74,8,30), CFrame.new(-125,4,-280), Color3.fromRGB(48,24,50), Enum.Material.Metal, 0)
part("PhotoOutdoor", Vector3.new(70,2,34), CFrame.new(128,1,-280), Color3.fromRGB(20,52,58), Enum.Material.SmoothPlastic, 0)
for _,cfg in ipairs({{-122,-225,Color3.fromRGB(205,78,64)},{-86,-225,Color3.fromRGB(210,210,220)},{88,-225,Color3.fromRGB(56,96,210)},{128,-225,Color3.fromRGB(205,78,64)}}) do
    part("CarDisplay", Vector3.new(18,5,34), CFrame.new(cfg[1],2.5,cfg[2]), cfg[3], Enum.Material.Metal, 0)
end

-- Practical QC lighting. Visible enough on mobile, still night-club oriented.
Lighting.ClockTime = 0.25
Lighting.Brightness = 3.4
Lighting.ExposureCompensation = 0.5
Lighting.Ambient = Color3.fromRGB(80,86,105)
Lighting.OutdoorAmbient = Color3.fromRGB(42,48,66)
Lighting.EnvironmentDiffuseScale = 0.7
Lighting.EnvironmentSpecularScale = 1

local lights = Instance.new("Folder")
lights.Name = "FailsafeLights"
lights.Parent = model
for _,z in ipairs({-125,-60,5,70,130}) do
    for _,x in ipairs({-120,0,120}) do
        local anchor = part("LightAnchor", Vector3.new(1,1,1), CFrame.new(x,76,z), Color3.new(1,1,1), Enum.Material.SmoothPlastic, 1)
        anchor.CanCollide = false
        anchor.Parent = lights
        local l = Instance.new("PointLight")
        l.Color = Color3.fromRGB(205,218,255)
        l.Brightness = 2.2
        l.Range = 90
        l.Shadows = false
        l.Parent = anchor
    end
end

Workspace:SetAttribute("AeroClubVisibleFailsafe", "V1_ACTIVE")
Workspace:SetAttribute("AeroClubMapNeverBlank", true)

-- If the approved static full-mesh asset actually appears, remove only this rescue model.
task.spawn(function()
    while model.Parent do
        local env = Workspace:FindFirstChild("Environment")
        local full = env and env:FindFirstChild("AeroClubStaticMeshV1_2")
        if full and Workspace:GetAttribute("AeroClubEnvironmentReady") == true then
            Workspace:SetAttribute("AeroClubVisibleFailsafe", "REMOVED_FULL_MESH_READY")
            model:Destroy()
            return
        end
        task.wait(1)
    end
end)

print("[AEROCLUB] visible failsafe active; map cannot be blank")
