-- BBYA SOCIAL HUB — COMMUNITY PHYSICAL DISPLAY v3.1 STABLE DESCRIPTION REFRESH
-- Physical podium geometry is frozen. Only the avatar model inside each locked slot may refresh.
-- QC: rebuild display avatars from complete HumanoidDescription sources instead of cloning a live Character mid-load.
-- Replacement is transactional: a visible working avatar is never removed until a valid replacement exists.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Workspace=game:GetService("Workspace")

local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")or Instance.new("Folder")
root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
for _,n in ipairs({"CommunityPhysicalAvatarsV1","CommunityPhysicalAvatarsV2","CommunityPhysicalAvatarsV3","CommunityPhysicalDisplayV1"})do
 local x=root:FindFirstChild(n);if x then x:Destroy()end
end

local runtime=Instance.new("Model")
runtime.Name="CommunityPhysicalDisplayV1"
runtime:SetAttribute("PhysicalAuthority","151_V3_1_STABLE_DESCRIPTION_REFRESH")
runtime:SetAttribute("StageGeometryLock","OWNER_-54.5_-50.6__DONOR_49.8_54.5_59.2_-50.6")
runtime:SetAttribute("AvatarUpdatePolicy","REPLACE_MODEL_ONLY_KEEP_STAGE")
runtime:SetAttribute("AvatarReplacementPolicy","BUILD_VALIDATE_THEN_SWAP")
runtime:SetAttribute("AvatarSourcePolicy","APPLIED_DESCRIPTION_FIRST_NO_LIVE_CHARACTER_CLONE")
runtime:SetAttribute("TopDonorCount",3)
runtime.Parent=root

-- LOCKED PHYSICAL POSITIONS. DO NOT MOVE WITHOUT EXPLICIT ARDA INSTRUCTION.
local FLOOR_Y=.62
local OWNER_SPOT=Vector3.new(-54.5,FLOOR_Y,-50.6)
local OWNER_COLOR=Color3.fromRGB(247,55,158)
local DONOR_COLOR=Color3.fromRGB(239,190,92)
local DONOR_SPECS={
 {rank=1,pos=Vector3.new(54.5,FLOOR_Y,-50.6),height=.86},
 {rank=2,pos=Vector3.new(49.8,FLOOR_Y,-50.6),height=.56},
 {rank=3,pos=Vector3.new(59.2,FLOOR_Y,-50.6),height=.38},
}

local slots={OWNER=nil,D1=nil,D2=nil,D3=nil}
local slotUid={OWNER=nil,D1=nil,D2=nil,D3=nil}
local refreshSerial={OWNER=0,D1=0,D2=0,D3=0}

local function part(parent,name,size,cf,color,material,tr)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Metal;p.Transparency=tr or 0
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p
end
local function stage(name,pos,accent,height)
 local m=Instance.new("Model");m.Name=name.."Stage";m:SetAttribute("FrozenDisplayLocation",true);m:SetAttribute("Uplight",true);m.Parent=runtime
 height=height or .34
 part(m,"Base",Vector3.new(4.2,height,4.2),CFrame.new(pos.X,height*.5,pos.Z),Color3.fromRGB(16,17,22),Enum.Material.Metal,0)
 part(m,"Top",Vector3.new(3.9,.10,3.9),CFrame.new(pos.X,height+.05,pos.Z),Color3.fromRGB(27,28,36),Enum.Material.SmoothPlastic,0)
 local rim=part(m,"LightRim",Vector3.new(3.55,.06,3.55),CFrame.new(pos.X,height+.11,pos.Z),accent,Enum.Material.Neon,0)
 local lamp=part(m,"UplightEmitter",Vector3.new(1.1,.07,1.1),CFrame.new(pos.X,height+.15,pos.Z+.25),accent,Enum.Material.Neon,.15)
 local spot=Instance.new("SpotLight");spot.Face=Enum.NormalId.Top;spot.Color=accent;spot.Brightness=3;spot.Range=18;spot.Angle=70;spot.Shadows=false;spot.Parent=lamp
 local glow=Instance.new("PointLight");glow.Color=accent;glow.Brightness=.45;glow.Range=7;glow.Shadows=false;glow.Parent=rim
 return height+.18
end

local ownerTop=stage("Owner",OWNER_SPOT,OWNER_COLOR,.34)
local donorTop={};for i,s in ipairs(DONOR_SPECS)do donorTop[i]=stage("TopDonor"..i,s.pos,DONOR_COLOR,s.height)end

local function accessoryAncestor(o)return o:FindFirstAncestorOfClass("Accessory")end
local function validRig(model)
 if not model then return false end
 local hum=model:FindFirstChildOfClass("Humanoid")
 local rootPart=model:FindFirstChild("HumanoidRootPart",true)
 local head=model:FindFirstChild("Head",true)
 local torso=model:FindFirstChild("UpperTorso",true)or model:FindFirstChild("Torso",true)
 if not hum or not rootPart or not rootPart:IsA("BasePart")or not head or not head:IsA("BasePart")or not torso or not torso:IsA("BasePart")then return false end
 local bodyParts=0
 for _,d in ipairs(model:GetDescendants())do
  if d:IsA("BasePart")and not accessoryAncestor(d)then bodyParts+=1 end
 end
 return bodyParts>=6
end
local function sanitizeRig(model)
 if not model then return end
 local removeAccessories={}
 for _,d in ipairs(model:GetDescendants())do
  if d:IsA("Script")or d:IsA("LocalScript")or d:IsA("Tool")then
   d:Destroy()
  elseif d:IsA("BasePart")then
   local acc=accessoryAncestor(d)
   if acc and(d.Size.X>24 or d.Size.Y>24 or d.Size.Z>24)then removeAccessories[acc]=true else
    d.Anchored=false;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;d.Massless=true;d.CastShadow=false
    d.AssemblyLinearVelocity=Vector3.zero;d.AssemblyAngularVelocity=Vector3.zero
   end
  elseif d:IsA("Humanoid")then
   d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;d.AutoRotate=false;d.BreakJointsOnDeath=false;d.PlatformStand=false
  end
 end
 for acc in pairs(removeAccessories)do if acc.Parent then acc:Destroy()end end
 local rp=model:FindFirstChild("HumanoidRootPart",true)
 if rp and rp:IsA("BasePart")then rp.Anchored=true;rp.Massless=false;model.PrimaryPart=rp end
end
local function fromAppliedDescription(uid)
 local p=Players:GetPlayerByUserId(uid);local hum=p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
 if not hum then return nil end
 local okD,desc=pcall(function()return hum:GetAppliedDescription()end);if not okD or not desc then return nil end
 local rig=hum.RigType or Enum.HumanoidRigType.R15
 local okM,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,rig)end)
 if okM and m then sanitizeRig(m);if validRig(m)then return m,"LIVE_APPLIED_DESCRIPTION_"..rig.Name end;m:Destroy()end
end
local function fromUserModel(uid)
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end)
 if ok and m then sanitizeRig(m);if validRig(m)then return m,"ROBLOX_USER_MODEL"end;m:Destroy()end
end
local function fromUserDescription(uid,rig)
 local okD,desc=pcall(function()return Players:GetHumanoidDescriptionFromUserId(uid)end);if not okD or not desc then return nil end
 local okM,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,rig)end)
 if okM and m then sanitizeRig(m);if validRig(m)then return m,"USER_DESCRIPTION_"..rig.Name end;m:Destroy()end
end
local function makeAvatar(uid,preferLive)
 uid=tonumber(uid);if not uid then return nil,"INVALID_UID" end
 if preferLive~=false then
  local m,s=fromAppliedDescription(uid);if m then return m,s end
 end
 local m,s=fromUserModel(uid);if m then return m,s end
 m,s=fromUserDescription(uid,Enum.HumanoidRigType.R15);if m then return m,s end
 m,s=fromUserDescription(uid,Enum.HumanoidRigType.R6);if m then return m,s end
 if preferLive==false then
  m,s=fromAppliedDescription(uid);if m then return m,s end
 end
 return nil,"FAILED_ALL_SOURCES"
end
local function bodyBottom(model)
 local minY=math.huge
 for _,d in ipairs(model:GetDescendants())do
  if d:IsA("BasePart")and not accessoryAncestor(d)then minY=math.min(minY,d.Position.Y-d.Size.Y*.5)end
 end
 return minY<math.huge and minY or nil
end
local function place(model,pos,topY)
 local target=CFrame.lookAt(Vector3.new(pos.X,4,pos.Z),Vector3.new(pos.X,4,pos.Z-10))
 model:PivotTo(target)
 local bottom=bodyBottom(model);if bottom then model:PivotTo(model:GetPivot()+Vector3.new(0,topY-bottom,0))end
 local rp=model:FindFirstChild("HumanoidRootPart",true);if rp and rp:IsA("BasePart")then rp.Anchored=true end
end
local function clearAvatar(key)
 local old=slots[key];slots[key]=nil;slotUid[key]=nil
 if old and old.Parent then old:Destroy()end
end
local function specForKey(key)
 if key=="OWNER"then return OWNER_SPOT,ownerTop end
 local i=tonumber(string.match(key,"D(%d+)"));local s=i and DONOR_SPECS[i]
 if s then return s.pos,donorTop[i]end
end
local function replaceAvatar(key,uid,preferLive)
 uid=tonumber(uid);local pos,topY=specForKey(key);if not uid or not pos then return false end
 refreshSerial[key]=(refreshSerial[key]or 0)+1;local serial=refreshSerial[key]
 local candidate,source=makeAvatar(uid,preferLive)
 if serial~=refreshSerial[key]then if candidate then candidate:Destroy()end;return false end
 if not candidate or not validRig(candidate)then
  if candidate then candidate:Destroy()end
  runtime:SetAttribute(key.."RenderStatus",slots[key]and"RETAINED_AFTER_BUILD_FAIL"or"FAILED")
  runtime:SetAttribute(key.."RenderSource",source or"NONE")
  warn("[BBYA Display] avatar build failed; stage remains locked",key,uid,source)
  return false
 end
 candidate.Name=key.."PhysicalAvatar";candidate:SetAttribute("UserId",uid);candidate:SetAttribute("AvatarSource",source);candidate.Parent=runtime
 place(candidate,pos,topY)
 local old=slots[key];slots[key]=candidate;slotUid[key]=uid
 runtime:SetAttribute(key.."RenderStatus","OK");runtime:SetAttribute(key.."RenderSource",source);runtime:SetAttribute(key.."UserId",uid)
 if old and old~=candidate and old.Parent then old:Destroy()end
 return true
end

local ownerUid=nil
local function resolveOwner()
 if ownerUid then return ownerUid end
 local ok,id=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end)
 if ok and id then ownerUid=id;runtime:SetAttribute("OwnerUserId",id);return id end
 runtime:SetAttribute("OWNERRenderStatus",slots.OWNER and"RETAINED_NAME_RESOLVE_FAIL"or"NAME_RESOLVE_FAILED")
end
local function refreshOwner(preferLive)
 local uid=resolveOwner();if not uid then return false end
 return replaceAvatar("OWNER",uid,preferLive~=false)
end

local donorToken=0
local function refreshDonors(forceLiveUid)
 donorToken+=1;local token=donorToken
 task.spawn(function()
  local ok,pages=pcall(function()return STORE:GetSortedAsync(false,50)end)
  if not ok or not pages or token~=donorToken then runtime:SetAttribute("DonorReadStatus","FAILED_RETAINING_EXISTING");return end
  local chosen={}
  for _,e in ipairs(pages:GetCurrentPage())do
   local uid=tonumber(e.key);local total=math.max(0,math.floor(tonumber(e.value)or 0))
   if uid and total>=QUALIFIER_MIN then table.insert(chosen,{uid=uid,total=total});if #chosen>=3 then break end end
  end
  if token~=donorToken then return end
  runtime:SetAttribute("DonorReadStatus","OK")
  for i=1,3 do
   local key="D"..i;local c=chosen[i]
   if c then
    local needs=slotUid[key]~=c.uid or slots[key]==nil or tonumber(forceLiveUid)==c.uid
    if needs then replaceAvatar(key,c.uid,Players:GetPlayerByUserId(c.uid)~=nil)end
    runtime:SetAttribute("TopDonor"..i.."UserId",c.uid);runtime:SetAttribute("TopDonor"..i.."Total",c.total)
   else
    clearAvatar(key);runtime:SetAttribute("TopDonor"..i.."UserId",nil);runtime:SetAttribute("TopDonor"..i.."Total",nil)
   end
  end
 end)
end
local function refreshDisplayedUser(uid)
 uid=tonumber(uid);if not uid then return end
 if ownerUid==uid then refreshOwner(true)end
 for key,currentUid in pairs(slotUid)do
  if key~="OWNER"and currentUid==uid then replaceAvatar(key,uid,true)end
 end
end
local function scheduleStableRefresh(p,firstDelay,secondDelay)
 if not p or not p.Parent then return end
 local uid=p.UserId
 task.delay(firstDelay or .2,function()if p.Parent then refreshDisplayedUser(uid)end end)
 if secondDelay then task.delay(secondDelay,function()if p.Parent then refreshDisplayedUser(uid)end end)end
end
local function wire(p)
 p.CharacterAdded:Connect(function()scheduleStableRefresh(p,1.6,2.8)end)
 p.CharacterAppearanceLoaded:Connect(function()scheduleStableRefresh(p,.15,.8)end)
 p:GetAttributeChangedSignal("BBYAActiveOutfitId"):Connect(function()scheduleStableRefresh(p,.25,1.0)end)
end
for _,p in ipairs(Players:GetPlayers())do wire(p)end
Players.PlayerAdded:Connect(wire)
Players.PlayerRemoving:Connect(function(p)
 task.delay(.1,function()if p.UserId==ownerUid then refreshOwner(false)else refreshDonors()end end)
end)

resolveOwner();refreshOwner(Players:GetPlayerByUserId(ownerUid or 0)~=nil)
task.delay(1.2,function()refreshDonors()end)
task.spawn(function()while task.wait(30)do refreshDonors()end end)
task.spawn(function()while task.wait(90)do if not slots.OWNER then refreshOwner(false)end end end)

print("[BBYA] Community Display v3.1 online: locked podium / stable HumanoidDescription refresh / no partial live clone")
