-- BBYA SOCIAL HUB — SKATEPARK UPGRADE v2
-- Fence-mounted road lights, graffiti program and denser skate obstacles.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local park=root:WaitForChild("RearSkatepark",30)
if not park then return end
task.wait(.35)

local old=park:FindFirstChild("SkateparkUpgradeV2")
if old then old:Destroy() end
local out=Instance.new("Model");out.Name="SkateparkUpgradeV2";out.Parent=park
out:SetAttribute("FenceRoadLights",true)
out:SetAttribute("GraffitiWalls",true)
out:SetAttribute("ObstacleUpgrade",true)

local C={dark=Color3.fromRGB(23,24,27),metal=Color3.fromRGB(72,75,80),concrete=Color3.fromRGB(82,83,86),white=Color3.fromRGB(244,241,229),warm=Color3.fromRGB(255,232,176),cyan=Color3.fromRGB(30,176,210),pink=Color3.fromRGB(235,50,143),yellow=Color3.fromRGB(234,185,48),blue=Color3.fromRGB(46,93,182),purple=Color3.fromRGB(139,70,190)}
local function part(name,size,cf,color,mat,collide,parent,class)
 local p
 if class=="WedgePart" then p=Instance.new("WedgePart") else p=Instance.new("Part") end
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.dark;p.Material=mat or Enum.Material.Metal;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out;return p
end

-- Tall road-style fixtures physically attached to the steel fence posts.
local lights=Instance.new("Model");lights.Name="FenceRoadLights";lights.Parent=out
local function roadLamp(name,pos,faceDir)
 local mast=part(name.."Mast",Vector3.new(.28,5.7,.28),CFrame.new(pos.X,12.7,pos.Z),C.metal,Enum.Material.Metal,false,lights)
 local armCenter=Vector3.new(pos.X,15.35,pos.Z)+faceDir*2.1
 local arm=part(name.."Arm",Vector3.new(.24,.24,4.4),CFrame.lookAt(armCenter,armCenter+faceDir)*CFrame.Angles(0,math.rad(90),0),C.metal,Enum.Material.Metal,false,lights)
 local headPos=Vector3.new(pos.X,15.15,pos.Z)+faceDir*4.15
 local head=part(name.."Head",Vector3.new(2.5,.32,1.15),CFrame.lookAt(headPos,headPos+faceDir),Color3.fromRGB(45,47,50),Enum.Material.Metal,false,lights)
 local lens=part(name.."Lens",Vector3.new(2.1,.08,.86),head.CFrame*CFrame.new(0,-.2,0),C.warm,Enum.Material.Glass,false,lights)
 lens.Transparency=.12
 local spot=Instance.new("SpotLight");spot.Name="RoadWash";spot.Face=Enum.NormalId.Bottom;spot.Color=C.warm;spot.Brightness=2.4;spot.Range=38;spot.Angle=72;spot.Shadows=true;spot.Parent=head
end
for _,x in ipairs({-48,-24,0,24,48}) do roadLamp("North"..x,Vector3.new(x,0,149.4),Vector3.new(0,0,-1)) end
for _,z in ipairs({92,124}) do
 roadLamp("West"..z,Vector3.new(-58.4,0,z),Vector3.new(1,0,0))
 roadLamp("East"..z,Vector3.new(58.4,0,z),Vector3.new(-1,0,0))
end

-- Graffiti canvases on the concrete half-walls. These are matte paint, not neon.
local graffiti=Instance.new("Model");graffiti.Name="GraffitiProgram";graffiti.Parent=out
local function graffitiPanel(name,cf,size,face,word,sub,accent)
 local backing=part(name,size,cf,Color3.fromRGB(27,28,31),Enum.Material.SmoothPlastic,false,graffiti)
 backing.Transparency=.04
 local sg=Instance.new("SurfaceGui");sg.Name="GraffitiCanvas";sg.Face=face;sg.PixelsPerStud=55;sg.LightInfluence=.15;sg.Parent=backing
 local main=Instance.new("TextLabel");main.BackgroundTransparency=1;main.Position=UDim2.fromScale(.04,.03);main.Size=UDim2.fromScale(.92,.72);main.Text=word;main.Font=Enum.Font.FredokaOne;main.TextScaled=true;main.TextColor3=accent;main.Rotation=-4;main.Parent=sg
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(10,10,12);stroke.Thickness=4;stroke.Transparency=.08;stroke.Parent=main
 local small=Instance.new("TextLabel");small.BackgroundTransparency=1;small.Position=UDim2.fromScale(.08,.72);small.Size=UDim2.fromScale(.84,.2);small.Text=sub;small.Font=Enum.Font.GothamBlack;small.TextScaled=true;small.TextColor3=C.white;small.Rotation=2;small.Parent=sg
 -- random-looking paint slashes around the canvas.
 for i=1,7 do
  local slash=Instance.new("Frame");slash.AnchorPoint=Vector2.new(.5,.5);slash.Position=UDim2.fromScale(.12+i*.11,.18+(i%3)*.19);slash.Size=UDim2.fromScale(.18,.035);slash.Rotation=-32+i*11;slash.BackgroundColor3=(i%2==0 and accent or C.white);slash.BackgroundTransparency=.12;slash.BorderSizePixel=0;slash.Parent=sg
 end
end
-- North wall faces inward toward -Z.
graffitiPanel("NorthGraffitiA",CFrame.new(-35,3.2,148.86),Vector3.new(34,3.0,.18),Enum.NormalId.Front,"BBYA","RIDE AFTER DARK",C.pink)
graffitiPanel("NorthGraffitiB",CFrame.new(35,3.2,148.86),Vector3.new(34,3.0,.18),Enum.NormalId.Front,"NO SLEEP","SKATE • MUSIC • CITY",C.cyan)
-- West/east wall panels face inward.
graffitiPanel("WestGraffiti",CFrame.new(-58.86,3.1,118)*CFrame.Angles(0,math.rad(90),0),Vector3.new(30,3.0,.18),Enum.NormalId.Front,"DROP IN","BBYA CREW",C.yellow)
graffitiPanel("EastGraffiti",CFrame.new(58.86,3.1,118)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(30,3.0,.18),Enum.NormalId.Front,"KEEP ROLLING","BALI NIGHT SESSION",C.purple)

-- Denser central skate line: funbox, kicker pair, ledge and coping rails.
local obstacles=Instance.new("Model");obstacles.Name="ProLine";obstacles.Parent=out
part("FunboxTop",Vector3.new(18,1.2,11),CFrame.new(1,2.15,108),C.concrete,Enum.Material.Concrete,true,obstacles)
part("FunboxRampA",Vector3.new(18,4.2,12),CFrame.new(1,2.6,97)*CFrame.Angles(0,math.rad(180),0),C.concrete,Enum.Material.Concrete,true,obstacles,"WedgePart")
part("FunboxRampB",Vector3.new(18,4.2,12),CFrame.new(1,2.6,119),C.concrete,Enum.Material.Concrete,true,obstacles,"WedgePart")
local centerRail=part("FunboxRail",Vector3.new(.28,.28,17),CFrame.new(1,4.15,108),C.metal,Enum.Material.Metal,true,obstacles)
for _,z in ipairs({101,115}) do part("FunboxRailLeg"..z,Vector3.new(.24,2.2,.24),CFrame.new(1,3.05,z),C.metal,Enum.Material.Metal,true,obstacles) end
part("StreetLedge",Vector3.new(20,1.6,4.5),CFrame.new(31,1.35,132),Color3.fromRGB(60,61,64),Enum.Material.Concrete,true,obstacles)
part("LedgeCoping",Vector3.new(20,.18,.36),CFrame.new(31,2.24,130),C.metal,Enum.Material.Metal,true,obstacles)
part("KickerWest",Vector3.new(12,3.6,10),CFrame.new(-35,2.3,101)*CFrame.Angles(0,math.rad(90),0),C.concrete,Enum.Material.Concrete,true,obstacles,"WedgePart")
part("KickerEast",Vector3.new(12,3.6,10),CFrame.new(35,2.3,101)*CFrame.Angles(0,math.rad(-90),0),C.concrete,Enum.Material.Concrete,true,obstacles,"WedgePart")

print("[BBYA] Skatepark v2 online: fence road lights / graffiti / pro obstacle line")
