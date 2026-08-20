-- BBYA SOCIAL HUB — REAR SKATEPARK v1
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local old=root:FindFirstChild("RearSkatepark")
if old then old:Destroy() end
local m=Instance.new("Model");m.Name="RearSkatepark";m.Parent=root
m:SetAttribute("Pass","REAR_SKATEPARK_V1")
m:SetAttribute("TeleportKey","Skatepark")

local C={concrete=Color3.fromRGB(92,92,94),dark=Color3.fromRGB(30,31,34),metal=Color3.fromRGB(78,80,84),white=Color3.fromRGB(218,218,214),blue=Color3.fromRGB(40,104,172),yellow=Color3.fromRGB(224,183,53)}
local function part(name,size,cf,color,material,collide,parent,class)
 local p=(class=="WedgePart") and Instance.new("WedgePart") or Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.concrete;p.Material=material or Enum.Material.Concrete;p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or m;return p
end
local function rail(name,size,cf)
 local p=part(name,size,cf,C.metal,Enum.Material.Metal,true);p.CastShadow=true;return p
end

-- rear connection and park slab
part("RearWalk",Vector3.new(16,.6,46),CFrame.new(0,.3,75),Color3.fromRGB(68,68,70),Enum.Material.Concrete,true)
part("SkateSlab",Vector3.new(120,1,78),CFrame.new(0,.5,112),C.concrete,Enum.Material.Concrete,true)

-- half-height concrete perimeter walls with a gate toward the venue
part("NorthHalfWall",Vector3.new(120,3.5,2),CFrame.new(0,2.25,150),C.dark,Enum.Material.Concrete,true)
part("WestHalfWall",Vector3.new(2,3.5,76),CFrame.new(-59,2.25,112),C.dark,Enum.Material.Concrete,true)
part("EastHalfWall",Vector3.new(2,3.5,76),CFrame.new(59,2.25,112),C.dark,Enum.Material.Concrete,true)
part("SouthHalfWallL",Vector3.new(49,3.5,2),CFrame.new(-35.5,2.25,74),C.dark,Enum.Material.Concrete,true)
part("SouthHalfWallR",Vector3.new(49,3.5,2),CFrame.new(35.5,2.25,74),C.dark,Enum.Material.Concrete,true)

-- wire-mesh fence: posts + framed grid above the half wall.
local function fenceSpanHorizontal(prefix,z,x0,x1)
 local y0=4;local yTop=11
 for x=x0,x1,12 do rail(prefix.."Post"..x,Vector3.new(.22,7,.22),CFrame.new(x,(y0+yTop)/2,z)) end
 rail(prefix.."Top",Vector3.new(math.abs(x1-x0)+.2,.18,.18),CFrame.new((x0+x1)/2,yTop,z))
 for y=5,10,1.25 do rail(prefix.."WireH"..y,Vector3.new(math.abs(x1-x0),.055,.055),CFrame.new((x0+x1)/2,y,z)) end
 for x=x0+3,x1-3,6 do rail(prefix.."WireV"..x,Vector3.new(.055,6.2,.055),CFrame.new(x,7.7,z)) end
end
local function fenceSpanVertical(prefix,x,z0,z1)
 local y0=4;local yTop=11
 for z=z0,z1,12 do rail(prefix.."Post"..z,Vector3.new(.22,7,.22),CFrame.new(x,(y0+yTop)/2,z)) end
 rail(prefix.."Top",Vector3.new(.18,.18,math.abs(z1-z0)+.2),CFrame.new(x,yTop,(z0+z1)/2))
 for y=5,10,1.25 do rail(prefix.."WireH"..y,Vector3.new(.055,.055,math.abs(z1-z0)),CFrame.new(x,y,(z0+z1)/2)) end
 for z=z0+3,z1-3,6 do rail(prefix.."WireV"..z,Vector3.new(.055,6.2,.055),CFrame.new(x,7.7,z)) end
end
fenceSpanHorizontal("NorthFence",150,-59,59)
fenceSpanHorizontal("SouthFenceL",74,-59,-11)
fenceSpanHorizontal("SouthFenceR",74,11,59)
fenceSpanVertical("WestFence",-59,74,150)
fenceSpanVertical("EastFence",59,74,150)

-- skate obstacles: banks, quarter-pipe style wedges, stairs, manual pad and grind rails.
part("WestBank",Vector3.new(18,7,28),CFrame.new(-46,4,116)*CFrame.Angles(0,math.rad(90),0),C.dark,Enum.Material.Concrete,true,m,"WedgePart")
part("EastBank",Vector3.new(18,7,28),CFrame.new(46,4,108)*CFrame.Angles(0,math.rad(-90),0),C.dark,Enum.Material.Concrete,true,m,"WedgePart")
part("CenterPyramidA",Vector3.new(20,4,12),CFrame.new(-9,2.5,113),C.dark,Enum.Material.Concrete,true,m,"WedgePart")
part("CenterPyramidB",Vector3.new(20,4,12),CFrame.new(9,2.5,113)*CFrame.Angles(0,math.rad(180),0),C.dark,Enum.Material.Concrete,true,m,"WedgePart")
part("ManualPad",Vector3.new(22,1.2,8),CFrame.new(0,1.6,132),Color3.fromRGB(62,63,66),Enum.Material.Concrete,true)
for i=0,3 do part("Stair"..i,Vector3.new(14,1,3),CFrame.new(-25,1+i*.5,92+i*2.2),Color3.fromRGB(66,67,70),Enum.Material.Concrete,true) end
rail("CenterGrindRail",Vector3.new(22,.25,.25),CFrame.new(17,2.8,92))
for _,x in ipairs({7,27}) do rail("RailLeg"..x,Vector3.new(.25,2.4,.25),CFrame.new(x,1.7,92)) end
rail("LongGrindRail",Vector3.new(.25,.25,28),CFrame.new(-18,2.6,132))
for _,z in ipairs({120,144}) do rail("LongRailLeg"..z,Vector3.new(.25,2.2,.25),CFrame.new(-18,1.65,z)) end

-- simple park identity / photo wall without neon.
local sign=part("SkateparkSign",Vector3.new(34,7,.45),CFrame.new(0,7.5,148.8),Color3.fromRGB(22,23,26),Enum.Material.Metal,false)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=45;sg.Parent=sign
local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text="BBYA SKATEPARK";t.TextColor3=C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.Parent=sg

print("[BBYA] Rear Skatepark online: half walls + wire fence + banks/rails")
