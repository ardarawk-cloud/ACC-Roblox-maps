-- BBYA SOCIAL HUB — MALL SAFE + STOREFRONT AUTHORITY v4
-- Keeps paid-zone security out of the Mall, then performs the late visual cleanup
-- required after every Mall/commerce pass has built.
-- Fixes the base tenant bug where one full Side wall sits directly on the storefront,
-- creating the giant white/grey slabs visible on mobile.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

-- SECURITY: preserve the safe Mall connector behavior.
task.wait(2.2)
local premium=root:FindFirstChild("WorldPremiumV338")
if premium then
 local security=premium:FindFirstChild("PaidZoneSecurity")
 if security then
  local rear=security:FindFirstChild("NoBypassRearBoundary")
  if rear then rear:Destroy() end
  for _,side in ipairs({"Left","Right"}) do
   local b=security:FindFirstChild("NoBypassWorldBoundary"..side)
   if b and b:IsA("BasePart") then
    b.Size=Vector3.new(3,28,340)
    b.CFrame=CFrame.new(side=="Left" and -73 or 73,14,80)
   end
  end
  security:SetAttribute("MallSafeNorthLimitZ",250)
  security:SetAttribute("RearBoundaryRemovedForMall",true)
 end
 premium:SetAttribute("MallConnectorPreserved",true)
end

local hard=root:FindFirstChild("PaidZoneHardSealV1")
if hard then
 local left=hard:FindFirstChild("NoGangLeft")
 local right=hard:FindFirstChild("NoGangRight")
 if left and left:IsA("BasePart") then left.Size=Vector3.new(14,26,340);left.CFrame=CFrame.new(-66,13,80) end
 if right and right:IsA("BasePart") then right.Size=Vector3.new(14,26,340);right.CFrame=CFrame.new(66,13,80) end
 hard:SetAttribute("MallSafeNorthLimitZ",250)
 hard:SetAttribute("MallConnectorPreserved",true)
end

local mall=root:WaitForChild("BBYAMall",90)
if not mall then return end
mall:WaitForChild("Tenant_luma",60)
mall:WaitForChild("MallArchitectureV3",90)
-- Commerce is optional, but if present let its prompts/badges finish first.
mall:WaitForChild("MallRobuxCommerceV1",15)
task.wait(1.25)

local old=mall:FindFirstChild("MallStorefrontAuthorityV4")
if old then old:Destroy() end
local out=Instance.new("Model")
out.Name="MallStorefrontAuthorityV4"
out:SetAttribute("Pass","MALL_STOREFRONT_AUTHORITY_V4")
out:SetAttribute("FrontBlockingWallsRemoved",true)
out:SetAttribute("NativeCommerceIntegrated",true)
out:SetAttribute("MobileSightlineCleanup",true)
out:SetAttribute("GlobalLightingUntouched",true)
out.Parent=mall

local C={
 ink=Color3.fromRGB(20,21,24),charcoal=Color3.fromRGB(34,35,39),graphite=Color3.fromRGB(56,58,63),
 stone=Color3.fromRGB(121,117,111),floor=Color3.fromRGB(151,148,143),brass=Color3.fromRGB(196,153,87),
 warm=Color3.fromRGB(255,218,181),glass=Color3.fromRGB(105,127,137),white=Color3.fromRGB(238,237,234)
}

local function part(name,size,cf,color,material,parent,collide,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
 return p
end
local function neon(name,size,cf,color,parent,transparency)
 local p=part(name,size,cf,color or C.brass,Enum.Material.Neon,parent,false,transparency or .15);p.CastShadow=false;return p
end
local function localLight(parent,color,brightness,range)
 local l=Instance.new("PointLight");l.Name="StoreLocalLight";l.Color=color or C.warm;l.Brightness=brightness or .23;l.Range=range or 8;l.Shadows=false;l.Parent=parent;return l
end

local cleaned=0
for _,unit in ipairs(mall:GetChildren()) do
 if unit:IsA("Model") and unit.Name:match("^Tenant_") and unit.Name~="Tenant_glow" then
  local glass=unit:FindFirstChild("StoreGlass")
  local floor=unit:FindFirstChild("Floor")
  if glass and glass:IsA("BasePart") and floor and floor:IsA("BasePart") then
   local frontX=glass.Position.X
   local centerX=floor.Position.X
   local inward=(centerX>frontX) and 1 or -1

   -- CRITICAL BUGFIX: SideA/SideB were built as X-facing walls. One lands exactly
   -- on StoreGlass and blocks the storefront. Remove only the wall nearest glass.
   local closest=nil
   local closestDist=math.huge
   for _,n in ipairs({"SideA","SideB"}) do
    local w=unit:FindFirstChild(n)
    if w and w:IsA("BasePart") then
     local d=math.abs(w.Position.X-frontX)
     if d<closestDist then closest=w;closestDist=d end
    end
   end
   if closest and closestDist<1.6 then closest:Destroy() end

   -- Neutral premium shell instead of bright raw blocks.
   floor.Color=C.floor;floor.Material=Enum.Material.Marble;floor.Reflectance=.03
   local back=unit:FindFirstChild("Back")
   if back and back:IsA("BasePart") then back.Color=C.ink;back.Material=Enum.Material.Slate end
   for _,n in ipairs({"SideA","SideB"}) do
    local w=unit:FindFirstChild(n)
    if w and w:IsA("BasePart") then w.Color=C.charcoal;w.Material=Enum.Material.Slate end
   end
   glass.Color=C.glass;glass.Transparency=.68;glass.Reflectance=.04;glass.CanCollide=false
   local door=unit:FindFirstChild("StoreDoor")
   if door and door:IsA("BasePart") then door.Color=C.glass;door.Transparency=.72;door.CanCollide=false end

   -- Hide the glowing browse cube. Prompt remains functional, but the world object disappears.
   local interact=unit:FindFirstChild("Interact")
   if interact and interact:IsA("BasePart") then
    interact.Transparency=1;interact.CanCollide=false;interact.CanQuery=false;interact.CastShadow=false
    if unit:GetAttribute("NativeRobuxShop")==true then
     for _,q in ipairs(interact:GetChildren()) do if q:IsA("ProximityPrompt") then q:Destroy() end end
    end
   end

   -- Base sign was 20 studs tall/wide and dominated the mobile view. Keep the identity,
   -- but turn it into a restrained fascia plate.
   local sign=unit:FindFirstChild("StoreSign")
   if sign and sign:IsA("BasePart") then
    sign.Size=Vector3.new(.36,1.75,11.5)
    sign.Color=C.ink;sign.Material=Enum.Material.Metal;sign.Transparency=.02
    for _,g in ipairs(sign:GetChildren()) do
     if g:IsA("SurfaceGui") then
      g.LightInfluence=.15
      for _,t in ipairs(g:GetDescendants()) do
       if t:IsA("TextLabel") then t.TextColor3=C.white;t.Font=Enum.Font.GothamBold end
      end
     end
    end
   end

   -- Existing block fixtures become slim retail plinths instead of Minecraft crates.
   local counter=unit:FindFirstChild("Counter")
   if counter and counter:IsA("BasePart") then
    counter.Size=Vector3.new(7.2,1.55,2.2);counter.Color=C.charcoal;counter.Material=Enum.Material.Metal
   end
   for i=1,3 do
    local d=unit:FindFirstChild("Display"..i)
    if d and d:IsA("BasePart") then d.Size=Vector3.new(5.4,.52,2.15);d.Color=C.graphite;d.Material=Enum.Material.Metal end
    local glow=unit:FindFirstChild("DisplayGlow"..i)
    if glow and glow:IsA("BasePart") then glow.Size=Vector3.new(4.8,.05,1.7);glow.Transparency=.35 end
   end

   -- One coherent storefront portal per tenant.
   local m=Instance.new("Model");m.Name=unit.Name.."_AuthorityFacade";m.Parent=out
   local gy=glass.Position.Y
   local gz=glass.Position.Z
   local halfZ=math.max(7.6,glass.Size.Z*.5)
   local accent=Color3.fromRGB(210,166,96)
   local oldSign=unit:FindFirstChild("StoreSign")
   if oldSign and oldSign:IsA("BasePart") then
    local gui=oldSign:FindFirstChildOfClass("SurfaceGui")
    local txt=gui and gui:FindFirstChildOfClass("TextLabel")
    if txt and txt.TextColor3 then accent=txt.TextColor3 end
   end

   for _,zoff in ipairs({-halfZ,halfZ}) do
    part("Jamb",Vector3.new(.72,9.4,.72),CFrame.new(frontX+inward*.18,gy,gz+zoff),C.charcoal,Enum.Material.Metal,m,false)
    neon("JambReveal",Vector3.new(.10,7.7,.10),CFrame.new(frontX-inward*.22,gy,gz+zoff),accent,m,.18)
   end
   part("Header",Vector3.new(.72,.72,halfZ*2+.7),CFrame.new(frontX+inward*.18,gy+5.05,gz),C.charcoal,Enum.Material.Metal,m,false)
   part("Plinth",Vector3.new(.78,.38,halfZ*2+.2),CFrame.new(frontX+inward*.18,gy-4.48,gz),C.stone,Enum.Material.Marble,m,false)

   -- Shallow internal ceiling rail gives local depth without global Lighting changes.
   local lightRail=part("LightRail",Vector3.new(5.6,.16,halfZ*1.45),CFrame.new(frontX+inward*7.2,gy+4.55,gz),C.ink,Enum.Material.Metal,m,false)
   local lamp=neon("WarmTask",Vector3.new(.10,.08,math.min(10,halfZ)),CFrame.new(frontX+inward*7.2,gy+4.43,gz),C.warm,m,.58)
   localLight(lamp,C.warm,.20,8)

   -- Integrate the Robux signage into the storefront instead of a giant floating billboard.
   if door and door:IsA("BasePart") then
    local badge=door:FindFirstChild("NativeRobuxBadge")
    if badge and badge:IsA("BillboardGui") then
     badge.Size=UDim2.fromOffset(150,30);badge.StudsOffset=Vector3.new(0,4.0,0);badge.MaxDistance=38;badge.AlwaysOnTop=false
     for _,t in ipairs(badge:GetDescendants()) do
      if t:IsA("TextLabel") then t.TextSize=11 end
     end
    end
    local q=door:FindFirstChild("NativeRobuxShopPrompt")
    if q and q:IsA("ProximityPrompt") then
     q.ActionText="SHOP • R$";q.MaxActivationDistance=8;q.HoldDuration=.08
    end
   end

   cleaned+=1
  end
 end
end

mall:SetAttribute("PremiumSecurityUntouchedMall",true)
out:SetAttribute("CleanedTenants",cleaned)
print(string.format("[BBYA] Mall storefront authority v4 online: %d tenant fronts opened/cleaned; giant blocking slabs removed",cleaned))
