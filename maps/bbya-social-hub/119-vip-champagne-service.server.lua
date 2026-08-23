-- BBYA SOCIAL HUB — VIP CHAMPAGNE SERVICE v1
-- Two premium wall-side service bars in the clear middle bands of VIP.
-- Keeps the four corner lounges, inner rail, precise floor neon, triangle ceiling,
-- audio routing, travel, rooftop access and center circulation untouched.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30)
if not vip then return end
local active=vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end
local lounge=active:WaitForChild("VIPLoungeSeatingV3",30)
if not lounge then return end

local old=active:FindFirstChild("VIPChampagneServiceV1")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="VIPChampagneServiceV1"
out:SetAttribute("Pass","VIP_CHAMPAGNE_SERVICE_V1")
out:SetAttribute("ServiceWallCount",2)
out:SetAttribute("CenterCirculationPreserved",true)
out:SetAttribute("CornerLoungesPreserved",true)
out:SetAttribute("AudioUntouched",true)
out:SetAttribute("FloorNeonUntouched",true)
out:SetAttribute("TriangleCeilingUntouched",true)
out.Parent=active

local C={
 black=Color3.fromRGB(8,8,10),
 ink=Color3.fromRGB(14,13,17),
 graphite=Color3.fromRGB(31,31,36),
 metal=Color3.fromRGB(58,57,63),
 smoked=Color3.fromRGB(31,37,42),
 brass=Color3.fromRGB(148,111,66),
 champagne=Color3.fromRGB(201,160,98),
 marble=Color3.fromRGB(122,118,124),
 warm=Color3.fromRGB(255,220,182),
 bottleDark=Color3.fromRGB(45,36,28),
 bottleGreen=Color3.fromRGB(31,52,39),
 glass=Color3.fromRGB(202,214,220),
 ice=Color3.fromRGB(215,228,235),
}

local function model(name,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m
end

local function block(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
 p.CastShadow=material~=Enum.Material.Neon;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end

local function verticalCylinder(name,height,diameter,cf,color,material,transparency,parent)
 local p=block(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,transparency,false,parent)
 p.Shape=Enum.PartType.Cylinder
 return p
end

local function point(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="VIPServiceWarmLight";l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=parent
 return l
end

local function addBottle(parent,cf,index)
 local bodyColor=(index%3==0) and C.bottleGreen or C.bottleDark
 local b=verticalCylinder("BottleBody"..index,.92,.38,cf,bodyColor,Enum.Material.Glass,.10,parent)
 b.Reflectance=.04
 verticalCylinder("BottleNeck"..index,.26,.18,cf*CFrame.new(0,.58,0),bodyColor,Enum.Material.Glass,.08,parent)
 verticalCylinder("BottleCap"..index,.10,.19,cf*CFrame.new(0,.76,0),C.champagne,Enum.Material.Metal,0,parent)
end

local function addGlass(parent,cf,index)
 local g=verticalCylinder("Glass"..index,.54,.34,cf,C.glass,Enum.Material.Glass,.62,parent)
 g.Reflectance=.06
 return g
end

local function makePlaque(parent,side)
 local x=side*55.94
 local p=block("VIPServicePlaque",Vector3.new(.16,1.20,8.8),CFrame.new(x,35.35,0),C.ink,Enum.Material.Metal,0,false,parent)
 local gui=Instance.new("SurfaceGui")
 gui.Name="VIPServicePlaqueFace"
 gui.Face=(side==1) and Enum.NormalId.Left or Enum.NormalId.Right
 gui.LightInfluence=.08;gui.PixelsPerStud=62;gui.Parent=p
 local t=Instance.new("TextLabel")
 t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text="BBYA  •  VIP SERVICE"
 t.TextColor3=Color3.fromRGB(232,207,164);t.TextStrokeTransparency=.88;t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.Parent=gui
end

local function makeServiceWall(side)
 local sideName=(side<0) and "WEST" or "EAST"
 local m=model("VIPServiceWall_"..sideName,out)
 local wallX=side*56.15
 local shelfX=side*55.45
 local counterX=side*54.90

 -- Dark framed backbar fits between the two corner lounge return sections.
 block("BackbarRecess",Vector3.new(.34,9.0,20.0),CFrame.new(wallX,31.1,0),C.ink,Enum.Material.Slate,0,false,m)
 block("BackbarSmokedGlass",Vector3.new(.18,7.8,18.6),CFrame.new(side*55.93,31.1,0),C.smoked,Enum.Material.Glass,.28,false,m).Reflectance=.07
 block("FrameTop",Vector3.new(.22,.12,19.0),CFrame.new(side*55.80,35.02,0),C.brass,Enum.Material.Metal,0,false,m)
 block("FrameBottom",Vector3.new(.22,.10,19.0),CFrame.new(side*55.80,27.18,0),C.brass,Enum.Material.Metal,0,false,m)
 block("FrameFrontA",Vector3.new(.22,7.7,.10),CFrame.new(side*55.80,31.1,-9.45),C.brass,Enum.Material.Metal,0,false,m)
 block("FrameFrontB",Vector3.new(.22,7.7,.10),CFrame.new(side*55.80,31.1,9.45),C.brass,Enum.Material.Metal,0,false,m)

 -- Three shelves + restrained warm shelf washes.
 local shelfYs={28.75,31.10,33.45}
 local bottleIndex=0
 for si,y in ipairs(shelfYs) do
  block("Shelf"..si,Vector3.new(1.25,.12,17.2),CFrame.new(shelfX,y,0),C.metal,Enum.Material.Metal,0,false,m)
  local glow=block("ShelfGlow"..si,Vector3.new(.08,.08,16.4),CFrame.new(side*54.82,y-.14,0),C.warm,Enum.Material.Neon,.54,false,m)
  point(glow,C.warm,.16,5.5)
  for _,z in ipairs({-6.2,-2.1,2.1,6.2}) do
   bottleIndex+=1
   addBottle(m,CFrame.new(side*55.20,y+.58,z),bottleIndex)
  end
 end

 -- Grounded marble service counter. It remains against the outer wall, leaving
 -- a broad walkway between the counter and the inner safety rail.
 block("CounterBody",Vector3.new(3.40,1.55,18.2),CFrame.new(counterX,25.82,0),C.black,Enum.Material.Metal,0,true,m)
 local top=block("CounterTop",Vector3.new(3.85,.24,18.8),CFrame.new(counterX-side*.02,26.73,0),C.marble,Enum.Material.Marble,0,true,m)
 top.Reflectance=.09
 block("CounterReveal",Vector3.new(3.58,.07,18.45),CFrame.new(counterX-side*.12,26.55,0),C.champagne,Enum.Material.Metal,0,false,m)
 block("ToeKick",Vector3.new(.08,.10,17.1),CFrame.new(side*53.18,25.08,0),C.warm,Enum.Material.Neon,.44,false,m)

 -- One champagne bucket + clean glass grouping per wall.
 local props=model("ServiceProps",m)
 local bucket=verticalCylinder("ChampagneBucket",.82,1.10,CFrame.new(side*53.95,27.42,-3.2),C.metal,Enum.Material.Metal,0,props)
 bucket.Reflectance=.12
 verticalCylinder("BucketRim",.10,1.20,CFrame.new(side*53.95,27.88,-3.2),C.champagne,Enum.Material.Metal,0,props)
 for i=1,3 do
  local ice=block("Ice"..i,Vector3.new(.24,.20,.24),CFrame.new(side*(53.80+.13*i),27.98,-3.35+.18*(i%2)),C.ice,Enum.Material.Glass,.34,false,props)
  ice.Reflectance=.05
 end
 for i,z in ipairs({1.6,2.3,3.0,3.7}) do addGlass(props,CFrame.new(side*53.82,27.32,z),i) end

 -- Architectural sconces, not club-neon floodlights.
 for i,z in ipairs({-7.6,7.6}) do
  local sconce=block("WarmSconce"..i,Vector3.new(.22,1.50,.24),CFrame.new(side*55.52,32.0,z),C.champagne,Enum.Material.Metal,0,false,m)
  local emitter=block("WarmSconceEmitter"..i,Vector3.new(.12,1.10,.12),CFrame.new(side*55.30,32.0,z),C.warm,Enum.Material.Neon,.42,false,m)
  point(emitter,C.warm,.30,9)
 end

 makePlaque(m,side)
 m:SetAttribute("BottleCount",bottleIndex)
 m:SetAttribute("WalkwayClearanceApprox",18)
end

makeServiceWall(-1)
makeServiceWall(1)

active:SetAttribute("VIPUpgradeProfile","PRIVATE_CLUB_SERVICE_V3")
active:SetAttribute("VIPServiceWalls",2)
out:SetAttribute("NoSoundObjects",true)
out:SetAttribute("NoGlobalLightingChanges",true)
out:SetAttribute("NoPromptOrMonetization",true)

print("[BBYA] VIP Champagne Service v1 online: dual premium service walls, clear center circulation preserved")
