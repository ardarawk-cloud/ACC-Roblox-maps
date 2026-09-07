-- BBYA SOCIAL HUB — TOP DONOR LIVE AVATAR RENDERER v1
-- Visual-only authority for the existing locked neon donor board.
-- Online qualified donors render from their CURRENT in-session HumanoidDescription, so Avatar Switch is reflected without changing board layout.
-- Offline/failure path keeps the server-provided Roblox thumbnail as fallback.

local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")

local renders=setmetatable({}, {__mode="k"})
local playerHooks={}

local function clearWorld(r)
 if not r then return end
 for _,c in ipairs(r.world:GetChildren())do c:Destroy()end
end

local function renderer(img)
 local r=renders[img]
 if r and r.frame.Parent==img then return r end
 local old=img:FindFirstChild("BBYALiveAvatarViewport")
 if old then old:Destroy()end
 local vp=Instance.new("ViewportFrame")
 vp.Name="BBYALiveAvatarViewport"
 vp.Size=UDim2.fromScale(1,1)
 vp.Position=UDim2.fromScale(0,0)
 vp.BackgroundTransparency=1
 vp.BorderSizePixel=0
 vp.Ambient=Color3.fromRGB(210,210,220)
 vp.LightColor=Color3.fromRGB(255,255,255)
 vp.LightDirection=Vector3.new(-1,-1,-2)
 vp.Visible=false
 vp.ZIndex=(img.ZIndex or 1)+1
 vp.Parent=img
 local cr=Instance.new("UICorner");cr.CornerRadius=UDim.new(1,0);cr.Parent=vp
 local world=Instance.new("WorldModel");world.Name="AvatarWorld";world.Parent=vp
 local cam=Instance.new("Camera");cam.Name="AvatarCamera";cam.FieldOfView=34;cam.Parent=vp;vp.CurrentCamera=cam
 r={frame=vp,world=world,camera=cam,userId=0}
 renders[img]=r
 return r
end

local function buildModel(p)
 local char=p and p.Character
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not hum then return nil end
 local okDesc,desc=pcall(function()return hum:GetAppliedDescription()end)
 if okDesc and desc then
  local okModel,m=pcall(function()return Players:CreateHumanoidModelFromDescription(desc,hum.RigType)end)
  if okModel and m then return m end
 end
 local old=char.Archivable;char.Archivable=true
 local okClone,m=pcall(function()return char:Clone()end)
 char.Archivable=old
 if okClone then return m end
end

local function prepareModel(m)
 if not m then return nil end
 for _,d in ipairs(m:GetDescendants())do
  if d:IsA("Script")or d:IsA("LocalScript")or d:IsA("Tool")then d:Destroy()
  elseif d:IsA("BasePart")then d.Anchored=true;d.CanCollide=false;d.CanTouch=false;d.CanQuery=false end
 end
 local root=m:FindFirstChild("HumanoidRootPart",true)
 if root and root:IsA("BasePart")then
  local pivot=m:GetPivot();m:PivotTo(CFrame.new(-pivot.Position)*pivot)
 end
 return m
end

local function renderSlot(img)
 if not img or not img.Parent then return end
 local r=renderer(img)
 local uid=tonumber(img:GetAttribute("BBYADonorUserId"))or 0
 r.userId=uid
 local p=uid>0 and Players:GetPlayerByUserId(uid)or nil
 if not p or not p.Character then clearWorld(r);r.frame.Visible=false;img.ImageTransparency=0;return end
 local m=prepareModel(buildModel(p))
 if not m then clearWorld(r);r.frame.Visible=false;img.ImageTransparency=0;return end
 clearWorld(r);m.Name="CurrentSessionAvatar";m.Parent=r.world
 local head=m:FindFirstChild("Head",true)
 local torso=m:FindFirstChild("UpperTorso",true)or m:FindFirstChild("Torso",true)
 local target
 if head and head:IsA("BasePart")and torso and torso:IsA("BasePart")then target=(head.Position+torso.Position)/2+Vector3.new(0,.15,0)
 elseif head and head:IsA("BasePart")then target=head.Position+Vector3.new(0,-.55,0)
 else local cf,size=m:GetBoundingBox();target=cf.Position+Vector3.new(0,size.Y*.14,0)end
 local _,size=m:GetBoundingBox();local dist=math.clamp(size.Y*.62,3.7,5.4)
 r.camera.CFrame=CFrame.new(target+Vector3.new(0,0,-dist),target)
 r.frame.Visible=true;img.ImageTransparency=1
end

local function refreshUser(uid)
 uid=tonumber(uid)or 0
 for img,r in pairs(renders)do if img.Parent and(tonumber(img:GetAttribute("BBYADonorUserId"))or 0)==uid then task.defer(renderSlot,img)end end
end

local function hookPlayer(p)
 if playerHooks[p]then return end;playerHooks[p]=true
 p.CharacterAdded:Connect(function()task.delay(.75,function()if p.Parent then refreshUser(p.UserId)end end)end)
 p:GetAttributeChangedSignal("BBYAActiveOutfitId"):Connect(function()task.delay(.35,function()if p.Parent then refreshUser(p.UserId)end end)end)
end
for _,p in ipairs(Players:GetPlayers())do hookPlayer(p)end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(p)playerHooks[p]=nil;task.defer(refreshUser,p.UserId)end)

local bound=setmetatable({}, {__mode="k"})
local function bindSlot(img)
 if bound[img]then return end;bound[img]=true
 renderer(img)
 img:GetAttributeChangedSignal("BBYADonorUserId"):Connect(function()task.defer(renderSlot,img)end)
 task.defer(renderSlot,img)
end
local function scan()
 local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
 local board=root and root:FindFirstChild("CommunityOwnerDonorHub")
 if not board then return end
 for _,d in ipairs(board:GetDescendants())do if d:IsA("ImageLabel")and d:GetAttribute("BBYADonorRank")~=nil then bindSlot(d)end end
end
Workspace.DescendantAdded:Connect(function(d)if d:IsA("ImageLabel")and d:GetAttribute("BBYADonorRank")~=nil then task.defer(bindSlot,d)end end)
task.spawn(function()while task.wait(1)do scan()end end)
task.defer(scan)
print("[BBYA] Donor live-avatar renderer v1 online: current session character / thumbnail fallback / board layout untouched")
