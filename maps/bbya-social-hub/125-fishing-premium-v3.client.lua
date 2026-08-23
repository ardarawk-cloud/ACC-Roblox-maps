-- BBYA SOCIAL HUB — FISHING PREMIUM CLIENT v3
-- Local motion/VFX only. No extra permanent HUD and no global Lighting changes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local district = root:WaitForChild("PremiumFishingDistrictV2", 35)
if not district then return end
local upgrade = district:WaitForChild("PremiumFishingUpgradeV3", 35)
if not upgrade then return end

local remotes = ReplicatedStorage:WaitForChild("BBYAFishingRemotes", 30)
local stateRemote = remotes and remotes:WaitForChild("State", 10)

local rarityColors = {
 COMMON = Color3.fromRGB(196,202,207),
 UNCOMMON = Color3.fromRGB(96,213,131),
 RARE = Color3.fromRGB(74,161,242),
 EPIC = Color3.fromRGB(177,102,236),
 LEGENDARY = Color3.fromRGB(246,188,72),
 MYTHIC = Color3.fromRGB(244,99,173),
}

local schools = {}
local floaters = {}
local lilies = {}
local shimmerParts = {}
local covePulseParts = {}

local function refreshTargets()
 table.clear(schools)
 table.clear(floaters)
 table.clear(lilies)
 table.clear(shimmerParts)
 table.clear(covePulseParts)
 for _, obj in ipairs(upgrade:GetDescendants()) do
  if obj:IsA("Model") and obj:GetAttribute("BBYAFishSchool") == true and obj.PrimaryPart then
   table.insert(schools, {
    model = obj,
    cx = obj:GetAttribute("CenterX") or obj.PrimaryPart.Position.X,
    cy = obj:GetAttribute("CenterY") or obj.PrimaryPart.Position.Y,
    cz = obj:GetAttribute("CenterZ") or obj.PrimaryPart.Position.Z,
    rx = obj:GetAttribute("RadiusX") or 18,
    rz = obj:GetAttribute("RadiusZ") or 10,
    speed = obj:GetAttribute("Speed") or .25,
    phase = obj:GetAttribute("Phase") or 0,
   })
  elseif obj:IsA("Model") and obj:GetAttribute("BBYAFloatingLantern") == true and obj.PrimaryPart then
   table.insert(floaters, {model=obj, base=obj:GetPivot(), phase=obj:GetAttribute("Phase") or 0})
  elseif obj:IsA("Model") and obj:GetAttribute("BBYALily") == true and obj.PrimaryPart then
   table.insert(lilies, {model=obj, base=obj:GetPivot(), phase=obj:GetAttribute("Phase") or 0})
  elseif obj:IsA("BasePart") and obj:GetAttribute("BBYAWaterfallShimmer") == true then
   table.insert(shimmerParts, obj)
  elseif obj:IsA("BasePart") and obj:GetAttribute("BBYACovePulse") == true then
   table.insert(covePulseParts, obj)
  end
 end
end
refreshTargets()

local fxFolder = Workspace:FindFirstChild("BBYAFishingLocalFX")
if fxFolder then fxFolder:Destroy() end
fxFolder = Instance.new("Folder")
fxFolder.Name = "BBYAFishingLocalFX"
fxFolder.Parent = Workspace

local function fxPart(name, size, cf, color, material, transparency)
 local p = Instance.new("Part")
 p.Name = name
 p.Size = size
 p.CFrame = cf
 p.Color = color
 p.Material = material or Enum.Material.Neon
 p.Transparency = transparency or 0
 p.Anchored = true
 p.CanCollide = false
 p.CanTouch = false
 p.CanQuery = false
 p.CastShadow = false
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p.Parent = fxFolder
 return p
end

local function nearestBobberPosition()
 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not hrp then return nil end
 local best, bestDist
 for _, obj in ipairs(district:GetDescendants()) do
  if obj:IsA("Model") and obj.Name == "ActiveBobber" then
   local float = obj:FindFirstChild("Float")
   if float and float:IsA("BasePart") then
    local d = (float.Position - hrp.Position).Magnitude
    if not bestDist or d < bestDist then bestDist = d; best = float.Position end
   end
  end
 end
 return best
end

local function ripple(pos, color, strength)
 if not pos then return end
 strength = strength or 1
 for i=1,3 do
  local startSize = 1.2 + i*.6
  local disc = fxPart("WaterRipple", Vector3.new(.06, startSize, startSize), CFrame.new(pos.X,.66,pos.Z)*CFrame.Angles(0,0,math.rad(90)), color, Enum.Material.Neon, .45 + i*.08)
  local delayTime = (i-1)*.08
  task.delay(delayTime, function()
   if not disc.Parent then return end
   local goal = {Size=Vector3.new(.035,(9+i*2)*strength,(9+i*2)*strength),Transparency=1}
   local tween = TweenService:Create(disc,TweenInfo.new(.7+.12*i,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal)
   tween:Play();tween.Completed:Connect(function() if disc.Parent then disc:Destroy() end end)
  end)
 end
end

local function catchBurst(rarity)
 local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not hrp then return end
 local color = rarityColors[rarity] or Color3.fromRGB(235,184,80)
 local count = rarity == "MYTHIC" and 16 or (rarity == "LEGENDARY" and 13 or 9)
 for i=1,count do
  local a = (i/count)*math.pi*2
  local y = 2.3 + (i%3)*.55
  local origin = hrp.Position + Vector3.new(math.cos(a)*1.4,y,math.sin(a)*1.4)
  local shard = fxPart("CatchShard",Vector3.new(.18,.65,.18),CFrame.new(origin)*CFrame.Angles(math.rad(i*17),a,math.rad(24)),color,Enum.Material.Neon,.05)
  local target = origin + Vector3.new(math.cos(a)*(3.2+(i%3)),1.3+(i%2)*1.1,math.sin(a)*(3.2+(i%3)))
  local tween=TweenService:Create(shard,TweenInfo.new(.72,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=CFrame.new(target)*shard.CFrame.Rotation,Transparency=1,Size=Vector3.new(.05,.18,.05)})
  tween:Play();tween.Completed:Connect(function() if shard.Parent then shard:Destroy() end end)
 end
 local glow = fxPart("CatchGlow",Vector3.new(.35,3.2,3.2),CFrame.new(hrp.Position+Vector3.new(0,3.1,0))*CFrame.Angles(0,0,math.rad(90)),color,Enum.Material.Neon,.72)
 local light=Instance.new("PointLight");light.Color=color;light.Brightness=rarity=="MYTHIC" and 1.0 or .65;light.Range=rarity=="MYTHIC" and 16 or 11;light.Shadows=false;light.Parent=glow
 local tween=TweenService:Create(glow,TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=Vector3.new(.1,8,8),Transparency=1})
 tween:Play();tween.Completed:Connect(function() if glow.Parent then glow:Destroy() end end)
end

local camera = Workspace.CurrentCamera
local function cameraPulse(rarity)
 if not camera then return end
 if rarity ~= "LEGENDARY" and rarity ~= "MYTHIC" then return end
 local base = camera.FieldOfView
 local peak = math.min(base + (rarity=="MYTHIC" and 4 or 2.5), 90)
 local outTween = TweenService:Create(camera,TweenInfo.new(.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{FieldOfView=peak})
 outTween:Play()
 outTween.Completed:Connect(function()
  if camera then TweenService:Create(camera,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{FieldOfView=base}):Play() end
 end)
end

if stateRemote then
 stateRemote.OnClientEvent:Connect(function(kind,payload)
  payload = type(payload)=="table" and payload or {}
  if kind == "Bite" then
   ripple(nearestBobberPosition(), Color3.fromRGB(74,211,220), 1.0)
  elseif kind == "Fight" then
   ripple(nearestBobberPosition(), rarityColors[payload.rarity] or Color3.fromRGB(74,211,220), 1.15)
  elseif kind == "Catch" then
   ripple(nearestBobberPosition(), rarityColors[payload.rarity] or Color3.fromRGB(235,184,80), 1.35)
   catchBurst(payload.rarity)
   cameraPulse(payload.rarity)
  end
 end)
end

-- 30 Hz ambient motion is enough for subtle premium life without heavy per-frame work.
local accumulator = 0
RunService.RenderStepped:Connect(function(dt)
 accumulator += dt
 if accumulator < 1/30 then return end
 local now = os.clock()
 accumulator = 0

 for _,s in ipairs(schools) do
  local m=s.model
  if m.Parent and m.PrimaryPart then
   local a=now*s.speed+s.phase
   local x=s.cx+math.cos(a)*s.rx
   local z=s.cz+math.sin(a)*s.rz
   local y=s.cy+math.sin(a*2.1)*.18
   local dx=-math.sin(a)*s.rx
   local dz=math.cos(a)*s.rz
   local yaw=math.atan2(-dz,dx)
   m:PivotTo(CFrame.new(x,y,z)*CFrame.Angles(0,yaw,0))
  end
 end

 for _,f in ipairs(floaters) do
  if f.model.Parent and f.model.PrimaryPart then
   local bob=math.sin(now*.9+f.phase)*.15
   local yaw=math.sin(now*.3+f.phase)*.025
   f.model:PivotTo(f.base*CFrame.new(0,bob,0)*CFrame.Angles(0,yaw,0))
  end
 end

 for _,l in ipairs(lilies) do
  if l.model.Parent and l.model.PrimaryPart then
   local bob=math.sin(now*.65+l.phase)*.035
   local yaw=math.sin(now*.28+l.phase)*.035
   l.model:PivotTo(l.base*CFrame.new(0,bob,0)*CFrame.Angles(0,yaw,0))
  end
 end

 for _,p in ipairs(shimmerParts) do
  if p.Parent then
   p.Transparency=.68+math.sin(now*2.4)*.08
   local light=p:FindFirstChildOfClass("PointLight")
   if light then light.Brightness=.34+math.sin(now*2.1)*.08 end
  end
 end

 for _,p in ipairs(covePulseParts) do
  if p.Parent then
   p.Transparency=.80+math.sin(now*1.45)*.07
   local light=p:FindFirstChildOfClass("PointLight")
   if light then light.Brightness=.27+math.sin(now*1.45)*.07 end
  end
 end
end)

upgrade:SetAttribute("ClientMotionV3", true)
print("[BBYA] Fishing Premium client v3 online: animated schools + lantern drift + lily motion + water/catch VFX")
