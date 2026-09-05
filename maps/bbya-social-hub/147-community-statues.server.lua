-- BBYA SOCIAL HUB — OWNER + TOP 3 PHYSICAL AVATARS v1.2
-- Physical 3D avatar display paired with the existing CommunityOwnerDonorHub boards.
-- Owner + Top 3 are moved to corner-safe display zones so the arrival walkway stays clear.
-- Top 3 statues wear lightweight procedural Gold / Silver / Bronze crowns.
-- Shadow/mesh artifact guard disables CastShadow on display avatars and crown parts.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Workspace=game:GetService("Workspace")

local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local RANK_STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")
local FLOOR_TOP_Y=.5
-- Front facade is toward negative Z. Keep the center arrival lane empty.
local OWNER_SPOT=Vector3.new(-52.5,FLOOR_TOP_Y,-50.6)
local DONOR_SPOTS={
 Vector3.new(38.5,FLOOR_TOP_Y,-50.6),
 Vector3.new(46.0,FLOOR_TOP_Y,-50.6),
 Vector3.new(53.5,FLOOR_TOP_Y,-50.6),
}
local RANK_COLORS={
 [1]=Color3.fromRGB(239,190,92),
 [2]=Color3.fromRGB(203,208,218),
 [3]=Color3.fromRGB(203,133,85),
}

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
local old=root:FindFirstChild("CommunityPhysicalAvatarsV1");if old then old:Destroy() end
local runtime=Instance.new("Model");runtime.Name="CommunityPhysicalAvatarsV1";runtime:SetAttribute("Pass","OWNER_TOP3_PHYSICAL_V1_2");runtime:SetAttribute("FakeDonors",false);runtime:SetAttribute("DonorEligibility",">1000");runtime:SetAttribute("CrownMode","PROCEDURAL_LIGHTWEIGHT_3D");runtime:SetAttribute("CornerSafePlacement",true);runtime:SetAttribute("ShadowArtifactGuard",true);runtime:SetAttribute("ExternalCrownMeshUsed",false);runtime.Parent=root

local slots={OWNER={model=nil,uid=nil}}
for i=1,3 do slots[i]={model=nil,uid=nil} end
local refreshToken=0

local function numeric(v)return math.max(0,math.floor(tonumber(v) or 0)) end
local function destroySlot(slot)
 if slot.model then slot.model:Destroy();slot.model=nil end;slot.uid=nil
end
local function weld(part,handle)local w=Instance.new("WeldConstraint");w.Part0=handle;w.Part1=part;w.Parent=part end
local function crownPart(acc,handle,name,size,cf,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=handle.CFrame*cf;p.Color=color;p.Material=material or Enum.Material.Metal;p.Anchored=false;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.CastShadow=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=acc;weld(p,handle);return p
end
local function buildRankCrown(rank)
 local color=RANK_COLORS[rank];if not color then return nil end
 local acc=Instance.new("Accessory");acc.Name="BBYATopDonorStatueCrown3D";acc:SetAttribute("Rank",rank);acc:SetAttribute("ExternalMeshAssetUsed",false);acc:SetAttribute("ShadowGuard",true)
 local handle=Instance.new("Part");handle.Name="Handle";handle.Size=Vector3.new(.2,.2,.2);handle.Transparency=1;handle.CanCollide=false;handle.CanTouch=false;handle.CanQuery=false;handle.Massless=true;handle.CastShadow=false;handle.Parent=acc
 local attach=Instance.new("Attachment");attach.Name="HatAttachment";attach.Position=Vector3.new(0,.55,0);attach.Parent=handle
 local radius=.68;local y=.11
 for i=1,8 do
  local a=math.rad((i-1)*45);local x,z=math.cos(a)*radius,math.sin(a)*radius
  crownPart(acc,handle,"Band"..i,Vector3.new(.46,.16,.12),CFrame.new(x,y,z)*CFrame.Angles(0,-a,0),color,Enum.Material.Metal)
 end
 -- Straight lightweight spikes avoid elongated wedge/mesh artifacts.
 for i=1,8 do
  local a=math.rad((i-1)*45);local x,z=math.cos(a)*radius,math.sin(a)*radius;local h=(i%2==1) and .56 or .42
  crownPart(acc,handle,"Spike"..i,Vector3.new(.16,h,.16),CFrame.new(x,y+.10+h*.5,z),color,Enum.Material.Metal)
 end
 local gemColor=rank==1 and Color3.fromRGB(255,70,100) or (rank==2 and Color3.fromRGB(73,207,235) or Color3.fromRGB(247,55,158))
 for i=1,4 do
  local a=math.rad((i-1)*90);local x,z=math.cos(a)*(radius+.02),math.sin(a)*(radius+.02)
  local gem=crownPart(acc,handle,"Gem"..i,Vector3.new(.12,.12,.10),CFrame.new(x,y+.02,z),gemColor,Enum.Material.Neon);gem.Shape=Enum.PartType.Ball
 end
 return acc
end
local function sanitize(model)
 for _,d in ipairs(model:GetDescendants()) do
  if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Tool") then d:Destroy()
  elseif d:IsA("BasePart") then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;d.Massless=true;d.CastShadow=false
  elseif d:IsA("Humanoid") then d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;d.AutoRotate=false;d.BreakJointsOnDeath=false end
 end
end
local function labelAvatar(model,title,accent)
 local head=model:FindFirstChild("Head",true);if not head or not head:IsA("BasePart") then return end
 local old=head:FindFirstChild("BBYAPhysicalAvatarLabel");if old then old:Destroy() end
 local gui=Instance.new("BillboardGui");gui.Name="BBYAPhysicalAvatarLabel";gui.Adornee=head;gui.Size=UDim2.fromOffset(170,38);gui.StudsOffset=Vector3.new(0,1.35,0);gui.AlwaysOnTop=true;gui.MaxDistance=70;gui.LightInfluence=0;gui.Parent=head
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=title;t.TextColor3=accent;t.TextStrokeTransparency=.35;t.Font=Enum.Font.GothamBlack;t.TextSize=13;t.Parent=gui
end
local function placeModel(model,pos)
 model:PivotTo(CFrame.lookAt(Vector3.new(pos.X,0,pos.Z),Vector3.new(pos.X,0,pos.Z-10)))
 local cf,size=model:GetBoundingBox();local bottom=cf.Position.Y-(size.Y*.5);local dy=pos.Y-bottom
 model:PivotTo(model:GetPivot()+Vector3.new(0,dy,0))
end
local function buildUserModel(uid,slotName,pos,title,accent,rank)
 local ok,model=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end)
 if not ok or not model then warn("[BBYA PhysicalAvatars] avatar build failed",uid,slotName);return nil end
 model.Name=slotName;model:SetAttribute("UserId",uid);model:SetAttribute("PhysicalDisplay",true);model:SetAttribute("ServerAuthoritative",true);model:SetAttribute("CastShadowDisabled",true);model.Parent=runtime
 if rank then
  local hum=model:FindFirstChildOfClass("Humanoid");local crown=buildRankCrown(rank)
  if hum and crown then pcall(function()hum:AddAccessory(crown)end) elseif crown then crown:Destroy() end
  model:SetAttribute("TopDonorRank",rank)
 end
 sanitize(model);placeModel(model,pos);labelAvatar(model,title,accent)
 return model
end
local function setSlot(slotKey,uid,pos,title,accent,rank)
 local slot=slots[slotKey];if not slot then return end
 if not uid then destroySlot(slot);return end
 if slot.uid==uid and slot.model and slot.model.Parent and tonumber(slot.model:GetAttribute("TopDonorRank"))==tonumber(rank) then return end
 destroySlot(slot);slot.uid=uid
 task.spawn(function()
  local m=buildUserModel(uid,slotKey=="OWNER" and "OwnerPhysicalAvatar" or ("TopDonorPhysicalAvatar"..tostring(slotKey)),pos,title,accent,rank)
  if slot.uid~=uid then if m then m:Destroy() end;return end
  slot.model=m
 end)
end
local function ownerRefresh()
 task.spawn(function()
  local ok,uid=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end);if not ok or not uid then return end
  setSlot("OWNER",uid,OWNER_SPOT,"OWNER • @"..OWNER_USERNAME,Color3.fromRGB(247,55,158),nil);runtime:SetAttribute("OwnerUserId",uid)
 end)
end
local function donorIdentity(uid)
 local name=tostring(uid);local ok,n=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);if ok and n then name=n end;return name
end
local function refreshDonors()
 refreshToken+=1;local token=refreshToken
 task.spawn(function()
  local ok,pages=pcall(function()return RANK_STORE:GetSortedAsync(false,20)end);if not ok or not pages or token~=refreshToken then return end
  local q={}
  for _,entry in ipairs(pages:GetCurrentPage()) do
   local uid=tonumber(entry.key);local total=numeric(entry.value)
   if uid and total>=QUALIFIER_MIN then table.insert(q,{uid=uid,total=total});if #q>=3 then break end end
  end
  if token~=refreshToken then return end
  for i=1,3 do
   local item=q[i]
   if item then
    local username=donorIdentity(item.uid);if token~=refreshToken then return end
    setSlot(i,item.uid,DONOR_SPOTS[i],"#"..i.." • @"..username,RANK_COLORS[i],i)
    runtime:SetAttribute("TopDonor"..i.."UserId",item.uid);runtime:SetAttribute("TopDonor"..i.."Total",item.total)
   else
    setSlot(i,nil,DONOR_SPOTS[i],"",RANK_COLORS[i],i);runtime:SetAttribute("TopDonor"..i.."UserId",nil);runtime:SetAttribute("TopDonor"..i.."Total",nil)
   end
  end
  runtime:SetAttribute("QualifiedDonorCount",#q)
 end)
end

ownerRefresh();task.delay(2,refreshDonors)
task.spawn(function()while task.wait(30) do refreshDonors() end end)
print("[BBYA] Owner + Top3 Physical Avatars v1.2 online: corner-safe positions / no display shadows / lightweight crowns / empty stays empty")