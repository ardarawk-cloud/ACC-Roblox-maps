-- BBYA SOCIAL HUB — VIP LINEAR CEILING v1
-- Premium staggered warm-white/gold ceiling bars inspired by modern luxury lounges.
-- Owns VIP ceiling lighting only. Does not touch Floor 1.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30)
if not vip then return end
local premium=vip:WaitForChild("PremiumVIPPass",30)
if not premium then return end

local ceiling=premium:FindFirstChild("VIPCeiling")
if not ceiling then
 ceiling=Instance.new("Model")
 ceiling.Name="VIPCeiling"
 ceiling.Parent=premium
end

local old=ceiling:FindFirstChild("LinearCeilingPass")
if old then old:Destroy() end

-- Retire the previous mixed pink/cyan pendant treatment inside VIPCeiling.
for _,obj in ipairs(ceiling:GetChildren()) do
 if obj.Name:match("^Pendant") or obj.Name:match("^Beam") or obj.Name:match("^EastGlow") or obj.Name:match("^NorthCove") then
  obj:Destroy()
 end
end

local pass=Instance.new("Model")
pass.Name="LinearCeilingPass"
pass:SetAttribute("Pass","VIP_LINEAR_CEILING_V1")
pass.Parent=ceiling

local WARM_WHITE=Color3.fromRGB(255,235,201)
local SOFT_GOLD=Color3.fromRGB(255,202,124)
local AMBER=Color3.fromRGB(255,179,94)
local HOUSING=Color3.fromRGB(20,18,21)

local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=true
 p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent
 return p
end

local function addStrip(i,x,z,length,tone,drop)
 local y=35.28-(drop or 0)
 local unit=Instance.new("Model")
 unit.Name=string.format("LinearStrip%02d",i)
 unit.Parent=pass

 -- Slim dark recessed housing makes each light read as an architectural fixture.
 part("Housing",Vector3.new(length+.35,.18,.34),CFrame.new(x,y+.11,z),HOUSING,Enum.Material.Metal,0,unit,false)
 local emitter=part("Emitter",Vector3.new(length,.08,.18),CFrame.new(x,y,z),tone,Enum.Material.Neon,.02,unit,false)

 local light=Instance.new("SurfaceLight")
 light.Name="Downlight"
 light.Face=Enum.NormalId.Bottom
 light.Color=tone
 light.Brightness=1.05
 light.Range=18
 light.Angle=118
 light.Shadows=false
 light.Parent=emitter

 -- Very soft secondary fill avoids harsh dark gaps between strips.
 local fill=Instance.new("PointLight")
 fill.Name="AmbientFill"
 fill.Color=tone
 fill.Brightness=.14
 fill.Range=9
 fill.Shadows=false
 fill.Parent=emitter
end

-- Deterministic staggered layout: long and short bars, all aligned like the reference.
-- Covers arrival, central social lounge, bar edge and private-booth corridor without touching Floor 1.
local layout={
 {-27,-21,10,WARM_WHITE,.00},{-12,-21,15,SOFT_GOLD,.10},{6,-21,9,WARM_WHITE,.03},{22,-21,14,WARM_WHITE,.12},{39,-21,8,AMBER,.02},
 {-33,-14,16,WARM_WHITE,.08},{-12,-14,8,SOFT_GOLD,.00},{3,-14,13,WARM_WHITE,.14},{21,-14,18,SOFT_GOLD,.04},{43,-14,10,WARM_WHITE,.10},
 {-25,-7,8,SOFT_GOLD,.13},{-9,-7,18,WARM_WHITE,.02},{13,-7,12,WARM_WHITE,.10},{32,-7,16,AMBER,.00},{50,-7,8,WARM_WHITE,.12},
 {-34,0,13,WARM_WHITE,.00},{-16,0,10,SOFT_GOLD,.11},{2,0,17,WARM_WHITE,.04},{24,0,11,WARM_WHITE,.14},{43,0,15,SOFT_GOLD,.03},
 {-28,8,18,SOFT_GOLD,.10},{-4,8,11,WARM_WHITE,.00},{14,8,9,AMBER,.13},{31,8,17,WARM_WHITE,.04},{50,8,8,WARM_WHITE,.11},
 {-35,17,10,WARM_WHITE,.03},{-19,17,15,SOFT_GOLD,.13},{2,17,8,WARM_WHITE,.00},{17,17,18,WARM_WHITE,.08},{40,17,12,AMBER,.02},
 {-26,27,14,WARM_WHITE,.10},{-7,27,9,SOFT_GOLD,.00},{10,27,16,WARM_WHITE,.13},{31,27,10,WARM_WHITE,.03},{48,27,13,SOFT_GOLD,.09},
 { -31,37,9,SOFT_GOLD,.02},{-15,37,17,WARM_WHITE,.12},{8,37,12,WARM_WHITE,.00},{27,37,15,AMBER,.09},{47,37,8,WARM_WHITE,.03},
}

for i,d in ipairs(layout) do
 addStrip(i,d[1],d[2],d[3],d[4],d[5])
end

pass:SetAttribute("FixtureCount",#layout)
pass:SetAttribute("LightingStyle","Warm Linear Staggered")
pass:SetAttribute("Floor1Untouched",true)

print(string.format("[BBYA] VIP Linear Ceiling v1 online: %d warm staggered fixtures",#layout))
