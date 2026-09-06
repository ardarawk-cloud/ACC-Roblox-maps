-- BBYA SOCIAL HUB — COMMUNITY PHYSICAL DISPLAY v1 CLEAN REBUILD
-- New authority after OWNER render QC fail #3. Frozen owner corner/stage/uplight preserved.
-- Owner uses exact live Character clone when online; offline fallback uses Roblox user avatar model.
-- Top donors render as 3 physical avatars on ranked podiums (#1 highest center, #2/#3 lower).

local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local Workspace=game:GetService("Workspace")
local OWNER_USERNAME="nadmo97"
local QUALIFIER_MIN=1001
local STORE=DataStoreService:GetOrderedDataStore("BBYA_TOP_DONATOR_V1")
local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")or Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=Workspace
for _,n in ipairs({"CommunityPhysicalAvatarsV1","CommunityPhysicalAvatarsV2","CommunityPhysicalAvatarsV3","CommunityPhysicalDisplayV1"})do local x=root:FindFirstChild(n);if x then x:Destroy()end end
local runtime=Instance.new("Model");runtime.Name="CommunityPhysicalDisplayV1";runtime:SetAttribute("PhysicalAuthority","151_CLEAN_REBUILD_V1");runtime:SetAttribute("OwnerRenderPolicy","LIVE_CHARACTER_CLONE_THEN_ROBLOX_USER_MODEL");runtime:SetAttribute("TopDonorCount",3);runtime.Parent=root

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

local function sanitize(model)
 for _,d in ipairs(model:GetDescendants())do if d:IsA("Script")or d:IsA("LocalScript")or d:IsA("Tool")then d:Destroy()elseif d:IsA("BasePart")then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false;d.Massless=true;d.CastShadow=false elseif d:IsA("Humanoid")then d.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;d.AutoRotate=false;d.BreakJointsOnDeath=false end end
end
local function exactLiveClone(uid)
 local p=Players:GetPlayerByUserId(uid);local c=p and p.Character;if not c then return nil end
 local old=c.Archivable;c.Archivable=true;local ok,m=pcall(function()return c:Clone()end);c.Archivable=old;if ok and m then return m,"LIVE_CHARACTER_CLONE"end
end
local function userModel(uid)
 local ok,m=pcall(function()return Players:CreateHumanoidModelFromUserIdAsync(uid)end);if ok and m then return m,"ROBLOX_USER_MODEL"end
 local okD,d=pcall(function()return Players:GetHumanoidDescriptionFromUserId(uid)end);if not okD or not d then return nil end
 local rig=Enum.HumanoidRigType.R15;local p=Players:GetPlayerByUserId(uid);local h=p and p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then rig=h.RigType end
 local okM,x=pcall(function()return Players:CreateHumanoidModelFromDescription(d,rig)end);if okM then return x,"HUMANOID_DESCRIPTION_EXACT"end
end
local function makeAvatar(uid)local m,source=exactLiveClone(uid);if not m then m,source=userModel(uid)end;if not m then return nil,"FAILED"end;sanitize(m);return m,source end
local function place(model,pos,topY)
 model:PivotTo(CFrame.lookAt(Vector3.new(pos.X,4,pos.Z),Vector3.new(pos.X,4,pos.Z-10)));local cf,size=model:GetBoundingBox();local bottom=cf.Position.Y-size.Y*.5;model:PivotTo(model:GetPivot()+Vector3.new(0,topY-bottom,0))
end
local function labelAvatar(model,textValue,color)
 local head=model:FindFirstChild("Head",true);if not head or not head:IsA("BasePart")then return end;local g=Instance.new("BillboardGui");g.Name="DisplayLabel";g.Adornee=head;g.Size=UDim2.fromOffset(190,40);g.StudsOffset=Vector3.new(0,1.45,0);g.AlwaysOnTop=true;g.MaxDistance=75;g.LightInfluence=0;g.Parent=head;local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=textValue;t.TextColor3=color;t.TextStrokeTransparency=.28;t.Font=Enum.Font.GothamBlack;t.TextSize=12;t.Parent=g
end
local function clear(key)if slots[key]then slots[key]:Destroy();slots[key]=nil end end
local function build(key,uid,pos,topY,textValue,color)
 clear(key);local m,source=makeAvatar(uid);if not m then warn("[BBYA Display] avatar build failed",key,uid);return end;m.Name=key.."PhysicalAvatar";m:SetAttribute("UserId",uid);m:SetAttribute("AvatarSource",source);m.Parent=runtime;place(m,pos,topY);labelAvatar(m,textValue,color);slots[key]=m
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
print("[BBYA] Community Display v1 online: owner exact avatar + ranked Top3 physical podiums")