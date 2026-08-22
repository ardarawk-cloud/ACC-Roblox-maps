-- ACC Mountain Social Adventure — Upper Mountain Scenic v4.5
local Workspace=game:GetService("Workspace")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20);if not root then return end
local old=root:FindFirstChild("UpperScenicV45");if old then old:Destroy() end
local f=Instance.new("Folder");f.Name="UpperScenicV45";f.Parent=root

local function mk(n,s,cf,m,c,p,tr,coll)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Rock
 if c then x.Color=c end;x.Transparency=tr or 0;x.CanCollide=coll~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or f;return x
end
local function beam(n,a,b,w,m,c,p)
 local d=b-a;if d.Magnitude<.05 then return end
 return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),m,c,p,0,true)
end
local function rock(pos,sz,rot,col)
 local p=mk("NaturalRock",sz,CFrame.new(pos)*CFrame.Angles(math.rad(rot.X),math.rad(rot.Y),math.rad(rot.Z)),Enum.Material.Rock,col or Color3.fromRGB(87,89,87),f)
 p.Shape=Enum.PartType.Ball;return p
end
local function shrub(pos,scale,col)
 local m=Instance.new("Model");m.Name="AlpineShrub";m.Parent=f
 for i=1,4 do local a=i/4*math.pi*2;local q=mk("Shrub",Vector3.new(3.8*scale,2.1*scale,3.8*scale),CFrame.new(pos+Vector3.new(math.cos(a)*1.6*scale,.8*scale,math.sin(a)*1.6*scale)),Enum.Material.LeafyGrass,col or Color3.fromRGB(64,88,52),m,0,false);q.Shape=Enum.PartType.Ball end
end
local function cairn(pos,count,scale)
 local m=Instance.new("Model");m.Name="Cairn";m.Parent=f
 local y=0
 for i=1,count do local s=(count-i+2)*.8*scale;local r=rock(pos+Vector3.new((i%2==0 and .35 or -.25)*scale,y+s*.34,0),Vector3.new(s*.95,s*.62,s*.8),Vector3.new(i*7,i*19,i*5),Color3.fromRGB(94,95,92));r.Parent=m;y+=s*.48 end
end

math.randomseed(450822)
local fog=Vector3.new(-265,455,-1480)
local highland=Vector3.new(-78,535,-1705)
local ridge=Vector3.new(165,615,-1910)
local falseSummit=Vector3.new(265,685,-2120)
local finalApproach=Vector3.new(112,750,-2315)
local summit=Vector3.new(0,815,-2525)

-- Fog zone: wet rocks, stunted vegetation and a narrow trail corridor.
for i=1,52 do
 local a=math.random()*math.pi*2;local r=math.random(28,125);local p=fog+Vector3.new(math.cos(a)*r,math.random(-5,9),math.sin(a)*r)
 if i%3==0 then shrub(p,.55+math.random()*.35,Color3.fromRGB(54,75,48)) else rock(p,Vector3.new(math.random(3,8),math.random(2,5),math.random(3,9)),Vector3.new(math.random(-18,18),math.random(0,180),math.random(-14,14)),Color3.fromRGB(82,88,84)) end
end
for i=1,6 do cairn(fog+Vector3.new(-20+i*10,3,-16-i*12),3,.62) end

-- Highland: vegetation drops in height and broad open sightlines appear.
for i=1,46 do
 local a=math.random()*math.pi*2;local r=math.random(35,145);local p=highland+Vector3.new(math.cos(a)*r,math.random(-4,8),math.sin(a)*r)
 if i%2==0 then shrub(p,.45+math.random()*.3,Color3.fromRGB(73,92,55)) else rock(p,Vector3.new(math.random(4,10),math.random(2,6),math.random(4,11)),Vector3.new(math.random(-20,20),math.random(0,180),math.random(-18,18)),Color3.fromRGB(92,92,87)) end
end
local highSign=mk("HighlandMarker",Vector3.new(9,4,.8),CFrame.new(highland+Vector3.new(18,5,-14))*CFrame.Angles(0,math.rad(-22),0),Enum.Material.WoodPlanks,Color3.fromRGB(76,57,40),f)
local hsg=Instance.new("SurfaceGui");hsg.Face=Enum.NormalId.Front;hsg.Parent=highSign;local htx=Instance.new("TextLabel");htx.Size=UDim2.fromScale(1,1);htx.BackgroundTransparency=1;htx.Text="HIGHLAND";htx.TextScaled=true;htx.Font=Enum.Font.GothamBold;htx.TextColor3=Color3.fromRGB(231,225,207);htx.Parent=hsg

-- Ridge: build an irregular rocky spine, not a rectangular bridge.
local ridgePts={ridge,Vector3.new(205,637,-1970),Vector3.new(238,660,-2038),falseSummit}
for i=1,#ridgePts-1 do
 local a,b=ridgePts[i],ridgePts[i+1]
 for s=0,8 do
  local t=s/8;local p=a:Lerp(b,t);local sway=math.sin((i*7+s)*1.17)*5
  local d=b-a;local flat=Vector3.new(d.X,0,d.Z);local side=flat.Magnitude>0 and Vector3.new(-flat.Z,0,flat.X).Unit or Vector3.xAxis
  local q=p+side*sway
  rock(q-Vector3.new(0,2.2,0),Vector3.new(18+math.random()*5,7+math.random()*3,16+math.random()*5),Vector3.new(math.random(-10,10),math.random(0,180),math.random(-8,8)),Color3.fromRGB(86,87,85))
  if s%3==1 then cairn(q+side*8+Vector3.new(0,3,0),3,.5) end
 end
end

-- False summit: obvious viewpoint, but main summit remains visible ahead.
for i=1,18 do local a=i/18*math.pi*2;rock(falseSummit+Vector3.new(math.cos(a)*math.random(18,38),math.random(-2,5),math.sin(a)*math.random(18,38)),Vector3.new(math.random(5,10),math.random(3,7),math.random(5,11)),Vector3.new(math.random(-14,14),math.random(0,180),math.random(-12,12)),Color3.fromRGB(90,91,88)) end
local fs=mk("FalseSummitBoard",Vector3.new(18,6,1),CFrame.lookAt(falseSummit+Vector3.new(-8,8,-18),finalApproach),Enum.Material.WoodPlanks,Color3.fromRGB(73,55,40),f)
local fsg=Instance.new("SurfaceGui");fsg.Face=Enum.NormalId.Front;fsg.Parent=fs;local fst=Instance.new("TextLabel");fst.Size=UDim2.fromScale(1,1);fst.BackgroundTransparency=1;fst.Text="FALSE SUMMIT\nPUNCAK UTAMA MASIH DI DEPAN";fst.TextScaled=true;fst.TextWrapped=true;fst.Font=Enum.Font.GothamBold;fst.TextColor3=Color3.fromRGB(236,229,210);fst.Parent=fsg

-- Final approach: exposed rock route with sparse cairns.
local finalPts={falseSummit,Vector3.new(214,710,-2180),Vector3.new(166,732,-2250),finalApproach,Vector3.new(62,785,-2420),summit}
for i=1,#finalPts-1 do
 local a,b=finalPts[i],finalPts[i+1]
 for s=0,6 do local t=s/6;local p=a:Lerp(b,t);rock(p-Vector3.new(0,2.0,0),Vector3.new(14+math.random()*4,5+math.random()*2,13+math.random()*4),Vector3.new(math.random(-9,9),math.random(0,180),math.random(-7,7)),Color3.fromRGB(88,89,87));if s==3 then cairn(p+Vector3.new(7,2,4),4,.55) end end
end

-- Replace the old tower-like monument with a grounded summit ensemble.
local oldMon=root:FindFirstChild("ACC_SummitMonument");if oldMon then oldMon:Destroy() end
for i=1,24 do local a=i/24*math.pi*2;local rr=math.random(22,48);rock(summit+Vector3.new(math.cos(a)*rr,math.random(-3,4),math.sin(a)*rr),Vector3.new(math.random(5,12),math.random(3,8),math.random(5,13)),Vector3.new(math.random(-16,16),math.random(0,180),math.random(-12,12)),Color3.fromRGB(91,92,89)) end
cairn(summit+Vector3.new(0,2,-8),7,1.0)
local pole=mk("SummitPole",Vector3.new(.8,13,.8),CFrame.new(summit+Vector3.new(7,7,2)),Enum.Material.Metal,Color3.fromRGB(89,91,90),f)
local board=mk("SummitBoard",Vector3.new(17,6,.8),CFrame.lookAt(summit+Vector3.new(7,10,2),summit+Vector3.new(7,10,22)),Enum.Material.WoodPlanks,Color3.fromRGB(74,57,41),f)
local sg=Instance.new("SurfaceGui");sg.Face=Enum.NormalId.Front;sg.Parent=board;local tx=Instance.new("TextLabel");tx.Size=UDim2.fromScale(1,1);tx.BackgroundTransparency=1;tx.Text="PUNCAK ACC\n815 STUD";tx.TextScaled=true;tx.TextWrapped=true;tx.Font=Enum.Font.GothamBold;tx.TextColor3=Color3.fromRGB(239,232,214);tx.Parent=sg
-- Small prayer/wind flags add scale and motion-ready detail without blocking views.
local flagColors={Color3.fromRGB(177,61,50),Color3.fromRGB(219,177,64),Color3.fromRGB(72,117,165),Color3.fromRGB(228,225,210),Color3.fromRGB(72,129,76)}
local flagA=summit+Vector3.new(-16,8,8);local flagB=summit+Vector3.new(18,8,8);beam("SummitFlagLine",flagA,flagB,.12,Enum.Material.SmoothPlastic,Color3.fromRGB(70,68,65),f)
for i=1,9 do local t=i/10;local p=flagA:Lerp(flagB,t);mk("WindFlag",Vector3.new(3.2,1.8,.18),CFrame.new(p-Vector3.new(0,1.2,0))*CFrame.Angles(0,math.rad((i%2==0 and 8 or -8)),math.rad(-8)),Enum.Material.Fabric,flagColors[((i-1)%#flagColors)+1],f,0,false) end

-- Invisible photo trigger area; visual remains natural stone.
local photo=mk("SummitPhotoSpot",Vector3.new(20,5,20),CFrame.new(summit+Vector3.new(-18,3,-2)),Enum.Material.SmoothPlastic,Color3.new(1,1,1),root:FindFirstChild("PhotoSpots") or f,1,false);photo:SetAttribute("PhotoSpot",true);photo:SetAttribute("SpotName","Summit Panorama")

root:SetAttribute("FogZoneReady",true)
root:SetAttribute("HighlandReady",true)
root:SetAttribute("RidgeReady",true)
root:SetAttribute("FalseSummitReady",true)
root:SetAttribute("SummitScenicReady",true)
root:SetAttribute("UpperScenicVersion","4.5")
print("[ACC] Mountain v4.5 upper scenic zones ready")