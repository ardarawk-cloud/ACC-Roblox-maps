-- BBYA SOCIAL HUB — COMMUNITY PHYSICAL DISPLAY v2.1 TRANSACTIONAL AVATAR
-- Sole physical Owner/Top3 authority. Podium positions/heights/uplights are frozen.
-- Avatar replacement is transactional: a working avatar is never destroyed until a valid replacement exists.
-- No floating donor names, no donor list, no extra board.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Workspace=game:GetService("Workspace")
local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
for _,n in ipairs({"CommunityPhysicalAvatarsV1","CommunityPhysicalAvatarsV2","CommunityPhysicalAvatarsV3","CommunityPhysicalDisplayV1"})do local x=root:FindFirstChild(n);if x then x:Destroy()end end
local runtime=Instance.new("Model");runtime.Name="CommunityPhysicalDisplayV1";runtime:SetAttribute("PhysicalAuthority","151_V2_1_TRANSACTIONAL_AVATAR");runtime:SetAttribute("OwnerRenderPolicy","R15_BODY_FLOOR_ROOT_ANCHORED");runtime:SetAttribute("TopDonorCount",3);runtime:SetAttribute("DonorVisualPolicy","PODIUM_HEIGHT_ONLY_NO_FLOATING_TEXT");runtime:SetAttribute("AvatarReplacementPolicy","BUILD_VALIDATE_THEN_SWAP");runtime.Parent=root

local FLOOR_Y=.62
local OWNER_SPOT=Vector3.new(-54.5,FLOOR_Y,-50.6)
local OWNER_COLOR=Color3.fromRGB(247,55,158)
local DONOR_COLOR=Color3.fromRGB(239,190,92)
local DONOR_SPECS={{rank=1,pos=Vector3.new(54.5,FLOOR_Y,-50.6),height=.86},{rank=2,pos=Vector3.new(49.8,FLOOR_Y,-50.6),height=.56},{rank=3,pos=Vector3.new(59.2,FLOOR_Y,-50.6),height=.38}}
local slots={OWNER=nil,D1=nil,D2=nil,D3=nil};local slotUid={OWNER=nil,D1=nil,D2=nil,D3=nil}

local function part(parent,name,size,cf,color,material,tr)local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Metal;p.Transparency=tr or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p end
local function stage(name,pos,accent,height)
 local m=Instance.new("Model");m.Name=name.."Stage";m:SetAttribute("FrozenDisplayLocation",true);m:SetAttribute("Uplight",true);m.Parent=runtime;height=height or .34
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
local function hasRigJoints(model)
 local h=model and model:FindFirstChildOfClass("Humanoid");local rp=model and model:FindFirstChild("HumanoidRootPart",true);local head=model and model:FindFirstChild("Head",true);if not h or not rp or not rp:IsA("BasePart")or not head or not head:IsA("BasePart")then return false end
 local motors=0;for _,d in ipairs(model:GetDescendants())do if d:IsA("Motor6D")then motors+=1 end end;return motors>=5
end
local function sanitizeRig(model)
 for _,d in ipairs(model:GetDescendants())do
  if d:IsA("Script")or d:IsA("LocalScript")or d:IsA("Tool")then d:Destroy()
  elseif d:IsA("BasePart")then local acc=accessoryAncestor(d);if acc and(d.Size.X>14 or d.Size.Y>14 or d.Size.Z>14)then acc:Destroy()else d.Anchored=false;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;d.Massless=true;d.CastShadow=false;d.AssemblyLinearVelocity=Vector3.zero;d.AssemblyAngularVelocity=Vector3.zero end
  elseif d:IsA("Humanoid")then d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;d.AutoRotate=false;d.BreakJointsOnDeath=false;d.PlatformStand=false end
 end
 local rp=model:FindFirstChild("HumanoidRootPart",true);if rp and rp:IsA("BasePart")then rp.Anchored=true;rp.Massless=false;model.PrimaryPart=rp end
end
local function fromDescription(desc,rig)
 if not desc then return nil end;local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,rig)end);if ok and m then sanitizeRig(m);if hasRigJoints(m)then return m,"HUMANOID_DESCRIPTION_"..rig.Name end;m:Destroy()end
end
local function staticAvatar(uid)
 local okD,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(uid)end);if okD and d then local m,s=fromDescription(d,Enum.HumanoidRigType.R15);if m then return m,s end end
 local okM,m=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end);if okM and m then sanitizeRig(m);if hasRigJoints(m)then return m,"ROBLOX_USER_MODEL"end;m:Destroy()end
 return nil,"FAILED"
end
local function liveAvatar(uid)
 local online=Players:GetPlayerByUserId(uid);local hum=online and online.Character and online.Character:FindFirstChildOfClass("Humanoid");if not hum then return nil end
 local okD,d=pcall(function()return hum:GetAppliedDescription()end);if okD and d then local m,s=fromDescription(d,Enum.HumanoidRigType.R15);if m then return m,"LIVE_"..s end end
end
local function makeAvatar(uid,preferLive)
 if preferLive then local m,s=liveAvatar(uid);if m then return m,s end end
 local m,s=staticAvatar(uid);if m then return m,s end
 if not preferLive then local lm,ls=liveAvatar(uid);if lm then return lm,ls end end
 return nil,"FAILED"
end
local function bodyBottom(model)local minY=math.huge;for _,d in ipairs(model:GetDescendants())do if d:IsA("BasePart")and not accessoryAncestor(d)then minY=math.min(minY,d.Position.Y-d.Size.Y*.5)end end;return minY<math.huge and minY or nil end
local function place(model,pos,topY)local target=CFrame.lookAt(Vector3.new(pos.X,4,pos.Z),Vector3.new(pos.X,4,pos.Z-10));model:PivotTo(target);local bottom=bodyBottom(model);if bottom then model:PivotTo(model:GetPivot()+Vector3.new(0,topY-bottom,0))end;local rp=model:FindFirstChild("HumanoidRootPart",true);if rp and rp:IsA("BasePart")then rp.Anchored=true end end
local function clear(key)if slots[key]then slots[key]:Destroy()end;slots[key]=nil;slotUid[key]=nil end
local function build(key,uid,pos,topY,preferLive)
 uid=tonumber(uid);if not uid then return false end
 local candidate,source=makeAvatar(uid,preferLive==true)
 if not candidate then runtime:SetAttribute(key.."RenderStatus",slots[key]and"RETAINED_AFTER_REFRESH_FAIL"or"FAILED");warn("[BBYA Display] avatar candidate failed; keeping existing",key,uid);return false end
 candidate.Name=key.."PhysicalAvatar";candidate:SetAttribute("UserId",uid);candidate:SetAttribute("AvatarSource",source);candidate.Parent=runtime;place(candidate,pos,topY)
 if not hasRigJoints(candidate)then candidate:Destroy();runtime:SetAttribute(key.."RenderStatus",slots[key]and"RETAINED_INVALID_CANDIDATE"or"INVALID_RIG");return false end
 local old=slots[key];slots[key]=candidate;slotUid[key]=uid;runtime:SetAttribute(key.."RenderStatus","OK");runtime:SetAttribute(key.."RenderSource",source);if old and old~=candidate then old:Destroy()end;return true
end
local function specForKey(key)
 if key=="OWNER"then return OWNER_SPOT,ownerTop end
 local i=tonumber(string.match(key,"D(%d+)"));local s=i and DONOR_SPECS[i];if s then return s.pos,donorTop[i]end
end

local ownerUid=nil
local function refreshOwner(forceLive)
 if not ownerUid then local ok,id=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end);if not ok then runtime:SetAttribute("OWNERRenderStatus",slots.OWNER and"RETAINED_NAME_RESOLVE_FAIL"or"NAME_RESOLVE_FAILED");return end;ownerUid=id;runtime:SetAttribute("OwnerUserId",id)end
 if slots.OWNER and slotUid.OWNER==ownerUid and not forceLive then return end
 build("OWNER",ownerUid,OWNER_SPOT,ownerTop,forceLive==true)
end
local donorToken=0
local function refreshDonors()
 donorToken+=1;local token=donorToken;task.spawn(function()
  local ok,pages=pcall(function()return STORE:GetSortedAsync(false,50)end);if not ok or token~=donorToken then runtime:SetAttribute("DonorReadStatus","FAILED_RETAINING_EXISTING");return end
  local chosen={};for _,e in ipairs(pages:GetCurrentPage())do local uid=tonumber(e.key);local total=math.max(0,math.floor(tonumber(e.value)or 0));if uid and total>=QUALIFIER_MIN then table.insert(chosen,{uid=uid,total=total});if #chosen>=3 then break end end end;if token~=donorToken then return end;runtime:SetAttribute("DonorReadStatus","OK")
  for i=1,3 do local key="D"..i;local c=chosen[i];local spec=DONOR_SPECS[i];if c then if not slots[key]or slotUid[key]~=c.uid then build(key,c.uid,spec.pos,donorTop[i],false)end;runtime:SetAttribute("TopDonor"..i.."UserId",c.uid);runtime:SetAttribute("TopDonor"..i.."Total",c.total)else clear(key);runtime:SetAttribute("TopDonor"..i.."UserId",nil);runtime:SetAttribute("TopDonor"..i.."Total",nil)end end
 end)
end
local function refreshLiveUser(uid)
 for key,currentUid in pairs(slotUid)do if currentUid==uid then local pos,topY=specForKey(key);if pos and topY then build(key,uid,pos,topY,true)end end end
end
local function wire(p)
 p.CharacterAdded:Connect(function()task.delay(1.3,function()if not p.Parent then return end;if p.UserId==ownerUid then refreshOwner(true)end;refreshLiveUser(p.UserId);refreshDonors()end)end)
 p:GetAttributeChangedSignal("BBYAActiveOutfitId"):Connect(function()task.delay(.8,function()if p.Parent then refreshLiveUser(p.UserId)end end)end)
end
for _,p in ipairs(Players:GetPlayers())do wire(p)end;Players.PlayerAdded:Connect(wire)
refreshOwner(false);task.delay(1.5,refreshDonors)
task.spawn(function()while task.wait(30)do refreshDonors()end end)
task.spawn(function()while task.wait(180)do if not slots.OWNER then refreshOwner(false)end end end)
print("[BBYA] Community Display v2.1 online: transactional avatar swap / stable donor slots / no floating donor text")
