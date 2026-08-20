-- BBYA SOCIAL HUB — FLOOR 1 VISUAL CLEANUP v1
-- Removes front-of-house ceiling fins that visually intrude into the dance floor
-- and replaces them with restrained dark-metal transition panels.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 20)
if not root then return end

local front = root:WaitForChild("Floor1FrontPremium", 20)
if not front then return end

local transition = front:WaitForChild("EntranceToClubTransition", 10)
if not transition then return end

-- Remove the wood ceiling-fin treatment completely. The old final fin at Z=-5
-- sat inside the dance-floor boundary and read as a random wooden object in the club.
for _, obj in ipairs(transition:GetChildren()) do
    if obj.Name:match("^CeilingFin") or obj.Name:match("^FinLight") then
        obj:Destroy()
    end
end

local C = {
    black = Color3.fromRGB(10,10,13),
    metal = Color3.fromRGB(30,29,34),
    warm = Color3.fromRGB(255,198,142),
}

local function part(name,size,cf,color,material)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Color=color
    p.Material=material or Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=true
    p.CastShadow=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=transition
    return p
end

-- Keep the transition treatment entirely south of the dance-floor boundary.
-- Dark metal panels visually lead toward the club without introducing wood overhead.
for i,z in ipairs({-18.0,-15.2,-12.4}) do
    part("TransitionCeilingPanel"..i,Vector3.new(18.5,.24,1.15),CFrame.new(0,14.2,z),C.metal,Enum.Material.Metal)
    local lamp=part("TransitionDownlight"..i,Vector3.new(.55,.18,.55),CFrame.new(0,13.98,z),C.black,Enum.Material.Metal)
    lamp.Shape=Enum.PartType.Cylinder
    lamp.CFrame=lamp.CFrame*CFrame.Angles(0,0,math.rad(90))
    local light=Instance.new("SpotLight")
    light.Face=Enum.NormalId.Bottom
    light.Color=C.warm
    light.Brightness=.7
    light.Range=15
    light.Angle=46
    light.Shadows=true
    light.Parent=lamp
end

-- Safety cleanup: no WoodPlanks material is allowed over the main dance rectangle.
for _, obj in ipairs(front:GetDescendants()) do
    if obj:IsA("BasePart") and obj.Material==Enum.Material.WoodPlanks then
        local pos=obj.Position
        if pos.X>-26 and pos.X<32 and pos.Z>-10 and pos.Z<32 then
            obj:Destroy()
        end
    end
end

print("[BBYA] Floor 1 visual cleanup loaded: stray wood removed from dance-floor sightline")
