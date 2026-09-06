-- BBYA SOCIAL HUB — COMMUNITY PHYSICAL DISPLAY v1.1 RIG-SAFE
-- Repair #1 on the clean display authority after v752 runtime QC.
-- Frozen owner/top-donor locations, stages and uplights are preserved exactly.
-- Render policy: build a clean Roblox avatar model, validate bounds/joints, anchor root only.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Workspace=game:GetService("Workspace")
local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
for _,n in ipairs({"CommunityPhysicalAvatarsV1","CommunityPhysicalAvatarsV2","CommunityPhysicalAvatarsV3","CommunityPhysicalDisplayV1"})do local x=root:FindFirstChild(n);if x then x:Destroy()end end
local runtime=Instance.new("Model");runtime.Name="CommunityPhysicalDisplayV1";runtime:SetAttribute("PhysicalAuthority","151_RIG_SAFE_V1_1");runtime:SetAttribute("OwnerRenderPolicy","ROBLOX_USER_MODEL_ROOT_ANCHORED");runtime:SetAttribute("TopDonorCount",3);runtime.Parent=root

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

local function hasRigJoints(model)
 local h=model:FindFirstChildOfClass("Humanoid");local rootPart=model:FindFirstChild("HumanoidRootPart",true)
 if not h or not rootPart or not rootPart:IsA("BasePart")then return false end
 local motors=0;for _,d in ipairs(model:GetDescendants())do if d:IsA("Motor6D")then motors+=1 end end
 return motors>=5
end
local function saneBounds(model)
 local ok,cf,size=pcall(function()local c,s=model:GetBoundingBox();return c,s end);if not ok or not cf or not size then return false end
 if size.X<1.2 or size.Y<2.4 or size.Z<.8 then return false end
 if size.X>18 or size.Y>24 or size.Z>18 then return false end
 return true
end
local function sanitizeRig(model)
 for _,d in ipairs(model:GetDescendants())do
  if d:IsA("Script")or d:IsA("LocalScript")or d:IsA("Tool")then d:Destroy()
  elseif d:IsA("BasePart")then d.Anchored=false;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;d.Massless=true;d.CastShadow=false;d.AssemblyLinearVelocity=Vector3.zero;d.AssemblyAngularVelocity=Vector3.zero
  elseif d:IsA("Humanoid")then d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;d.AutoRotate=false;d.BreakJointsOnDeath=false;d.PlatformStand=false
  end
 end
 local rp=model:FindFirstChild("HumanoidRootPart",true);if rp and rp:IsA("BasePart")then rp.Anchored=true;rp.Massless=false;model.PrimaryPart=rp end
end
local function validate(model)
 if not model or not model:IsA("Model")then return false end
 if not hasRigJoints(model)then return false end
 if not saneBounds(model)then return false end
 return true
end
local function fromUserModel(uid)
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end)
 if ok and m then sanitizeRig(m);if validate(m)then return m,"ROBLOX_USER_MODEL"end;m:Destroy()end
end
local function fromDescription(uid,rig)
 local okD,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(uid)end);if not okD or not d then return nil end
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(d,rig)end)
 if ok and m then sanitizeRig(m);if validate(m)then return m,"HUMANOID_DESCRIPTION_"..rig.Name end;m:Destroy()end
end
local function makeAvatar(uid)
 local m,source=fromUserModel(uid);if m then return m,source end
 m,source=fromDescription(uid,Enum.HumanoidRigType.R15);if m then return m,source end
 m,source=fromDescription(uid,Enum.HumanoidRigType.R6);if m then return m,source end
 return nil,"FAILED"
end
local function place(model,pos,topY)
 local target=CFrame.lookAt(Vector3.new(pos.X,4,pos.Z),Vector3.new(pos.X,4,pos.Z-10));model:PivotTo(target)
 local cf,size=model:GetBoundingBox();local bottom=cf.Position.Y-size.Y*.5;model:PivotTo(model:GetPivot()+Vector3.new(0,topY-bottom,0))
 local rp=model:FindFirstChild("HumanoidRootPart",true);if rp and rp:IsA("BasePart")then rp.Anchored=true end
end
local function labelAvatar(model,textValue,color)
 local head=model:FindFirstChild("Head",true);if not head or not head:IsA("BasePart")then return end;local g=Instance.new("BillboardGui");g.Name="DisplayLabel";g.Adornee=head;g.Size=UDim2.fromOffset(190,40);g.StudsOffset=Vector3.new(0,1.45,0);g.AlwaysOnTop=true;g.MaxDistance=75;g.LightInfluence=0;g.Parent=head;local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=textValue;t.TextColor3=color;t.TextStrokeTransparency=.28;t.Font=Enum.Font.GothamBlack;t.TextSize=12;t.Parent=g
end
local function clear(key)if slots[key]then slots[key]:Destroy();slots[key]=nil end end
local function build(key,uid,pos,topY,textValue,color)
 clear(key);local m,source=makeAvatar(uid);if not m then warn("[BBYA Display] rig-safe avatar build failed",key,uid);runtime:SetAttribute(key.."RenderStatus","FAILED");return end
 m.Name=key.."PhysicalAvatar";m:SetAttribute("UserId",uid);m:SetAttribute("AvatarSource",source);m.Parent=runtime;place(m,pos,topY)
 if not saneBounds(m)then m:Destroy();runtime:SetAttribute(key.."RenderStatus","INVALID_BOUNDS");warn("[BBYA Display] post-place bounds invalid",key,uid);return end
 labelAvatar(m,textValue,color);slots[key]=m;runtime:SetAttribute(key.."RenderStatus","OK");runtime:SetAttribute(key.."RenderSource",source)
end
local ownerUid=nil
local function refreshOwner()
 if not ownerUid then local ok,id=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end);if not ok then return end;ownerUid=id;runtime:SetAttribute("OwnerUserId",id)end;build("OWNER",ownerUid,OWNER_SPOT,ownerTop,"OWNER • @"..OWNER_USERNAME,OWNER_COLOR)
end
local function username(uid)local ok,n=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);return ok and n or tostring(uid)end
local donorToken=0
local function refreshDonors()
 donorToken+=1;local token=donorToken;task.spawn(function()
  local ok,pages=pcall(function()return STORE:GetSortedAsync(false,50)end);if not ok or token~=donorToken then return end;local chosen={};for _,e in ipairs(pages:GetCurrentPage())do local uid=tonumber(e.key);local total=math.max(0,math.floor(tonumber(e.value)or 0));if uid and total>=QUALIFIER_MIN then table.insert(chosen,{uid=uid,total=total});if #chosen>=3 then break end end end;if token~=donorToken then return end
  for i=1,3 do local key="D"..i;local c=chosen[i];local spec=DONOR_SPECS[i];if c then build(key,c.uid,spec.pos,donorTop[i],"#"..i.." TOP DONOR • @"..username(c.uid),DONOR_COLOR);runtime:SetAttribute("TopDonor"..i.."UserId",c.uid);runtime:SetAttribute("TopDonor"..i.."Total",c.total)else clear(key);runtime:SetAttribute("TopDonor"..i.."UserId",nil);runtime:SetAttribute("TopDonor"..i.."Total",nil)end end
 end)
end
local function wire(p)p.CharacterAdded:Connect(function()task.delay(1.2,function()if p.Parent then if p.UserId==ownerUid then refreshOwner()end;refreshDonors()end end)end);p:GetAttributeChangedSignal("BBYAActiveOutfitId"):Connect(function()task.delay(.5,function()if p.Parent then if p.UserId==ownerUid then refreshOwner()end;refreshDonors()end end)end)end
for _,p in ipairs(Players:GetPlayers())do wire(p)end;Players.PlayerAdded:Connect(wire)
refreshOwner();task.delay(1.5,refreshDonors);task.spawn(function()while task.wait(30)do refreshDonors()end end);task.spawn(function()while task.wait(180)do refreshOwner();refreshDonors()end end)
print("[BBYA] Community Display v1.1 online: rig-safe clean avatar models / root-only anchor / frozen stages")