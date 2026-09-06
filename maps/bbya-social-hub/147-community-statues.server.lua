-- BBYA SOCIAL HUB — OWNER + TOP DONOR PHYSICAL AVATARS v3 RIG-SAFE
-- Stage/position/uplight authority preserved from v2.
-- Render root fix: reject stretched/malformed bounds, then rebuild from normalized non-layered HumanoidDescription.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Workspace=game:GetService("Workspace")
local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local RANK_STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")
local FLOOR_TOP_Y=.62
local OWNER_SPOT=Vector3.new(-54.5,FLOOR_TOP_Y,-50.6)
local DONOR_SPOT=Vector3.new(54.5,FLOOR_TOP_Y,-50.6)
local OWNER_COLOR=Color3.fromRGB(247,55,158)
local DONOR_COLOR=Color3.fromRGB(239,190,92)

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
for _,n in ipairs({"CommunityPhysicalAvatarsV1","CommunityPhysicalAvatarsV2","CommunityPhysicalAvatarsV3"})do local o=root:FindFirstChild(n);if o then o:Destroy()end end
local runtime=Instance.new("Model");runtime.Name="CommunityPhysicalAvatarsV3";runtime:SetAttribute("PhysicalAuthority","147_V3_RIG_SAFE");runtime:SetAttribute("PrimaryPhysicalDisplayCount",2);runtime:SetAttribute("StageUplight",true);runtime:SetAttribute("RigPolicy","SANE_BOUNDS_THEN_NORMALIZED_NON_LAYERED_FALLBACK");runtime.Parent=root
local slots={OWNER={model=nil,uid=nil},DONOR={model=nil,uid=nil}};local refreshToken=0
local function numeric(v)return math.max(0,math.floor(tonumber(v)or 0))end
local function destroySlot(s)if s.model then s.model:Destroy();s.model=nil end;s.uid=nil end
local function sanitize(model)for _,d in ipairs(model:GetDescendants())do if d:IsA("Script")or d:IsA("LocalScript")or d:IsA("Tool")then d:Destroy()elseif d:IsA("BasePart")then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;d.Massless=true;d.CastShadow=false elseif d:IsA("Humanoid")then d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;d.AutoRotate=false;d.BreakJointsOnDeath=false end end end
local function validCore(model)
 if not model or not model:IsA("Model")then return false end;local hum=model:FindFirstChildOfClass("Humanoid");local head=model:FindFirstChild("Head",true);local hrp=model:FindFirstChild("HumanoidRootPart",true);return hum~=nil and head and head:IsA("BasePart")and hrp and hrp:IsA("BasePart")
end
local function saneBounds(model)
 if not validCore(model)then return false,"CORE"end
 local cf,size=model:GetBoundingBox();local head=model:FindFirstChild("Head",true)
 if size.Y<3.5 or size.Y>9.5 then return false,"HEIGHT"end
 if size.X<1 or size.X>7.5 then return false,"WIDTH"end
 if size.Z<.8 or size.Z>6.5 then return false,"DEPTH"end
 if head.Size.X>4 or head.Size.Y>4 or head.Size.Z>4 then return false,"HEAD_SIZE"end
 local dy=head.Position.Y-cf.Position.Y;if math.abs(dy)>size.Y*.65 then return false,"HEAD_POSITION"end
 return true,"PASS"
end
local function validateOrDestroy(model)
 local ok,reason=saneBounds(model);if ok then model:SetAttribute("BBYARigBoundsValidated",true);return model end
 if model then model:Destroy()end;return nil,reason
end
local function part(parent,name,size,cf,color,material,tr)local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Metal;p.Transparency=tr or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p end
local function buildStage(name,pos,accent)
 local stage=Instance.new("Model");stage.Name=name.."Stage";stage:SetAttribute("CornerLocked",true);stage:SetAttribute("Uplight",true);stage.Parent=runtime
 part(stage,"PlinthBase",Vector3.new(5.6,.34,5.6),CFrame.new(pos.X,.17,pos.Z),Color3.fromRGB(16,17,22),Enum.Material.Metal,0)
 part(stage,"PlinthTop",Vector3.new(5.15,.12,5.15),CFrame.new(pos.X,.40,pos.Z),Color3.fromRGB(27,28,36),Enum.Material.SmoothPlastic,0)
 local rim=part(stage,"LightRim",Vector3.new(4.75,.06,4.75),CFrame.new(pos.X,.49,pos.Z),accent,Enum.Material.Neon,0)
 local lamp=part(stage,"UplightEmitter",Vector3.new(1.2,.08,1.2),CFrame.new(pos.X,.54,pos.Z+.35),accent,Enum.Material.Neon,.15)
 local spot=Instance.new("SpotLight");spot.Face=Enum.NormalId.Top;spot.Color=accent;spot.Brightness=3.2;spot.Range=18;spot.Angle=72;spot.Shadows=false;spot.Parent=lamp
 local glow=Instance.new("PointLight");glow.Color=accent;glow.Brightness=.55;glow.Range=8;glow.Shadows=false;glow.Parent=rim
end
buildStage("Owner",OWNER_SPOT,OWNER_COLOR);buildStage("TopDonor",DONOR_SPOT,DONOR_COLOR)
local function crownPart(model,name,size,cf,color)return part(model,name,size,cf,color,Enum.Material.Metal,0)end
local function buildRankCrown(model)
 local head=model:FindFirstChild("Head",true);if not head then return end;local crown=Instance.new("Model");crown.Name="BBYATopDonorCrown";crown.Parent=model;local base=head.CFrame*CFrame.new(0,head.Size.Y*.58+.08,0)
 crownPart(crown,"BandFront",Vector3.new(1.05,.12,.10),base*CFrame.new(0,0,-.44),DONOR_COLOR);crownPart(crown,"BandBack",Vector3.new(1.05,.12,.10),base*CFrame.new(0,0,.44),DONOR_COLOR);crownPart(crown,"BandLeft",Vector3.new(.10,.12,.78),base*CFrame.new(-.48,0,0),DONOR_COLOR);crownPart(crown,"BandRight",Vector3.new(.10,.12,.78),base*CFrame.new(.48,0,0),DONOR_COLOR)
 for i,x in ipairs({-.34,0,.34})do local h=i==2 and .48 or .34;crownPart(crown,"Peak"..i,Vector3.new(.12,h,.12),base*CFrame.new(x,h*.5,-.40),DONOR_COLOR)end
end
local function labelAvatar(model,title,accent)local head=model:FindFirstChild("Head",true);if not head then return end;local gui=Instance.new("BillboardGui");gui.Adornee=head;gui.Size=UDim2.fromOffset(180,38);gui.StudsOffset=Vector3.new(0,1.45,0);gui.AlwaysOnTop=true;gui.MaxDistance=70;gui.LightInfluence=0;gui.Parent=head;local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=title;t.TextColor3=accent;t.TextStrokeTransparency=.28;t.Font=Enum.Font.GothamBlack;t.TextSize=13;t.Parent=gui end
local function placeModel(model,pos)model:PivotTo(CFrame.lookAt(Vector3.new(pos.X,4,pos.Z),Vector3.new(pos.X,4,pos.Z-10)));local cf,size=model:GetBoundingBox();local bottom=cf.Position.Y-size.Y*.5;model:PivotTo(model:GetPivot()+Vector3.new(0,pos.Y-bottom,0))end

local function normalizedDescription(uid)
 local ok,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserId(uid)end);if not ok or not desc then return nil end
 pcall(function()desc.HeightScale=1;desc.WidthScale=1;desc.DepthScale=1;desc.HeadScale=1;desc.BodyTypeScale=0;desc.ProportionScale=0 end)
 pcall(function()
  local accessories=desc:GetAccessories(true);local keep={};for _,a in ipairs(accessories)do if a.IsLayered~=true then table.insert(keep,a)end end;desc:SetAccessories(keep,true)
 end)
 return desc
end
local function makeFromDescription(desc)local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)end);if not ok then return nil end;return validateOrDestroy(m)end
local function createDisplayModel(uid)
 local online=Players:GetPlayerByUserId(uid)
 if online and online.Character then local hum=online.Character:FindFirstChildOfClass("Humanoid");if hum then local okD,d=pcall(function()return hum:GetAppliedDescription()end);if okD and d then local m=makeFromDescription(d);if m then return m,"LIVE_DESCRIPTION_SANE"end end end end
 local okUser,m=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end);if okUser and m then m=validateOrDestroy(m);if m then return m,"ROBLOX_USER_MODEL_SANE"end end
 local desc=normalizedDescription(uid);if desc then local nm=makeFromDescription(desc);if nm then return nm,"NORMALIZED_NON_LAYERED_R15"end end
 return nil,"FAILED_SANE_RIG"
end
local function buildUser(uid,name,pos,title,accent,isDonor)
 local model,source=createDisplayModel(uid);if not model then warn("[BBYA PhysicalAvatars] sane avatar build failed",uid,name);return nil end;model.Name=name;model:SetAttribute("UserId",uid);model:SetAttribute("AvatarSource",source);model:SetAttribute("RigValidated",true);model.Parent=runtime;sanitize(model);if isDonor then buildRankCrown(model)end;placeModel(model,pos);labelAvatar(model,title,accent);return model
end
local function setSlot(key,uid,pos,title,accent,isDonor,force)
 local slot=slots[key];if not uid then destroySlot(slot);return end;if not force and slot.uid==uid and slot.model and slot.model.Parent and saneBounds(slot.model)then return end;destroySlot(slot);slot.uid=uid;task.spawn(function()local m=buildUser(uid,key=="OWNER"and"OwnerPhysicalAvatar"or"TopDonorPhysicalAvatar1",pos,title,accent,isDonor);if slot.uid~=uid then if m then m:Destroy()end;return end;slot.model=m end)
end
local ownerUid=nil
local function ownerRefresh(force)task.spawn(function()if not ownerUid then local ok,uid=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end);if not ok then return end;ownerUid=uid;runtime:SetAttribute("OwnerUserId",uid)end;setSlot("OWNER",ownerUid,OWNER_SPOT,"OWNER • @"..OWNER_USERNAME,OWNER_COLOR,false,force==true)end)end
local function donorName(uid)local ok,n=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);return ok and n or tostring(uid)end
local function refreshDonor(force)
 refreshToken+=1;local token=refreshToken;task.spawn(function()local ok,pages=pcall(function()return RANK_STORE:GetSortedAsync(false,20)end);if not ok or token~=refreshToken then return end;local chosen=nil;for _,e in ipairs(pages:GetCurrentPage())do local uid=tonumber(e.key);local total=numeric(e.value);if uid and total>=QUALIFIER_MIN then chosen={uid=uid,total=total};break end end;if token~=refreshToken then return end;if chosen then setSlot("DONOR",chosen.uid,DONOR_SPOT,"TOP DONOR • @"..donorName(chosen.uid),DONOR_COLOR,true,force==true);runtime:SetAttribute("TopDonor1UserId",chosen.uid);runtime:SetAttribute("TopDonor1Total",chosen.total)else setSlot("DONOR",nil,DONOR_SPOT,"",DONOR_COLOR,true,false)end end)
end
local function refreshUid(uid)if ownerUid==uid then ownerRefresh(true)end;if slots.DONOR.uid==uid then task.delay(.4,function()refreshDonor(true)end)end end
local function wire(p)p.CharacterAdded:Connect(function()task.delay(1.3,function()if p.Parent then refreshUid(p.UserId)end end)end);p:GetAttributeChangedSignal("BBYAActiveOutfitId"):Connect(function()task.delay(.9,function()if p.Parent then refreshUid(p.UserId)end end)end)end
for _,p in ipairs(Players:GetPlayers())do wire(p)end;Players.PlayerAdded:Connect(wire)
ownerRefresh(true);task.delay(2,function()refreshDonor(true)end);task.spawn(function()while task.wait(30)do refreshDonor(false)end end);task.spawn(function()while task.wait(180)do ownerRefresh(true);refreshDonor(true)end end)
print("[BBYA] Physical Avatars v3 online: stages preserved / sane-bounds validation / normalized non-layered R15 fallback")