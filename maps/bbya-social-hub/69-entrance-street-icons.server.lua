-- BBYA SOCIAL HUB — ENTRANCE STREET v1.2
-- Makes the spawn read as a venue on a real main road.
-- v1.2 RETIRES the old procedural red/blue sports-car fallback.
-- Entrance cars are now exclusively owned by 77-entrance-car-cleanup.server.lua
-- and sourced from the baked Ddiaz model container packaged into ServerStorage.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local entrance = root:WaitForChild("Entrance", 30)
if not entrance then return end

task.wait(0.25)
local old = root:FindFirstChild("EntranceStreetScene")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "EntranceStreetScene"
out:SetAttribute("Pass", "ENTRANCE_STREET_V1_2")
out:SetAttribute("PhotoSpot", true)
out:SetAttribute("ProceduralCarFallbackRetired", true)
out:SetAttribute("EntranceCarAuthority", "77_BAKED_DDIAZ_ONLY")
out.Parent = root

local C = {
    asphalt = Color3.fromRGB(31,32,34),
    curb = Color3.fromRGB(108,107,105),
    sidewalk = Color3.fromRGB(66,64,62),
    line = Color3.fromRGB(224,210,148),
    white = Color3.fromRGB(225,225,222),
    black = Color3.fromRGB(12,12,14),
    metal = Color3.fromRGB(45,46,49),
}

local function part(name,size,cf,color,material,transparency,collide,parent,className)
    local p = className=="WedgePart" and Instance.new("WedgePart") or Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Color=color or C.black
    p.Material=material or Enum.Material.SmoothPlastic
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=collide==true
    p.CanTouch=false
    p.CanQuery=true
    p.CastShadow=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or out
    return p
end

-- Main road parallel to the facade.
part("MainRoad",Vector3.new(190,1.2,30),CFrame.new(0,-.15,-82),C.asphalt,Enum.Material.Asphalt,0,true)
part("VenueSidewalk",Vector3.new(190,.65,9),CFrame.new(0,.65,-64.5),C.sidewalk,Enum.Material.Concrete,0,true)
part("VenueCurb",Vector3.new(190,.9,1.2),CFrame.new(0,.5,-69.1),C.curb,Enum.Material.Concrete,0,true)
part("OppositeCurb",Vector3.new(190,.9,1.2),CFrame.new(0,.5,-96.9),C.curb,Enum.Material.Concrete,0,true)

-- Centerline and edge markings. These are road markings, not decorative venue neon.
for _,x in ipairs({-78,-52,-26,0,26,52,78}) do
    part("CenterDash"..x,Vector3.new(13,.04,.28),CFrame.new(x,.48,-82),C.line,Enum.Material.SmoothPlastic,0,false)
end
part("RoadEdgeNear",Vector3.new(184,.04,.18),CFrame.new(0,.48,-72),C.white,Enum.Material.SmoothPlastic,0,false)
part("RoadEdgeFar",Vector3.new(184,.04,.18),CFrame.new(0,.48,-92),C.white,Enum.Material.SmoothPlastic,0,false)

-- Pedestrian approach from spawn/venue to the display-car area.
for i,x in ipairs({-8,-4,0,4,8}) do
    part("Crosswalk"..i,Vector3.new(2.2,.05,8),CFrame.new(x,.5,-72.7),C.white,Enum.Material.SmoothPlastic,0,false)
end

-- No car geometry is authored here. This prevents a second car authority and guarantees
-- that Ddiaz models can never silently degrade into the old red/blue placeholder shells.

for i,x in ipairs({-52,52}) do
    local pole=part("StreetPole"..i,Vector3.new(.35,10,.35),CFrame.new(x,5.5,-66),C.metal,Enum.Material.Metal,0,false)
    local lamp=part("StreetLamp"..i,Vector3.new(2.5,.45,1.1),CFrame.new(x,10.4,-66),Color3.fromRGB(235,218,188),Enum.Material.SmoothPlastic,0,false)
    local light=Instance.new("PointLight")
    light.Color=Color3.fromRGB(255,222,180)
    light.Brightness=1.8
    light.Range=24
    light.Shadows=true
    light.Parent=lamp
end

local function fixCommunityWallBottomNeon()
    local dashboard=root:FindFirstChild("SupportDashboard")
    if not dashboard then return false end

    local fixed=0
    for _,name in ipairs({"TopSupportersWall","LiveCommunityWall"}) do
        local holder=dashboard:FindFirstChild(name)
        local bottom=holder and holder:FindFirstChild("BottomTrim")
        if bottom and bottom:IsA("BasePart") then
            if bottom:GetAttribute("BBYABottomNeonVisibleV1")~=true then
                bottom.Size=Vector3.new(bottom.Size.X,.18,.18)
                bottom.CFrame=bottom.CFrame*CFrame.new(0,.18,-.10)
                bottom.Material=Enum.Material.Neon
                bottom.Transparency=0
                bottom:SetAttribute("BBYABottomNeonVisibleV1",true)
            end
            fixed+=1
        end
    end
    return fixed==2
end

task.spawn(function()
    for _=1,100 do
        if fixCommunityWallBottomNeon() then return end
        task.wait(.1)
    end
end)
root.ChildAdded:Connect(function(child)
    if child.Name=="SupportDashboard" then task.delay(.2,fixCommunityWallBottomNeon) end
end)

print("[BBYA] Entrance street v1.2 online: road + streetlights; procedural car fallback retired")
