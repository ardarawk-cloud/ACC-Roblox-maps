-- BBYA SOCIAL HUB — MALL STOREFRONT FINAL AUTHORITY v5
-- Root-cause correction for the Mall tenant shells.
-- The base builder placed StoreGlass on the OUTER facade (x ~= +/-93) while the atrium
-- is toward x=0, leaving a full Side wall facing players inside the Mall.
-- This authority waits until every L1/L2 tenant + commerce + architecture pass exists,
-- then flips each storefront inward, removes the atrium-facing blocker, converts the
-- remaining outer wall into the real back wall, rebuilds restrained retail side walls,
-- and integrates native Robux commerce without floating billboard clutter.
-- Global Lighting / DJ / VIP / fishing / monetization logic are not changed here.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

-- SECURITY: preserve the existing safe Mall connector behavior.
task.wait(2.2)
local premium=root:FindFirstChild("WorldPremiumV338")
if premium then
 local security=premium:FindFirstChild("PaidZoneSecurity")
 if security then
  local rear=security:FindFirstChild("NoBypassRearBoundary")
  if rear then rear:Destroy() end
  for _,sideName in ipairs({"Left","Right"}) do
   local b=security:FindFirstChild("NoBypassWorldBoundary"..sideName)
   if b and b:IsA("BasePart") then
    b.Size=Vector3.new(3,28,340)
    b.CFrame=CFrame.new(sideName=="Left" and -73 or 73,14,80)
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

-- IMPORTANT: the old v4 ran after only Tenant_luma existed. v5 waits for the LAST
-- base L2 tenant so the builder cannot add raw shells after this authority has finished.
local requiredTenants={
 "Tenant_luma","Tenant_stride","Tenant_byte","Tenant_daily","Tenant_mono","Tenant_muse",
 "Tenant_north","Tenant_street","Tenant_page","Tenant_glow","Tenant_sound","Tenant_fit",
}
for _,name in ipairs(requiredTenants) do
 if not mall:WaitForChild(name,90) then
  warn("[BBYA] Mall storefront v5 aborted: missing "..name)
  return
 end
end

local architecture=mall:WaitForChild("MallArchitectureV3",90)
-- Commerce is optional from a gameplay standpoint, but wait briefly so its prompts/badges
-- are present before the final visual authority integrates them.
mall:WaitForChild("MallRobuxCommerceV1",30)
task.wait(2.0)

-- Remove all prior Mall storefront authority output.
for _,n in ipairs({"MallStorefrontAuthorityV4","MallStorefrontAuthorityV5"}) do
 local old=mall:FindFirstChild(n)
 if old then old:Destroy() end
end

-- Architecture v3 added a second storefront portal on top of the base shell. Once v5 fixes
-- the base geometry correctly, that extra portal is unnecessary and causes stacking.
if architecture then
 local duplicate=architecture:FindFirstChild("StorefrontDepthV3")
 if duplicate then duplicate:Destroy() end
end

local out=Instance.new("Model")
out.Name="MallStorefrontAuthorityV5"
out:SetAttribute("Pass","MALL_STOREFRONT_FINAL_AUTHORITY_V5")
out:SetAttribute("StorefrontsFaceAtrium",true)
out:SetAttribute("OuterFacingStorefrontBugFixed",true)
out:SetAttribute("AtriumBlockingWallsRemoved",true)
out:SetAttribute("DuplicateFacadeRemoved",true)
out:SetAttribute("NativeCommerceIntegrated",true)
out:SetAttribute("GlobalLightingUntouched",true)
out.Parent=mall

local C={
 black=Color3.fromRGB(10,11,13),
 ink=Color3.fromRGB(20,21,24),
 charcoal=Color3.fromRGB(34,35,39),
 graphite=Color3.fromRGB(58,60,65),
 stone=Color3.fromRGB(122,118,112),
 marble=Color3.fromRGB(151,147,141),
 brass=Color3.fromRGB(196,153,87),
 glass=Color3.fromRGB(102,128,139),
 warm=Color3.fromRGB(255,220,184),
 white=Color3.fromRGB(241,240,236),
}

local function part(name,size,cf,color,material,parent,collide,transparency)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.graphite
 p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=false
 p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent
 return p
end

local function neon(name,size,cf,color,parent,transparency)
 local p=part(name,size,cf,color or C.brass,Enum.Material.Neon,parent,false,transparency or .12)
 p.CastShadow=false
 return p
end

local function localLight(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="RetailLocalLight"
 l.Color=color or C.warm
 l.Brightness=brightness or .18
 l.Range=range or 8
 l.Shadows=false
 l.Parent=parent
 return l
end

local function setSignStyle(signPart,accent,inward,frontX,y,z)
 if not signPart or not signPart:IsA("BasePart") then return end
 signPart.Size=Vector3.new(.34,1.8,10.8)
 signPart.CFrame=CFrame.new(frontX+inward*.32,y+9.35,z)
  * CFrame.Angles(0,inward>0 and math.rad(-90) or math.rad(90),0)
 signPart.Color=C.ink
 signPart.Material=Enum.Material.Metal
 signPart.Transparency=.01
 signPart.CanCollide=false
 for _,g in ipairs(signPart:GetChildren()) do
  if g:IsA("SurfaceGui") then
   g.LightInfluence=.08
   g.PixelsPerStud=68
   for _,t in ipairs(g:GetDescendants()) do
    if t:IsA("TextLabel") then
     t.TextColor3=C.white
     t.Font=Enum.Font.GothamBold
    end
   end
  end
 end
 -- Accent is expressed as a narrow architectural underline, not a giant colored slab.
 local line=neon("BrandUnderline",Vector3.new(.08,.10,9.6),CFrame.new(frontX+inward*.50,y+8.22,z),accent,out,.10)
 line:SetAttribute("TenantSignAccent",true)
end

local function marketplacePlaque(unit,frontX,y,z,inward,accent)
 if unit:GetAttribute("NativeRobuxShop")~=true then return end
 local p=part(unit.Name.."_MarketplacePlaque",Vector3.new(.20,.72,5.2),
  CFrame.new(frontX+inward*.48,y+7.05,z)*CFrame.Angles(0,inward>0 and math.rad(-90) or math.rad(90),0),
  C.ink,Enum.Material.Metal,out,false,0)
 local gui=Instance.new("SurfaceGui")
 gui.Face=Enum.NormalId.Front
 gui.PixelsPerStud=72
 gui.LightInfluence=.08
 gui.Parent=p
 local label=Instance.new("TextLabel")
 label.Size=UDim2.fromScale(1,1)
 label.BackgroundTransparency=1
 label.Text="R$  MARKETPLACE"
 label.TextColor3=accent
 label.Font=Enum.Font.GothamBold
 label.TextScaled=true
 label.Parent=gui
end

local fixed=0
local native=0
for _,unitName in ipairs(requiredTenants) do
 local unit=mall:FindFirstChild(unitName)
 if unit and unit:IsA("Model") then
  local floor=unit:FindFirstChild("Floor")
  local glass=unit:FindFirstChild("StoreGlass")
  local door=unit:FindFirstChild("StoreDoor")
  if floor and floor:IsA("BasePart") and glass and glass:IsA("BasePart") and door and door:IsA("BasePart") then
   local cx=floor.Position.X
   local y=floor.Position.Y-.7
   local z=floor.Position.Z
   local width=floor.Size.X
   local depth=floor.Size.Z
   -- Direction from this tenant toward the central atrium at x=0.
   local inward=(cx<0) and 1 or -1
   local frontX=cx+inward*(width/2-.28)
   local outerX=cx-inward*(width/2-.48)

   unit:SetAttribute("StorefrontFacesAtrium",true)
   unit:SetAttribute("StorefrontFrontX",frontX)
   unit:SetAttribute("StorefrontInwardX",inward)
   unit:SetAttribute("StorefrontAuthority","V5")

   -- The old builder's Back wall was placed on a Z edge based on tenant row, which produced
   -- a giant slab from oblique mobile views. Remove it; v5 creates proper north/south walls.
   local legacyBack=unit:FindFirstChild("Back")
   if legacyBack then legacyBack:Destroy() end

   -- Of SideA / SideB, the wall closest to the ATRIUM is the bug visible in screenshots.
   -- Delete it. The other wall becomes the true exterior/back wall of the shop.
   local sideParts={}
   for _,n in ipairs({"SideA","SideB"}) do
    local w=unit:FindFirstChild(n)
    if w and w:IsA("BasePart") then table.insert(sideParts,w) end
   end
   local innerWall=nil
   local innerDist=math.huge
   local outerWall=nil
   local outerDist=math.huge
   for _,w in ipairs(sideParts) do
    local di=math.abs(w.Position.X-frontX)
    if di<innerDist then innerDist=di;innerWall=w end
    local do_=math.abs(w.Position.X-outerX)
    if do_<outerDist then outerDist=do_;outerWall=w end
   end
   if innerWall and innerWall~=outerWall then innerWall:Destroy() end
   if outerWall and outerWall.Parent then
    outerWall.Name="BackWall"
    outerWall.Size=Vector3.new(.72,10.6,depth-.8)
    outerWall.CFrame=CFrame.new(outerX,y+5.9,z)
    outerWall.Color=C.ink
    outerWall.Material=Enum.Material.Slate
    outerWall.Transparency=0
   end

   -- Restrained side walls run from the outer back toward the store, but stop short of the
   -- atrium edge. This creates open retail corners instead of another sealed box.
   local sideLen=width*.72
   local sideCenterX=cx-inward*(width*.14)
   local shell=Instance.new("Model")
   shell.Name="PremiumShellV5"
   shell.Parent=unit
   part("NorthWall",Vector3.new(sideLen,10.4,.58),CFrame.new(sideCenterX,y+5.8,z-depth/2+.32),C.charcoal,Enum.Material.Slate,shell,true,0)
   part("SouthWall",Vector3.new(sideLen,10.4,.58),CFrame.new(sideCenterX,y+5.8,z+depth/2-.32),C.charcoal,Enum.Material.Slate,shell,true,0)
   -- Ceiling stops before the storefront for a shadow reveal and a cleaner entrance.
   part("Ceiling",Vector3.new(sideLen,.26,depth-1.4),CFrame.new(sideCenterX,y+10.95,z),C.black,Enum.Material.Metal,shell,false,0)

   -- Move the actual storefront from the OUTER wall to the ATRIUM wall.
   glass.Size=Vector3.new(.28,8.65,depth-3.0)
   glass.CFrame=CFrame.new(frontX,y+5.35,z)
   glass.Color=C.glass
   glass.Transparency=.72
   glass.Reflectance=.035
   glass.CanCollide=false
   glass.CanTouch=false
   glass.CanQuery=false

   door.Size=Vector3.new(.22,7.65,5.6)
   door.CFrame=CFrame.new(frontX+inward*.06,y+4.95,z)
   door.Color=C.glass
   door.Transparency=.80
   door.Reflectance=.025
   door.CanCollide=false
   door.CanTouch=false

   -- One coherent structural portal around the full storefront.
   local facade=Instance.new("Model")
   facade.Name="StorefrontFacadeV5"
   facade.Parent=unit
   local jambZ=depth/2-.72
   part("JambNorth",Vector3.new(.66,9.4,.66),CFrame.new(frontX-inward*.08,y+5.45,z-jambZ),C.graphite,Enum.Material.Metal,facade,false,0)
   part("JambSouth",Vector3.new(.66,9.4,.66),CFrame.new(frontX-inward*.08,y+5.45,z+jambZ),C.graphite,Enum.Material.Metal,facade,false,0)
   part("Header",Vector3.new(.66,.66,depth-1.0),CFrame.new(frontX-inward*.08,y+10.15,z),C.graphite,Enum.Material.Metal,facade,false,0)
   part("Threshold",Vector3.new(.72,.16,depth-1.5),CFrame.new(frontX-inward*.08,y+.92,z),C.stone,Enum.Material.Marble,facade,false,0)

   -- Floor becomes restrained stone/marble, not a bright concrete slab.
   floor.Color=C.marble
   floor.Material=Enum.Material.Marble
   floor.Reflectance=.025

   -- Use the current StoreSign text color as accent when available.
   local accent=C.brass
   local signPart=unit:FindFirstChild("StoreSign")
   if signPart and signPart:IsA("BasePart") then
    local sg=signPart:FindFirstChildOfClass("SurfaceGui")
    local st=sg and sg:FindFirstChildOfClass("TextLabel")
    if st then accent=st.TextColor3 end
   end
   setSignStyle(signPart,accent,inward,frontX,y,z)

   -- Reposition block fixtures deeper inside, slim them and keep a clear central entry axis.
   local counter=unit:FindFirstChild("Counter")
   if counter and counter:IsA("BasePart") then
    counter.Size=Vector3.new(6.8,1.45,2.15)
    counter.CFrame=CFrame.new(cx-inward*13,y+1.65,z+8.2)
    counter.Color=C.charcoal
    counter.Material=Enum.Material.Metal
   end
   local displayX=cx+inward*1.6
   for i,zoff in ipairs({-7.2,0,7.2}) do
    local d=unit:FindFirstChild("Display"..i)
    if d and d:IsA("BasePart") then
     d.Size=Vector3.new(4.0,.46,2.1)
     d.CFrame=CFrame.new(displayX,y+1.15,z+zoff)
     d.Color=C.graphite
     d.Material=Enum.Material.Metal
    end
    local glow=unit:FindFirstChild("DisplayGlow"..i)
    if glow and glow:IsA("BasePart") then
     glow.Size=Vector3.new(3.3,.035,1.45)
     glow.CFrame=CFrame.new(displayX,y+1.405,z+zoff)
     glow.Transparency=.42
     glow.CanCollide=false
    end
   end

   -- Invisible interaction anchor. Never show a glowing cube in a premium storefront.
   local interact=unit:FindFirstChild("Interact")
   if interact and interact:IsA("BasePart") then
    interact.CFrame=CFrame.new(frontX-inward*2.2,y+2.0,z)
    interact.Size=Vector3.new(1,1,1)
    interact.Transparency=1
    interact.CanCollide=false
    interact.CanTouch=false
    interact.CanQuery=false
    interact.CastShadow=false
    for _,q in ipairs(interact:GetChildren()) do
     if q:IsA("ProximityPrompt") then
      if unit:GetAttribute("NativeRobuxShop")==true then
       q:Destroy()
      else
       q.ActionText="BROWSE"
       q.MaxActivationDistance=7
       q.HoldDuration=.05
      end
     end
    end
   end

   -- Local hospitality lighting only; no global Lighting edits.
   local rail=part("TrackRail",Vector3.new(7.2,.14,depth-5.2),CFrame.new(cx-inward*4.0,y+10.55,z),C.black,Enum.Material.Metal,shell,false,0)
   local lamp=neon("WarmLinear",Vector3.new(4.6,.055,depth-7.0),CFrame.new(cx-inward*4.0,y+10.43,z),C.warm,shell,.62)
   localLight(lamp,C.warm,.17,7.5)

   -- Native Robux commerce: keep official purchase prompt, remove the floating billboard that
   -- dominated screenshots, and use a small integrated marketplace plaque instead.
   if unit:GetAttribute("NativeRobuxShop")==true then
    native+=1
    local badge=door:FindFirstChild("NativeRobuxBadge")
    if badge then badge:Destroy() end
    local q=door:FindFirstChild("NativeRobuxShopPrompt")
    if q and q:IsA("ProximityPrompt") then
     q.ActionText="SHOP • R$"
     q.ObjectText=(signPart and signPart:FindFirstChildOfClass("SurfaceGui") and signPart:FindFirstChildOfClass("SurfaceGui"):FindFirstChildOfClass("TextLabel") and signPart:FindFirstChildOfClass("SurfaceGui"):FindFirstChildOfClass("TextLabel").Text) or "ROBLOX MARKETPLACE"
     q.MaxActivationDistance=7
     q.HoldDuration=.06
     q.RequiresLineOfSight=false
    end
    marketplacePlaque(unit,frontX,y,z,inward,accent)
   end

   fixed+=1
  end
 end
end

mall:SetAttribute("StorefrontAuthority","V5")
mall:SetAttribute("StorefrontsFaceAtrium",true)
mall:SetAttribute("PremiumSecurityUntouchedMall",true)
out:SetAttribute("FixedTenants",fixed)
out:SetAttribute("NativeStoresIntegrated",native)
print(string.format("[BBYA] Mall storefront FINAL authority v5: %d tenants flipped inward to atrium; %d native Robux stores integrated",fixed,native))
