-- BBYA SOCIAL HUB — CLUB PURITY + MALL LIFESTYLE RELOCATION v1
-- Keeps Floor 1 as a pure nightclub, grounds/declutters the DJ zone,
-- and relocates Look Lab + Editorial Photo Studio into GLOW LAB on Mall Level 2.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local Debris=game:GetService("Debris")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end
local club=root:WaitForChild("MainClubRealism",45)
local front=root:WaitForChild("Floor1FrontPremium",45)
local luxury=root:WaitForChild("Floor1LuxuryFinish",45)
local ultra=root:WaitForChild("Floor1UltraPremium",45)
local features=root:WaitForChild("Floor1Features",45)
local oldLookRuntime=root:WaitForChild("LookLabAvatarEditorV1",45)
local mall=root:WaitForChild("BBYAMall",60)
if not club or not front or not luxury or not ultra or not features or not mall then
 warn("[BBYA Club Purity] prerequisite build unavailable")
 return
end
local mallLive=mall:WaitForChild("MallLiveUpgradeV2",60)
if not mallLive then warn("[BBYA Club Purity] MallLiveUpgradeV2 unavailable");return end
-- Let the other mall dressing passes finish before the targeted tenant replacement.
task.wait(2)

local old=root:FindFirstChild("ClubPurityMallStudiosV1")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="ClubPurityMallStudiosV1"
out:SetAttribute("Pass","CLUB_PURITY_MALL_STUDIOS_V1")
out:SetAttribute("ClubPureNightclub",true)
out:SetAttribute("DJGrounded",true)
out:SetAttribute("DJLooseFurnitureRemoved",true)
out:SetAttribute("SalonMovedToMall",true)
out:SetAttribute("PhotoStudioMovedToMall",true)
out:SetAttribute("MallLevel",2)
out.Parent=root

local C={
 black=Color3.fromRGB(8,8,10),ink=Color3.fromRGB(14,13,17),charcoal=Color3.fromRGB(24,23,28),
 graphite=Color3.fromRGB(43,41,47),metal=Color3.fromRGB(62,61,68),stone=Color3.fromRGB(83,79,86),
 fabric=Color3.fromRGB(39,35,43),plum=Color3.fromRGB(72,50,68),glass=Color3.fromRGB(105,119,130),
 brass=Color3.fromRGB(184,139,84),champagne=Color3.fromRGB(215,177,126),warm=Color3.fromRGB(255,207,161),
 pink=Color3.fromRGB(244,48,149),cyan=Color3.fromRGB(31,184,207),white=Color3.fromRGB(240,237,242),
}
local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CastShadow=material~=Enum.Material.Neon;p.Parent=parent or out;return p
end
local function wedge(name,size,cf,color,material,parent,collide)
 local p=Instance.new("WedgePart");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true;p.Parent=parent or out;return p
end
local function cylinder(name,size,cf,color,material,transparency,parent,collide)
 local p=part(name,size,cf,color,material,transparency,parent,collide);p.Shape=Enum.PartType.Cylinder;return p
end
local function ball(name,size,cf,color,material,transparency,parent,collide)
 local p=part(name,size,cf,color,material,transparency,parent,collide);p.Shape=Enum.PartType.Ball;return p
end
local function model(name,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m end
local function point(parent,color,brightness,range,shadows)
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=shadows==true;l.Parent=parent;return l
end
local function spot(parent,face,color,brightness,range,angle,shadows)
 local l=Instance.new("SpotLight");l.Face=face;l.Color=color;l.Brightness=brightness;l.Range=range;l.Angle=angle;l.Shadows=shadows==true;l.Parent=parent;return l
end
local function prompt(parent,action,obj,dist,hold)
 local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=obj;q.KeyboardKeyCode=Enum.KeyCode.E;q.GamepadKeyCode=Enum.KeyCode.ButtonX
 q.MaxActivationDistance=dist or 9;q.HoldDuration=hold or .15;q.RequiresLineOfSight=false;q.Parent=parent;return q
end
local function textPlate(parent,name,size,cf,textValue,color,face)
 local p=part(name,size,cf,C.black,Enum.Material.Glass,.05,parent,false)
 local g=Instance.new("SurfaceGui");g.Face=face or Enum.NormalId.Front;g.PixelsPerStud=70;g.LightInfluence=.25;g.Parent=p
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text=textValue;t.TextColor3=color or C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g
 return p,t
end
local function hrpHum(plr)
 local ch=plr.Character;if not ch then return nil,nil,nil end
 return ch:FindFirstChild("HumanoidRootPart"),ch:FindFirstChildOfClass("Humanoid"),ch
end

-- 1) RETIRE SALON + PHOTO ROOM FROM MAIN CLUB --------------------------------
for _,name in ipairs({"PhotoAreaPremium","SalonLookStudioPremium"}) do
 local obj=front:FindFirstChild(name);if obj then obj:Destroy() end
end
for _,folderName in ipairs({"EditorialPhotoRoom","LookLab"}) do
 local f=luxury:FindFirstChild(folderName);if f then f:Destroy() end
end
for _,folderName in ipairs({"EditorialPhotoRefinement","LookLabRefinement"}) do
 local f=ultra:FindFirstChild(folderName);if f then f:Destroy() end
end
-- Remove old interaction anchors from the former club locations.
for _,obj in ipairs(features:GetDescendants()) do
 local n=obj.Name
 if n=="PhotoModeInteract" or n=="PhotoPrepInteract" or n=="LookWashInteract" or n:match("^LookChairInteract") then
  obj:Destroy()
 end
end
if oldLookRuntime and oldLookRuntime.Parent then oldLookRuntime:Destroy() end

-- 2) MAIN CLUB FRONT-LEFT EXTENSION: SAME VENUE LANGUAGE ----------------------
local clubFront=model("MainClubFrontExtension",out)
part("FrontClubFloor",Vector3.new(25,.16,42),CFrame.new(-39,1.02,-14.5),Color3.fromRGB(22,22,27),Enum.Material.SmoothPlastic,0,clubFront,true).Reflectance=.08
-- Continuous edge/detail ties this former salon/photo footprint into the dance-room architecture.
part("BronzeFloorReveal",Vector3.new(.07,.035,39.5),CFrame.new(-26.65,1.115,-14.5),C.brass,Enum.Material.Metal,0,clubFront,false)
part("CeilingField",Vector3.new(24,.42,40),CFrame.new(-39,13.0,-14.5),C.ink,Enum.Material.Slate,0,clubFront,false)
for i,z in ipairs({-30,-20,-10,0}) do
 part("WallRecess"..i,Vector3.new(.48,8.3,8.0),CFrame.new(-50.0,6.0,z),C.ink,Enum.Material.Slate,0,clubFront,false)
 part("WallPanel"..i,Vector3.new(.22,6.7,6.7),CFrame.new(-49.72,6.0,z),C.fabric,Enum.Material.Fabric,0,clubFront,false)
 local cove=part("WarmCove"..i,Vector3.new(.08,5.8,.10),CFrame.new(-49.55,6.0,z-3.15),C.warm,Enum.Material.Neon,.32,clubFront,false)
 point(cove,C.warm,.16,7,false)
end
part("BronzeDatum",Vector3.new(.08,.10,38),CFrame.new(-49.50,9.35,-14.5),C.brass,Enum.Material.Metal,0,clubFront,false)
-- Open portal to the dance room; no door or obstruction in the circulation path.
part("PortalPierA",Vector3.new(1.0,10.5,1.0),CFrame.new(-27.2,6.25,-5.8),C.graphite,Enum.Material.Metal,0,clubFront,false)
part("PortalPierB",Vector3.new(1.0,10.5,1.0),CFrame.new(-27.2,6.25,-23.0),C.graphite,Enum.Material.Metal,0,clubFront,false)
part("PortalHeader",Vector3.new(1.0,.75,18.2),CFrame.new(-27.2,11.1,-14.4),C.graphite,Enum.Material.Metal,0,clubFront,false)
part("PortalReveal",Vector3.new(.12,.12,14.0),CFrame.new(-26.65,10.62,-14.4),C.brass,Enum.Material.Metal,0,clubFront,false)

local function roundedLounge(index,z)
 local m=model("ArrivalLounge"..index,clubFront)
 part("Rug",Vector3.new(13,.08,9.5),CFrame.new(-39.0,1.13,z),Color3.fromRGB(29,26,31),Enum.Material.Fabric,0,m,false)
 -- Ellipsoid cushions remove the old block/Minecraft silhouette.
 for n=1,3 do
  local zz=z-2.35+(n-1)*2.35
  ball("Seat"..n,Vector3.new(3.7,.85,2.20),CFrame.new(-44.0,1.72,zz),index==1 and C.fabric or C.plum,Enum.Material.Fabric,0,m,true)
  ball("Back"..n,Vector3.new(1.00,2.65,2.15),CFrame.new(-46.0,2.82,zz),index==1 and Color3.fromRGB(49,43,52) or Color3.fromRGB(77,56,72),Enum.Material.Fabric,0,m,false)
 end
 cylinder("TableFoot",Vector3.new(.12,1.75,1.75),CFrame.new(-36.3,1.30,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,m,false)
 cylinder("TableStem",Vector3.new(1.05,.18,.18),CFrame.new(-36.3,1.00,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,m,false)
 cylinder("TableTop",Vector3.new(.16,3.15,3.15),CFrame.new(-36.3,1.62,z)*CFrame.Angles(0,0,math.rad(90)),C.stone,Enum.Material.Marble,0,m,false)
 local glow=part("ToeGlow",Vector3.new(.08,.10,6.5),CFrame.new(-45.8,1.20,z),C.warm,Enum.Material.Neon,.40,m,false);point(glow,C.warm,.12,5,false)
end
roundedLounge(1,-27)
roundedLounge(2,-13)

-- 3) CLEAN / GROUND DJ BOOTH --------------------------------------------------
local mainLuxury=luxury:FindFirstChild("MainClub")
if mainLuxury then
 local loose=mainLuxury:FindFirstChild("RearSocialRail");if loose then loose:Destroy() end
end
-- Remove actual Seat/VehicleSeat instances only in the DJ/stage-front footprint.
for _,obj in ipairs(root:GetDescendants()) do
 if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
  local p=obj.Position
  if p.X>=-18 and p.X<=24 and p.Z>=28 and p.Z<=39 and p.Y<12 then obj:Destroy() end
 end
end
local djGround=model("DJGrounding",out)
-- The old DJ platform mostly sat in front of the physical stage deck; this riser carries it down to Floor 1.
part("RiserCore",Vector3.new(14.8,2.25,8.3),CFrame.new(3,2.20,34.3),C.black,Enum.Material.Metal,0,djGround,true)
part("RiserWingL",Vector3.new(5.4,2.15,7.5),CFrame.new(-6.8,2.18,34.5)*CFrame.Angles(0,math.rad(-11),0),C.charcoal,Enum.Material.Metal,0,djGround,true)
part("RiserWingR",Vector3.new(5.4,2.15,7.5),CFrame.new(12.8,2.18,34.5)*CFrame.Angles(0,math.rad(11),0),C.charcoal,Enum.Material.Metal,0,djGround,true)
part("FrontFascia",Vector3.new(21.4,1.70,.34),CFrame.new(3,2.25,30.08),C.ink,Enum.Material.Metal,0,djGround,false)
for i=1,7 do
 part("FasciaRib"..i,Vector3.new(.16,1.15,.10),CFrame.new(-6+(i-1)*3,2.28,29.88),i==4 and C.brass or C.graphite,Enum.Material.Metal,0,djGround,false)
end
part("RiserReveal",Vector3.new(18.5,.07,.08),CFrame.new(3,3.10,29.84),C.brass,Enum.Material.Metal,0,djGround,false)
local av=club:FindFirstChild("AudioVisual")
local dj=av and av:FindFirstChild("DJBoothPremium")
if dj then
 local platform=dj:FindFirstChild("DJPlatform")
 if platform and platform:IsA("BasePart") then platform.CFrame=platform.CFrame+Vector3.new(0,-.025,0) end
end

-- 4) GLOW LAB ON MALL LEVEL 2: LOOK LAB + PHOTO STUDIO ------------------------
-- Repurpose the existing Beauty tenant so the old mall directory remains truthful: GLOW LAB -> styling/beauty/photo.
local oldGlow=mall:FindFirstChild("Tenant_glow")
if oldGlow then oldGlow:Destroy() end
local oldBooth=mallLive:FindFirstChild("BBYAPhotoBooth")
if oldBooth then oldBooth:Destroy() end

local lifestyle=model("Tenant_glow",mall)
lifestyle:SetAttribute("TenantName","GLOW LAB")
lifestyle:SetAttribute("Department","LOOK_LAB_AND_PHOTO_STUDIO")
lifestyle:SetAttribute("Floor",2)
lifestyle:SetAttribute("Functional",true)
local Y=15
part("Floor",Vector3.new(46,.35,26),CFrame.new(70,Y+.70,365),Color3.fromRGB(204,199,197),Enum.Material.Marble,0,lifestyle,true)
part("BackWall",Vector3.new(.65,11.5,25),CFrame.new(92.55,Y+6.3,365),C.charcoal,Enum.Material.Slate,0,lifestyle,true)
part("SideWallA",Vector3.new(45,11.5,.55),CFrame.new(70,Y+6.3,352.35),C.ink,Enum.Material.Slate,0,lifestyle,true)
part("SideWallB",Vector3.new(45,11.5,.55),CFrame.new(70,Y+6.3,377.65),C.ink,Enum.Material.Slate,0,lifestyle,true)
-- Angled glass wings and circular metal posts make the storefront read as a designed boutique, not a box.
part("GlassWingA",Vector3.new(.34,8.7,8.3),CFrame.new(49.1,Y+5.3,356.2)*CFrame.Angles(0,math.rad(-12),0),C.glass,Enum.Material.Glass,.32,lifestyle,false)
part("GlassWingB",Vector3.new(.34,8.7,8.3),CFrame.new(49.1,Y+5.3,373.8)*CFrame.Angles(0,math.rad(12),0),C.glass,Enum.Material.Glass,.32,lifestyle,false)
for _,z in ipairs({352.8,377.2}) do cylinder("FacadePost"..z,Vector3.new(9.4,.48,.48),CFrame.new(49.0,Y+5.4,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,lifestyle,false) end
local sign=textPlate(lifestyle,"GlowLabSign",Vector3.new(.35,4.2,20),CFrame.new(48.55,Y+10.5,365),"GLOW LAB\nLOOK LAB • PHOTO STUDIO",C.white,Enum.NormalId.Left)
point(sign,C.pink,.28,9,false)
part("SignUnderline",Vector3.new(.12,.10,17.5),CFrame.new(48.34,Y+8.15,365),C.pink,Enum.Material.Neon,.18,lifestyle,false)

-- Soft ceiling islands.
for i,z in ipairs({356,365,374}) do
 part("CeilingRaft"..i,Vector3.new(24,.36,5.6),CFrame.new(76,Y+11.55,z)*CFrame.Angles(0,math.rad(i==2 and -5 or 5),0),Color3.fromRGB(32,29,35),Enum.Material.Fabric,0,lifestyle,false)
 local d=cylinder("CeilingDownlight"..i,Vector3.new(.28,.85,.85),CFrame.new(76,Y+11.25,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,lifestyle,false)
 spot(d,Enum.NormalId.Bottom,C.warm,.85,18,54,false)
end

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local feature=remotes:FindFirstChild("Feature") or Instance.new("RemoteEvent")
feature.Name="Feature";feature.Parent=remotes
local lookRemote=remotes:FindFirstChild("LookLabAvatar") or Instance.new("RemoteEvent")
lookRemote.Name="LookLabAvatar";lookRemote.Parent=remotes
local state=remotes:FindFirstChild("State")

local function toast(plr,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(plr,"toast",msg) else feature:FireClient(plr,"toast",msg) end
end

-- LOOK LAB section: three rounded styling stations facing illuminated mirrors.
local lookSection=model("MallLookLab",lifestyle)
textPlate(lookSection,"LookLabLabel",Vector3.new(.16,1.8,8.5),CFrame.new(92.10,Y+9.0,360),"LOOK LAB",C.warm,Enum.NormalId.Left)
local touchDebounce={}
local originalDescriptions={}
local lookZ={355.5,361.5,367.5}
for i,z in ipairs(lookZ) do
 local station=model("LookStation"..i,lookSection)
 local mirror=part("Mirror",Vector3.new(.18,5.8,4.5),CFrame.new(90.7,Y+5.0,z),Color3.fromRGB(115,127,138),Enum.Material.Glass,.18,station,false);mirror.Reflectance=.35
 for _,dz in ipairs({-2.25,2.25}) do part("MirrorSide",Vector3.new(.10,5.7,.10),CFrame.new(90.48,Y+5.0,z+dz),C.warm,Enum.Material.Neon,.18,station,false) end
 part("Vanity",Vector3.new(3.8,.38,4.7),CFrame.new(88.8,Y+2.15,z),Color3.fromRGB(118,110,119),Enum.Material.Marble,0,station,false)
 cylinder("ChairBase",Vector3.new(.15,2.0,2.0),CFrame.new(80.4,Y+.85,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,station,false)
 cylinder("ChairStem",Vector3.new(1.15,.20,.20),CFrame.new(80.4,Y+1.50,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,station,false)
 ball("ChairCushion",Vector3.new(2.7,.90,2.55),CFrame.new(80.4,Y+2.12,z),i==2 and C.plum or C.fabric,Enum.Material.Fabric,0,station,true)
 ball("ChairBack",Vector3.new(1.15,2.7,2.55),CFrame.new(81.55,Y+3.10,z),i==2 and Color3.fromRGB(80,57,75) or Color3.fromRGB(53,46,55),Enum.Material.Fabric,0,station,false)
 local seat=Instance.new("Seat");seat.Name="LookLabSeat"..i;seat.Size=Vector3.new(2.2,.45,2.0);seat.CFrame=CFrame.new(80.2,Y+2.26,z)*CFrame.Angles(0,math.rad(-90),0)
 seat.Transparency=1;seat.Anchored=true;seat.CanCollide=false;seat.CanTouch=false;seat.CanQuery=false;seat.Parent=station
 local trigger=part("AutoStyleTrigger"..i,Vector3.new(3.2,3.0,3.5),CFrame.new(77.7,Y+2.6,z),C.white,Enum.Material.SmoothPlastic,1,station,false);trigger.CanTouch=true
 trigger.Touched:Connect(function(hit)
  local ch=hit and hit:FindFirstAncestorOfClass("Model");local hum=ch and ch:FindFirstChildOfClass("Humanoid");local plr=ch and Players:GetPlayerFromCharacter(ch)
  if not hum or not plr or hum.Health<=0 or hum.Sit or seat.Occupant then return end
  local now=os.clock();if (touchDebounce[plr] or 0)+2>now then return end;touchDebounce[plr]=now
  seat:Sit(hum)
  task.delay(.18,function()if plr.Parent and hum.Parent and hum.SeatPart==seat then lookRemote:FireClient(plr,"open",{station=i,mall=true}) end end)
 end)
end
-- Wash/refresh counter retained as a real salon function.
local wash=part("WashConsole",Vector3.new(5.2,2.2,3.2),CFrame.new(85.8,Y+1.95,353.9),C.charcoal,Enum.Material.Metal,0,lookSection,true)
cylinder("WashBasin",Vector3.new(.52,2.2,2.2),CFrame.new(85.8,Y+3.18,353.9)*CFrame.Angles(0,0,math.rad(90)),C.stone,Enum.Material.Marble,0,lookSection,false)
local washPrompt=prompt(wash,"REFRESH","LOOK LAB WASH",8,.20)
washPrompt.Triggered:Connect(function(plr)
 local hrp,_,ch=hrpHum(plr);if not hrp or (hrp.Position-wash.Position).Magnitude>12 or not ch then return end
 local h=Instance.new("Highlight");h.Name="BBYARefreshGlow";h.FillColor=C.cyan;h.FillTransparency=.82;h.OutlineColor=C.warm;h.OutlineTransparency=.25;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=ch
 Debris:AddItem(h,4);feature:FireClient(plr,"washFx",{});toast(plr,"Look refreshed — siap untuk photo studio.")
end)

-- Look Lab avatar try-on handling for the new Mall location. Existing client UI is reused.
local TOP_TYPES={[Enum.AccessoryType.TShirt]=true,[Enum.AccessoryType.Shirt]=true,[Enum.AccessoryType.Jacket]=true,[Enum.AccessoryType.Sweater]=true}
local BOTTOM_TYPES={[Enum.AccessoryType.Pants]=true,[Enum.AccessoryType.Shorts]=true,[Enum.AccessoryType.DressSkirt]=true}
local TYPE_MAP={
 HairAccessory={acc=Enum.AccessoryType.Hair,group="HAIR",layered=false},Hat={acc=Enum.AccessoryType.Hat,group="SAME",layered=false},
 FaceAccessory={acc=Enum.AccessoryType.Face,group="SAME",layered=false},NeckAccessory={acc=Enum.AccessoryType.Neck,group="SAME",layered=false},
 ShoulderAccessory={acc=Enum.AccessoryType.Shoulder,group="SAME",layered=false},FrontAccessory={acc=Enum.AccessoryType.Front,group="SAME",layered=false},
 BackAccessory={acc=Enum.AccessoryType.Back,group="SAME",layered=false},WaistAccessory={acc=Enum.AccessoryType.Waist,group="SAME",layered=false},
 TShirtAccessory={acc=Enum.AccessoryType.TShirt,group="TOP",layered=true},ShirtAccessory={acc=Enum.AccessoryType.Shirt,group="TOP",layered=true},
 JacketAccessory={acc=Enum.AccessoryType.Jacket,group="TOP",layered=true},SweaterAccessory={acc=Enum.AccessoryType.Sweater,group="TOP",layered=true},
 PantsAccessory={acc=Enum.AccessoryType.Pants,group="BOTTOM",layered=true},ShortsAccessory={acc=Enum.AccessoryType.Shorts,group="BOTTOM",layered=true},
 DressSkirtAccessory={acc=Enum.AccessoryType.DressSkirt,group="BOTTOM",layered=true},
}
local CLASSIC={Shirt="Shirt",Pants="Pants",TShirt="GraphicTShirt"}
local function nearMallLookLab(plr)
 local hrp=hrpHum(plr);return hrp and (hrp.Position-Vector3.new(80,Y+2.4,361.5)).Magnitude<=30
end
local function cleanTypeName(v)local s=tostring(v or "");return (s:gsub("Enum%.AvatarAssetType%.","")) end
local function rememberOriginal(plr,hum)
 if originalDescriptions[plr] then return end
 local ok,desc=pcall(function()return hum:GetAppliedDescription()end);if ok and desc then originalDescriptions[plr]=desc:Clone() end
end
local function replaceAccessory(desc,assetId,spec)
 local ok,list=pcall(function()return desc:GetAccessories(true)end);if not ok then return false end
 local kept={}
 for _,entry in ipairs(list) do
  local t=entry.AccessoryType;local remove=false
  if spec.group=="HAIR" then remove=(t==Enum.AccessoryType.Hair)
  elseif spec.group=="TOP" then remove=TOP_TYPES[t]==true
  elseif spec.group=="BOTTOM" then remove=BOTTOM_TYPES[t]==true
  elseif spec.group=="SAME" then remove=(t==spec.acc) end
  if not remove then table.insert(kept,entry) end
 end
 local add={AssetId=assetId,AccessoryType=spec.acc};if spec.layered then add.Order=(spec.group=="TOP") and 2 or 5;add.Puffiness=0 end
 table.insert(kept,add);return pcall(function()desc:SetAccessories(kept,true)end)
end
local function applyDescription(hum,desc)local ok=pcall(function()hum:ApplyDescriptionAsync(desc)end);return ok end
lookRemote.OnServerEvent:Connect(function(plr,action,payload)
 local _,hum=hrpHum(plr);if not hum or not nearMallLookLab(plr) then return end
 if action=="tryOn" then
  if typeof(payload)~="table" then return end
  local assetId=tonumber(payload.assetId);local typeName=cleanTypeName(payload.assetType)
  if not assetId or assetId<=0 or assetId>999999999999999 then return end
  rememberOriginal(plr,hum)
  local ok,desc=pcall(function()return hum:GetAppliedDescription()end);if not ok or not desc then return end
  local changed=false;local classic=CLASSIC[typeName]
  if classic then changed=pcall(function()desc[classic]=assetId end) else local spec=TYPE_MAP[typeName];if spec then changed=replaceAccessory(desc,assetId,spec) end end
  if not changed then lookRemote:FireClient(plr,"status","Item type belum didukung di Look Lab.");return end
  if applyDescription(hum,desc) then lookRemote:FireClient(plr,"status","TRY ON aktif — RESET kapan saja.") else lookRemote:FireClient(plr,"status","Item tidak bisa dipakai pada avatar ini.") end
 elseif action=="reset" then
  local original=originalDescriptions[plr]
  if original and applyDescription(hum,original:Clone()) then originalDescriptions[plr]=nil;lookRemote:FireClient(plr,"status","Avatar dikembalikan ke tampilan awal.")
  else lookRemote:FireClient(plr,"status","Belum ada perubahan untuk di-reset.") end
 end
end)

-- PHOTO STUDIO section: proper cove, softboxes, camera and the same multi-angle UI.
local photoSection=model("MallPhotoStudio",lifestyle)
textPlate(photoSection,"PhotoLabel",Vector3.new(.16,1.8,9.5),CFrame.new(92.08,Y+9.0,373.0),"PHOTO STUDIO",C.white,Enum.NormalId.Left)
part("Backdrop",Vector3.new(.28,7.7,8.7),CFrame.new(90.5,Y+5.1,373.0),Color3.fromRGB(26,23,29),Enum.Material.Slate,0,photoSection,false)
part("BackdropFloor",Vector3.new(8.6,.10,8.7),CFrame.new(86.2,Y+.93,373.0),Color3.fromRGB(26,23,29),Enum.Material.SmoothPlastic,0,photoSection,true)
wedge("Cove",Vector3.new(2.6,1.45,8.7),CFrame.new(89.0,Y+1.72,373.0)*CFrame.Angles(0,0,math.rad(-90)),Color3.fromRGB(26,23,29),Enum.Material.SmoothPlastic,photoSection,false)
local subject=Vector3.new(84.2,Y+2.25,373.0)
local function softbox(name,pos,target,size,col)
 local m=model(name,photoSection);local look=CFrame.lookAt(pos,target)
 cylinder("StandBase",Vector3.new(.14,1.8,1.8),CFrame.new(pos.X,Y+.85,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,m,false)
 part("Stand",Vector3.new(.16,5.0,.16),CFrame.new(pos.X,Y+3.2,pos.Z),C.metal,Enum.Material.Metal,0,m,false)
 local panel=part("Softbox",size,look,C.white,Enum.Material.Neon,.05,m,false)
 local light=Instance.new("SurfaceLight");light.Face=Enum.NormalId.Front;light.Color=col;light.Brightness=2.1;light.Range=24;light.Angle=115;light.Shadows=false;light.Parent=panel
end
softbox("KeySoftbox",Vector3.new(72,Y+6.3,368.4),subject,Vector3.new(4.6,3.2,.18),C.warm)
softbox("FillSoftbox",Vector3.new(72,Y+5.7,377.2),subject,Vector3.new(4.1,3.0,.18),C.white)
softbox("RimSoftbox",Vector3.new(87.0,Y+6.4,367.8),subject,Vector3.new(3.0,2.2,.16),C.cyan)
-- Camera pedestal is grounded and unmistakably camera equipment.
cylinder("CameraBase",Vector3.new(.16,2.0,2.0),CFrame.new(60.5,Y+.85,373)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,photoSection,false)
part("CameraStem",Vector3.new(.18,3.7,.18),CFrame.new(60.5,Y+2.65,373),C.metal,Enum.Material.Metal,0,photoSection,false)
part("CameraBody",Vector3.new(1.2,.8,1.6),CFrame.new(60.5,Y+4.65,373),C.black,Enum.Material.Metal,0,photoSection,false)
cylinder("CameraLens",Vector3.new(.65,.70,.70),CFrame.new(61.15,Y+4.65,373)*CFrame.Angles(0,math.rad(90),0),Color3.fromRGB(25,29,36),Enum.Material.Glass,.06,photoSection,false)
local photoAnchor=part("MallPhotoInteract",Vector3.new(1.3,2.8,3.0),CFrame.new(57.7,Y+2.4,373),C.pink,Enum.Material.Neon,.70,photoSection,false)
local photoPrompt=prompt(photoAnchor,"OPEN PHOTO STUDIO","GLOW LAB",10,.18)
local PHOTO_ANGLES={
 Classic=CFrame.lookAt(Vector3.new(62.0,Y+4.7,373.0),Vector3.new(84.2,Y+2.3,373.0)),
 Low=CFrame.lookAt(Vector3.new(64.0,Y+2.5,368.5),Vector3.new(84.2,Y+2.5,373.0)),
 Editorial=CFrame.lookAt(Vector3.new(68.0,Y+6.0,377.6),Vector3.new(84.2,Y+2.7,373.0)),
}
photoPrompt.Triggered:Connect(function(plr)
 local hrp=hrpHum(plr);if hrp and (hrp.Position-photoAnchor.Position).Magnitude<=15 then feature:FireClient(plr,"photoMenu",{angles={"Classic","Low","Editorial"}}) end
end)
local photoCooldown={}
local function freezeFor(plr,seconds)
 local _,hum=hrpHum(plr);if not hum then return end
 local walk,jump=hum.WalkSpeed,hum.JumpPower;hum.WalkSpeed=0;hum.JumpPower=0
 task.delay(seconds,function()if hum.Parent then hum.WalkSpeed=walk;hum.JumpPower=jump end end)
end
feature.OnServerEvent:Connect(function(plr,action,arg)
 if action~="photoStart" then return end
 local hrp=hrpHum(plr);if not hrp or (hrp.Position-photoAnchor.Position).Magnitude>22 then return end
 local now=os.clock();if (photoCooldown[plr] or 0)+7>now then return end;photoCooldown[plr]=now
 local angle=tostring(arg or "Classic");local camera=PHOTO_ANGLES[angle];if not camera then return end
 hrp.CFrame=CFrame.lookAt(subject,Vector3.new(62,Y+2.5,373));freezeFor(plr,7)
 feature:FireClient(plr,"photoMode",{camera=camera,duration=7,label="GLOW LAB EDITORIAL · "..string.upper(angle)})
end)

Players.PlayerRemoving:Connect(function(plr)touchDebounce[plr]=nil;originalDescriptions[plr]=nil;photoCooldown[plr]=nil end)

print("[BBYA] Club Purity + Mall Studios v1 online: clean DJ, pure club, GLOW LAB Look Lab + Photo Studio")
