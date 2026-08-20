-- BBYA SOCIAL HUB — MAIN CLUB REALISM PASS v1.0
-- Scope: realistic lounge furniture, DJ/audio reinforcement, and living R15 avatar crowd.
-- This intentionally avoids block-built NPCs. Every crowd character is a real R15 Humanoid model.

local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")
local InsertService=game:GetService("InsertService")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD")
local floor1=root:WaitForChild("Floor1Core",20)
if not floor1 then
 warn("[BBYA MainClub Realism] Floor1Core unavailable; pass skipped")
 return
end

local old=root:FindFirstChild("MainClubRealism")
if old then old:Destroy() end
local out=Instance.new("Folder")
out.Name="MainClubRealism"
out.Parent=root

local furniture=Instance.new("Folder")
furniture.Name="Furniture"
furniture.Parent=out
local audioVisual=Instance.new("Folder")
audioVisual.Name="AudioVisual"
audioVisual.Parent=out
local crowd=Instance.new("Folder")
crowd.Name="LivingR15Crowd"
crowd.Parent=out

local ASSET={
 DJ=10823585593,
 SPEAKER=9380977481,
 SOFA=17149922176,
 LOUNGE_CHAIR=15058709461,
 BAR_STOOL=5580435847,
}

local function sanitize(container)
 for _,d in ipairs(container:GetDescendants()) do
  if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") or d:IsA("Tool") then
   d:Destroy()
  elseif d:IsA("BasePart") then
   d.Anchored=true
   d.CanCollide=false
   d.CanTouch=false
   d.CanQuery=true
   d.CastShadow=true
   if d:IsA("MeshPart") then
    d.RenderFidelity=Enum.RenderFidelity.Automatic
    d.CollisionFidelity=Enum.CollisionFidelity.Box
   end
  end
 end
end

local function loadAsset(assetId,name,parent,cf,targetMax)
 local ok,pack=pcall(function() return InsertService:LoadAsset(assetId) end)
 if not ok or not pack then
  warn("[BBYA MainClub Realism] Creator Store asset failed",assetId,name)
  return nil
 end
 sanitize(pack)
 local model=Instance.new("Model")
 model.Name=name
 for _,child in ipairs(pack:GetChildren()) do child.Parent=model end
 pack:Destroy()
 model.Parent=parent
 local sizeOk,size=pcall(function() return model:GetExtentsSize() end)
 if sizeOk and targetMax then
  local largest=math.max(size.X,size.Y,size.Z)
  if largest>0 then
   local scale=math.clamp(targetMax/largest,0.05,12)
   pcall(function() model:ScaleTo(scale) end)
  end
 end
 pcall(function() model:PivotTo(cf) end)
 return model
end

local METAL=Color3.fromRGB(40,38,44)
local GLASS=Color3.fromRGB(90,78,96)
local PINK=Color3.fromRGB(255,42,157)
local BLUE=Color3.fromRGB(0,174,255)

local function part(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or METAL
 p.Material=material or Enum.Material.Metal
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=false
 p.CanTouch=false
 p.CanQuery=true
 p.CastShadow=true
 p.Parent=parent
 return p
end

local function loungeTable(name,pos)
 local model=Instance.new("Model")
 model.Name=name
 model.Parent=furniture
 local stem=part("Pedestal",Vector3.new(1.7,.34,.34),CFrame.new(pos+Vector3.new(0,1.05,0))*CFrame.Angles(0,0,math.rad(90)),METAL,Enum.Material.Metal,0,model)
 local base=part("Base",Vector3.new(.18,2.6,2.6),CFrame.new(pos+Vector3.new(0,.18,0))*CFrame.Angles(0,0,math.rad(90)),METAL,Enum.Material.Metal,0,model)
 base.Shape=Enum.PartType.Cylinder
 local top=part("GlassTop",Vector3.new(.18,3.8,3.8),CFrame.new(pos+Vector3.new(0,1.95,0))*CFrame.Angles(0,0,math.rad(90)),GLASS,Enum.Material.Glass,.22,model)
 top.Shape=Enum.PartType.Cylinder
 return model
end

-- LEFT LOUNGE: all seating faces the dance floor and stays outside the clear dance rectangle.
for i,z in ipairs({-3,11,25}) do
 loadAsset(ASSET.SOFA,"MainClub_Sofa_L_"..i,furniture,CFrame.new(-36,1.25,z)*CFrame.Angles(0,math.rad(-90),0),9.2)
 loungeTable("MainClub_Table_L_"..i,Vector3.new(-30.5,.5,z))
end

-- RIGHT EDGE / BAR APPROACH: compact real stools, never crossing the dance-floor sightline.
for i,z in ipairs({-2,4.5,11,17.5,24}) do
 loadAsset(ASSET.BAR_STOOL,"MainClub_BarStool_"..i,furniture,CFrame.new(30.2,1.25,z)*CFrame.Angles(0,math.rad(-90),0),3.0)
end

-- Rear corner social pair: individual mesh chairs plus small cocktail tables.
for i,z in ipairs({30,38}) do
 loadAsset(ASSET.LOUNGE_CHAIR,"MainClub_RearChair_L_"..i,furniture,CFrame.new(-31,1.35,z)*CFrame.Angles(0,math.rad(-30),0),4.6)
 loadAsset(ASSET.LOUNGE_CHAIR,"MainClub_RearChair_R_"..i,furniture,CFrame.new(31,1.35,z)*CFrame.Angles(0,math.rad(30),0),4.6)
end
loungeTable("MainClub_RearCocktail_L",Vector3.new(-26,.5,34))
loungeTable("MainClub_RearCocktail_R",Vector3.new(26,.5,34))

-- Keep the existing authoritative DJ package / stage arrays from MeshAssetPass when available.
local meshPass=root:FindFirstChild("MeshAssetPass")
if not meshPass then
 meshPass=root:WaitForChild("MeshAssetPass",8)
end
if meshPass then
 for _=1,25 do
  if meshPass:FindFirstChild("MainClub_DJMesh") and meshPass:FindFirstChild("MainClub_Speaker_L") and meshPass:FindFirstChild("MainClub_Speaker_R") then break end
  task.wait(.2)
 end
end

-- Fallback DJ package only if the authoritative asset pass failed to provide it.
if not (meshPass and meshPass:FindFirstChild("MainClub_DJMesh")) then
 loadAsset(ASSET.DJ,"MainClub_DJMesh_Fallback",audioVisual,CFrame.new(0,3.7,32)*CFrame.Angles(0,math.rad(180),0),16)
end
if not (meshPass and meshPass:FindFirstChild("MainClub_Speaker_L")) then
 loadAsset(ASSET.SPEAKER,"MainClub_Speaker_L_Fallback",audioVisual,CFrame.new(-27,5.2,42)*CFrame.Angles(0,math.rad(180),0),14)
end
if not (meshPass and meshPass:FindFirstChild("MainClub_Speaker_R")) then
 loadAsset(ASSET.SPEAKER,"MainClub_Speaker_R_Fallback",audioVisual,CFrame.new(27,5.2,42)*CFrame.Angles(0,math.rad(180),0),14)
end

-- Mid-room fills + scaled DJ booth monitors create believable club sound coverage.
loadAsset(ASSET.SPEAKER,"MainClub_MidFill_L",audioVisual,CFrame.new(-43,6,12)*CFrame.Angles(0,math.rad(-90),0),6.5)
loadAsset(ASSET.SPEAKER,"MainClub_MidFill_R",audioVisual,CFrame.new(43,6,12)*CFrame.Angles(0,math.rad(90),0),6.5)
loadAsset(ASSET.SPEAKER,"MainClub_DJMonitor_L",audioVisual,CFrame.new(-6.5,4.9,35)*CFrame.Angles(0,math.rad(180),0),4.2)
loadAsset(ASSET.SPEAKER,"MainClub_DJMonitor_R",audioVisual,CFrame.new(6.5,4.9,35)*CFrame.Angles(0,math.rad(180),0),4.2)

-- A slim illuminated booth rail makes the real DJ equipment read as one professional station.
local rail=part("DJBoothRail",Vector3.new(17,.24,.26),CFrame.new(0,4.9,29),PINK,Enum.Material.Neon,0,audioVisual)
local railLight=Instance.new("PointLight")
railLight.Color=PINK
railLight.Brightness=.8
railLight.Range=9
railLight.Shadows=false
railLight.Parent=rail

-- Living crowd ---------------------------------------------------------------
local DANCE_IDS={507771019,507776043,507777268,507771955,507776720,507777451}
local IDLE_IDS={507766388,507766666}
local EMOTE_IDS={507770677,507770239,507770818,507770453}
local HAIR={"63690008","16630147"}

local SKINS={
 Color3.fromRGB(255,219,172),
 Color3.fromRGB(224,172,105),
 Color3.fromRGB(198,134,66),
 Color3.fromRGB(141,85,48),
 Color3.fromRGB(244,194,151),
}
local TOPS={
 Color3.fromRGB(20,20,24),Color3.fromRGB(70,24,70),Color3.fromRGB(19,53,81),
 Color3.fromRGB(95,30,48),Color3.fromRGB(35,69,58),Color3.fromRGB(116,79,33),
}
local BOTTOMS={Color3.fromRGB(18,18,22),Color3.fromRGB(35,38,48),Color3.fromRGB(45,31,38)}

local function loadTrack(humanoid,id,priority)
 local animator=humanoid:FindFirstChildOfClass("Animator")
 if not animator then animator=Instance.new("Animator");animator.Parent=humanoid end
 local anim=Instance.new("Animation")
 anim.AnimationId="rbxassetid://"..tostring(id)
 local ok,track=pcall(function() return animator:LoadAnimation(anim) end)
 anim:Destroy()
 if not ok or not track then return nil end
 track.Looped=true
 track.Priority=priority or Enum.AnimationPriority.Action
 return track
end

local function makeAvatar(spec,index)
 local desc=Instance.new("HumanoidDescription")
 local skin=SKINS[((index-1)%#SKINS)+1]
 local top=TOPS[((index-1)%#TOPS)+1]
 local bottoms=BOTTOMS[((index-1)%#BOTTOMS)+1]
 desc.HeadColor=skin
 desc.LeftArmColor=skin
 desc.RightArmColor=skin
 desc.TorsoColor=top
 desc.LeftLegColor=bottoms
 desc.RightLegColor=bottoms
 desc.HeightScale=spec.height or (0.95+((index%4)*.025))
 desc.WidthScale=spec.width or (0.92+((index%3)*.035))
 desc.DepthScale=1
 desc.HeadScale=1
 desc.BodyTypeScale=.35+((index%4)*.12)
 desc.ProportionScale=.25+((index%3)*.18)
 desc.HairAccessory=HAIR[((index-1)%#HAIR)+1]

 local ok,rig=pcall(function()
  return Players:CreateHumanoidModelFromDescription(desc,Enum.HumanoidRigType.R15)
 end)
 desc:Destroy()
 if not ok or not rig then
  warn("[BBYA MainClub Realism] R15 avatar creation failed",spec.name)
  return nil
 end
 rig.Name="ClubGuest_"..spec.name
 rig.Parent=crowd
 local humanoid=rig:FindFirstChildOfClass("Humanoid")
 local hrp=rig:FindFirstChild("HumanoidRootPart")
 if not humanoid or not hrp then rig:Destroy();return nil end
 humanoid.DisplayName=spec.name
 humanoid.NameDisplayDistance=18
 humanoid.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff
 humanoid.BreakJointsOnDeath=false
 humanoid.AutoRotate=false
 humanoid.WalkSpeed=0
 for _,d in ipairs(rig:GetDescendants()) do
  if d:IsA("BasePart") then
   d.CanCollide=false
   d.CanTouch=false
   d.CanQuery=false
   d.Massless=true
  end
 end
 hrp.Anchored=true
 rig:PivotTo(CFrame.new(spec.pos)*CFrame.Angles(0,math.rad(spec.yaw or 0),0))
 return rig,humanoid
end

local guests={
 {name="Mira",role="dance",pos=Vector3.new(-15,3.8,2),yaw=12},
 {name="Nara",role="dance",pos=Vector3.new(-6,3.8,12),yaw=-18},
 {name="Kei",role="dance",pos=Vector3.new(5,3.8,5),yaw=20},
 {name="Raka",role="dance",pos=Vector3.new(15,3.8,15),yaw=-12},
 {name="Ari",role="dance",pos=Vector3.new(-12,3.8,23),yaw=25},
 {name="Luna",role="dance",pos=Vector3.new(10,3.8,25),yaw=-24},
 {name="Dimas",role="social",pos=Vector3.new(-31,3.8,-3),yaw=90},
 {name="Sera",role="social",pos=Vector3.new(-31,3.8,11),yaw=85},
 {name="Nova",role="social",pos=Vector3.new(-31,3.8,25),yaw=100},
 {name="DJ KAI",role="dj",pos=Vector3.new(0,5.55,35.3),yaw=180,height=1.02,width=.98},
}

for index,spec in ipairs(guests) do
 local rig,humanoid=makeAvatar(spec,index)
 if rig and humanoid then
  task.spawn(function()
   local pool=spec.role=="dance" and DANCE_IDS or (spec.role=="dj" and {507770453,507770677,507771019} or IDLE_IDS)
   while rig.Parent do
    local id=pool[math.random(1,#pool)]
    if spec.role=="social" and math.random()<.35 then id=EMOTE_IDS[math.random(1,#EMOTE_IDS)] end
    local track=loadTrack(humanoid,id,spec.role=="social" and Enum.AnimationPriority.Idle or Enum.AnimationPriority.Action)
    if track then
     track:Play(.25,1,spec.role=="dance" and (0.92+math.random()*.20) or 1)
    end
    task.wait(spec.role=="dance" and math.random(8,13) or math.random(7,12))
    if track then track:Stop(.3);track:Destroy() end
   end
  end)
 end
end

print("[BBYA] Main Club realism loaded: mesh lounge furniture, reinforced sound/DJ setup, living R15 avatar crowd")