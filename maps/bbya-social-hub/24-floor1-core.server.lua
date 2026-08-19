local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD")
if not root then root=Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=W end
local old=root:FindFirstChild("Floor1Core")
if old then old:Destroy() end
local m=Instance.new("Model");m.Name="Floor1Core";m.Parent=root

local C={dark=Color3.fromRGB(14,12,17),wall=Color3.fromRGB(28,23,31),floor=Color3.fromRGB(61,49,56),floor2=Color3.fromRGB(77,60,67),pink=Color3.fromRGB(255,42,157),blue=Color3.fromRGB(0,174,255),warm=Color3.fromRGB(255,188,122),glass=Color3.fromRGB(56,37,61),metal=Color3.fromRGB(44,39,49)}
local function p(n,s,cf,col,mat,t,parent)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.CanCollide=true;x.Size=s;x.CFrame=cf;x.Color=col;x.Material=mat or Enum.Material.SmoothPlastic;x.Transparency=t or 0;x.Parent=parent or m;return x end
local function neon(n,s,cf,col,parent)local x=p(n,s,cf,col or C.pink,Enum.Material.Neon,0,parent);x.CanCollide=false;return x end
local function light(parent,col,b,r)local l=Instance.new("PointLight");l.Color=col;l.Brightness=b;l.Range=r;l.Shadows=true;l.Parent=parent;return l end
local function zone(name)local z=Instance.new("Model");z.Name=name;z.Parent=m;return z end

-- IRREGULAR BLUEPRINT FOOTPRINT
-- Entrance remains separate and LOCKED in 20-entrance.server.lua.
-- Front is SOUTH (-Z). Floor 1 expands wider toward the club core and narrows again at the rear.
p("FrontSpine",Vector3.new(54,1,24),CFrame.new(0,.5,-30),C.floor,Enum.Material.Slate)
p("FrontLeftWing",Vector3.new(34,1,24),CFrame.new(-42,.5,-25),C.floor,Enum.Material.Slate)
p("FrontRightWing",Vector3.new(28,1,22),CFrame.new(43,.5,-22),C.floor,Enum.Material.Slate)
p("ClubCore",Vector3.new(92,1,58),CFrame.new(2,.5,8),C.floor,Enum.Material.Slate)
p("RearStageMass",Vector3.new(66,1,20),CFrame.new(0,.5,42),C.floor,Enum.Material.Slate)
p("RearLeftStep",Vector3.new(18,1,18),CFrame.new(-46,.5,32),C.floor,Enum.Material.Slate)
p("RearRightStep",Vector3.new(24,1,26),CFrame.new(48,.5,30),C.floor,Enum.Material.Slate)

-- Outer irregular shell pieces, leaving a real central entrance opening.
p("FrontLeftWall",Vector3.new(2,24,22),CFrame.new(-27,12,-30),C.dark)
p("FrontRightWall",Vector3.new(2,24,22),CFrame.new(27,12,-30),C.dark)
p("LeftFrontOuter",Vector3.new(2,24,28),CFrame.new(-59,12,-22),C.dark)
p("LeftMidOuter",Vector3.new(2,24,44),CFrame.new(-51,12,14),C.dark)
p("LeftRearOuter",Vector3.new(2,24,18),CFrame.new(-41,12,44),C.dark)
p("RightFrontOuter",Vector3.new(2,24,24),CFrame.new(57,12,-18),C.dark)
p("RightMidOuter",Vector3.new(2,24,46),CFrame.new(52,12,14),C.dark)
p("RightRearOuter",Vector3.new(2,24,24),CFrame.new(39,12,43),C.dark)
p("RearWall",Vector3.new(80,24,2),CFrame.new(0,12,52),C.dark)

-- 02 RECEPTION: compact and centered just after entrance, with breathing room before club.
local reception=zone("02_Reception")
p("ReceptionDesk",Vector3.new(20,3.2,4),CFrame.new(0,2.1,-25),C.metal,Enum.Material.Slate,0,reception)
p("ReceptionBackdrop",Vector3.new(26,9,1),CFrame.new(0,5,-20),C.wall,Enum.Material.Metal,0,reception)
neon("ReceptionEdge",Vector3.new(18,.18,.25),CFrame.new(0,3.8,-27.05),C.pink,reception)

-- 03 PHOTO AREA: front-left pocket, angled away from centerline.
local photo=zone("03_PhotoArea")
p("PhotoFloor",Vector3.new(24,.3,18),CFrame.new(-39,.7,-25),C.floor2,Enum.Material.Slate,0,photo)
p("PhotoBackdrop",Vector3.new(1,11,18),CFrame.new(-50,5.5,-25),C.wall,Enum.Material.Metal,0,photo)
neon("PhotoFrameTop",Vector3.new(.25,.25,14),CFrame.new(-49.35,8,-25),C.pink,photo)

-- 04 SALON / LOOK STUDIO: separate side mass, not a mirror-image box.
local salon=zone("04_SalonLookStudio")
p("SalonFloor",Vector3.new(26,.3,22),CFrame.new(-38,.7,-4),C.floor2,Enum.Material.Slate,0,salon)
p("SalonRear",Vector3.new(24,10,1),CFrame.new(-38,5,6.5),C.wall,Enum.Material.Metal,0,salon)
for i,z in ipairs({-10,-3,4}) do p("SalonConsole"..i,Vector3.new(7,2.2,2),CFrame.new(-45,1.8,z),C.metal,Enum.Material.Slate,0,salon) end

-- 05 MAIN DANCE FLOOR: dominant central irregular core.
local dance=zone("05_MainDanceFloor")
p("DanceFloor",Vector3.new(58,.35,42),CFrame.new(3,.72,11),Color3.fromRGB(36,31,42),Enum.Material.Slate,0,dance)
for _,x in ipairs({-20,-10,0,10,20}) do neon("DanceStripX"..x,Vector3.new(.14,.07,38),CFrame.new(3+x,.94,11),x==0 and C.blue or C.pink,dance) end
for _,z in ipairs({-3,11,25}) do neon("DanceStripZ"..z,Vector3.new(54,.07,.14),CFrame.new(3,.95,z),z==11 and C.blue or C.pink,dance) end

-- 06 DJ BOOTH: centered exactly on the main sightline x=0.
local dj=zone("06_DJBooth")
p("DJPlatform",Vector3.new(22,2.2,8),CFrame.new(0,1.6,34),C.metal,Enum.Material.Metal,0,dj)
p("DJDesk",Vector3.new(17,3,4),CFrame.new(0,3.2,31),C.dark,Enum.Material.Metal,0,dj)
neon("DJDeskGlow",Vector3.new(15,.22,.25),CFrame.new(0,4.8,28.95),C.pink,dj)

-- 07 STAGE / LIGHTING: broad rear band, slightly wider than DJ but narrower than dance floor.
local stage=zone("07_StageLighting")
p("StageDeck",Vector3.new(54,2.6,10),CFrame.new(3,2,43),C.wall,Enum.Material.Metal,0,stage)
p("StageBack",Vector3.new(54,15,1.2),CFrame.new(3,8.5,48),C.dark,Enum.Material.Metal,0,stage)
for _,x in ipairs({-20,-10,0,10,20}) do local n=neon("StageBar"..x,Vector3.new(5,.25,.3),CFrame.new(3+x,12.5,47.3),(x%20==0) and C.pink or C.blue,stage);light(n,n.Color,2,15) end

-- 08 MAIN BAR: right-side projection, set back from entrance rather than forming a full rectangle.
local bar=zone("08_MainBar")
p("BarFloor",Vector3.new(22,.3,30),CFrame.new(42,.7,11),C.floor2,Enum.Material.Slate,0,bar)
p("BarBack",Vector3.new(2,12,28),CFrame.new(52,6,11),C.wall,Enum.Material.Metal,0,bar)
p("BarCounter",Vector3.new(4,3,24),CFrame.new(34.5,2,11),C.metal,Enum.Material.Slate,0,bar)
neon("BarCounterGlow",Vector3.new(.18,.2,22),CFrame.new(32.45,3.6,11),C.pink,bar)

-- Clear transition court between reception and dance floor: no object blocks this space.
p("TransitionCourt",Vector3.new(34,.08,12),CFrame.new(0,1.01,-12),Color3.fromRGB(55,45,52),Enum.Material.Slate,0,m).CanCollide=false
local sight=neon("CenterSightline",Vector3.new(.10,.04,70),CFrame.new(0,1.03,2),C.blue,m);sight.Transparency=.72

print("[BBYA] Floor 1 remapped to irregular stepped blueprint footprint; DJ booth centered on sightline")