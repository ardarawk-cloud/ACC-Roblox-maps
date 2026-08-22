-- BBYA SOCIAL HUB — NIGHT MARKET BOUNDARY / LAYOUT GUARD v1
-- Fixes the premium rear-row expansion so every playable attraction remains on a grounded fair footprint.
-- Keeps the existing rides, games, Travel 10R and audio policy intact.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local market=root:WaitForChild("BBYANightMarket",30)
if not market then return end
local premium=market:WaitForChild("PremiumNightMarketV3",30)
if not premium then return end

task.wait(1.1)

local old=market:FindFirstChild("NightMarketBoundaryLayoutGuardV1")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="NightMarketBoundaryLayoutGuardV1"
out.Parent=market
out:SetAttribute("Pass","NIGHT_MARKET_BOUNDARY_LAYOUT_GUARD_V1")
out:SetAttribute("RearAttractionsContained",true)
out:SetAttribute("TravelPriceRobux",10)
out:SetAttribute("AudioInjected",false)

local C={
 ground=Color3.fromRGB(106,86,64),asphalt=Color3.fromRGB(55,55,52),paver=Color3.fromRGB(93,89,82),
 concrete=Color3.fromRGB(103,101,96),metal=Color3.fromRGB(105,108,106),dark=Color3.fromRGB(31,31,29),
 warm=Color3.fromRGB(255,224,174),yellow=Color3.fromRGB(228,173,62),red=Color3.fromRGB(183,53,44),
}

local function part(name,size,cf,color,material,collide,parent,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.concrete;p.Material=material or Enum.Material.Concrete
 p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.CanQuery=true;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
 return p
end
local function beam(name,a,b,t,parent)
 local mid=(a+b)/2
 return part(name,Vector3.new(t,t,(b-a).Magnitude),CFrame.lookAt(mid,b),C.metal,Enum.Material.Metal,false,parent)
end
local function lamp(name,x,z,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or out
 part("Base",Vector3.new(.85,.28,.85),CFrame.new(x,1.05,z),C.concrete,Enum.Material.Concrete,true,m)
 part("Post",Vector3.new(.34,8,.34),CFrame.new(x,5,z),C.dark,Enum.Material.Metal,true,m)
 local head=part("Head",Vector3.new(1.2,.28,.75),CFrame.new(x,9,z),C.dark,Enum.Material.Metal,false,m)
 local l=Instance.new("PointLight");l.Color=C.warm;l.Brightness=.62;l.Range=15;l.Shadows=false;l.Parent=head
end
local function railSegment(name,a,b,parent)
 part(name.."PostA",Vector3.new(.32,3.2,.32),CFrame.new(a.X,2.3,a.Z),C.metal,Enum.Material.Metal,true,parent)
 part(name.."PostB",Vector3.new(.32,3.2,.32),CFrame.new(b.X,2.3,b.Z),C.metal,Enum.Material.Metal,true,parent)
 beam(name.."Top",Vector3.new(a.X,3.7,a.Z),Vector3.new(b.X,3.7,b.Z),.18,parent)
 beam(name.."Mid",Vector3.new(a.X,2.5,a.Z),Vector3.new(b.X,2.5,b.Z),.14,parent)
end

-- The original fair stopped at Z=635 / X=±107, while the premium rear row reaches roughly Z=654 and X=-112.
-- Preserve the original entrance line at Z=465 and extend only outward/backward.
local ground=market:FindFirstChild("MarketGround")
if ground and ground:IsA("BasePart") then
 ground.Size=Vector3.new(236,.8,220)
 ground.CFrame=CFrame.new(0,.4,575)
 ground.Material=Enum.Material.Ground
 ground.Color=C.ground
 ground:SetAttribute("FrontBoundaryZ",465)
 ground:SetAttribute("RearBoundaryZ",685)
 ground:SetAttribute("LeftBoundaryX",-118)
 ground:SetAttribute("RightBoundaryX",118)
 ground:SetAttribute("PremiumRearExpansionGrounded",true)
end

-- Keep the main pedestrian spine continuous all the way to the rear row.
local mainAisle=market:FindFirstChild("MainAisle")
if mainAisle and mainAisle:IsA("BasePart") then
 mainAisle.Size=Vector3.new(30,.25,210)
 mainAisle.CFrame=CFrame.new(0,.86,575)
 mainAisle:SetAttribute("RearRowConnected",true)
end
local cross=market:FindFirstChild("CrossAisle")
if cross and cross:IsA("BasePart") then
 cross.Size=Vector3.new(220,.25,24)
end
part("RearCrossAisle",Vector3.new(220,.22,22),CFrame.new(0,.88,646),C.asphalt,Enum.Material.Asphalt,true,out)
part("RearPaverBand",Vector3.new(220,.08,5),CFrame.new(0,1.02,633),C.paver,Enum.Material.Slate,false,out)

-- Defined ride pads make the layout readable and ensure dismounts never land over void.
local pads={
 {"CarouselSafetyPad",-55,512,54,54},
 {"FerrisSafetyPad",56,515,58,58},
 {"KoraSafetyPad",0,594,50,52},
 {"MiniTrainSafetyPad",-55,617,78,48},
 {"RingTossSafetyPad",0,646,48,26},
 {"ServiceSafetyPad",-95,647,40,28},
}
for _,p in ipairs(pads) do
 local pad=part(p[1],Vector3.new(p[4],.16,p[5]),CFrame.new(p[2],1.0,p[3]),C.concrete,Enum.Material.Concrete,true,out)
 pad:SetAttribute("SafeDismountSurface",true)
end

-- Rear perimeter: contained, but with deliberate openings so it does not feel like a closed box.
local perimeter=Instance.new("Model");perimeter.Name="RearSafetyPerimeter";perimeter.Parent=out
for _,seg in ipairs({
 {Vector3.new(-116,0,682),Vector3.new(-72,0,682)},
 {Vector3.new(-60,0,682),Vector3.new(-18,0,682)},
 {Vector3.new(18,0,682),Vector3.new(60,0,682)},
 {Vector3.new(72,0,682),Vector3.new(116,0,682)},
 {Vector3.new(-116,0,610),Vector3.new(-116,0,682)},
 {Vector3.new(116,0,610),Vector3.new(116,0,682)},
}) do railSegment("Rail",seg[1],seg[2],perimeter) end

-- Rear-row lighting / navigation rhythm so the extension reads as intentional fairground, not spill-over.
local rearLights=Instance.new("Model");rearLights.Name="RearRowLighting";rearLights.Parent=out
for i,x in ipairs({-105,-72,-36,36,72,105}) do lamp("RearLamp"..i,x,675,rearLights) end
for i,x in ipairs({-86,-42,42,86}) do
 local mark=part("LaneMarker"..i,Vector3.new(18,.04,.45),CFrame.new(x,1.08,646),C.yellow,Enum.Material.Neon,false,out)
 mark.CastShadow=false
end

-- Hard geometry invariant for runtime QC/debugging.
market:SetAttribute("FairgroundFootprintMinX",-118)
market:SetAttribute("FairgroundFootprintMaxX",118)
market:SetAttribute("FairgroundFootprintMinZ",465)
market:SetAttribute("FairgroundFootprintMaxZ",685)
market:SetAttribute("RearRowGrounded",true)
market:SetAttribute("MiniTrainTrackContained",true)
market:SetAttribute("RingTossContained",true)
market:SetAttribute("ServiceAreaContained",true)

print("[BBYA] Night Market boundary/layout guard: rear row grounded to Z685 / X±118; train, ring toss and service contained")