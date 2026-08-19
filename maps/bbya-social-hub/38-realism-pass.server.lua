local W=game:GetService("Workspace")
local root=W:WaitForChild("BBYA_ZERO_BUILD")
local old=root:FindFirstChild("RealismPass");if old then old:Destroy() end
local m=Instance.new("Model",root);m.Name="RealismPass"
local C={black=Color3.fromRGB(12,13,16),charcoal=Color3.fromRGB(28,30,36),metal=Color3.fromRGB(56,60,68),fabric=Color3.fromRGB(44,37,48),pink=Color3.fromRGB(255,42,157),cyan=Color3.fromRGB(0,174,255),blue=Color3.fromRGB(0,142,255),yellow=Color3.fromRGB(255,202,36),warm=Color3.fromRGB(205,160,115)}
local function part(n,size,cf,col,mat,parent,class)
 local p=Instance.new(class or "Part");p.Name=n;p.Anchored=true;p.CanCollide=true;p.Size=size;p.CFrame=cf;p.Color=col;p.Material=mat or Enum.Material.SmoothPlastic;p.Parent=parent or m;return p
end
local function neon(n,size,cf,col,parent)local p=part(n,size,cf,col,Enum.Material.Neon,parent);p.CanCollide=false;return p end
local function cyl(n,size,cf,col,parent)local p=part(n,size,cf,col,Enum.Material.Metal,parent);p.Shape=Enum.PartType.Cylinder;return p end
local function wedge(n,size,cf,col,parent)local p=part(n,size,cf,col,Enum.Material.SmoothPlastic,parent,"WedgePart");return p end
local function roundedSofa(prefix,cf,accent)
 local g=Instance.new("Model",m);g.Name=prefix
 local base=part(prefix.."Seat",Vector3.new(12,1.5,4.8),cf,C.fabric,Enum.Material.Fabric,g)
 local back=part(prefix.."Back",Vector3.new(12,3.8,1.5),cf*CFrame.new(0,2.15,1.7)*CFrame.Angles(math.rad(-8),0,0),C.fabric,Enum.Material.Fabric,g)
 for _,sx in ipairs({-1,1}) do
  local arm=cyl(prefix.."Arm"..sx,Vector3.new(2.1,1.5,2.1),cf*CFrame.new(sx*5.6,.35,0)*CFrame.Angles(0,0,math.rad(90)),C.fabric,g)
  arm.Material=Enum.Material.Fabric
 end
 for _,x in ipairs({-4.5,-1.5,1.5,4.5}) do part(prefix.."Leg"..x,Vector3.new(.35,.8,.35),cf*CFrame.new(x,-1.05,1.3),C.metal,Enum.Material.Metal,g) end
 neon(prefix.."Accent",Vector3.new(9,.08,.08),cf*CFrame.new(0,-.72,-2.45),accent,g)
 return g
end
local function cocktailTable(prefix,cf)
 local g=Instance.new("Model",m);g.Name=prefix
 cyl(prefix.."Top",Vector3.new(.45,3.4,3.4),cf*CFrame.Angles(0,0,math.rad(90)),C.black,g)
 cyl(prefix.."Stem",Vector3.new(2.2,.35,.35),cf*CFrame.new(0,-1.25,0),C.metal,g)
 cyl(prefix.."Foot",Vector3.new(.25,2.5,2.5),cf*CFrame.new(0,-2.35,0)*CFrame.Angles(0,0,math.rad(90)),C.metal,g)
end
local function lineArray(prefix,cf,accent)
 local g=Instance.new("Model",m);g.Name=prefix
 for i=0,3 do
  local y=i*2.1
  local a=math.rad((i-1.5)*4)
  local cab=wedge(prefix.."Cab"..i,Vector3.new(6.3,2,3.6),cf*CFrame.new(0,y,0)*CFrame.Angles(a,0,0),C.black,g)
  local grille=part(prefix.."Grille"..i,Vector3.new(5.5,1.25,.16),cab.CFrame*CFrame.new(0,0,-1.83),Color3.fromRGB(22,24,28),Enum.Material.DiamondPlate,g)
  grille.CanCollide=false
  for _,x in ipairs({-1.6,1.6}) do cyl(prefix.."Driver"..i..x,Vector3.new(.18,1.15,1.15),cab.CFrame*CFrame.new(x,0,-1.95)*CFrame.Angles(0,math.rad(90),0),C.metal,g).CanCollide=false end
 end
 part(prefix.."Sub",Vector3.new(7.2,4.8,5.4),cf*CFrame.new(0,-3.4,.5),C.black,Enum.Material.Metal,g)
 cyl(prefix.."SubCone",Vector3.new(.25,3.3,3.3),cf*CFrame.new(0,-3.4,-2.25)*CFrame.Angles(0,math.rad(90),0),C.metal,g).CanCollide=false
 neon(prefix.."Accent",Vector3.new(4.5,.08,.08),cf*CFrame.new(0,7.6,-1.95),accent,g)
end
local function playerUnit(prefix,cf,accent)
 local g=Instance.new("Model",m);g.Name=prefix
 part(prefix.."Chassis",Vector3.new(7,.7,5),cf,C.black,Enum.Material.Metal,g)
 local jog=cyl(prefix.."Jog",Vector3.new(.42,3.1,3.1),cf*CFrame.new(0,.55,0)*CFrame.Angles(0,0,math.rad(90)),C.metal,g)
 jog.Material=Enum.Material.SmoothPlastic
 neon(prefix.."JogRing",Vector3.new(.12,3.35,3.35),cf*CFrame.new(0,.78,0)*CFrame.Angles(0,0,math.rad(90)),accent,g)
 part(prefix.."Screen",Vector3.new(2.4,.12,1.5),cf*CFrame.new(1.8,.52,-1.35)*CFrame.Angles(math.rad(-8),0,0),accent,Enum.Material.Neon,g).CanCollide=false
 for r=0,1 do for c=0,3 do neon(prefix.."Pad"..r..c,Vector3.new(.5,.1,.5),cf*CFrame.new(-2.2+c*.65,.52,1.35+r*.62),((r+c)%2==0) and accent or C.warm,g) end end
 for i=0,4 do cyl(prefix.."Knob"..i,Vector3.new(.28,.32,.32),cf*CFrame.new(2.25+i*.55,.58,.4)*CFrame.Angles(0,0,math.rad(90)),C.metal,g).CanCollide=false end
end
local function mixer(prefix,cf,accent)
 local g=Instance.new("Model",m);g.Name=prefix
 part(prefix.."Body",Vector3.new(6.5,.8,5),cf,C.black,Enum.Material.Metal,g)
 for ch=-1.5,1.5,1 do
  for row=0,2 do cyl(prefix.."Knob"..ch..row,Vector3.new(.22,.3,.3),cf*CFrame.new(ch*1.15,.58,-1.4+row*.75)*CFrame.Angles(0,0,math.rad(90)),row==0 and accent or C.metal,g).CanCollide=false end
  part(prefix.."Fader"..ch,Vector3.new(.16,.12,1.45),cf*CFrame.new(ch*1.15,.58,1.25),C.metal,Enum.Material.Metal,g).CanCollide=false
 end
 for i=-4,4 do neon(prefix.."Meter"..i,Vector3.new(.12,.08,.45),cf*CFrame.new(i*.35,.62,-2),i<0 and C.cyan or C.yellow,g) end
end
-- Underground: replace the most visibly boxy lounge read with layered curved-looking silhouettes.
roundedSofa("UGSofaLeft",CFrame.new(-46,-12.1,5)*CFrame.Angles(0,math.rad(90),0),C.blue)
roundedSofa("UGSofaRight",CFrame.new(46,-12.1,5)*CFrame.Angles(0,math.rad(-90),0),C.yellow)
cocktailTable("UGTableLeft",CFrame.new(-38,-11.4,5));cocktailTable("UGTableRight",CFrame.new(38,-11.4,5))
-- Professional club PA silhouettes; intentionally brand-neutral.
lineArray("UGPALeft",CFrame.new(-28,-8.8,30),C.blue);lineArray("UGPARight",CFrame.new(28,-8.8,30),C.yellow)
lineArray("MainPALeft",CFrame.new(-28,5.3,43),C.cyan);lineArray("MainPARight",CFrame.new(28,5.3,43),C.pink)
-- Brand-neutral media-player + 4-channel mixer package with denser controls.
playerUnit("UGPlayerL",CFrame.new(-8,-8.9,30.4),C.blue);mixer("UGMixer",CFrame.new(0,-8.9,30.4),C.yellow);playerUnit("UGPlayerR",CFrame.new(8,-8.9,30.4),C.yellow)
-- bar stools with circular seats and foot rings for a less blocky silhouette
for _,x in ipairs({-12,-6,0,6,12}) do
 local g=Instance.new("Model",m);g.Name="UGBarStool"..x
 cyl("Seat",Vector3.new(.7,2.4,2.4),CFrame.new(x,-12,-29.5)*CFrame.Angles(0,0,math.rad(90)),C.fabric,g).Material=Enum.Material.Fabric
 cyl("Stem",Vector3.new(2.4,.32,.32),CFrame.new(x,-13.4,-29.5),C.metal,g)
 cyl("Base",Vector3.new(.22,2,2),CFrame.new(x,-14.65,-29.5)*CFrame.Angles(0,0,math.rad(90)),C.metal,g)
end
print("[BBYA] Realism pass installed: rounded lounge silhouettes, line-array PA, denser professional DJ gear")