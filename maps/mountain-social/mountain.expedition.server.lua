-- ACC Mountain Social Adventure — Expedition Layer v4.3
-- Realistic progression after POS 1: lower forest -> river crossing -> dense forest -> mid camp -> cliff approach.
local Workspace=game:GetService("Workspace")
local Terrain=Workspace.Terrain
local root=Workspace:WaitForChild("ACC_MountainSocial",20)
if not root then return end
local old=root:FindFirstChild("ExpeditionV43");if old then old:Destroy() end
local zone=Instance.new("Folder");zone.Name="ExpeditionV43";zone.Parent=root

local function mk(n,s,cf,m,col,p,tr,co)
 local x=Instance.new("Part");x.Name=n;x.Anchored=true;x.Size=s;x.CFrame=cf;x.Material=m or Enum.Material.Ground
 if col then x.Color=col end;x.Transparency=tr or 0;x.CanCollide=co~=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=p or zone;return x
end
local function beam(n,a,b,w,mat,col,p,tr,co)
 local d=b-a;if d.Magnitude<.05 then return end
 return mk(n,Vector3.new(w,w,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,p,tr,co)
end
local function ball(n,pos,size,mat,col,p,co)
 local x=mk(n,Vector3.new(size,size*.82,size),CFrame.new(pos),mat,col,p,0,co);x.Shape=Enum.PartType.Ball;return x
end
local function tree(pos,scale,dense)
 local m=Instance.new("Model");m.Name=dense and "DenseForestTree" or "LowerForestTree";m.Parent=zone
 local bark=Color3.fromRGB(70,52,36);local leaf=dense and Color3.fromRGB(31,66,36) or Color3.fromRGB(42,83,43)
 local trunk=mk("Trunk",Vector3.new(2.0*scale,13*scale,2.0*scale),CFrame.new(pos+Vector3.new(0,6.5*scale,0)),Enum.Material.Wood,bark,m)
 beam("Branch1",pos+Vector3.new(0,8*scale,0),pos+Vector3.new(4.2*scale,11.5*scale,1.8*scale),1.0*scale,Enum.Material.Wood,bark,m)
 beam("Branch2",pos+Vector3.new(0,9*scale,0),pos+Vector3.new(-4*scale,12*scale,-1.2*scale),.9*scale,Enum.Material.Wood,bark,m)
 ball("CrownA",pos+Vector3.new(0,15.5*scale,0),8.4*scale,Enum.Material.LeafyGrass,leaf,m,false)
 ball("CrownB",pos+Vector3.new(4.0*scale,14.5*scale,1.0*scale),6.0*scale,Enum.Material.LeafyGrass,leaf,m,false)
 ball("CrownC",pos+Vector3.new(-3.7*scale,14.8*scale,-1.5*scale),5.8*scale,Enum.Material.LeafyGrass,leaf,m,false)
 if dense then ball("CrownD",pos+Vector3.new(1.0*scale,17.4*scale,-2.1*scale),5.4*scale,Enum.Material.LeafyGrass,Color3.fromRGB(27,59,33),m,false) end
 return trunk
end
local function fern(pos,scale)
 local m=Instance.new("Model");m.Name="Fern";m.Parent=zone
 for i=1,6 do local a=(i-1)/6*math.pi*2;local leaf=mk("Frond",Vector3.new(.55*scale,.25*scale,5.2*scale),CFrame.new(pos+Vector3.new(0,.65*scale,0))*CFrame.Angles(math.rad(-18),a,math.rad(12)),Enum.Material.LeafyGrass,Color3.fromRGB(45,91,48),m,0,false);leaf.CanCollide=false end
end
local function rock(pos,size)
 local r=ball("MossRock",pos,size,Enum.Material.Rock,Color3.fromRGB(78,82,76),zone,true)
 r.CFrame=r.CFrame*CFrame.Angles(math.rad(math.random(-12,12)),math.rad(math.random(0,180)),math.rad(math.random(-12,12)))
 local moss=ball("RockMoss",pos+Vector3.new(0,size*.34,0),size*.56,Enum.Material.LeafyGrass,Color3.fromRGB(48,78,45),zone,false);moss.Transparency=.08
 return r
end
local function sign(pos,text,rot)
 local post=mk("TrailSignPost",Vector3.new(.8,6,.8),CFrame.new(pos+Vector3.new(0,3,0)),Enum.Material.Wood,Color3.fromRGB(75,55,38),zone)
 local board=mk("TrailSignBoard",Vector3.new(10,3,.65),CFrame.new(pos+Vector3.new(0,5.3,0))*CFrame.Angles(0,math.rad(rot or 0),0),Enum.Material.WoodPlanks,Color3.fromRGB(81,60,41),zone)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=28;g.Parent=board
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextScaled=true;t.TextWrapped=true;t.Font=Enum.Font.GothamBold;t.TextColor3=Color3.fromRGB(231,224,203);t.Parent=g
 return post
end

math.randomseed(430822)
local P1=Vector3.new(-55,44,-30)
local P2=Vector3.new(-180,100,-270)
local P3=Vector3.new(20,160,-520)
local P4=Vector3.new(185,225,-770)
local CAMP=Vector3.new(42,295,-1020)
local CLIFF=Vector3.new(-185,375,-1250)

-- Natural shoulders around the real trail: many smaller terrain forms, avoiding a single spherical mountain silhouette.
for i=0,10 do
 local t=i/10;local c=P1:Lerp(P2,t);local sway=Vector3.new(math.sin(t*8)*32,-18,math.cos(t*6)*24)
 Terrain:FillBall(c+sway,55+math.random(0,22),i<5 and Enum.Material.Grass or Enum.Material.Ground)
end
for i=0,12 do
 local t=i/12;local c=P2:Lerp(P3,t);local side=(i%2==0 and 1 or -1);Terrain:FillBall(c+Vector3.new(side*math.random(28,62),-22,math.random(-22,22)),math.random(45,68),Enum.Material.Ground)
end
for i=0,12 do
 local t=i/12;local c=P3:Lerp(P4,t);Terrain:FillBall(c+Vector3.new((i%2==0 and -1 or 1)*math.random(30,70),-25,math.random(-28,28)),math.random(48,72),Enum.Material.Ground)
end

-- Lower forest: tall irregular canopy with undergrowth and occasional clear sightlines.
for i=1,58 do
 local t=math.random();local c=P1:Lerp(P2,t);local d=P2-P1;local side=Vector3.new(-d.Z,0,d.X).Unit;local offset=side*(math.random(28,105)*(math.random()<.5 and -1 or 1));local q=c+offset+Vector3.new(0,-1,math.random(-18,18));tree(q,.68+math.random()*.48,false)
 if i%3==0 then fern(q+Vector3.new(math.random(-5,5),0,math.random(-5,5)),.65+math.random()*.35) end
end
for i=1,22 do local t=math.random();local c=P1:Lerp(P2,t);rock(c+Vector3.new(math.random(-70,70),-1,math.random(-35,35)),math.random(4,9)) end
-- Fallen logs and root-like crossings.
for i,t in ipairs({.28,.57,.76}) do local c=P1:Lerp(P2,t);local log=mk("FallenLog_"..i,Vector3.new(2.3,2.3,22),CFrame.new(c+Vector3.new((i-2)*5,2,6))*CFrame.Angles(math.rad(4*i),math.rad(38+i*19),math.rad(86)),Enum.Material.Wood,Color3.fromRGB(72,52,35),zone);log.Shape=Enum.PartType.Cylinder end
sign(P1+Vector3.new(12,0,-20),"HUTAN BAWAH\nJAGA JALUR",-12)

-- River valley: a meandering water ribbon built from short water pools, stones and eroded banks.
local riverPts={Vector3.new(-75,148,-558),Vector3.new(-45,151,-546),Vector3.new(-12,154,-535),Vector3.new(20,157,-520),Vector3.new(54,159,-507),Vector3.new(88,161,-495)}
for i,p in ipairs(riverPts) do
 Terrain:FillBall(p-Vector3.new(0,4,0),20,Enum.Material.Water)
 Terrain:FillBall(p+Vector3.new(0,-11,0),25,Enum.Material.Mud)
 if i<#riverPts then local q=riverPts[i+1];local mid=(p+q)/2;Terrain:FillBlock(CFrame.lookAt(mid-Vector3.new(0,5,0),q-Vector3.new(0,5,0)),Vector3.new(34,8,(q-p).Magnitude+10),Enum.Material.Water) end
end
for i=1,30 do local base=P3+Vector3.new(math.random(-105,105),math.random(-2,5),math.random(-55,55));local r=ball("RiverBoulder",base,math.random(4,10),Enum.Material.Rock,Color3.fromRGB(84,88,83),zone,true);r.CFrame=r.CFrame*CFrame.Angles(math.random(),math.random(),math.random()) end
-- Proper wooden bridge, slightly elevated, with rails and support posts.
local bridgeC=P3+Vector3.new(0,7,-4);local bridgeA=bridgeC+Vector3.new(-37,0,0);local bridgeB=bridgeC+Vector3.new(37,0,0)
for i=-12,12 do mk("BridgePlank",Vector3.new(3.1,.8,10),CFrame.new(bridgeC+Vector3.new(i*3,0,0)),Enum.Material.WoodPlanks,Color3.fromRGB(92,67,43),zone) end
for _,z in ipairs({-5.2,5.2}) do
 beam("BridgeRailTop",bridgeA+Vector3.new(0,4,z),bridgeB+Vector3.new(0,4,z),.45,Enum.Material.Wood,Color3.fromRGB(72,52,36),zone)
 beam("BridgeRailMid",bridgeA+Vector3.new(0,2.3,z),bridgeB+Vector3.new(0,2.3,z),.35,Enum.Material.Wood,Color3.fromRGB(72,52,36),zone)
 for i=-6,6 do mk("BridgeRailPost",Vector3.new(.5,4,.5),CFrame.new(bridgeC+Vector3.new(i*6,2,z)),Enum.Material.Wood,Color3.fromRGB(72,52,36),zone) end
end
for _,x in ipairs({-32,32}) do for _,z in ipairs({-4.5,4.5}) do mk("BridgeSupport",Vector3.new(1.4,11,1.4),CFrame.new(bridgeC+Vector3.new(x,-5,z)),Enum.Material.Wood,Color3.fromRGB(68,50,35),zone) end end
sign(P3+Vector3.new(-30,6,38),"SUNGAI BATU\nJEMBATAN UTAMA",20)

-- Dense forest after the river. Darker canopy, tighter vegetation, but the trail stays readable.
for i=1,72 do
 local t=math.random();local c=P3:Lerp(P4,t);local d=P4-P3;local side=Vector3.new(-d.Z,0,d.X).Unit;local offset=side*(math.random(24,95)*(math.random()<.5 and -1 or 1));local q=c+offset+Vector3.new(0,-2,math.random(-20,20));tree(q,.62+math.random()*.45,true)
 if i%2==0 then fern(q+Vector3.new(math.random(-6,6),0,math.random(-6,6)),.58+math.random()*.38) end
end
for i=1,34 do local t=math.random();local c=P3:Lerp(P4,t);rock(c+Vector3.new(math.random(-90,90),-1,math.random(-40,40)),math.random(3,8)) end
-- Small ravine edges near dense forest.
for i=1,8 do local t=i/9;local c=P3:Lerp(P4,t);Terrain:FillBall(c+Vector3.new(72,-42,0),58,Enum.Material.Rock) end

-- Mid-camp: a believable hikers' clearing, not a hub platform.
local camp=Instance.new("Model");camp.Name="MidMountainCamp";camp.Parent=zone
Terrain:FillBall(CAMP-Vector3.new(0,54,0),62,Enum.Material.Ground)
local clearing=mk("CampClearing",Vector3.new(78,1.6,62),CFrame.new(CAMP-Vector3.new(0,1.1,0))*CFrame.Angles(0,math.rad(-8),0),Enum.Material.Ground,Color3.fromRGB(92,78,60),camp)
for i,off in ipairs({Vector3.new(-22,2,14),Vector3.new(24,2,13),Vector3.new(-18,2,-18),Vector3.new(25,2,-16)}) do
 local m=Instance.new("Model");m.Name="HikerTent_"..i;m.Parent=camp
 local cf=CFrame.new(CAMP+off)*CFrame.Angles(0,math.rad(i*31),0)
 mk("TentFloor",Vector3.new(11,.5,8),cf,Enum.Material.Fabric,Color3.fromRGB(64,78,57),m)
 mk("TentSideL",Vector3.new(7,.6,9),cf*CFrame.new(-2.3,3,0)*CFrame.Angles(0,0,math.rad(48)),Enum.Material.Fabric,Color3.fromRGB(68,84,60),m,0,false)
 mk("TentSideR",Vector3.new(7,.6,9),cf*CFrame.new(2.3,3,0)*CFrame.Angles(0,0,math.rad(-48)),Enum.Material.Fabric,Color3.fromRGB(68,84,60),m,0,false)
end
local fireBase=mk("CampfireRing",Vector3.new(6,1,6),CFrame.new(CAMP+Vector3.new(0,1,1)),Enum.Material.Slate,Color3.fromRGB(70,68,63),camp);fireBase.Shape=Enum.PartType.Cylinder
local fire=Instance.new("Fire");fire.Size=4.5;fire.Heat=6;fire.Color=Color3.fromRGB(255,172,92);fire.Parent=fireBase
local light=Instance.new("PointLight");light.Range=24;light.Brightness=1.7;light.Color=Color3.fromRGB(255,181,105);light.Parent=fireBase
for i=1,5 do local a=i/5*math.pi*2;local log=mk("CampLogSeat",Vector3.new(1.6,1.6,9),CFrame.new(CAMP+Vector3.new(math.cos(a)*12,1.2,1+math.sin(a)*12))*CFrame.Angles(0,-a,math.rad(90)),Enum.Material.Wood,Color3.fromRGB(77,55,37),camp);log.Shape=Enum.PartType.Cylinder end
local shelter=Instance.new("Model");shelter.Name="RainShelter";shelter.Parent=camp
mk("ShelterRoof",Vector3.new(28,.8,16),CFrame.new(CAMP+Vector3.new(0,9,-30))*CFrame.Angles(math.rad(-8),0,0),Enum.Material.Fabric,Color3.fromRGB(87,92,72),shelter,0,false)
for _,x in ipairs({-12,12}) do for _,z in ipairs({-6,6}) do mk("ShelterPole",Vector3.new(.8,9,.8),CFrame.new(CAMP+Vector3.new(x,4.5,-30+z)),Enum.Material.Wood,Color3.fromRGB(78,57,39),shelter) end end
sign(CAMP+Vector3.new(-38,0,24),"CAMP TENGAH\nISTIRAHAT SEBELUM TEBING",-32)

-- Cliff approach: exposed rock shelves, switchback feeling and sparse vegetation.
for i=0,12 do
 local t=i/12;local c=CAMP:Lerp(CLIFF,t);local side=(i%2==0 and -1 or 1);Terrain:FillBall(c+Vector3.new(side*math.random(45,95),-32,math.random(-25,25)),math.random(52,82),Enum.Material.Rock)
end
for i=1,26 do local t=math.random();local c=CAMP:Lerp(CLIFF,t);local q=c+Vector3.new(math.random(-78,78),math.random(-5,7),math.random(-36,36));local r=ball("CliffRock",q,math.random(5,12),Enum.Material.Rock,Color3.fromRGB(82,83,79),zone,true);r.CFrame=r.CFrame*CFrame.Angles(math.rad(math.random(-18,18)),math.rad(math.random(0,180)),math.rad(math.random(-18,18))) end
for i=1,14 do local t=math.random();local c=CAMP:Lerp(CLIFF,t);fern(c+Vector3.new(math.random(-60,60),0,math.random(-25,25)),.5+math.random()*.25) end
sign(CLIFF+Vector3.new(22,0,28),"POS 5 — TEBING\nJALUR MULAI TERBUKA",18)

root:SetAttribute("LowerForestReady",true)
root:SetAttribute("RiverCrossingReady",true)
root:SetAttribute("DenseForestReady",true)
root:SetAttribute("MidCampReady",true)
root:SetAttribute("CliffZoneReady",true)
root:SetAttribute("ExpeditionLayer","4.3")
root:SetAttribute("BuildVersion","4.3.0-expedition")
print("[ACC] Mountain v4.3 expedition layer ready")