-- MOUNT BBYA — FULL MAP RESET AUTHORITY v7.0
-- User-authorized reset: 2026-09-08. Replaces prior Spawn->CP1 authority.
-- Target: MOUNT BBYA Universe 4187755690 / Place 11832985967 only.

local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Terrain=Workspace.Terrain

local VERSION="7.0.0-full-map-reset"
local ROOT_NAME="MOUNT_BBYA_WORLD"
local XZ_SCALE,Y_SCALE,BASE_Y=8,4,12
local WITA_OFFSET=8

for _,name in ipairs({ROOT_NAME,"ACC_MountainSocial","MountBBYAWorld"}) do
 local old=Workspace:FindFirstChild(name);if old then old:Destroy() end
end
local oldCP=Workspace:FindFirstChild("Checkpoints");if oldCP then oldCP:Destroy() end
Terrain:Clear()

local root=Instance.new("Folder");root.Name=ROOT_NAME;root.Parent=Workspace
root:SetAttribute("Project","MOUNT BBYA");root:SetAttribute("Version",VERSION)
root:SetAttribute("Architecture","VISUALIZER_20CP_WITA");root:SetAttribute("ResetAuthority",true)

local folders={}
for _,name in ipairs({"Village","Agriculture","Vegetation","Route","Checkpoints","Lake","Summit"}) do
 local f=Instance.new("Folder");f.Name=name;f.Parent=root;folders[name]=f
end
local checkpointFolder=Instance.new("Folder");checkpointFolder.Name="Checkpoints";checkpointFolder.Parent=Workspace

-- id, name, mdpl, zone, x, y, z, vegetation, facility, difficulty
local CP={
 {0,"Desa Spawn Padang Sambian",120,"Desa & Sawah",0,2,140,"Padi, Kelapa, Pisang","Warung Pendaftaran & Safezone","Sangat Mudah"},
 {1,"CP 1 - Gerbang Alang-Alang",280,"Kaki Gunung",8,5,120,"Alang-Alang Rimbun","Gazebo Bambu Pintu Masuk","Mudah"},
 {2,"CP 2 - Pos Pembudidayaan Bunga",410,"Kaki Gunung",18,9,100,"Bunga Liar & Semak","Pos Logistik Khusus","Lanjutan"},
 {3,"CP 3 - Pondok Bambu Lereng",560,"Kaki Gunung",28,14,82,"Hutan Bambu Hitam","Shelter Bambu & Sumber Air","Sedang"},
 {4,"CP 4 - Pos Bukit Angin",720,"Kaki Gunung",38,20,65,"Rumput Sabana","Posko Kayu Jati","Sedang"},
 {5,"CP 5 - Pos Batang Tua",890,"Hutan Hujan",45,27,48,"Pohon Beringin & Pakis","Posko Tempat Duduk Kayu","Tanjakan Landai"},
 {6,"CP 6 - Pos Akar Rimba",1050,"Hutan Hujan",40,35,30,"Pohon Meranti & Moss","Posko Atap Ijuk","Menantang"},
 {7,"CP 7 - Pos Lembah Cabang",1210,"Hutan Hujan",28,42,15,"Pakis Raksasa & Bunga Hutan","Shelter P3K","Sedang"},
 {8,"CP 8 - Pos Hutan Pinus Asri",1390,"Hutan Hujan",12,50,0,"Pinus & Tanah Jarum","Posko Kayu Log","Landai Terbuka"},
 {9,"CP 9 - Pos Kabut Lembab",1560,"Hutan Hujan",-5,58,-15,"Pohon Lumut Basah","Pondok Kayu Bertingkat","Tanjakan Berbatu"},
 {10,"CP 10 - Pos Tengah Gunung",1750,"Transisi Sub-Alpin",-22,67,-28,"Cantigi & Pinus Kerdil","Posko Utama Rest Area (Camp)","Sedang"},
 {11,"CP 11 - Pos Tanjakan Terjal",1920,"Transisi Sub-Alpin",-38,77,-40,"Semak Batu Gunung","Posko Perlindungan Tebing","Terjal & Berbatu"},
 {12,"CP 12 - Pos Angin Gunung",2100,"Transisi Sub-Alpin",-50,88,-52,"Rumput Alpine & Cantigi","Shelter Angin Batu","Menantang"},
 {13,"CP 13 - Pos Viewpoint Kawah",2280,"Zona Danau Kawah",-58,97,-35,"Bunga Edelweiss Hijau","Posko Gazebo Kayu View","Sedang"},
 {14,"CP 14 - Pos Pesisir Danau",2320,"Zona Danau Kawah",-42,92,-10,"Rumput Danau & Pinus","Posko Dermaga Danau","Turunan Halus"},
 {15,"CP 15 - Pos Danau Agung",2330,"Zona Danau Kawah",-20,93,10,"Rawa Danau & Edelweiss","Shelter Danau Komplit","Santai / Istirahat"},
 {16,"CP 16 - Pos Tanjakan Punggungan",2500,"Sub-Puncak",-5,105,-15,"Cantigi & Edelweiss","Posko Pasir Kayu","Sangat Terjal"},
 {17,"CP 17 - Pos Taman Edelweiss",2680,"Sub-Puncak",12,116,-35,"Hamparan Bunga Edelweiss","Posko Edelweiss Rest","Sedang"},
 {18,"CP 18 - Pos Batu Batas",2850,"Sub-Puncak",25,126,-55,"Lumut Batu & Cantigi","Posko Batu Tumpuk","Terjal Berbatu"},
 {19,"CP 19 - Pos Ridge Awan",3010,"Sub-Puncak",15,137,-70,"Batu Vulkanik Hitam","Shelter Darurat Puncak","Ekstrem"},
 {20,"CP 20 - PUNCAK GUNUNG NUSANTARA",3142,"PUNCAK UTAMA",0,145,-85,"Puncak Berbatu & Bendera","Spot Foto Official & Tugu MDPL","Puncak Tertinggi"}
}

local function wp(cp)return Vector3.new(cp[5]*XZ_SCALE,BASE_Y+cp[6]*Y_SCALE,cp[7]*XZ_SCALE)end
local function mk(name,size,cf,mat,col,parent,coll,tr)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.Size=size;p.CFrame=cf
 p.Material=mat or Enum.Material.SmoothPlastic;p.Color=col or Color3.fromRGB(150,150,150)
 p.CanCollide=coll~=false;p.Transparency=tr or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.CastShadow=true;p.Parent=parent or root;return p
end
local function beam(name,a,b,w,h,mat,col,parent,coll)
 local d=b-a;if d.Magnitude<.1 then return end
 return mk(name,Vector3.new(w,h,d.Magnitude),CFrame.lookAt((a+b)/2,b),mat,col,parent,coll)
end
local function label(p,text)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=36;g.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextScaled=true;t.TextWrapped=true
 t.Font=Enum.Font.GothamBold;t.TextColor3=Color3.fromRGB(245,240,225);t.TextStrokeTransparency=.55;t.Parent=g
end

-- Terrain mass follows the visualizer's 21 locations, scaled to a playable Roblox mountain.
Terrain:FillBlock(CFrame.new(0,-48,200),Vector3.new(2700,120,2700),Enum.Material.Grass)
local function terrainMat(id)
 if id<=4 then return Enum.Material.Grass elseif id<=9 then return Enum.Material.Ground elseif id<=12 then return Enum.Material.Rock elseif id<=15 then return Enum.Material.Slate elseif id<=17 then return Enum.Material.Ground else return Enum.Material.Basalt end
end
for i,cp in ipairs(CP) do
 local id=cp[1];local p=wp(cp);local r=105+math.min(id,12)*5
 if id>=13 and id<=15 then r=150 elseif id>=18 then r=125 end
 Terrain:FillBall(p-Vector3.new(0,r*.72,0),r,terrainMat(id))
 if i<#CP then
  local q=wp(CP[i+1]);local mid=(p+q)/2;local mr=math.clamp((q-p).Magnitude*.55,80,150)
  Terrain:FillBall(mid-Vector3.new(0,mr*.72,0),mr,terrainMat(id))
 end
end

-- Spawn village plateau + stepped agriculture.
local spawnP=wp(CP[1])
Terrain:FillBlock(CFrame.new(spawnP.X,spawnP.Y-8,spawnP.Z+80),Vector3.new(560,18,500),Enum.Material.Grass)
for row=0,5 do
 local z=spawnP.Z+210-row*72;local y=spawnP.Y-1+row*1.4
 for side=-1,1,2 do
  local x=spawnP.X+side*(105+(row%2)*18)
  Terrain:FillBlock(CFrame.new(x,y-3,z),Vector3.new(165,8,56),Enum.Material.Ground)
  Terrain:FillBlock(CFrame.new(x,y,z),Vector3.new(156,2,50),Enum.Material.Grass)
 end
end

-- Crater and water centered on the visualizer lake; CP14/15 remain shoreline/rest points.
local lakeCenter=Vector3.new(-30*XZ_SCALE,BASE_Y+90.5*Y_SCALE,0)
Terrain:FillBall(lakeCenter-Vector3.new(0,48,0),340,Enum.Material.Air)
Terrain:FillBall(lakeCenter-Vector3.new(0,100,0),360,Enum.Material.Rock)
Terrain:FillCylinder(CFrame.new(lakeCenter-Vector3.new(0,5,0)),12,300,Enum.Material.Water)
Terrain.WaterColor=Color3.fromRGB(28,118,156);Terrain.WaterTransparency=.28;Terrain.WaterReflectance=.25;Terrain.WaterWaveSize=.15;Terrain.WaterWaveSpeed=8

-- Guaranteed walkable route Spawn -> CP20.
for i=1,#CP-1 do
 local a,b=wp(CP[i]),wp(CP[i+1]);local id=CP[i][1]
 local width=id==0 and 22 or (id<=5 and 14 or (id<=12 and 10 or 8))
 local mat=id==0 and Enum.Material.Pavement or (id<=5 and Enum.Material.Ground or Enum.Material.Slate)
 local col=id==0 and Color3.fromRGB(84,86,82) or (id<=5 and Color3.fromRGB(116,92,62) or Color3.fromRGB(88,84,78))
 beam(string.format("Route_%02d_%02d",id,id+1),a,b,width,1.4,mat,col,folders.Route,true)
 local d=b-a;local flat=Vector3.new(d.X,0,d.Z)
 if flat.Magnitude>0 then
  local side=Vector3.new(-flat.Z,0,flat.X).Unit
  for _,sgn in ipairs({-1,1}) do beam("NaturalShoulder",a+side*sgn*(width*.5+2)-Vector3.new(0,.7,0),b+side*sgn*(width*.5+2)-Vector3.new(0,.7,0),4,1.2,Enum.Material.Ground,Color3.fromRGB(91,76,57),folders.Route,true) end
 end
end

-- Indonesian mountain-foot village.
local function house(name,pos,yaw,col)
 local m=Instance.new("Model");m.Name=name;m.Parent=folders.Village;local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
 mk("Foundation",Vector3.new(28,2,22),cf*CFrame.new(0,1,0),Enum.Material.Rock,Color3.fromRGB(102,98,87),m,true)
 mk("Wall",Vector3.new(26,13,20),cf*CFrame.new(0,8,0),Enum.Material.Brick,col,m,true)
 for _,s in ipairs({-1,1}) do mk("Roof",Vector3.new(16,1,25),cf*CFrame.new(s*6,16,0)*CFrame.Angles(0,0,math.rad(-s*28)),Enum.Material.Metal,Color3.fromRGB(70,72,68),m,true) end
 mk("Door",Vector3.new(4,8,.5),cf*CFrame.new(0,5,-10.25),Enum.Material.WoodPlanks,Color3.fromRGB(86,61,42),m,false)
 mk("Porch",Vector3.new(16,1,6),cf*CFrame.new(0,1.5,-13),Enum.Material.WoodPlanks,Color3.fromRGB(112,80,53),m,true)
end
for i=1,8 do
 local side=i%2==0 and 1 or -1;local z=spawnP.Z+210-i*55;local x=spawnP.X+side*(205+(i%3)*18)
 house("VillageHouse_"..i,Vector3.new(x,spawnP.Y+1,z),side*8,i%2==0 and Color3.fromRGB(210,199,177) or Color3.fromRGB(188,184,166))
end
local officePos=spawnP+Vector3.new(42,2,-40)
mk("TrailOffice",Vector3.new(34,14,22),CFrame.new(officePos+Vector3.new(0,7,0)),Enum.Material.WoodPlanks,Color3.fromRGB(118,83,51),folders.Village,true)
local officeSign=mk("TrailOfficeSign",Vector3.new(24,5,.5),CFrame.new(officePos+Vector3.new(0,11,-11.3)),Enum.Material.WoodPlanks,Color3.fromRGB(73,53,38),folders.Village,false);label(officeSign,"MOUNT BBYA\nREGISTRATION & TRAIL INFO")
for terrace=0,5 do
 local z=spawnP.Z+210-terrace*72
 for side=-1,1,2 do
  local cx=spawnP.X+side*(105+(terrace%2)*18)
  for row=-3,3 do local s=mk("CropRow",Vector3.new(145,.6,3),CFrame.new(cx,spawnP.Y+1+terrace*1.4,z+row*6),Enum.Material.Grass,Color3.fromRGB(63,126,63),folders.Agriculture,false);s.CastShadow=false end
 end
end

-- Zoned vegetation; intentionally sparse above CP17.
math.randomseed(700908)
local function tree(pos,scale,pine)
 local m=Instance.new("Model");m.Name=pine and "Pine" or "HighlandTree";m.Parent=folders.Vegetation
 local h=11*scale;local trunk=mk("Trunk",Vector3.new(h,1.6*scale,1.6*scale),CFrame.new(pos+Vector3.new(0,h/2,0))*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Wood,Color3.fromRGB(85,65,45),m,true)
 if pine then
  for k=0,2 do local c=mk("Needles",Vector3.new(9*scale,6*scale,9*scale),CFrame.new(pos+Vector3.new(0,h-1+k*3.1*scale,0)),Enum.Material.Grass,Color3.fromRGB(42,76,52),m,false);c.Shape=Enum.PartType.Ball end
 else
  for _,off in ipairs({Vector3.new(),Vector3.new(3,1,-1),Vector3.new(-3,.5,1)}) do local c=mk("Canopy",Vector3.new(8*scale,7*scale,8*scale),CFrame.new(pos+Vector3.new(0,h+2,0)+off*scale),Enum.Material.Grass,Color3.fromRGB(48,102,58),m,false);c.Shape=Enum.PartType.Ball end
 end
end
for i=1,#CP-1 do
 local id=CP[i][1]
 if id<=17 then
  local a,b=wp(CP[i]),wp(CP[i+1]);local d=b-a;local flat=Vector3.new(d.X,0,d.Z)
  if flat.Magnitude>0 then
   local side=Vector3.new(-flat.Z,0,flat.X).Unit;local density=id<=4 and 2 or (id<=10 and 4 or 2)
   for k=1,density do local center=a:Lerp(b,k/(density+1));for _,sgn in ipairs({-1,1}) do tree(center+side*(32+math.random()*48)*sgn-Vector3.new(0,4,0),.75+math.random()*.45,id>=7 and id<=10) end end
  end
 end
end
local cp1P=wp(CP[2])
for i=1,36 do
 local a=(i/36)*math.pi*2;local r=28+math.random()*42
 local blade=mk("AlangAlang",Vector3.new(.8,5+math.random()*5,.8),CFrame.new(cp1P.X+math.cos(a)*r,cp1P.Y+2.5,cp1P.Z+math.sin(a)*r)*CFrame.Angles(0,math.random()*math.pi,math.rad(math.random(-8,8))),Enum.Material.Grass,Color3.fromRGB(156,139,71),folders.Vegetation,false);blade.CastShadow=false
end
for id=13,17 do local center=wp(CP[id+1]);for n=1,12 do local a=math.random()*math.pi*2;local r=12+math.random()*38;local s=mk("AlpineShrub",Vector3.new(1.2,2.4,1.2),CFrame.new(center.X+math.cos(a)*r,center.Y+1.2,center.Z+math.sin(a)*r),Enum.Material.Grass,Color3.fromRGB(92,109,66),folders.Vegetation,false);s.CastShadow=false end end

-- 20 checkpoints + Spawn, each carrying visualizer metadata.
local cpParts={}
local function shelter(cp)
 local id=cp[1];local p=wp(cp);local m=Instance.new("Model");m.Name=id==0 and "SpawnDesa" or string.format("CP%02d_Shelter",id);m.Parent=folders.Checkpoints
 local platformW=(id==10 or id==15) and 28 or 20
 mk("Platform",Vector3.new(platformW,1,16),CFrame.new(p+Vector3.new(0,.4,0)),Enum.Material.WoodPlanks,Color3.fromRGB(103,75,49),m,true)
 for _,o in ipairs({Vector3.new(-8,5,-6),Vector3.new(8,5,-6),Vector3.new(-8,5,6),Vector3.new(8,5,6)}) do mk("Pillar",Vector3.new(1,10,1),CFrame.new(p+o),Enum.Material.Wood,Color3.fromRGB(74,54,37),m,true) end
 for _,s in ipairs({-1,1}) do mk("Roof",Vector3.new(11,1,20),CFrame.new(p+Vector3.new(s*4.5,11,0))*CFrame.Angles(0,0,math.rad(-s*24)),Enum.Material.WoodPlanks,Color3.fromRGB(55,48,41),m,true) end
 local sign=mk("CheckpointSign",Vector3.new(14,5,.6),CFrame.new(p+Vector3.new(0,6,-8.5)),Enum.Material.WoodPlanks,Color3.fromRGB(91,61,38),m,false);label(sign,(id==0 and "SPAWN" or ("CP "..id)).."\n"..cp[3].." MDPL")
 local lamp=mk("MarkerLamp",Vector3.new(1.2,1.2,1.2),CFrame.new(p+Vector3.new(8.5,7,-7)),Enum.Material.Neon,id==20 and Color3.fromRGB(225,65,75) or Color3.fromRGB(236,170,55),m,false);lamp.Shape=Enum.PartType.Ball
 local light=Instance.new("PointLight");light.Brightness=1;light.Range=16;light.Color=lamp.Color;light.Parent=lamp
 local trigger=mk(id==0 and "SpawnDesa" or ("CP"..id),Vector3.new(18,5,14),CFrame.new(p+Vector3.new(0,2.5,0)),Enum.Material.ForceField,Color3.new(1,1,1),checkpointFolder,false,1)
 trigger:SetAttribute("CheckpointId",id);trigger:SetAttribute("DisplayName",cp[2]);trigger:SetAttribute("AltitudeMDPL",cp[3]);trigger:SetAttribute("Zone",cp[4]);trigger:SetAttribute("Vegetation",cp[8]);trigger:SetAttribute("Facility",cp[9]);trigger:SetAttribute("Difficulty",cp[10]);cpParts[id]=trigger
end
for _,cp in ipairs(CP) do shelter(cp) end

local spawn=Instance.new("SpawnLocation");spawn.Name="MOUNT_BBYA_SPAWN";spawn.Size=Vector3.new(12,1,12);spawn.CFrame=CFrame.new(spawnP+Vector3.new(0,2,18));spawn.Anchored=true;spawn.Neutral=true;spawn.Material=Enum.Material.WoodPlanks;spawn.Color=Color3.fromRGB(102,82,57);spawn.Parent=folders.Village

-- Summit monument + photo seat + correct Indonesian red/white flag.
local summitP=wp(CP[21]);local summit=Instance.new("Model");summit.Name="SummitPhotoSpot_3142MDPL";summit.Parent=folders.Summit
mk("MonumentBase",Vector3.new(18,2,10),CFrame.new(summitP+Vector3.new(0,1,-10)),Enum.Material.Rock,Color3.fromRGB(83,83,80),summit,true)
local board=mk("SummitBoard",Vector3.new(18,7,1),CFrame.new(summitP+Vector3.new(0,8,-13)),Enum.Material.WoodPlanks,Color3.fromRGB(105,66,38),summit,true);label(board,"PUNCAK GUNUNG NUSANTARA\n3.142 MDPL")
mk("FlagPole",Vector3.new(.7,24,.7),CFrame.new(summitP+Vector3.new(-13,12,-8)),Enum.Material.Metal,Color3.fromRGB(220,224,228),summit,true)
local red=mk("FlagRed",Vector3.new(8,2.4,.25),CFrame.new(summitP+Vector3.new(-9,21.2,-8)),Enum.Material.Fabric,Color3.fromRGB(206,17,38),summit,false);red.CastShadow=false
local white=mk("FlagWhite",Vector3.new(8,2.4,.25),CFrame.new(summitP+Vector3.new(-9,18.8,-8)),Enum.Material.Fabric,Color3.fromRGB(245,245,245),summit,false);white.CastShadow=false
local seat=Instance.new("Seat");seat.Name="SummitPhotoSeat";seat.Size=Vector3.new(5,1,3);seat.CFrame=CFrame.new(summitP+Vector3.new(0,2,8))*CFrame.Angles(0,math.rad(180),0);seat.Anchored=true;seat.Material=Enum.Material.WoodPlanks;seat.Color=Color3.fromRGB(97,65,42);seat.Parent=summit
local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Duduk / Photo Spot";prompt.ObjectText="Puncak 3.142 MDPL";prompt.HoldDuration=.25;prompt.MaxActivationDistance=10;prompt.Parent=seat
prompt.Triggered:Connect(function(player)local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");if hum then seat:Sit(hum) end end)

-- Full CP save/respawn. Correct pcall result handling.
local store=DataStoreService:GetDataStore("MountainHiking_CP_Data_v2_FullMap")
local debounce={}
local function stats(player)
 local f=player:FindFirstChild("leaderstats") or Instance.new("Folder");f.Name="leaderstats";f.Parent=player
 local v=f:FindFirstChild("Checkpoint") or Instance.new("IntValue");v.Name="Checkpoint";v.Parent=f;return v
end
local function load(player)
 local v=stats(player);local ok,saved=pcall(function()return store:GetAsync("Player_"..player.UserId)end)
 v.Value=(ok and typeof(saved)=="number") and math.clamp(saved,0,20) or 0
 player.CharacterAdded:Connect(function(char)task.wait(.6);local target=cpParts[math.clamp(v.Value,0,20)];if target and char.Parent then char:PivotTo(target.CFrame+Vector3.new(0,5,0)) end end)
end
Players.PlayerAdded:Connect(load);for _,p in ipairs(Players:GetPlayers()) do task.spawn(load,p) end
local function save(player,value)task.spawn(function()pcall(function()store:UpdateAsync("Player_"..player.UserId,function(old)old=typeof(old)=="number" and old or 0;return math.max(old,value)end)end)end)end
for id,trigger in pairs(cpParts) do
 trigger.Touched:Connect(function(hit)
  local char=hit and hit.Parent;local player=char and Players:GetPlayerFromCharacter(char);if not player then return end
  local key=player.UserId..":"..id;if debounce[key] then return end;debounce[key]=true;task.delay(1.5,function()debounce[key]=nil end)
  local hum=char:FindFirstChildOfClass("Humanoid");if hum then hum.Health=hum.MaxHealth end
  local v=stats(player);if id>v.Value then v.Value=id;save(player,id) end
 end)
end

-- Realtime WITA lighting (UTC+8).
Lighting.Technology=Enum.Technology.Future;Lighting.GlobalShadows=true;Lighting.Brightness=2.2;Lighting.EnvironmentDiffuseScale=.35;Lighting.EnvironmentSpecularScale=.25
for _,name in ipairs({"MOUNT_BBYA_ATMOSPHERE","MOUNT_BBYA_COLOR"}) do local e=Lighting:FindFirstChild(name);if e then e:Destroy() end end
local atmos=Instance.new("Atmosphere");atmos.Name="MOUNT_BBYA_ATMOSPHERE";atmos.Offset=.12;atmos.Glare=.08;atmos.Haze=1.6;atmos.Parent=Lighting
local color=Instance.new("ColorCorrectionEffect");color.Name="MOUNT_BBYA_COLOR";color.Saturation=.04;color.Contrast=.06;color.Parent=Lighting
local function wita()
 local utc=os.date("!*t");local hour=(utc.hour+WITA_OFFSET)%24;local clock=hour+utc.min/60+utc.sec/3600;Lighting.ClockTime=clock
 if clock>=5.5 and clock<6.5 then Lighting.Ambient=Color3.fromRGB(118,92,83);Lighting.OutdoorAmbient=Color3.fromRGB(145,116,93);atmos.Color=Color3.fromRGB(255,188,138);atmos.Decay=Color3.fromRGB(123,151,180);atmos.Density=.32
 elseif clock>=6.5 and clock<15.5 then Lighting.Ambient=Color3.fromRGB(118,128,122);Lighting.OutdoorAmbient=Color3.fromRGB(145,153,147);atmos.Color=Color3.fromRGB(199,224,237);atmos.Decay=Color3.fromRGB(96,126,145);atmos.Density=.24
 elseif clock>=15.5 and clock<18.5 then Lighting.Ambient=Color3.fromRGB(119,94,91);Lighting.OutdoorAmbient=Color3.fromRGB(144,108,94);atmos.Color=Color3.fromRGB(236,156,120);atmos.Decay=Color3.fromRGB(111,92,126);atmos.Density=.30
 else Lighting.Ambient=Color3.fromRGB(35,45,65);Lighting.OutdoorAmbient=Color3.fromRGB(42,52,72);atmos.Color=Color3.fromRGB(73,95,124);atmos.Decay=Color3.fromRGB(28,35,54);atmos.Density=.34 end
end
wita();task.spawn(function()while root.Parent do task.wait(10);wita() end end)

root:SetAttribute("CheckpointCount",20);root:SetAttribute("LocationCount",21);root:SetAttribute("SummitMDPL",3142);root:SetAttribute("WITARealtime",true);root:SetAttribute("LakeCheckpoint",15);root:SetAttribute("BuildComplete",true)
print("[MOUNT BBYA] FULL RESET COMPLETE",VERSION,"Spawn + CP1..CP20 / WITA / Lake CP15 / Summit 3142 MDPL")
