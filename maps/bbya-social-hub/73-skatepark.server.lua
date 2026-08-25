-- BBYA SOCIAL HUB — REAR SKATEPARK v3.1 PROPER BASE
-- Clean, rideable street-plaza layout. Keeps teleport center clear at (0,3,112).
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

local old=root:FindFirstChild("RearSkatepark")
if old then old:Destroy() end
local m=Instance.new("Model")
m.Name="RearSkatepark"
m.Parent=root
m:SetAttribute("Pass","REAR_SKATEPARK_V3_1_PROPER")
m:SetAttribute("TeleportKey","Skatepark")
m:SetAttribute("Layout","STREET_PLAZA_FLOW_V3_1")
m:SetAttribute("TeleportCenterClear",true)
m:SetAttribute("NorthTransitionRideDirection","CENTER_TO_NORTH_SLOPE_FIRST")
m:SetAttribute("AudioAuthorityUntouched",true)

local C={
 concrete=Color3.fromRGB(86,87,90), concrete2=Color3.fromRGB(68,69,72),
 dark=Color3.fromRGB(25,26,29), metal=Color3.fromRGB(76,79,84),
 white=Color3.fromRGB(232,231,224), blue=Color3.fromRGB(46,104,170),
 yellow=Color3.fromRGB(224,181,48), wood=Color3.fromRGB(112,82,57),
}
local function part(name,size,cf,color,material,collide,parent,class)
 local p=(class=="WedgePart") and Instance.new("WedgePart") or Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.concrete
 p.Material=material or Enum.Material.Concrete;p.Anchored=true;p.CanCollide=collide~=false
 p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or m;return p
end
local function rail(name,size,cf,parent)
 local p=part(name,size,cf,C.metal,Enum.Material.Metal,true,parent);p.CastShadow=true;return p
end
local function textSign(name,cf,size,text,sub)
 local p=part(name,size,cf,C.dark,Enum.Material.Metal,false)
 local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=46;sg.LightInfluence=.15;sg.Parent=p
 local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromScale(.04,.08);title.Size=UDim2.fromScale(.92,.58);title.Text=text;title.TextColor3=C.white;title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.Parent=sg
 local small=Instance.new("TextLabel");small.BackgroundTransparency=1;small.Position=UDim2.fromScale(.08,.68);small.Size=UDim2.fromScale(.84,.18);small.Text=sub or "";small.TextColor3=Color3.fromRGB(177,181,187);small.Font=Enum.Font.GothamBold;small.TextScaled=true;small.Parent=sg
 return p
end

-- SITE / ACCESS ----------------------------------------------------------------
part("RearWalk",Vector3.new(18,.6,46),CFrame.new(0,.3,75),C.concrete2,Enum.Material.Concrete,true)
part("SkateSlab",Vector3.new(120,1,78),CFrame.new(0,.5,112),C.concrete,Enum.Material.Concrete,true)

-- Perimeter is low and readable; south gate remains wide for circulation.
part("NorthWall",Vector3.new(120,3.2,2),CFrame.new(0,2.1,150),C.dark,Enum.Material.Concrete,true)
part("WestWall",Vector3.new(2,3.2,76),CFrame.new(-59,2.1,112),C.dark,Enum.Material.Concrete,true)
part("EastWall",Vector3.new(2,3.2,76),CFrame.new(59,2.1,112),C.dark,Enum.Material.Concrete,true)
part("SouthWallL",Vector3.new(47,3.2,2),CFrame.new(-36.5,2.1,74),C.dark,Enum.Material.Concrete,true)
part("SouthWallR",Vector3.new(47,3.2,2),CFrame.new(36.5,2.1,74),C.dark,Enum.Material.Concrete,true)

local function fenceH(prefix,z,x0,x1)
 for x=x0,x1,12 do rail(prefix.."Post"..x,Vector3.new(.22,7,.22),CFrame.new(x,7.4,z)) end
 rail(prefix.."Top",Vector3.new(math.abs(x1-x0)+.2,.18,.18),CFrame.new((x0+x1)/2,10.9,z))
 for y=4.7,10.2,1.38 do rail(prefix.."WireH"..y,Vector3.new(math.abs(x1-x0),.05,.05),CFrame.new((x0+x1)/2,y,z)) end
 for x=x0+4,x1-4,8 do rail(prefix.."WireV"..x,Vector3.new(.05,6.2,.05),CFrame.new(x,7.55,z)) end
end
local function fenceV(prefix,x,z0,z1)
 for z=z0,z1,12 do rail(prefix.."Post"..z,Vector3.new(.22,7,.22),CFrame.new(x,7.4,z)) end
 rail(prefix.."Top",Vector3.new(.18,.18,math.abs(z1-z0)+.2),CFrame.new(x,10.9,(z0+z1)/2))
 for y=4.7,10.2,1.38 do rail(prefix.."WireH"..y,Vector3.new(.05,.05,math.abs(z1-z0)),CFrame.new(x,y,(z0+z1)/2)) end
 for z=z0+4,z1-4,8 do rail(prefix.."WireV"..z,Vector3.new(.05,6.2,.05),CFrame.new(x,7.55,z)) end
end
fenceH("NorthFence",150,-59,59)
fenceH("SouthFenceL",74,-59,-13)
fenceH("SouthFenceR",74,13,59)
fenceV("WestFence",-59,74,150)
fenceV("EastFence",59,74,150)

-- TELEPORT / SAFE APRON --------------------------------------------------------
-- Travel system lands at (0,3,112); nothing solid is placed in this 22x20 box.
local arrival=part("ArrivalMark",Vector3.new(20,.05,18),CFrame.new(0,1.03,112),Color3.fromRGB(58,60,64),Enum.Material.SmoothPlastic,false)
arrival.Transparency=.18
part("ArrivalStripeL",Vector3.new(.16,.06,16),CFrame.new(-10,1.04,112),C.yellow,Enum.Material.SmoothPlastic,false)
part("ArrivalStripeR",Vector3.new(.16,.06,16),CFrame.new(10,1.04,112),C.yellow,Enum.Material.SmoothPlastic,false)

-- SOUTH STREET PLAZA: five stair + handrail + two hubbas ----------------------
local plaza=Instance.new("Model");plaza.Name="SouthStreetPlaza";plaza.Parent=m
for i=0,4 do
 part("Stair"..i,Vector3.new(15,.9,3.1),CFrame.new(-10,1.45+i*.42,82.5+i*2.3),C.concrete2,Enum.Material.Concrete,true,plaza)
end
rail("StairHandrail",Vector3.new(.28,.28,13.5),CFrame.new(-10,4.0,88.3)*CFrame.Angles(math.rad(-10),0,0),plaza)
for _,z in ipairs({83.2,93.2}) do rail("StairRailLeg"..z,Vector3.new(.24,2.8,.24),CFrame.new(-10,2.45,z),plaza) end
part("HubbaLeft",Vector3.new(2.8,1.5,14),CFrame.new(-19.2,2.1,88.4)*CFrame.Angles(math.rad(-7),0,0),Color3.fromRGB(61,62,65),Enum.Material.Concrete,true,plaza)
part("HubbaRight",Vector3.new(2.8,1.5,14),CFrame.new(-.8,2.1,88.4)*CFrame.Angles(math.rad(-7),0,0),Color3.fromRGB(61,62,65),Enum.Material.Concrete,true,plaza)
rail("HubbaCopingL",Vector3.new(.18,.18,14),CFrame.new(-17.9,2.92,88.4)*CFrame.Angles(math.rad(-7),0,0),plaza)
rail("HubbaCopingR",Vector3.new(.18,.18,14),CFrame.new(-2.1,2.92,88.4)*CFrame.Angles(math.rad(-7),0,0),plaza)

-- WEST STREET LINE: bank -> manual pad -> flat bar ----------------------------
local west=Instance.new("Model");west.Name="WestStreetLine";west.Parent=m
part("WestBank",Vector3.new(18,5.2,13),CFrame.new(-43,3.1,94)*CFrame.Angles(0,math.rad(180),0),C.concrete2,Enum.Material.Concrete,true,west,"WedgePart")
part("WestManualPad",Vector3.new(18,1.15,10),CFrame.new(-43,1.55,113),Color3.fromRGB(62,63,66),Enum.Material.Concrete,true,west)
rail("WestPadCoping",Vector3.new(18,.18,.32),CFrame.new(-43,2.19,108.1),west)
rail("WestFlatBar",Vector3.new(.28,.28,20),CFrame.new(-43,2.35,133),west)
for _,z in ipairs({124,142}) do rail("WestFlatBarLeg"..z,Vector3.new(.24,2.1,.24),CFrame.new(-43,1.5,z),west) end

-- EAST TECH LINE: low ledge + euro bank --------------------------------------
local east=Instance.new("Model");east.Name="EastTechLine";east.Parent=m
part("EastLedge",Vector3.new(22,1.45,4),CFrame.new(37,1.72,91),Color3.fromRGB(60,61,64),Enum.Material.Concrete,true,east)
rail("EastLedgeCoping",Vector3.new(22,.18,.32),CFrame.new(37,2.52,89.15),east)
part("EastEuroBank",Vector3.new(18,4.8,15),CFrame.new(39,2.9,112)*CFrame.Angles(0,math.rad(90),0),C.concrete2,Enum.Material.Concrete,true,east,"WedgePart")
part("EastDeck",Vector3.new(12,1,16),CFrame.new(50,3.9,112),Color3.fromRGB(58,59,62),Enum.Material.Concrete,true,east)

-- NORTH TRANSITION RETURN: slope must face the arrival/ride line from center.
local trans=Instance.new("Model");trans.Name="NorthTransition";trans.Parent=m
part("NorthQuarterLeft",Vector3.new(31,7.2,16),CFrame.new(-38,4.1,140),C.concrete2,Enum.Material.Concrete,true,trans,"WedgePart")
part("NorthQuarterRight",Vector3.new(31,7.2,16),CFrame.new(38,4.1,140),C.concrete2,Enum.Material.Concrete,true,trans,"WedgePart")
rail("NorthCopingLeft",Vector3.new(31,.26,.34),CFrame.new(-38,7.72,147.8),trans)
rail("NorthCopingRight",Vector3.new(31,.26,.34),CFrame.new(38,7.72,147.8),trans)

-- SOCIAL / SPECTATOR edges stay outside ride lines and clear of board rack.
local social=Instance.new("Model");social.Name="SpectatorEdge";social.Parent=m
for i,x in ipairs({14,26,36}) do
 part("BenchSeat"..i,Vector3.new(9,.45,2.4),CFrame.new(x,2.0,77.2),C.wood,Enum.Material.WoodPlanks,true,social)
 part("BenchLegA"..i,Vector3.new(.35,1.5,1.8),CFrame.new(x-3,1.25,77.2),C.metal,Enum.Material.Metal,true,social)
 part("BenchLegB"..i,Vector3.new(.35,1.5,1.8),CFrame.new(x+3,1.25,77.2),C.metal,Enum.Material.Metal,true,social)
end

textSign("SkateparkSign",CFrame.new(0,7.2,148.82),Vector3.new(34,7,.38),"BBYA SKATEPARK","STREET PLAZA • NIGHT SESSION")

print("[BBYA] Rear Skatepark v3.1 proper: north transition faces ride line; center clear")
