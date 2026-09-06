-- BBYA SOCIAL HUB — COMMUNITY PHYSICAL DISPLAY v1.2 FINAL RIG REPAIR
-- Final repair after v1.1 runtime QC: preserve frozen owner/top-donor locations and podiums.
-- Avatar policy: build intact R15 user rigs, validate body joints (not accessory bounding boxes), sanitize pathological accessories, place by body floor, anchor root only.
-- Adds one readable physical TOP DONOR neon list driven by the same ordered datastore.

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Workspace=game:GetService("Workspace")
local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
for _,n in ipairs({"CommunityPhysicalAvatarsV1","CommunityPhysicalAvatarsV2","CommunityPhysicalAvatarsV3","CommunityPhysicalDisplayV1"})do local x=root:FindFirstChild(n);if x then x:Destroy()end end
local runtime=Instance.new("Model");runtime.Name="CommunityPhysicalDisplayV1";runtime:SetAttribute("PhysicalAuthority","151_RIG_SAFE_V1_2_FINAL");runtime:SetAttribute("OwnerRenderPolicy","R15_BODY_FLOOR_ROOT_ANCHORED");runtime:SetAttribute("TopDonorCount",3);runtime.Parent=root

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

-- Physical neon donor list: same frozen donor zone, same datastore, no monetization logic.
local donorBoard=part(runtime,"TopDonorNeonList",Vector3.new(16,8,.45),CFrame.new(54.5,7.0,-55.5)*CFrame.Angles(0,math.rad(180),0),Color3.fromRGB(10,10,14),Enum.Material.Metal,0)
part(runtime,"TopDonorNeonTop",Vector3.new(16.1,.10,.52),donorBoard.CFrame*CFrame.new(0,4.02,0),DONOR_COLOR,Enum.Material.Neon,0)
part(runtime,"TopDonorNeonBottom",Vector3.new(16.1,.08,.52),donorBoard.CFrame*CFrame.new(0,-4.02,0),DONOR_COLOR,Enum.Material.Neon,0)
local boardGui=Instance.new("SurfaceGui");boardGui.Name="TopDonorListUI";boardGui.Face=Enum.NormalId.Front;boardGui.PixelsPerStud=45;boardGui.Parent=donorBoard
local boardBg=Instance.new("Frame");boardBg.Size=UDim2.fromScale(1,1);boardBg.BackgroundColor3=Color3.fromRGB(9,9,13);boardBg.BorderSizePixel=0;boardBg.Parent=boardGui
local function boardLabel(text,pos,size,font,ts,color,align)local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font;l.TextSize=ts;l.TextColor3=color;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.TextTruncate=Enum.TextTruncate.AtEnd;l.Parent=boardBg;return l end
boardLabel("TOP DONOR",UDim2.fromScale(.06,.05),UDim2.fromScale(.88,.18),Enum.Font.GothamBlack,34,DONOR_COLOR,Enum.TextXAlignment.Center)
local donorRows={}
for i=1,3 do donorRows[i]=boardLabel("#"..i.." —",UDim2.fromScale(.09,.24+(i-1)*.22),UDim2.fromScale(.82,.18),Enum.Font.GothamBold,23,Color3.fromRGB(244,242,247))end

local function hasRigJoints(model)
 local h=model:FindFirstChildOfClass("Humanoid");local rootPart=model:FindFirstChild("HumanoidRootPart",true);local head=model:FindFirstChild("Head",true)
 if not h or not rootPart or not rootPart:IsA("BasePart")or not head or not head:IsA("BasePart")then return false end
 local motors=0;for _,d in ipairs(model:GetDescendants())do if d:IsA("Motor6D")then motors+=1 end end
 return motors>=5
end
local function accessoryAncestor(o)local a=o:FindFirstAncestorOfClass("Accessory");return a end
local function sanitizeRig(model)
 for _,d in ipairs(model:GetDescendants())do
  if d:IsA("Script")or d:IsA("LocalScript")or d:IsA("Tool")then d:Destroy()
  elseif d:IsA("BasePart")then
   local acc=accessoryAncestor(d)
   if acc and(d.Size.X>14 or d.Size.Y>14 or d.Size.Z>14)then acc:Destroy()
   else d.Anchored=false;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;d.Massless=true;d.CastShadow=false;d.AssemblyLinearVelocity=Vector3.zero;d.AssemblyAngularVelocity=Vector3.zero end
  elseif d:IsA("Humanoid")then d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;d.AutoRotate=false;d.BreakJointsOnDeath=false;d.PlatformStand=false
  end
 end
 local rp=model:FindFirstChild("HumanoidRootPart",true);if rp and rp:IsA("BasePart")then rp.Anchored=true;rp.Massless=false;model.PrimaryPart=rp end
end
local function validate(model)return model and model:IsA("Model")and hasRigJoints(model)end
local function fromDescription(uid,rig)
 local okD,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(uid)end);if not okD or not d then return nil end
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromDescription(d,rig)end)
 if ok and m then sanitizeRig(m);if validate(m)then return m,"HUMANOID_DESCRIPTION_"..rig.Name end;m:Destroy()end
end
local function fromUserModel(uid)
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end)
 if ok and m then sanitizeRig(m);if validate(m)then return m,"ROBLOX_USER_MODEL"end;m:Destroy()end
end
local function makeAvatar(uid)
 local m,source=fromDescription(uid,Enum.HumanoidRigType.R15);if m then return m,source end
 m,source=fromUserModel(uid);if m then return m,source end
 m,source=fromDescription(uid,Enum.HumanoidRigType.R6);if m then return m,source end
 return nil,"FAILED"
end
local function bodyBottom(model)
 local minY=math.huge
 for _,d in ipairs(model:GetDescendants())do if d:IsA("BasePart")and not accessoryAncestor(d)then minY=math.min(minY,d.Position.Y-d.Size.Y*.5)end end
 return minY<math.huge and minY or nil
end
local function place(model,pos,topY)
 local target=CFrame.lookAt(Vector3.new(pos.X,4,pos.Z),Vector3.new(pos.X,4,pos.Z-10));model:PivotTo(target)
 local bottom=bodyBottom(model);if bottom then model:PivotTo(model:GetPivot()+Vector3.new(0,topY-bottom,0))end
 local rp=model:FindFirstChild("HumanoidRootPart",true);if rp and rp:IsA("BasePart")then rp.Anchored=true end
end
local function labelAvatar(model,textValue,color)
 local head=model:FindFirstChild("Head",true);if not head or not head:IsA("BasePart")then return end;local g=Instance.new("BillboardGui");g.Name="DisplayLabel";g.Adornee=head;g.Size=UDim2.fromOffset(210,44);g.StudsOffset=Vector3.new(0,1.45,0);g.AlwaysOnTop=true;g.MaxDistance=75;g.LightInfluence=0;g.Parent=head;local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=textValue;t.TextColor3=color;t.TextStrokeTransparency=.28;t.Font=Enum.Font.GothamBlack;t.TextSize=12;t.Parent=g
end
local function clear(key)if slots[key]then slots[key]:Destroy();slots[key]=nil end end
local function build(key,uid,pos,topY,textValue,color)
 clear(key);local m,source=makeAvatar(uid);if not m then warn("[BBYA Display] avatar build failed",key,uid);runtime:SetAttribute(key.."RenderStatus","FAILED");return end
 m.Name=key.."PhysicalAvatar";m:SetAttribute("UserId",uid);m:SetAttribute("AvatarSource",source);m.Parent=runtime;place(m,pos,topY)
 if not hasRigJoints(m)then m:Destroy();runtime:SetAttribute(key.."RenderStatus","INVALID_RIG");warn("[BBYA Display] post-place rig invalid",key,uid);return end
 labelAvatar(m,textValue,color);slots[key]=m;runtime:SetAttribute(key.."RenderStatus","OK");runtime:SetAttribute(key.."RenderSource",source)
end
local ownerUid=nil
local function refreshOwner()
 if not ownerUid then local ok,id=pcall(function()return Players:GetUserIdFromNameAsync(OWNER_USERNAME)end);if not ok then runtime:SetAttribute("OWNERRenderStatus","NAME_RESOLVE_FAILED");return end;ownerUid=id;runtime:SetAttribute("OwnerUserId",id)end;build("OWNER",ownerUid,OWNER_SPOT,ownerTop,"OWNER • @"..OWNER_USERNAME,OWNER_COLOR)
end
local function username(uid)local ok,n=pcall(function()return Players:GetNameFromUserIdAsync(uid)end);return ok and n or tostring(uid)end
local donorToken=0
local function refreshDonors()
 donorToken+=1;local token=donorToken;task.spawn(function()
  local ok,pages=pcall(function()return STORE:GetSortedAsync(false,50)end);if not ok or token~=donorToken then runtime:SetAttribute("DonorReadStatus","FAILED");return end;local chosen={};for _,e in ipairs(pages:GetCurrentPage())do local uid=tonumber(e.key);local total=math.max(0,math.floor(tonumber(e.value)or 0));if uid and total>=QUALIFIER_MIN then table.insert(chosen,{uid=uid,total=total});if #chosen>=3 then break end end end;if token~=donorToken then return end
  runtime:SetAttribute("DonorReadStatus","OK")
  for i=1,3 do local key="D"..i;local c=chosen[i];local spec=DONOR_SPECS[i];if c then local name=username(c.uid);build(key,c.uid,spec.pos,donorTop[i],"#"..i.." TOP DONOR • @"..name,DONOR_COLOR);runtime:SetAttribute("TopDonor"..i.."UserId",c.uid);runtime:SetAttribute("TopDonor"..i.."Total",c.total);donorRows[i].Text="#"..i.."  @"..name.."  •  "..tostring(c.total).." R$" else clear(key);runtime:SetAttribute("TopDonor"..i.."UserId",nil);runtime:SetAttribute("TopDonor"..i.."Total",nil);donorRows[i].Text="#"..i.."  —" end end
 end)
end
local function wire(p)p.CharacterAdded:Connect(function()task.delay(1.2,function()if p.Parent then if p.UserId==ownerUid then refreshOwner()end;refreshDonors()end end)end);p:GetAttributeChangedSignal("BBYAActiveOutfitId"):Connect(function()task.delay(.5,function()if p.Parent then if p.UserId==ownerUid then refreshOwner()end;refreshDonors()end end)end)end
for _,p in ipairs(Players:GetPlayers())do wire(p)end;Players.PlayerAdded:Connect(wire)
refreshOwner();task.delay(1.5,refreshDonors);task.spawn(function()while task.wait(30)do refreshDonors()end end);task.spawn(function()while task.wait(180)do refreshOwner();refreshDonors()end end)
print("[BBYA] Community Display v1.2 final repair online: R15 body-floor placement / root-only anchor / donor neon list / frozen stages")