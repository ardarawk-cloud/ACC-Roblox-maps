-- BBYA SOCIAL HUB — FISHING CORE v2
-- Server-authoritative fishing loop + persistent Lake Tokens + procedural 3D fish + dimensional rod skins.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",35)
if not root then return end
local district=root:WaitForChild("PremiumFishingDistrictV2",35)
if not district then return end

local LAKE_CENTER=Vector3.new(district:GetAttribute("LakeCenterX") or 0,.25,district:GetAttribute("LakeCenterZ") or 790)
local RX=district:GetAttribute("LakeRadiusX") or 112
local RZ=district:GetAttribute("LakeRadiusZ") or 70
local DISTRICT_RADIUS=225
local WATER_Y=.25

local remotes=ReplicatedStorage:FindFirstChild("BBYAFishingRemotes") or Instance.new("Folder")
remotes.Name="BBYAFishingRemotes";remotes.Parent=ReplicatedStorage
local actionRemote=remotes:FindFirstChild("Action") or Instance.new("RemoteEvent")
actionRemote.Name="Action";actionRemote.Parent=remotes
local stateRemote=remotes:FindFirstChild("State") or Instance.new("RemoteEvent")
stateRemote.Name="State";stateRemote.Parent=remotes

local SKINS={
 {name="Graphite Core",rarity="COMMON",price=0,required=0,body=Color3.fromRGB(35,39,46),accent=Color3.fromRGB(185,190,197),reel=Color3.fromRGB(84,88,96),style="CORE"},
 {name="Pearl Tide",rarity="UNCOMMON",price=300,required=3,body=Color3.fromRGB(232,234,230),accent=Color3.fromRGB(94,205,219),reel=Color3.fromRGB(176,183,188),style="TIDE"},
 {name="Sakura Koi",rarity="RARE",price=750,required=8,body=Color3.fromRGB(246,208,222),accent=Color3.fromRGB(239,91,160),reel=Color3.fromRGB(238,188,96),style="KOI"},
 {name="Neon Circuit",rarity="RARE",price=1400,required=15,body=Color3.fromRGB(22,28,34),accent=Color3.fromRGB(55,229,226),reel=Color3.fromRGB(87,98,107),style="CIRCUIT"},
 {name="Crimson Dragon",rarity="EPIC",price=2600,required=28,body=Color3.fromRGB(86,22,26),accent=Color3.fromRGB(238,66,67),reel=Color3.fromRGB(204,145,72),style="DRAGON"},
 {name="Celestial Moon",rarity="EPIC",price=4200,required=45,body=Color3.fromRGB(41,47,76),accent=Color3.fromRGB(178,199,255),reel=Color3.fromRGB(220,222,230),style="MOON"},
 {name="Poseidon Crown",rarity="LEGENDARY",price=6500,required=70,body=Color3.fromRGB(18,65,86),accent=Color3.fromRGB(52,218,207),reel=Color3.fromRGB(224,180,84),style="POSEIDON"},
 {name="Phantom Leviathan",rarity="LEGENDARY",price=10000,required=110,body=Color3.fromRGB(24,18,39),accent=Color3.fromRGB(153,94,231),reel=Color3.fromRGB(91,77,126),style="PHANTOM"},
 {name="BBYA Royal",rarity="MYTHIC",price=16000,required=175,body=Color3.fromRGB(19,19,23),accent=Color3.fromRGB(244,182,82),reel=Color3.fromRGB(235,193,101),style="ROYAL"},
}
local skinByName={}
for _,s in ipairs(SKINS) do skinByName[s.name]=s end

local FISH={
 {name="Moon Carp",rarity="COMMON",chance=32,min=.7,max=2.4,value=18,body=Color3.fromRGB(165,183,188),accent=Color3.fromRGB(224,232,231),shape="STANDARD"},
 {name="Azure Gourami",rarity="COMMON",chance=29,min=.5,max=1.9,value=20,body=Color3.fromRGB(65,145,181),accent=Color3.fromRGB(96,215,218),shape="STANDARD"},
 {name="Jade Peacock Bass",rarity="UNCOMMON",chance=14,min=1.2,max=4.8,value=42,body=Color3.fromRGB(70,132,79),accent=Color3.fromRGB(193,207,64),shape="STANDARD"},
 {name="Redtail Giant",rarity="UNCOMMON",chance=12,min=2.2,max=8.5,value=55,body=Color3.fromRGB(68,74,82),accent=Color3.fromRGB(214,62,58),shape="CATFISH"},
 {name="Royal Koi",rarity="RARE",chance=5.4,min=1,max=5,value=105,body=Color3.fromRGB(239,236,219),accent=Color3.fromRGB(228,111,58),shape="KOI"},
 {name="Sapphire Barramundi",rarity="RARE",chance=4.4,min=3,max=11,value=125,body=Color3.fromRGB(83,119,151),accent=Color3.fromRGB(158,208,224),shape="STANDARD"},
 {name="Crimson Arowana",rarity="EPIC",chance=1.8,min=2.4,max=7.2,value=260,body=Color3.fromRGB(185,42,54),accent=Color3.fromRGB(247,143,78),shape="LONG"},
 {name="Obsidian Ray",rarity="EPIC",chance=1.45,min=4,max=15,value=300,body=Color3.fromRGB(34,31,42),accent=Color3.fromRGB(111,84,145),shape="RAY"},
 {name="Golden Mahseer",rarity="LEGENDARY",chance=.48,min=5,max=18,value=700,body=Color3.fromRGB(169,120,40),accent=Color3.fromRGB(246,205,91),shape="STANDARD"},
 {name="Aurora Arapaima",rarity="LEGENDARY",chance=.34,min=9,max=31,value=900,body=Color3.fromRGB(55,83,126),accent=Color3.fromRGB(72,224,206),shape="LONG"},
 {name="Celestial Koi",rarity="MYTHIC",chance=.075,min=3,max=10,value=2400,body=Color3.fromRGB(235,236,229),accent=Color3.fromRGB(240,190,68),shape="KOI"},
 {name="Phantom Leviathan",rarity="MYTHIC",chance=.035,min=18,max=55,value=4200,body=Color3.fromRGB(42,31,67),accent=Color3.fromRGB(132,82,216),shape="LEVIATHAN"},
}
local DIFFICULTY={COMMON=.64,UNCOMMON=.76,RARE=.91,EPIC=1.08,LEGENDARY=1.25,MYTHIC=1.42}
local VALUE_MULT={COMMON=1,UNCOMMON=1.1,RARE=1.25,EPIC=1.45,LEGENDARY=1.7,MYTHIC=2.1}

local store=DataStoreService:GetDataStore("BBYA_FISHING_V1")
local dataByUser={}
local sessions={}

local function defaultData()
 return {tokens=0,total=0,best=0,equipped="Graphite Core",unlocked={['Graphite Core']=true}}
end
local function normalize(raw)
 local d=defaultData()
 if type(raw)=="table" then
  d.tokens=math.max(0,math.floor(tonumber(raw.tokens) or 0));d.total=math.max(0,math.floor(tonumber(raw.total) or 0));d.best=math.max(0,tonumber(raw.best) or 0)
  if type(raw.unlocked)=="table" then for name,v in pairs(raw.unlocked) do if v==true and skinByName[name] then d.unlocked[name]=true end end end
  if type(raw.equipped)=="string" and d.unlocked[raw.equipped] and skinByName[raw.equipped] then d.equipped=raw.equipped end
 end
 return d
end
local function publishAttributes(player,d)
 player:SetAttribute("BBYAFishingTokens",d.tokens);player:SetAttribute("BBYAFishingTotal",d.total);player:SetAttribute("BBYAFishingBestWeight",math.floor(d.best*100)/100);player:SetAttribute("BBYAFishingSkin",d.equipped)
end
local function loadData(player)
 local raw;local ok=pcall(function() raw=store:GetAsync("u_"..player.UserId) end);local d=normalize(ok and raw or nil);dataByUser[player.UserId]=d;publishAttributes(player,d)
end
local function saveData(player)
 local d=dataByUser[player.UserId];if not d then return end;pcall(function() store:SetAsync("u_"..player.UserId,d) end)
end
local function skinSnapshot(d)
 local list={};for _,s in ipairs(SKINS) do table.insert(list,{name=s.name,rarity=s.rarity,price=s.price,required=s.required,unlocked=d.unlocked[s.name]==true,equipped=d.equipped==s.name}) end;return list
end
local function sendSnapshot(player)
 local d=dataByUser[player.UserId];if not d then return end;stateRemote:FireClient(player,"Snapshot",{tokens=d.tokens,total=d.total,best=math.floor(d.best*100)/100,equipped=d.equipped,skins=skinSnapshot(d)})
end

-- =============================================================================
-- DIMENSIONAL 3D RODS + SKINS
-- =============================================================================
local function weld(base,child)
 child.Anchored=false;child.CanCollide=false;child.CanTouch=false;child.CanQuery=false;child.Massless=true
 local w=Instance.new("WeldConstraint");w.Part0=base;w.Part1=child;w.Parent=child
end
local function rodCylinder(name,size,cf,parent,role)
 local p=Instance.new("Part");p.Name=name;p.Shape=Enum.PartType.Cylinder;p.Size=size;p.CFrame=cf;p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(40,43,48)
 p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p:SetAttribute("RodRole",role);p.Parent=parent;return p
end
local function rodBall(name,size,cf,parent,role)
 local p=Instance.new("Part");p.Name=name;p.Shape=Enum.PartType.Ball;p.Size=size;p.CFrame=cf;p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(100,100,105)
 p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p:SetAttribute("RodRole",role);p.Parent=parent;return p
end
local function ornamentPart(folder,handle,kind,name,size,localCF,color,neon)
 local p
 if kind=="WEDGE" then p=Instance.new("WedgePart") else p=Instance.new("Part");if kind=="BALL" then p.Shape=Enum.PartType.Ball elseif kind=="CYLINDER" then p.Shape=Enum.PartType.Cylinder end end
 p.Name=name;p.Size=size;p.CFrame=handle.CFrame*localCF;p.Color=color;p.Material=neon and Enum.Material.Neon or Enum.Material.Metal;p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.Parent=folder;weld(handle,p);return p
end
local function rebuildOrnaments(tool,s)
 local old=tool:FindFirstChild("SkinOrnaments");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="SkinOrnaments";folder.Parent=tool
 local handle=tool:FindFirstChild("Handle");if not handle then return end
 if s.style=="TIDE" then
  for _,x in ipairs({2.1,4.2,6.1}) do ornamentPart(folder,handle,"CYLINDER","TideRing",Vector3.new(.16,.33,.33),CFrame.new(x,0,0),s.accent,false) end
 elseif s.style=="KOI" then
  ornamentPart(folder,handle,"WEDGE","KoiFinL",Vector3.new(1.25,.18,.8),CFrame.new(1.2,.20,.42)*CFrame.Angles(0,math.rad(180),math.rad(18)),s.accent,false)
  ornamentPart(folder,handle,"WEDGE","KoiFinR",Vector3.new(1.25,.18,.8),CFrame.new(1.2,.20,-.42)*CFrame.Angles(math.rad(180),0,math.rad(-18)),s.accent,false)
 elseif s.style=="CIRCUIT" then
  for _,x in ipairs({1.65,2.75,3.85,5.0,6.15}) do ornamentPart(folder,handle,"CYLINDER","CircuitRing",Vector3.new(.10,.29,.29),CFrame.new(x,0,0),s.accent,true) end
 elseif s.style=="DRAGON" then
  for i=1,4 do ornamentPart(folder,handle,"WEDGE","DragonSpine"..i,Vector3.new(.72,.78,.18),CFrame.new(1.9+i*.95,.34,0)*CFrame.Angles(0,math.rad(90),0),s.accent,i>=3) end
 elseif s.style=="MOON" then
  for _,spec in ipairs({{2.2,.34},{4.5,.28},{6.6,.22}}) do ornamentPart(folder,handle,"BALL","MoonOrb",Vector3.new(spec[2],spec[2],spec[2]),CFrame.new(spec[1],.26,0),s.accent,true) end
 elseif s.style=="POSEIDON" then
  ornamentPart(folder,handle,"CYLINDER","TridentCore",Vector3.new(1.35,.14,.14),CFrame.new(8.45,0,0),s.accent,true)
  ornamentPart(folder,handle,"CYLINDER","TridentL",Vector3.new(.95,.10,.10),CFrame.new(8.65,.30,0)*CFrame.Angles(0,0,math.rad(12)),s.accent,true)
  ornamentPart(folder,handle,"CYLINDER","TridentR",Vector3.new(.95,.10,.10),CFrame.new(8.65,-.30,0)*CFrame.Angles(0,0,math.rad(-12)),s.accent,true)
 elseif s.style=="PHANTOM" then
  for i=1,5 do ornamentPart(folder,handle,"WEDGE","PhantomSpine"..i,Vector3.new(.58,.70,.16),CFrame.new(2.2+i*.85,.32,0)*CFrame.Angles(0,math.rad(90),0),s.accent,true) end
  ornamentPart(folder,handle,"BALL","PhantomCore",Vector3.new(.52,.52,.52),CFrame.new(.35,-.48,0),s.accent,true)
 elseif s.style=="ROYAL" then
  for _,x in ipairs({1.55,3.65,5.7,7.1}) do ornamentPart(folder,handle,"CYLINDER","RoyalRing",Vector3.new(.13,.35,.35),CFrame.new(x,0,0),s.accent,false) end
  for i=-2,2 do ornamentPart(folder,handle,"WEDGE","Crown"..i,Vector3.new(.45,.62,.14),CFrame.new(.2+i*.24,.05,.44)*CFrame.Angles(0,math.rad(90),0),s.accent,i==0) end
  ornamentPart(folder,handle,"BALL","RoyalTip",Vector3.new(.38,.38,.38),CFrame.new(8.12,0,0),s.accent,true)
 end
end
local function applySkin(tool,skinName)
 local s=skinByName[skinName] or SKINS[1]
 for _,d in ipairs(tool:GetDescendants()) do
  if d:IsA("BasePart") then
   local role=d:GetAttribute("RodRole")
   if role=="BODY" then d.Color=s.body;d.Material=Enum.Material.Metal
   elseif role=="ACCENT" then d.Color=s.accent;d.Material=(s.rarity=="LEGENDARY" or s.rarity=="MYTHIC") and Enum.Material.Neon or Enum.Material.Metal
   elseif role=="REEL" then d.Color=s.reel;d.Material=Enum.Material.Metal
   elseif role=="GRIP" then d.Color=Color3.fromRGB(38,31,29);d.Material=Enum.Material.Fabric end
  end
 end
 rebuildOrnaments(tool,s)
 local tip=tool:FindFirstChild("TipSegment");if tip then
  local old=tip:FindFirstChild("SkinLight");if old then old:Destroy() end
  if s.rarity=="LEGENDARY" or s.rarity=="MYTHIC" then local l=Instance.new("PointLight");l.Name="SkinLight";l.Color=s.accent;l.Brightness=.42;l.Range=5;l.Shadows=false;l.Parent=tip end
 end
 tool:SetAttribute("RodSkin",s.name);tool:SetAttribute("RodSkinRarity",s.rarity)
end
local function createRod(player)
 local tool=Instance.new("Tool");tool.Name="BBYA Fishing Rod";tool.RequiresHandle=true;tool.CanBeDropped=false;tool.ToolTip="BBYA Lakeside Fishing";tool:SetAttribute("BBYAFishingRod",true)
 local base=CFrame.new(0,1000,0)
 local handle=rodCylinder("Handle",Vector3.new(2.45,.34,.34),base,tool,"GRIP")
 local p1=rodCylinder("RodSegment1",Vector3.new(2.8,.24,.24),base*CFrame.new(2.55,0,0),tool,"BODY")
 local r1=rodCylinder("AccentRing1",Vector3.new(.20,.32,.32),base*CFrame.new(1.28,0,0),tool,"ACCENT")
 local p2=rodCylinder("RodSegment2",Vector3.new(2.35,.17,.17),base*CFrame.new(5.1,0,0),tool,"BODY")
 local r2=rodCylinder("AccentRing2",Vector3.new(.14,.24,.24),base*CFrame.new(4.05,0,0),tool,"ACCENT")
 local tip=rodCylinder("TipSegment",Vector3.new(1.8,.10,.10),base*CFrame.new(7.15,0,0),tool,"ACCENT")
 local reel=rodCylinder("ReelSpool",Vector3.new(.62,.92,.92),base*CFrame.new(.35,-.48,0)*CFrame.Angles(0,0,math.rad(90)),tool,"REEL")
 local arm=rodCylinder("ReelArm",Vector3.new(.86,.13,.13),base*CFrame.new(.10,-.94,0)*CFrame.Angles(0,0,math.rad(35)),tool,"REEL")
 local knob=rodBall("ReelKnob",Vector3.new(.28,.28,.28),base*CFrame.new(-.18,-1.22,0),tool,"GRIP")
 for _,p in ipairs({p1,r1,p2,r2,tip,reel,arm,knob}) do weld(handle,p) end
 local att=Instance.new("Attachment");att.Name="LineTip";att.Position=Vector3.new(tip.Size.X/2,0,0);att.Parent=tip
 tool.Grip=CFrame.new(0,-.45,0)*CFrame.Angles(0,0,math.rad(68))
 local d=dataByUser[player.UserId] or defaultData();applySkin(tool,d.equipped);tool.Parent=player:WaitForChild("Backpack");return tool
end
local function findRod(player)
 local char=player.Character;if char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Tool") and v:GetAttribute("BBYAFishingRod") then return v end end end
 local bag=player:FindFirstChildOfClass("Backpack");if bag then for _,v in ipairs(bag:GetChildren()) do if v:IsA("Tool") and v:GetAttribute("BBYAFishingRod") then return v end end end;return nil
end
local function grantRod(player,equip)
 local rod=findRod(player) or createRod(player)
 if equip and player.Character then local h=player.Character:FindFirstChildOfClass("Humanoid");if h then h:EquipTool(rod) end end;return rod
end

-- =============================================================================
-- PROCEDURAL 3D FISH
-- =============================================================================
local function fishPart(name,size,cf,color,material,parent,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Shape=shape or Enum.PartType.Block
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function fishWedge(name,size,cf,color,parent,neon)
 local p=Instance.new("WedgePart");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=neon and Enum.Material.Neon or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
end
local function createFishVisual(fish,weight,cf)
 local m=Instance.new("Model");m.Name="Catch_"..string.gsub(fish.name," ","");m.Parent=district;m:SetAttribute("FishName",fish.name);m:SetAttribute("Rarity",fish.rarity);m:SetAttribute("Weight",weight)
 local scale=math.clamp(.72+weight/(fish.max*1.8),.8,1.45)
 local size;if fish.shape=="LONG" or fish.shape=="LEVIATHAN" then size=Vector3.new(7.4,2.1,2.0)*scale elseif fish.shape=="RAY" then size=Vector3.new(5.7,1.0,5.0)*scale else size=Vector3.new(5.4,2.45,2.05)*scale end
 local body=fishPart("Body",size,cf,fish.body,fish.rarity=="MYTHIC" and Enum.Material.Neon or Enum.Material.SmoothPlastic,m,Enum.PartType.Ball);m.PrimaryPart=body
 local back=-size.X*.52
 if fish.shape=="RAY" then
  fishWedge("WingL",Vector3.new(4.8,.7,3.2)*scale,cf*CFrame.new(-.2,0,2.8*scale)*CFrame.Angles(0,math.rad(180),0),fish.body,m,false)
  fishWedge("WingR",Vector3.new(4.8,.7,3.2)*scale,cf*CFrame.new(-.2,0,-2.8*scale),fish.body,m,false)
  fishPart("RayTail",Vector3.new(5.2*scale,.12,.12),cf*CFrame.new(back-2.2*scale,0,0),fish.accent,Enum.Material.SmoothPlastic,m,Enum.PartType.Cylinder)
 else
  fishWedge("TailTop",Vector3.new(2.3,2.7,.42)*scale,cf*CFrame.new(back-1.0*scale,.55*scale,0)*CFrame.Angles(0,math.rad(90),0),fish.accent,m,false)
  fishWedge("TailBottom",Vector3.new(2.3,2.7,.42)*scale,cf*CFrame.new(back-1.0*scale,-.55*scale,0)*CFrame.Angles(math.rad(180),math.rad(90),0),fish.accent,m,false)
  fishWedge("Dorsal",Vector3.new(1.9,1.25,.32)*scale,cf*CFrame.new(-.4*scale,size.Y*.48,0)*CFrame.Angles(0,math.rad(90),0),fish.accent,m,fish.rarity=="MYTHIC")
  fishWedge("FinL",Vector3.new(1.5,.32,1.2)*scale,cf*CFrame.new(.2*scale,-.15*scale,size.Z*.48)*CFrame.Angles(math.rad(-18),0,0),fish.accent,m,false)
  fishWedge("FinR",Vector3.new(1.5,.32,1.2)*scale,cf*CFrame.new(.2*scale,-.15*scale,-size.Z*.48)*CFrame.Angles(math.rad(198),0,0),fish.accent,m,false)
 end
 local ex=size.X*.35;local ez=size.Z*.47
 for _,z in ipairs({-ez,ez}) do fishPart("Eye",Vector3.new(.34,.34,.34)*scale,cf*CFrame.new(ex,size.Y*.18,z),Color3.fromRGB(8,9,10),Enum.Material.SmoothPlastic,m,Enum.PartType.Ball) end
 if fish.shape=="CATFISH" then for _,z in ipairs({-.72,.72}) do fishPart("Whisker",Vector3.new(2.3*scale,.05,.05),cf*CFrame.new(size.X*.47,-.15*scale,z*scale)*CFrame.Angles(0,math.rad(z>0 and 25 or -25),math.rad(8)),fish.accent,Enum.Material.SmoothPlastic,m,Enum.PartType.Cylinder) end end
 if fish.shape=="LEVIATHAN" then for i=1,4 do fishWedge("Spine"..i,Vector3.new(1.1,1,.3)*scale,cf*CFrame.new(-2.2*scale+i*1.1*scale,size.Y*.50,0)*CFrame.Angles(0,math.rad(90),0),fish.accent,m,true) end end
 if fish.rarity=="LEGENDARY" or fish.rarity=="MYTHIC" then local h=Instance.new("Highlight");h.FillColor=fish.accent;h.FillTransparency=.84;h.OutlineColor=fish.accent;h.OutlineTransparency=.18;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=m end
 return m
end
local function showCatch(player,fish,weight)
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not hrp then return end
 local base=CFrame.new(hrp.Position+hrp.CFrame.RightVector*4+Vector3.new(0,4.1,0))*CFrame.Angles(0,math.rad(18),0);local visual=createFishVisual(fish,weight,base)
 task.spawn(function() local start=os.clock();while visual.Parent and os.clock()-start<4.1 do local t=os.clock()-start;visual:PivotTo(base*CFrame.new(0,math.sin(t*3)*.18,0)*CFrame.Angles(0,math.sin(t*2)*.08,0));task.wait(.05) end;if visual.Parent then visual:Destroy() end end)
end

-- =============================================================================
-- FISHING LOOP
-- =============================================================================
local function inDistrict(player)
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not hrp then return false end;local dx=hrp.Position.X-LAKE_CENTER.X;local dz=hrp.Position.Z-LAKE_CENTER.Z;return dx*dx+dz*dz<=DISTRICT_RADIUS*DISTRICT_RADIUS
end
local function insideLake(pos,margin)
 margin=margin or .9;local dx=(pos.X-LAKE_CENTER.X)/(RX*margin);local dz=(pos.Z-LAKE_CENTER.Z)/(RZ*margin);return dx*dx+dz*dz<=1
end
local function castTarget(player)
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not hrp then return nil end
 local target=hrp.Position+hrp.CFrame.LookVector*52;target=Vector3.new(target.X,WATER_Y+.8,target.Z)
 if not insideLake(target,.90) then local toward=Vector3.new(LAKE_CENTER.X-hrp.Position.X,0,LAKE_CENTER.Z-hrp.Position.Z);if toward.Magnitude>1 then target=hrp.Position+toward.Unit*math.min(64,toward.Magnitude*.72);target=Vector3.new(target.X,WATER_Y+.8,target.Z) end end
 if not insideLake(target,.90) then local v=Vector3.new(target.X-LAKE_CENTER.X,0,target.Z-LAKE_CENTER.Z);local scale=math.max(math.abs(v.X)/(RX*.82),math.abs(v.Z)/(RZ*.82),1);target=Vector3.new(LAKE_CENTER.X+v.X/scale,WATER_Y+.8,LAKE_CENTER.Z+v.Z/scale) end;return target
end
local function createBobber(tool,target)
 local m=Instance.new("Model");m.Name="ActiveBobber";m.Parent=district
 local body=fishPart("Float",Vector3.new(.7,.7,.7),CFrame.new(target),Color3.fromRGB(238,239,234),Enum.Material.SmoothPlastic,m,Enum.PartType.Ball)
 fishPart("Top",Vector3.new(.42,.42,.42),CFrame.new(target+Vector3.new(0,.35,0)),Color3.fromRGB(210,63,73),Enum.Material.SmoothPlastic,m,Enum.PartType.Ball)
 fishPart("Stem",Vector3.new(1.1,.10,.10),CFrame.new(target+Vector3.new(0,.55,0))*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(40,44,49),Enum.Material.Metal,m,Enum.PartType.Cylinder)
 local endAtt=Instance.new("Attachment");endAtt.Name="LineEnd";endAtt.Parent=body;local tipAtt=tool:FindFirstChild("LineTip",true);local beam
 if tipAtt and tipAtt:IsA("Attachment") then beam=Instance.new("Beam");beam.Name="FishingLine";beam.Attachment0=tipAtt;beam.Attachment1=endAtt;beam.Width0=.035;beam.Width1=.025;beam.FaceCamera=true;beam.Color=ColorSequence.new(Color3.fromRGB(224,228,229));beam.Transparency=NumberSequence.new(.12);beam.Parent=tipAtt end;return m,beam
end
local function cleanup(player)
 local s=sessions[player];if not s then return end;if s.beam then pcall(function() s.beam:Destroy() end) end;if s.bobber then pcall(function() s.bobber:Destroy() end) end;sessions[player]=nil
end
local function rareBoost(player)
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if hrp and hrp.Position.X>58 and hrp.Position.Z>775 then return 2.2 end;return 1
end
local function pickFish(player)
 local boost=rareBoost(player);local total=0
 for _,f in ipairs(FISH) do local w=f.chance;if f.rarity=="RARE" or f.rarity=="EPIC" then w*=boost elseif f.rarity=="LEGENDARY" or f.rarity=="MYTHIC" then w*=1+(boost-1)*.6 end;total+=w end
 local roll=math.random()*total;local acc=0
 for _,f in ipairs(FISH) do local w=f.chance;if f.rarity=="RARE" or f.rarity=="EPIC" then w*=boost elseif f.rarity=="LEGENDARY" or f.rarity=="MYTHIC" then w*=1+(boost-1)*.6 end;acc+=w;if roll<=acc then return f end end;return FISH[1]
end
local function fail(player,msg)
 cleanup(player);stateRemote:FireClient(player,"Escaped",{text=msg or "Ikan lepas."});task.delay(.65,function() if player.Parent then stateRemote:FireClient(player,"Idle",{}) end end)
end
local function finish(player,fish)
 local d=dataByUser[player.UserId];if not d then fail(player,"Data belum siap.");return end
 local weight=math.floor((fish.min+math.random()*(fish.max-fish.min))*100)/100;local reward=math.max(1,math.floor(fish.value*(.72+weight/fish.max*.55)*(VALUE_MULT[fish.rarity] or 1)))
 d.total+=1;d.tokens+=reward;d.best=math.max(d.best,weight);publishAttributes(player,d);cleanup(player);showCatch(player,fish,weight)
 stateRemote:FireClient(player,"Catch",{name=fish.name,rarity=fish.rarity,weight=weight,reward=reward,tokens=d.tokens,total=d.total,best=d.best});task.delay(.9,function() if player.Parent then stateRemote:FireClient(player,"Idle",{}) end end)
 if d.total%5==0 then task.spawn(saveData,player) end
end
local function startCast(player)
 if not inDistrict(player) then stateRemote:FireClient(player,"Toast",{text="Dekati danau untuk mancing."});return end;if sessions[player] then return end
 local rod=grantRod(player,true);local target=castTarget(player);if not rod or not target then return end;local bobber,beam=createBobber(rod,target);local s={state="WAITING",rod=rod,bobber=bobber,beam=beam};sessions[player]=s;stateRemote:FireClient(player,"Waiting",{})
 task.delay(2.2+math.random()*3.1,function() if sessions[player]~=s or s.state~="WAITING" then return end;s.fish=pickFish(player);s.state="BITE";s.deadline=os.clock()+2.35;stateRemote:FireClient(player,"Bite",{});task.delay(2.4,function() if sessions[player]==s and s.state=="BITE" then fail(player,"Strike terlambat — ikan lepas.") end end) end)
end
local function hook(player)
 local s=sessions[player];if not s or s.state~="BITE" or not s.fish then return end;if os.clock()>(s.deadline or 0) then fail(player,"Strike terlambat — ikan lepas.");return end
 s.state="FIGHT";s.progress=0;s.tension=.20;s.reeling=false;s.lastPush=0;s.difficulty=DIFFICULTY[s.fish.rarity] or .8;stateRemote:FireClient(player,"Fight",{rarity=s.fish.rarity,progress=0,tension=.2})
end

RunService.Heartbeat:Connect(function(dt)
 dt=math.min(dt,.12);local now=os.clock()
 for player,s in pairs(sessions) do
  if s.state=="FIGHT" then
   if not player.Parent or not inDistrict(player) then fail(player,"Keluar dari area mancing.") else
    local pressure=math.max(.42,.78+.20*math.sin(now*2.3+player.UserId%17)+.12*math.sin(now*5.1+player.UserId%11))
    if s.reeling then s.progress=math.clamp(s.progress+dt*(.31/s.difficulty),0,1);s.tension=math.clamp(s.tension+dt*(.36*s.difficulty*pressure),0,1.2)
    else s.progress=math.clamp(s.progress-dt*(.028*s.difficulty),0,1);s.tension=math.clamp(s.tension-dt*.49+dt*.035*s.difficulty*pressure,0,1.2) end
    if s.tension>=1 then fail(player,"Tali terlalu tegang — ikan lepas.") elseif s.progress>=1 then finish(player,s.fish) elseif now-(s.lastPush or 0)>.10 then s.lastPush=now;stateRemote:FireClient(player,"FightTick",{progress=s.progress,tension=s.tension}) end
   end
  end
 end
end)

local prompt=district:FindFirstChild("GetFishingRod",true)
if prompt and prompt:IsA("ProximityPrompt") then prompt.Triggered:Connect(function(player) grantRod(player,true);stateRemote:FireClient(player,"Toast",{text="Pancing siap. Skin ada di ROD / SHOP."});sendSnapshot(player) end) end

actionRemote.OnServerEvent:Connect(function(player,action,payload)
 if type(action)~="string" then return end;local d=dataByUser[player.UserId]
 if action=="Snapshot" then sendSnapshot(player);return end;if not d then return end
 if action=="GetRod" then grantRod(player,true);sendSnapshot(player);return end
 if action=="Cast" then startCast(player);return end
 if action=="Hook" then hook(player);return end
 if action=="Reel" then local s=sessions[player];if s and s.state=="FIGHT" then s.reeling=payload==true end;return end
 if action=="EquipSkin" and type(payload)=="string" then
  if d.unlocked[payload] and skinByName[payload] then d.equipped=payload;publishAttributes(player,d);local rod=findRod(player);if rod then applySkin(rod,payload) end;sendSnapshot(player);stateRemote:FireClient(player,"Toast",{text=payload.." dipakai."}) end;return
 end
 if action=="BuySkin" and type(payload)=="string" then
  local skin=skinByName[payload];if not skin then return end
  if d.unlocked[payload] then d.equipped=payload;local rod=findRod(player);if rod then applySkin(rod,payload) end;publishAttributes(player,d);sendSnapshot(player);return end
  if d.total<skin.required then stateRemote:FireClient(player,"Toast",{text="Butuh "..skin.required.." tangkapan."});return end
  if d.tokens<skin.price then stateRemote:FireClient(player,"Toast",{text="Lake Token belum cukup."});return end
  d.tokens-=skin.price;d.unlocked[payload]=true;d.equipped=payload;publishAttributes(player,d);local rod=findRod(player);if rod then applySkin(rod,payload) end;task.spawn(saveData,player);sendSnapshot(player);stateRemote:FireClient(player,"Toast",{text="Skin "..payload.." terbuka."})
 end
end)

local function setup(player)
 task.spawn(function() loadData(player);task.wait(.2);sendSnapshot(player) end)
 player.CharacterAdded:Connect(function() task.wait(1);local d=dataByUser[player.UserId];if d then publishAttributes(player,d) end end)
end
for _,p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) cleanup(player);saveData(player);dataByUser[player.UserId]=nil end)
task.spawn(function() while task.wait(90) do for _,p in ipairs(Players:GetPlayers()) do task.spawn(saveData,p) end end end)
game:BindToClose(function() for _,p in ipairs(Players:GetPlayers()) do saveData(p) end end)

print("[BBYA] Fishing core v2 online: server-authoritative tension fishing + 3D fish + dimensional rod skins")
