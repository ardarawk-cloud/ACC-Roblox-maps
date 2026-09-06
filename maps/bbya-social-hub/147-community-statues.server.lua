-- BBYA SOCIAL HUB — OWNER + TOP DONOR PHYSICAL AVATARS v2
-- Single physical-avatar authority paired with CommunityOwnerDonorHub boards from 34-support-dashboard.server.lua.
-- Runtime QC lock: exactly two primary physical displays = OWNER + TOP DONOR #1, each locked to a corner-safe stage.
-- Display rig MUST contain Humanoid + HumanoidRootPart + Head; malformed live descriptions fall back to Roblox user avatar.
-- Each display gets a low plinth + upward spotlight. Static display parts never collide with players.

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

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
local old=root:FindFirstChild("CommunityPhysicalAvatarsV1");if old then old:Destroy() end
local old2=root:FindFirstChild("CommunityPhysicalAvatarsV2");if old2 then old2:Destroy() end
local runtime=Instance.new("Model");runtime.Name="CommunityPhysicalAvatarsV2";runtime:SetAttribute("Pass","OWNER_TOP1_PHYSICAL_V2_CORNER_STAGE");runtime:SetAttribute("FakeDonors",false);runtime:SetAttribute("DonorEligibility",">1000");runtime:SetAttribute("CornerSafePlacement",true);runtime:SetAttribute("PhysicalAuthority","147_ONLY");runtime:SetAttribute("PrimaryPhysicalDisplayCount",2);runtime:SetAttribute("RigValidation","HEAD_HRP_HUMANOID_REQUIRED");runtime:SetAttribute("StageUplight",true);runtime.Parent=root

local slots={OWNER={model=nil,uid=nil},DONOR={model=nil,uid=nil}}
local refreshToken=0
local function numeric(v)return math.max(0,math.floor(tonumber(v) or 0))end
local function destroySlot(slot)if slot.model then slot.model:Destroy();slot.model=nil end;slot.uid=nil end

local function sanitize(model)
 for _,d in ipairs(model:GetDescendants()) do
  if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Tool") then d:Destroy()
  elseif d:IsA("BasePart") then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;d.Massless=true;d.CastShadow=false
  elseif d:IsA("Humanoid") then d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;d.AutoRotate=false;d.BreakJointsOnDeath=false;d.PlatformStand=false end
 end
end
local function validRig(model)
 if not model or not model:IsA("Model") then return false end
 local hum=model:FindFirstChildOfClass("Humanoid")
 local head=model:FindFirstChild("Head",true)
 local hrp=model:FindFirstChild("HumanoidRootPart",true)
 return hum~=nil and head~=nil and head:IsA("BasePart") and hrp~=nil and hrp:IsA("BasePart")
end
local function rejectMalformed(model)
 if model and not validRig(model) then model:Destroy();return nil end
 return model
end

local function part(parent,name,size,cf,color,material,tr)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Metal;p.Transparency=tr or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p
end
local function buildStage(name,pos,accent)
 local stage=Instance.new("Model");stage.Name=name.."Stage";stage:SetAttribute("CornerLocked",true);stage:SetAttribute("Uplight",true);stage.Parent=runtime
 local base=part(stage,"PlinthBase",Vector3.new(5.6,.34,5.6),CFrame.new(pos.X,.17,pos.Z),Color3.fromRGB(16,17,22),Enum.Material.Metal,0)
 local top=part(stage,"PlinthTop",Vector3.new(5.15,.12,5.15),CFrame.new(pos.X,.40,pos.Z),Color3.fromRGB(27,28,36),Enum.Material.SmoothPlastic,0)
 local rim=part(stage,"LightRim",Vector3.new(4.75,.06,4.75),CFrame.new(pos.X,.49,pos.Z),accent,Enum.Material.Neon,0)
 local lamp=part(stage,"UplightEmitter",Vector3.new(1.2,.08,1.2),CFrame.new(pos.X,.54,pos.Z+.35),accent,Enum.Material.Neon,.15)
 local spot=Instance.new("SpotLight");spot.Name="DisplayUplight";spot.Face=Enum.NormalId.Top;spot.Color=accent;spot.Brightness=3.2;spot.Range=18;spot.Angle=72;spot.Shadows=false;spot.Parent=lamp
 local glow=Instance.new("PointLight");glow.Name="StageGlow";glow.Color=accent;glow.Brightness=.55;glow.Range=8;glow.Shadows=false;glow.Parent=rim
 return stage
end
local ownerStage=buildStage("Owner",OWNER_SPOT,OWNER_COLOR)
local donorStage=buildStage("TopDonor",DONOR_SPOT,DONOR_COLOR)

local function crownPart(model,name,size,cf,color)
 local p=part(model,name,size,cf,color,Enum.Material.Metal,0);return p
end
local function buildRankCrown(model)
 local head=model:FindFirstChild("Head",true);if not head or not head:IsA("BasePart") then return end
 local crown=Instance.new("Model");crown.Name="BBYATopDonorCrown";crown:SetAttribute("Rank",1);crown:SetAttribute("RigSafe",true);crown.Parent=model
 local y=head.Size.Y*.58+.08;local base=head.CFrame*CFrame.new(0,y,0);local color=DONOR_COLOR
 crownPart(crown,"BandFront",Vector3.new(1.05,.12,.10),base*CFrame.new(0,0,-.44),color)
 crownPart(crown,"BandBack",Vector3.new(1.05,.12,.10),base*CFrame.new(0,0,.44),color)
 crownPart(crown,"BandLeft",Vector3.new(.10,.12,.78),base*CFrame.new(-.48,0,0),color)
 crownPart(crown,"BandRight",Vector3.new(.10,.12,.78),base*CFrame.new(.48,0,0),color)
 for i,x in ipairs({-.34,0,.34}) do local h=i==2 and .48 or .34;crownPart(crown,"Peak"..i,Vector3.new(.12,h,.12),base*CFrame.new(x,h*.5,-.40),color) end
end

local function labelAvatar(model,title,accent)
 local head=model:FindFirstChild("Head",true);if not head or not head:IsA("BasePart") then return end
 local gui=Instance.new("BillboardGui");gui.Name="BBYAPhysicalAvatarLabel";gui.Adornee=head;gui.Size=UDim2.fromOffset(180,38);gui.StudsOffset=Vector3.new(0,1.45,0);gui.AlwaysOnTop=true;gui.MaxDistance=70;gui.LightInfluence=0;gui.Parent=head
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=title;t.TextColor3=accent;t.TextStrokeTransparency=.28;t.Font=Enum.Font.GothamBlack;t.TextSize=13;t.Parent=gui
end
local function placeModel(model,pos)
 model:PivotTo(CFrame.lookAt(Vector3.new(pos.X,4,pos.Z),Vector3.new(pos.X,4,pos.Z-10)))
 local cf,size=model:GetBoundingBox();local bottom=cf.Position.Y-(size.Y*.5);model:PivotTo(model:GetPivot()+Vector3.new(0,pos.Y-bottom,0))
end

local function fromDescription(desc)
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)end)
 if ok then return rejectMalformed(m) end
 return nil
end
local function createDisplayModel(uid)
 local online=Players:GetPlayerByUserId(uid)
 if online and online.Character then
  local hum=online.Character:FindFirstChildOfClass("Humanoid")
  if hum then
   local okDesc,desc=pcall(function()return hum:GetAppliedDescription()end)
   if okDesc and desc then local model=fromDescription(desc);if model then return model,"LIVE_APPLIED_DESCRIPTION_VALIDATED" end end
  end
 end
 local okUser,model=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end)
 if okUser then model=rejectMalformed(model);if model then return model,"ROBLOX_USER_AVATAR_VALIDATED" end end
 local okDesc,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserId(uid)end)
 if okDesc and desc then local fallback=fromDescription(desc);if fallback then return fallback,"ROBLOX_DESCRIPTION_FALLBACK_VALIDATED" end end
 return nil,"FAILED_RIG_VALIDATION"
end

local function buildUserModel(uid,slotName,pos,title,accent,isDonor)
 local model,source=createDisplayModel(uid)
 if not model then warn("[BBYA PhysicalAvatars] validated avatar build failed",uid,slotName);return nil end
 model.Name=slotName;model:SetAttribute("UserId",uid);model:SetAttribute("PhysicalDisplay",true);model:SetAttribute("ServerAuthoritative",true);model:SetAttribute("AvatarSource",source);model:SetAttribute("RigValidated",true);model.Parent=runtime
 sanitize(model)
 if isDonor then buildRankCrown(model);model:SetAttribute("TopDonorRank",1) end
 placeModel(model,pos);labelAvatar(model,title,accent)
 return model
end
local function setSlot(slotKey,uid,pos,title,accent,isDonor,force)
 local slot=slots[slotKey];if not slot then return end
 if not uid then destroySlot(slot);return end
 if not force and slot.uid==uid and slot.model and slot.model.Parent and validRig(slot.model) then return end
 destroySlot(slot);slot.uid=uid
 task.spawn(function()
  local m=buildUserModel(uid,slotKey=="OWNER" and "OwnerPhysicalAvatar" or "TopDonorPhysicalAvatar1",pos,title,accent,isDonor)
  if slot.uid~=uid then if m then m:Destroy() end;return end
  slot.model=m
 end)
end
local function donorIdentity(uid)local name=tostring(uid);local ok,n=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);if ok and n then name=n end;return name end

local ownerUid=nil
local function ownerRefresh(force)
 task.spawn(function()
  if not ownerUid then local ok,uid=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end);if not ok or not uid then return end;ownerUid=uid;runtime:SetAttribute("OwnerUserId",uid) end
  setSlot("OWNER",ownerUid,OWNER_SPOT,"OWNER • @"..OWNER_USERNAME,OWNER_COLOR,false,force==true)
 end)
end
local function refreshDonor(force)
 refreshToken+=1;local token=refreshToken
 task.spawn(function()
  local ok,pages=pcall(function()return RANK_STORE:GetSortedAsync(false,20)end);if not ok or not pages or token~=refreshToken then return end
  local chosen=nil
  for _,entry in ipairs(pages:GetCurrentPage()) do local uid=tonumber(entry.key);local total=numeric(entry.value);if uid and total>=QUALIFIER_MIN then chosen={uid=uid,total=total};break end end
  if token~=refreshToken then return end
  if chosen then local username=donorIdentity(chosen.uid);if token~=refreshToken then return end;setSlot("DONOR",chosen.uid,DONOR_SPOT,"TOP DONOR • @"..username,DONOR_COLOR,true,force==true);runtime:SetAttribute("TopDonor1UserId",chosen.uid);runtime:SetAttribute("TopDonor1Total",chosen.total)
  else setSlot("DONOR",nil,DONOR_SPOT,"",DONOR_COLOR,true,false);runtime:SetAttribute("TopDonor1UserId",nil);runtime:SetAttribute("TopDonor1Total",nil) end
 end)
end
local function refreshDisplayedUid(uid)
 if ownerUid==uid then ownerRefresh(true) end
 if slots.DONOR.uid==uid then task.delay(.35,function()if slots.DONOR.uid==uid then refreshDonor(true) end end) end
end
local function wirePlayer(p)
 p.CharacterAdded:Connect(function()task.delay(1.25,function()if p.Parent then refreshDisplayedUid(p.UserId) end end)end)
 p:GetAttributeChangedSignal("BBYAActiveOutfitId"):Connect(function()task.delay(.85,function()if p.Parent then refreshDisplayedUid(p.UserId) end end)end)
end
for _,p in ipairs(Players:GetPlayers()) do wirePlayer(p) end
Players.PlayerAdded:Connect(wirePlayer)

ownerRefresh(true);task.delay(2,function()refreshDonor(true)end)
task.spawn(function()while task.wait(30)do refreshDonor(false)end end)
task.spawn(function()while task.wait(180)do ownerRefresh(true);refreshDonor(true)end end)
print("[BBYA] Physical Avatars v2 online: OWNER + TOP DONOR / corner stages / uplight / validated full-head rigs")