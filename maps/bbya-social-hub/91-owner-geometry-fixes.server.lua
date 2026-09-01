-- BBYA SOCIAL HUB — OWNER GEOMETRY + TALL-AVATAR FIXES v5
-- Targeted geometry fixes plus local daytime floor-reflection suppression.
-- Adds street entrance + Main Club headroom for tall/Zepeto-style avatars while preserving approved identity.
-- Global Lighting, audio, Underground lighting, VIP, Rooftop and Mall are untouched.
-- VIP floor-neon ownership belongs EXCLUSIVELY to 72-vip-floor-neon-fix.server.lua.
-- IMPORTANT: never delete South/West/North/East approved PreciseInnerFloorNeon segments here.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

-- 5) The old 10x44x10 LiftCore reads as a giant pillar from the VIP approach.
task.spawn(function()
 local upper=root:WaitForChild("UpperLevels",30);if not upper then return end
 local circ=upper:FindFirstChild("VerticalCirculation") or upper:WaitForChild("VerticalCirculation",10)
 if circ then
  local lift=circ:FindFirstChild("LiftCore")
  if lift then lift:Destroy() end
  if #circ:GetChildren()==0 then circ:Destroy() end
 end
end)

-- 6) Close only the lower left/right gaps between the 90-stud entrance facade and 120-stud shell.
task.spawn(function()
 local entrance=root:WaitForChild("Entrance",30);if not entrance then return end
 local old=entrance:FindFirstChild("OwnerLowerCornerFill");if old then old:Destroy() end
 local m=Instance.new("Model");m.Name="OwnerLowerCornerFill";m.Parent=entrance
 for _,x in ipairs({-52.5,52.5}) do
  local p=Instance.new("Part")
  p.Name=x<0 and "LowerFrontCornerLeft" or "LowerFrontCornerRight"
  p.Size=Vector3.new(15,8,10)
  p.CFrame=CFrame.new(x,4,-39)
  p.Color=Color3.fromRGB(9,8,12)
  p.Material=Enum.Material.Metal
  p.Anchored=true
  p.CanCollide=true
  p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth
  p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=m
 end
 m:SetAttribute("ClosedLowerFrontCornerHoles",true)
end)

-- VIP: remove only the obsolete single colored ceiling triangle if it survived a race.
-- DO NOT touch PreciseInnerFloorNeon. The v6 neon owner lock guarantees all four sides.
task.spawn(function()
 local upper=root:WaitForChild("UpperLevels",30);if not upper then return end
 local vip=upper:WaitForChild("L2_VIP_Level",30);if not vip then return end
 local active=vip:WaitForChild("VIPMinimalStanding",30);if not active then return end
 local oldColored=active:FindFirstChild("TriangleCeilingLight")
 if oldColored then oldColored:Destroy() end
 active:SetAttribute("OwnerGeometryPreservesAllVIPNeonSides",true)
end)

-- 7) UNDERGROUND INVISIBLE-COLLIDER FIX
-- RuntimeQC historically created SafetyFloor at Y=-18 while the Underground floor was near Y=-15.5.
-- The tall-avatar pass lowers the real BasementFloor to Y=-29.5. Leaving SafetyFloor at -18 turns that
-- invisible fall-protection slab into a false ceiling across the Underground. Keep the safety net, but
-- relocate it beneath the deepened structural floor so the playable air volume remains completely clear.
task.spawn(function()
 local site=root:WaitForChild("SiteBasement",30);if not site then return end
 local basementFloor=site:WaitForChild("BasementFloor",30);if not basementFloor or not basementFloor:IsA("BasePart") then return end
 local safety=root:WaitForChild("SafetyFloor",30);if not safety or not safety:IsA("BasePart") then return end

 local function relocateSafetyFloor()
  local current=root:FindFirstChild("SafetyFloor")
  if not current or not current:IsA("BasePart") then return end
  local floorBottom=basementFloor.Position.Y-(basementFloor.Size.Y/2)
  local targetY=floorBottom-1.5-(current.Size.Y/2)
  current.Anchored=true
  current.CanCollide=true
  current.Transparency=1
  current.CFrame=CFrame.new(current.Position.X,targetY,current.Position.Z)*current.CFrame.Rotation
  current:SetAttribute("BBYASafetyFloorRole","FALL_PROTECTION_BELOW_UNDERGROUND")
  current:SetAttribute("BBYASafetyFloorRelocatedV1",true)
  root:SetAttribute("BBYASafetyFloorBelowUnderground","V1_CLEAR_AIRSPACE")
  root:SetAttribute("BBYASafetyFloorY",targetY)
 end

 relocateSafetyFloor()
 -- Defensive re-asserts cover startup ordering without creating any watchdog loop.
 for _,delaySeconds in ipairs({2,8,20}) do task.delay(delaySeconds,relocateSafetyFloor) end
end)

-- 8) DAYTIME FLOOR REFLECTION GUARD
-- Roblox environment/specular response can make smooth indoor floors mirror the daytime sky/sun.
-- Keep the fix local to the three music venues; do not reduce EnvironmentSpecularScale globally.
local function matte(part,material)
 if part and part:IsA("BasePart") then
  part.Reflectance=0
  if material then part.Material=material end
 end
end

local function applyDaytimeFloorGuard()
 -- MAIN CLUB: the realism pass replaces the original Slate dance floor with SmoothPlastic
 -- and explicitly adds Reflectance=.10. Restore a dark architectural Slate finish instead.
 local realism=root:FindFirstChild("MainClubRealism")
 if realism then
  local dance=realism:FindFirstChild("DanceFloor",true)
  matte(dance,Enum.Material.Slate)
 end
 local floor1=root:FindFirstChild("Floor1Core")
 if floor1 then
  for _,name in ipairs({"FrontSpine","FrontLeftWing","FrontRightWing","ClubCore","RearStageMass","RearLeftStep","RearRightStep","PhotoFloor","SalonFloor","BarFloor","TransitionCourt"}) do
   matte(floor1:FindFirstChild(name,true),nil)
  end
 end

 -- UNDERGROUND: preserve the black/white checker identity but use regular Plastic rather than
 -- SmoothPlastic so daytime environment highlights stay subdued. The late dark-lock pass may
 -- rebuild/re-enforce the checker during startup, so this guard is repeated after it settles.
 local underground=root:FindFirstChild("Underground")
 local checker=underground and underground:FindFirstChild("CheckerFloor")
 if checker then
  for _,tile in ipairs(checker:GetChildren()) do
   if tile:IsA("BasePart") then matte(tile,Enum.Material.Plastic) end
  end
 end

 -- FUNKOT: concrete remains concrete; explicitly zero reflectance on the large exposed floor slabs.
 local funkot=root:FindFirstChild("FunkotClub")
 if funkot then
  matte(funkot:FindFirstChild("DanceFloorSlab"),Enum.Material.Concrete)
  matte(funkot:FindFirstChild("ConnectorFloor"),Enum.Material.Concrete)
 end

 root:SetAttribute("DaytimeFloorReflectionGuard","V1_LOCAL_THREE_VENUES")
 root:SetAttribute("DaytimeFloorReflectionGuardLastApplied",os.time())
end

-- Builders settle at different times; 22s intentionally lands after Underground's 20s checker lock.
for _,delaySeconds in ipairs({1,6,22,40}) do
 task.delay(delaySeconds,applyDaytimeFloorGuard)
end

-- 9) ENTRANCE + MAIN CLUB TALL-AVATAR HEADROOM V2
-- Existing SiteBasement tall-avatar stack already gives Main roughly 28 studs of structural room,
-- but the premium false ceiling still sits near Y=20.6 and the entrance portals are much lower.
-- Raise only those overhead layers by 8 studs. X/Z, floors, furniture, audio authority and venue stack stay fixed.
local HEADROOM_DELTA=8
local HEADROOM_MARK="BBYAMainEntranceHeadroomV2"

local function shiftPartY(part,delta)
 if not part or not part:IsA("BasePart") or part:GetAttribute(HEADROOM_MARK) then return end
 part.CFrame=part.CFrame+Vector3.new(0,delta,0)
 part:SetAttribute(HEADROOM_MARK,true)
end

local function extendUp(part,extra)
 if not part or not part:IsA("BasePart") or part:GetAttribute(HEADROOM_MARK) then return end
 part.Size=Vector3.new(part.Size.X,part.Size.Y+extra,part.Size.Z)
 part.CFrame=part.CFrame+Vector3.new(0,extra/2,0)
 part:SetAttribute(HEADROOM_MARK,true)
end

local function shiftModelY(model,delta)
 if not model or not model:IsA("Model") or model:GetAttribute(HEADROOM_MARK) then return end
 model:PivotTo(model:GetPivot()+Vector3.new(0,delta,0))
 model:SetAttribute(HEADROOM_MARK,true)
 for _,d in ipairs(model:GetDescendants()) do
  if d:IsA("BasePart") then d:SetAttribute(HEADROOM_MARK,true) end
 end
end

-- Street entrance: preserve the legendary approved BBYA logo/crown/signage; translate it upward as one assembly.
task.spawn(function()
 local entrance=root:WaitForChild("Entrance",30);if not entrance then return end
 local signage=entrance:WaitForChild("EntranceSignage",20)
 local portalTop=entrance:WaitForChild("PortalTop",20)
 local crown=entrance:WaitForChild("CrownBase2",20)
 if not signage or not portalTop or not crown then return end
 task.wait(.4)

 for _,name in ipairs({"FacadeLeft","FacadeRight","PortalLeft","PortalRight","GlassLeft","GlassRight"}) do
  extendUp(entrance:FindFirstChild(name),HEADROOM_DELTA)
 end
 shiftPartY(entrance:FindFirstChild("FacadeHeader"),HEADROOM_DELTA)
 shiftPartY(portalTop,HEADROOM_DELTA)
 shiftPartY(entrance:FindFirstChild("PortalPinkTop"),HEADROOM_DELTA)
 shiftModelY(signage,HEADROOM_DELTA)
 for _,d in ipairs(entrance:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^Crown") then shiftPartY(d,HEADROOM_DELTA) end
 end

 entrance:SetAttribute("BBYATallAvatarEntranceProfile","ZEPETO_CLEARANCE_V2")
 entrance:SetAttribute("BBYAEntranceVerticalDeltaY",HEADROOM_DELTA)
 entrance:SetAttribute("BBYALegendaryLogoPreserved",true)
 root:SetAttribute("BBYAEntranceTallAvatarClearance",true)
end)

-- Reception + inner club portal: remove the second low overhead pinch-point between entrance and dance floor.
task.spawn(function()
 local front=root:WaitForChild("Floor1FrontPremium",35);if not front then return end
 local reception=front:WaitForChild("Reception",20)
 local transition=front:WaitForChild("EntranceToClubTransition",20)
 if not reception or not transition then return end
 task.wait(.4)

 for _,d in ipairs(reception:GetDescendants()) do
  if d:IsA("BasePart") and (d.Name:match("^ReceptionCeilingSlat") or d.Name:match("^ReceptionDownlight")) then
   shiftPartY(d,HEADROOM_DELTA)
  end
 end
 for _,d in ipairs(transition:GetDescendants()) do
  if d:IsA("BasePart") then
   if d.Name:match("^CeilingFin") or d.Name:match("^FinLight") or d.Name=="PortalTop" then
    shiftPartY(d,HEADROOM_DELTA)
   elseif d.Name=="PortalL" or d.Name=="PortalR" or d.Name=="PortalAccentL" or d.Name=="PortalAccentR" then
    extendUp(d,HEADROOM_DELTA)
   end
  end
 end
 front:SetAttribute("BBYATallAvatarTransitionProfile","ZEPETO_CLEARANCE_V2")
end)

-- Main Club: lift the complete premium false-ceiling assembly into the structural headroom already available.
task.spawn(function()
 local main=root:WaitForChild("MainClubRealism",40);if not main then return end
 local architecture=main:WaitForChild("Architecture",20);if not architecture then return end
 local ceiling=architecture:WaitForChild("CeilingArchitecture",20)
 local shell=architecture:WaitForChild("PremiumShell",20)
 if not ceiling or not shell then return end
 task.wait(.6)

 shiftModelY(ceiling,HEADROOM_DELTA)
 for _,d in ipairs(shell:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^ColumnCore") then extendUp(d,HEADROOM_DELTA) end
 end

 main:SetAttribute("BBYATallAvatarMainProfile","ZEPETO_CLEARANCE_V2")
 main:SetAttribute("BBYAMainCeilingDeltaY",HEADROOM_DELTA)
 main:SetAttribute("BBYAMainTargetClearHeadroom",28)
 root:SetAttribute("BBYAMainTallAvatarClearance",true)
 root:SetAttribute("BBYAMainEntranceHeadroomAuthority","MAIN_ENTRANCE_TALL_AVATAR_V2")
end)

print("[BBYA] Owner geometry v5 online: Underground safety collider + floor guard + Zepeto-safe entrance/Main headroom; legendary entrance logo preserved")
