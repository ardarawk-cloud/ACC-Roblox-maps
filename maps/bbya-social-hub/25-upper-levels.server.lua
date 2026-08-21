local W=game:GetService("Workspace")
local root=W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder",W);root.Name="BBYA_ZERO_BUILD"
local old=root:FindFirstChild("UpperLevels");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="UpperLevels"
local C={dark=Color3.fromRGB(14,12,17),wall=Color3.fromRGB(28,23,31),floor=Color3.fromRGB(61,49,56),pink=Color3.fromRGB(255,42,157),blue=Color3.fromRGB(0,174,255),warm=Color3.fromRGB(255,188,122),water=Color3.fromRGB(0,145,220),metal=Color3.fromRGB(44,39,49)}
local function p(n,s,cf,c,mat,t,parent)local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Color=c;x.Material=mat or Enum.Material.SmoothPlastic;x.Transparency=t or 0;x.Parent=parent or m;return x end
local function neon(n,s,cf,c,parent)local x=p(n,s,cf,c or C.pink,Enum.Material.Neon,0,parent);x.CanCollide=false;return x end
local function zone(n)local z=Instance.new("Model",m);z.Name=n;return z end
local vip=zone("L2_VIP_Level")
p("VIPNorth",Vector3.new(120,1,20),CFrame.new(0,24.5,34),C.floor,Enum.Material.Slate,0,vip)
p("VIPSouth",Vector3.new(120,1,18),CFrame.new(0,24.5,-36),C.floor,Enum.Material.Slate,0,vip)
p("VIPWest",Vector3.new(22,1,52),CFrame.new(-49,24.5,-1),C.floor,Enum.Material.Slate,0,vip)
p("VIPEast",Vector3.new(22,1,52),CFrame.new(49,24.5,-1),C.floor,Enum.Material.Slate,0,vip)
-- VIP inner-edge safety neon is owned by the late precise floor-neon pass.
-- Do not spawn the old floating BalconyRail / QueenCrown neon here.
p("VIPLoungeFloor",Vector3.new(30,.4,26),CFrame.new(-43,25,27),C.floor,Enum.Material.Slate,0,vip)
p("VIPLoungeBack",Vector3.new(30,10,1),CFrame.new(-43,30,40),C.wall,Enum.Material.Metal,0,vip)
p("QueenSkybox",Vector3.new(26,10,16),CFrame.new(-43,30,10),C.wall,Enum.Material.Metal,0,vip)
p("VIPBalcony",Vector3.new(22,.5,42),CFrame.new(46,25,2),C.floor,Enum.Material.Slate,0,vip)
for i,z in ipairs({17,29,39}) do p("PrivateRoom"..i,Vector3.new(20,9,10),CFrame.new(48,29.5,z),C.wall,Enum.Material.Metal,0,vip) end
local circ=zone("VerticalCirculation")
p("LiftCore",Vector3.new(10,44,10),CFrame.new(52,22,-32),C.dark,Enum.Material.Metal,0,circ)
local roof=zone("R_Rooftop")
p("RoofWest",Vector3.new(38,1,90),CFrame.new(-41,44.5,0),C.floor,Enum.Material.Slate,0,roof)
p("RoofEast",Vector3.new(38,1,90),CFrame.new(41,44.5,0),C.floor,Enum.Material.Slate,0,roof)
p("RoofFront",Vector3.new(44,1,22),CFrame.new(0,44.5,-34),C.floor,Enum.Material.Slate,0,roof)
p("RoofRear",Vector3.new(44,1,22),CFrame.new(0,44.5,34),C.floor,Enum.Material.Slate,0,roof)
local pool=p("InfinityPool",Vector3.new(58,2,34),CFrame.new(0,45,12),C.water,Enum.Material.Glass,.18,roof);pool.CanCollide=true
neon("PoolEdge",Vector3.new(58,.18,.25),CFrame.new(0,46.1,-5),C.blue,roof)
p("PoolDJDeck",Vector3.new(18,2,10),CFrame.new(0,46,-13),C.metal,Enum.Material.Metal,0,roof);neon("PoolDJGlow",Vector3.new(16,.2,.25),CFrame.new(0,47.1,-18),C.pink,roof)
for _,x in ipairs({-47,47}) do p("SkyBar"..x,Vector3.new(18,3,16),CFrame.new(x,46,29),C.metal,Enum.Material.Slate,0,roof);neon("SkyBarGlow"..x,Vector3.new(14,.2,.25),CFrame.new(x,47.7,20.9),C.pink,roof) end
for _,x in ipairs({-38,-19,19,38}) do p("CabanaDeck"..x,Vector3.new(15,.5,12),CFrame.new(x,45.2,37),C.floor,Enum.Material.WoodPlanks,0,roof);p("CabanaBack"..x,Vector3.new(15,7,.5),CFrame.new(x,48.5,42.5),C.wall,Enum.Material.WoodPlanks,0,roof) end
p("ViewDeckL",Vector3.new(24,.5,16),CFrame.new(-45,45,-36),C.floor,Enum.Material.Slate,0,roof)
p("ViewDeckR",Vector3.new(24,.5,16),CFrame.new(45,45,-36),C.floor,Enum.Material.Slate,0,roof)
print("[BBYA] VIP + rooftop built; public stairs removed")