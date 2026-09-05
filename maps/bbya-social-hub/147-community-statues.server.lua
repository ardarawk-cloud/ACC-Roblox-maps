-- BBYA SOCIAL HUB — OWNER + TOP 3 PHYSICAL AVATARS v1.3
-- Single physical-avatar authority paired with CommunityOwnerDonorHub boards from 34-support-dashboard.server.lua.
-- Owner placement mirrors the proven right-side first slot; live outfit changes force a clean rebuild.
-- Display rigs are static, non-colliding, shadow-safe; donor crowns are simple model geometry, never Humanoid accessories.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Workspace=game:GetService("Workspace")

local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local RANK_STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")
local FLOOR_TOP_Y=.5
local OWNER_SPOT=Vector3.new(-38.5,FLOOR_TOP_Y,-50.6)
local DONOR_SPOTS={Vector3.new(38.5,FLOOR_TOP_Y,-50.6),Vector3.new(46.0,FLOOR_TOP_Y,-50.6),Vector3.new(53.5,FLOOR_TOP_Y,-50.6)}
local RANK_COLORS={[1]=Color3.fromRGB(239,190,92),[2]=Color3.fromRGB(203,208,218),[3]=Color3.fromRGB(203,133,85)}

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
local old=root:FindFirstChild("CommunityPhysicalAvatarsV1");if old then old:Destroy() end
local runtime=Instance.new("Model");runtime.Name="CommunityPhysicalAvatarsV1";runtime:SetAttribute("Pass","OWNER_TOP3_PHYSICAL_V1_3");runtime:SetAttribute("FakeDonors",false);runtime:SetAttribute("DonorEligibility",">1000");runtime:SetAttribute("CornerSafePlacement",true);runtime:SetAttribute("OwnerPlacement","MIRROR_OF_RIGHT_SLOT_1");runtime:SetAttribute("ShadowArtifactGuard",true);runtime:SetAttribute("PhysicalAuthority","147_ONLY");runtime:SetAttribute("CrownMode","SIMPLE_RIG_SAFE_GEOMETRY");runtime.Parent=root

local slots={OWNER={model=nil,uid=nil}}
for i=1,3 do slots[i]={model=nil,uid=nil} end
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

local function crownPart(model,name,size,cf,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Metal;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=model;return p
end
local function buildRankCrown(model,rank)
 local head=model:FindFirstChild("Head",true);local color=RANK_COLORS[rank];if not head or not head:IsA("BasePart") or not color then return end
 local crown=Instance.new("Model");crown.Name="BBYATopDonorCrown";crown:SetAttribute("Rank",rank);crown:SetAttribute("RigSafe",true);crown.Parent=model
 local y=head.Size.Y*.58+.08;local base=head.CFrame*CFrame.new(0,y,0)
 crownPart(crown,"BandFront",Vector3.new(1.05,.12,.10),base*CFrame.new(0,0,-.44),color)
 crownPart(crown,"BandBack",Vector3.new(1.05,.12,.10),base*CFrame.new(0,0,.44),color)
 crownPart(crown,"BandLeft",Vector3.new(.10,.12,.78),base*CFrame.new(-.48,0,0),color)
 crownPart(crown,"BandRight",Vector3.new(.10,.12,.78),base*CFrame.new(.48,0,0),color)
 for i,x in ipairs({-.34,0,.34}) do local h=i==2 and .48 or .34;crownPart(crown,"Peak"..i,Vector3.new(.12,h,.12),base*CFrame.new(x,h*.5,-.40),color) end
end

local function labelAvatar(model,title,accent)
 local head=model:FindFirstChild("Head",true);if not head or not head:IsA("BasePart") then return end
 local gui=Instance.new("BillboardGui");gui.Name="BBYAPhysicalAvatarLabel";gui.Adornee=head;gui.Size=UDim2.fromOffset(170,38);gui.StudsOffset=Vector3.new(0,1.35,0);gui.AlwaysOnTop=true;gui.MaxDistance=70;gui.LightInfluence=0;gui.Parent=head
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=title;t.TextColor3=accent;t.TextStrokeTransparency=.35;t.Font=Enum.Font.GothamBlack;t.TextSize=13;t.Parent=gui
end
local function placeModel(model,pos)
 model:PivotTo(CFrame.lookAt(Vector3.new(pos.X,4,pos.Z),Vector3.new(pos.X,4,pos.Z-10)))
 local cf,size=model:GetBoundingBox();local bottom=cf.Position.Y-(size.Y*.5);model:PivotTo(model:GetPivot()+Vector3.new(0,pos.Y-bottom,0))
end

local function createDisplayModel(uid)
 local online=Players:GetPlayerByUserId(uid)
 if online and online.Character then
  local hum=online.Character:FindFirstChildOfClass("Humanoid")
  if hum then
   local okDesc,desc=pcall(function()return hum:GetAppliedDescription()end)
   if okDesc and desc then
    local okModel,model=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)end)
    if okModel and model then return model,"LIVE_APPLIED_DESCRIPTION" end
   end
  end
 end
 local ok,model=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end)
 if ok and model then return model,"ROBLOX_USER_AVATAR" end
 return nil,"FAILED"
end

local function buildUserModel(uid,slotName,pos,title,accent,rank)
 local model,source=createDisplayModel(uid)
 if not model then warn("[BBYA PhysicalAvatars] avatar build failed",uid,slotName);return nil end
 model.Name=slotName;model:SetAttribute("UserId",uid);model:SetAttribute("PhysicalDisplay",true);model:SetAttribute("ServerAuthoritative",true);model:SetAttribute("AvatarSource",source);model:SetAttribute("CastShadowDisabled",true);model.Parent=runtime
 sanitize(model)
 if rank then buildRankCrown(model,rank);model:SetAttribute("TopDonorRank",rank) end
 placeModel(model,pos);labelAvatar(model,title,accent)
 return model
end
local function setSlot(slotKey,uid,pos,title,accent,rank,force)
 local slot=slots[slotKey];if not slot then return end
 if not uid then destroySlot(slot);return end
 if not force and slot.uid==uid and slot.model and slot.model.Parent and tonumber(slot.model:GetAttribute("TopDonorRank"))==tonumber(rank) then return end
 destroySlot(slot);slot.uid=uid
 task.spawn(function()
  local m=buildUserModel(uid,slotKey=="OWNER" and "OwnerPhysicalAvatar" or ("TopDonorPhysicalAvatar"..tostring(slotKey)),pos,title,accent,rank)
  if slot.uid~=uid then if m then m:Destroy() end;return end
  slot.model=m
 end)
end
local function donorIdentity(uid)local name=tostring(uid);local ok,n=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);if ok and n then name=n end;return name end

local ownerUid=nil
local function ownerRefresh(force)
 task.spawn(function()
  if not ownerUid then local ok,uid=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end);if not ok or not uid then return end;ownerUid=uid;runtime:SetAttribute("OwnerUserId",uid) end
  setSlot("OWNER",ownerUid,OWNER_SPOT,"OWNER • @"..OWNER_USERNAME,Color3.fromRGB(247,55,158),nil,force==true)
 end)
end
local function refreshDonors(force)
 refreshToken+=1;local token=refreshToken
 task.spawn(function()
  local ok,pages=pcall(function()return RANK_STORE:GetSortedAsync(false,20)end);if not ok or not pages or token~=refreshToken then return end
  local q={}
  for _,entry in ipairs(pages:GetCurrentPage()) do local uid=tonumber(entry.key);local total=numeric(entry.value);if uid and total>=QUALIFIER_MIN then table.insert(q,{uid=uid,total=total});if #q>=3 then break end end end
  if token~=refreshToken then return end
  for i=1,3 do
   local item=q[i]
   if item then local username=donorIdentity(item.uid);if token~=refreshToken then return end;setSlot(i,item.uid,DONOR_SPOTS[i],"#"..i.." • @"..username,RANK_COLORS[i],i,force==true);runtime:SetAttribute("TopDonor"..i.."UserId",item.uid);runtime:SetAttribute("TopDonor"..i.."Total",item.total)
   else setSlot(i,nil,DONOR_SPOTS[i],"",RANK_COLORS[i],i,false);runtime:SetAttribute("TopDonor"..i.."UserId",nil);runtime:SetAttribute("TopDonor"..i.."Total",nil) end
  end
  runtime:SetAttribute("QualifiedDonorCount",#q)
 end)
end
local function refreshDisplayedUid(uid)
 if ownerUid==uid then ownerRefresh(true) end
 for i=1,3 do if slots[i].uid==uid then task.delay(.35,function()if slots[i] and slots[i].uid==uid then local total=runtime:GetAttribute("TopDonor"..i.."Total");local username=donorIdentity(uid);setSlot(i,uid,DONOR_SPOTS[i],"#"..i.." • @"..username,RANK_COLORS[i],i,true);runtime:SetAttribute("TopDonor"..i.."Total",total) end end) end end
end
local function wirePlayer(p)
 p.CharacterAdded:Connect(function()task.delay(1.2,function()if p.Parent then refreshDisplayedUid(p.UserId) end end)end)
 p:GetAttributeChangedSignal("BBYAActiveOutfitId"):Connect(function()task.delay(.8,function()if p.Parent then refreshDisplayedUid(p.UserId) end end)end)
end
for _,p in ipairs(Players:GetPlayers()) do wirePlayer(p) end
Players.PlayerAdded:Connect(wirePlayer)

ownerRefresh(true);task.delay(2,function()refreshDonors(true)end)
task.spawn(function()while task.wait(30)do refreshDonors(false)end end)
task.spawn(function()while task.wait(180)do ownerRefresh(true);refreshDonors(true)end end)
print("[BBYA] Owner + Top3 Physical Avatars v1.3 online: mirrored owner position / rig-safe render / live outfit refresh")