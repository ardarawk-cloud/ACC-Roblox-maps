-- BBYA SOCIAL HUB — MALL PREMIUM GALLERY AUTHORITY v6
-- Live-mobile-evidence correction after v420.
-- IMPORTANT: the base builder already places StoreGlass on the atrium side (~x +/-47).
-- The real problem is that legacy Side walls, primitive fixtures and later visual passes
-- overlap that storefront and keep the Mall looking like stacked boxes.
-- v6 replaces the visible L1/L2 tenant shells instead of trying to skin them again.
-- Global Lighting / DJ / VIP / fishing / monetization logic are not changed here.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

-- Preserve the existing Mall-safe paid-zone boundary behavior.
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

local requiredTenants={
 "Tenant_luma","Tenant_stride","Tenant_byte","Tenant_daily","Tenant_mono","Tenant_muse",
 "Tenant_north","Tenant_street","Tenant_page","Tenant_glow","Tenant_sound","Tenant_fit",
}
for _,name in ipairs(requiredTenants) do
 if not mall:WaitForChild(name,90) then
  warn("[BBYA] Mall Gallery v6 aborted: missing "..name)
  return
 end
end

local architecture=mall:WaitForChild("MallArchitectureV3",90)
local live=mall:WaitForChild("MallLiveUpgradeV2",90)
mall:WaitForChild("MallRobuxCommerceV1",30)
task.wait(2.0)

-- Retire every previous tenant authority. v6 is the single final visual authority.
for _,name in ipairs({"MallStorefrontAuthorityV4","MallStorefrontAuthorityV5","MallPremiumGalleryV6"}) do
 local d=mall:FindFirstChild(name)
 if d then d:Destroy() end
end

-- Remove the old second storefront system and the edge-on neon sculpture that reads as
-- three horizontal bars from the mobile entrance camera.
if architecture then
 for _,name in ipairs({"StorefrontDepthV3","OpenAtriumSculptureV3"}) do
  local d=architecture:FindFirstChild(name)
  if d then d:Destroy() end
 end
end

-- Remove low-value atrium clutter from the live-upgrade pass. We rebuild one clean focal point.
if live then
 for _,name in ipairs({"AtriumLiveStageV2","AtriumKiosks"}) do
  local d=live:FindFirstChild(name)
  if d then d:Destroy() end
 end
end
local atrium=mall:FindFirstChild("AtriumExperience")
if atrium then
 local stage=atrium:FindFirstChild("AtriumStage")
 if stage then stage:Destroy() end
 for _,d in ipairs(atrium:GetChildren()) do
  if d.Name:match("^SculptureRing") then d:Destroy() end
 end
end

local out=Instance.new("Model")
out.Name="MallPremiumGalleryV6"
out:SetAttribute("Pass","MALL_PREMIUM_GALLERY_AUTHORITY_V6")
out:SetAttribute("LegacyTenantVisualsReplaced",true)
out:SetAttribute("WorldRobuxBillboardsRemoved",true)
out:SetAttribute("AtriumStageRemoved",true)
out:SetAttribute("MobileEntranceSightline",true)
out:SetAttribute("GlobalLightingUntouched",true)
out.Parent=mall

local C={
 black=Color3.fromRGB(10,11,13),
 ink=Color3.fromRGB(20,21,24),
 charcoal=Color3.fromRGB(34,35,39),
 graphite=Color3.fromRGB(58,60,65),
 metal=Color3.fromRGB(92,95,101),
 stone=Color3.fromRGB(126,122,116),
 marble=Color3.fromRGB(154,150,143),
 brass=Color3.fromRGB(192,151,88),
 champagne=Color3.fromRGB(220,184,122),
 glass=Color3.fromRGB(101,129,141),
 warm=Color3.fromRGB(255,224,192),
 white=Color3.fromRGB(239,239,236),
 muted=Color3.fromRGB(170,168,163),
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
 p.Parent=parent or out
 return p
end

local function neon(name,size,cf,color,parent,transparency)
 local p=part(name,size,cf,color or C.champagne,Enum.Material.Neon,parent,false,transparency or .08)
 p.CastShadow=false
 return p
end

local function cylinder(name,height,diameter,cf,color,material,parent,collide,transparency)
 local p=part(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,parent,collide,transparency)
 p.Shape=Enum.PartType.Cylinder
 return p
end

local function localPoint(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="MallLocalLight"
 l.Color=color or C.warm
 l.Brightness=brightness or .42
 l.Range=range or 13
 l.Shadows=false
 l.Parent=parent
 return l
end

local function surfaceText(partObj,face,title,subtitle,accent)
 local gui=Instance.new("SurfaceGui")
 gui.Name="PremiumStoreSignGui"
 gui.Face=face
 gui.PixelsPerStud=72
 gui.LightInfluence=.05
 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
 gui.Parent=partObj

 local bg=Instance.new("Frame")
 bg.Size=UDim2.fromScale(1,1)
 bg.BackgroundColor3=C.ink
 bg.BorderSizePixel=0
 bg.Parent=gui

 local titleLabel=Instance.new("TextLabel")
 titleLabel.BackgroundTransparency=1
 titleLabel.Position=UDim2.fromScale(.05,.10)
 titleLabel.Size=UDim2.fromScale(.90,.54)
 titleLabel.Text=title
 titleLabel.TextColor3=C.white
 titleLabel.Font=Enum.Font.GothamBold
 titleLabel.TextScaled=true
 titleLabel.TextXAlignment=Enum.TextXAlignment.Center
 titleLabel.Parent=bg

 local sub=Instance.new("TextLabel")
 sub.BackgroundTransparency=1
 sub.Position=UDim2.fromScale(.08,.67)
 sub.Size=UDim2.fromScale(.84,.20)
 sub.Text=subtitle or ""
 sub.TextColor3=accent or C.champagne
 sub.Font=Enum.Font.GothamBold
 sub.TextScaled=true
 sub.TextXAlignment=Enum.TextXAlignment.Center
 sub.Parent=bg
end

local stores={
 Tenant_luma={title="LUMA FASHION",sub="R$ CATALOG",kind="fashion",accent=Color3.fromRGB(228,77,153),native=true},
 Tenant_stride={title="STRIDE SNEAKERS",sub="R$ CATALOG",kind="shoes",accent=Color3.fromRGB(224,132,70),native=true},
 Tenant_byte={title="BYTE TECH",sub="ELECTRONICS",kind="tech",accent=Color3.fromRGB(69,181,203)},
 Tenant_daily={title="DAILY MARKET",sub="EVERYDAY",kind="market",accent=Color3.fromRGB(78,170,116)},
 Tenant_mono={title="MONO HOME",sub="HOME & LIVING",kind="home",accent=Color3.fromRGB(202,165,98)},
 Tenant_muse={title="MUSE BEAUTY",sub="R$ CATALOG",kind="beauty",accent=Color3.fromRGB(151,94,205),native=true},
 Tenant_north={title="NORTH LABEL",sub="R$ CATALOG",kind="fashion",accent=Color3.fromRGB(78,120,202),native=true},
 Tenant_street={title="STREET UNIT",sub="STREETWEAR",kind="fashion",accent=Color3.fromRGB(194,77,77)},
 Tenant_page={title="PAGE & CO",sub="BOOKS & CULTURE",kind="books",accent=Color3.fromRGB(202,165,98)},
 Tenant_glow={title="GLOW LAB",sub="LOOK LAB • PHOTO",kind="beauty",accent=Color3.fromRGB(224,85,154)},
 Tenant_sound={title="SOUND ROOM",sub="AUDIO",kind="tech",accent=Color3.fromRGB(63,183,207)},
 Tenant_fit={title="FIT DISTRICT",sub="SPORT",kind="sport",accent=Color3.fromRGB(72,169,111)},
}

local function addPodium(parent,x,y,z,accent,scale)
 scale=scale or 1
 cylinder("GalleryPodium",.42,3.7*scale,CFrame.new(x,y,z),C.graphite,Enum.Material.Metal,parent,true,0)
 cylinder("GalleryPodiumTop",.08,3.3*scale,CFrame.new(x,y+.25,z),accent,Enum.Material.Metal,parent,false,.10)
end

local function addBackDisplay(parent,outerX,inward,y,z,accent,kind)
 local wallX=outerX+inward*.55
 local panel=part("FeaturePanel",Vector3.new(.26,6.6,14.6),CFrame.new(wallX,y+5.2,z),C.ink,Enum.Material.Metal,parent,false,0)
 neon("FeatureLine",Vector3.new(.08,4.9,.08),CFrame.new(wallX+inward*.18,y+5.15,z-6.4),accent,parent,.16)

 if kind=="beauty" then
  local mirror=part("BeautyMirror",Vector3.new(.16,4.5,5.0),CFrame.new(wallX+inward*.22,y+5.25,z),Color3.fromRGB(110,126,133),Enum.Material.Glass,parent,false,.28)
  for _,zo in ipairs({-3.0,3.0}) do
   neon("VanityLight",Vector3.new(.08,4.4,.10),CFrame.new(wallX+inward*.36,y+5.25,z+zo),C.warm,parent,.08)
  end
 elseif kind=="shoes" or kind=="books" or kind=="home" or kind=="market" then
  for i=1,3 do
   part("Shelf"..i,Vector3.new(1.25,.16,11.2),CFrame.new(outerX+inward*1.05,y+2.7+i*1.55,z),C.graphite,Enum.Material.Metal,parent,false,0)
   neon("ShelfEdge"..i,Vector3.new(.06,.055,10.5),CFrame.new(outerX+inward*1.72,y+2.82+i*1.55,z),accent,parent,.48)
  end
 elseif kind=="fashion" or kind=="sport" then
  for _,zo in ipairs({-4.1,4.1}) do
   part("RackPost",Vector3.new(.18,4.2,.18),CFrame.new(outerX+inward*3.4,y+3.2,z+zo),C.metal,Enum.Material.Metal,parent,false,0)
  end
  part("RackRail",Vector3.new(.18,.18,8.4),CFrame.new(outerX+inward*3.4,y+5.0,z),C.brass,Enum.Material.Metal,parent,false,0)
 elseif kind=="tech" then
  for _,zo in ipairs({-4.6,0,4.6}) do
   local screen=part("TechScreen",Vector3.new(.20,2.2,3.2),CFrame.new(wallX+inward*.22,y+5.0,z+zo),C.black,Enum.Material.Metal,parent,false,0)
   neon("TechScreenGlow",Vector3.new(.06,1.65,2.55),CFrame.new(wallX+inward*.35,y+5.0,z+zo),accent,parent,.30)
  end
 end
 return panel
end

local rebuilt=0
local nativeCount=0
for _,unitName in ipairs(requiredTenants) do
 local unit=mall:FindFirstChild(unitName)
 local spec=stores[unitName]
 if unit and unit:IsA("Model") and spec then
  local floor=unit:FindFirstChild("Floor")
  local door=unit:FindFirstChild("StoreDoor")
  if floor and floor:IsA("BasePart") and door and door:IsA("BasePart") then
   local cx=floor.Position.X
   local y=floor.Position.Y-.7
   local z=floor.Position.Z
   local width=floor.Size.X
   local depth=floor.Size.Z
   local inward=(cx<0) and 1 or -1
   local frontX=cx+inward*(width/2-.34)
   local outerX=cx-inward*(width/2-.38)

   -- Delete every primitive visible tenant shell/fixture from the base builder and prior passes.
   for _,name in ipairs({
    "Back","SideA","SideB","BackWall","StoreGlass","StoreSign","Counter",
    "PremiumShellV5","StorefrontFacadeV5"
   }) do
    local d=unit:FindFirstChild(name)
    if d then d:Destroy() end
   end
   for i=1,3 do
    for _,prefix in ipairs({"Display","DisplayGlow"}) do
     local d=unit:FindFirstChild(prefix..i)
     if d then d:Destroy() end
    end
   end

   -- Remove any earlier gallery if Studio hot-reloads this authority.
   local oldGallery=unit:FindFirstChild("PremiumRetailGalleryV6")
   if oldGallery then oldGallery:Destroy() end
   local gallery=Instance.new("Model")
   gallery.Name="PremiumRetailGalleryV6"
   gallery.Parent=unit

   floor.Color=C.stone
   floor.Material=Enum.Material.Marble
   floor.Reflectance=.025

   -- Real retail plan: exterior back wall + short rear side returns; the front half stays open.
   part("ExteriorBack",Vector3.new(.72,10.6,depth-1.0),CFrame.new(outerX,y+5.9,z),C.ink,Enum.Material.Slate,gallery,true,0)
   local returnLen=15.0
   local returnCenterX=outerX+inward*(returnLen/2)
   for _,zo in ipairs({-(depth/2-.35),(depth/2-.35)}) do
    part("ShortSideReturn",Vector3.new(returnLen,10.4,.60),CFrame.new(returnCenterX,y+5.8,z+zo),C.charcoal,Enum.Material.Slate,gallery,true,0)
   end
   part("RearCeiling",Vector3.new(returnLen,.22,depth-1.2),CFrame.new(returnCenterX,y+10.95,z),C.black,Enum.Material.Metal,gallery,false,0)

   -- Thin gallery portal; no giant physical sign slab and no full glass wall blocking entry.
   local jambZ=depth/2-.75
   for _,zo in ipairs({-jambZ,jambZ}) do
    part("PortalJamb",Vector3.new(.60,9.5,.60),CFrame.new(frontX,y+5.45,z+zo),C.graphite,Enum.Material.Metal,gallery,false,0)
    neon("PortalReveal",Vector3.new(.08,7.7,.08),CFrame.new(frontX+inward*.18,y+5.2,z+zo),spec.accent,gallery,.20)
   end
   part("PortalHeader",Vector3.new(.62,.62,depth-1.0),CFrame.new(frontX,y+10.18,z),C.graphite,Enum.Material.Metal,gallery,false,0)
   part("Threshold",Vector3.new(.66,.12,depth-1.7),CFrame.new(frontX,y+.96,z),C.marble,Enum.Material.Marble,gallery,false,0)

   -- Two glass wings leave a true open center entrance.
   local glassLen=8.1
   for _,zo in ipairs({-7.2,7.2}) do
    local g=part("GlassWing",Vector3.new(.18,8.35,glassLen),CFrame.new(frontX+inward*.08,y+5.25,z+zo),C.glass,Enum.Material.Glass,gallery,false,.72)
    g.Reflectance=.025
    g.CastShadow=false
   end

   -- Small integrated tenant identity panel. Native Robux stores use a restrained subtitle only.
   local signPart=part("TenantIdentity",Vector3.new(.18,1.25,10.2),CFrame.new(frontX+inward*.12,y+9.05,z),C.ink,Enum.Material.Metal,gallery,false,0)
   local face=inward>0 and Enum.NormalId.Right or Enum.NormalId.Left
   surfaceText(signPart,face,spec.title,spec.sub,spec.accent)
   neon("IdentityUnderline",Vector3.new(.08,.07,8.6),CFrame.new(frontX+inward*.24,y+8.28,z),spec.accent,gallery,.18)

   -- Gallery fixtures: round podiums instead of glowing cubes / rectangular crates.
   addPodium(gallery,cx+inward*5.0,y+1.15,z-5.3,spec.accent,.90)
   addPodium(gallery,cx+inward*6.2,y+1.15,z+5.3,spec.accent,.90)
   addPodium(gallery,cx+inward*9.0,y+1.15,z,spec.accent,.74)
   addBackDisplay(gallery,outerX,inward,y,z,spec.accent,spec.kind)

   -- One restrained local ceiling rail and one local light per store.
   local rail=part("TrackRail",Vector3.new(5.8,.14,12.5),CFrame.new(cx-inward*2.0,y+10.58,z),C.black,Enum.Material.Metal,gallery,false,0)
   local lamp=neon("TrackGlow",Vector3.new(3.8,.055,9.4),CFrame.new(cx-inward*2.0,y+10.45,z),C.warm,gallery,.62)
   localPoint(lamp,C.warm,.38,12)

   -- Commerce / browse anchors stay functional but are fully invisible in-world.
   door.Size=Vector3.new(1,1,1)
   door.CFrame=CFrame.new(frontX-inward*1.4,y+2.4,z)
   door.Transparency=1
   door.CanCollide=false
   door.CanTouch=false
   door.CanQuery=false
   door.CastShadow=false
   local badge=door:FindFirstChild("NativeRobuxBadge")
   if badge then badge:Destroy() end
   local nativePrompt=door:FindFirstChild("NativeRobuxShopPrompt")
   if nativePrompt and nativePrompt:IsA("ProximityPrompt") then
    nativePrompt.ActionText="SHOP • R$"
    nativePrompt.ObjectText=spec.title
    nativePrompt.MaxActivationDistance=6
    nativePrompt.HoldDuration=.05
    nativePrompt.RequiresLineOfSight=false
   end

   local interact=unit:FindFirstChild("Interact")
   if interact and interact:IsA("BasePart") then
    interact.Size=Vector3.new(1,1,1)
    interact.CFrame=CFrame.new(frontX-inward*1.5,y+2.2,z)
    interact.Transparency=1
    interact.CanCollide=false
    interact.CanTouch=false
    interact.CanQuery=false
    interact.CastShadow=false
    for _,q in ipairs(interact:GetChildren()) do
     if q:IsA("ProximityPrompt") then
      if spec.native then
       q:Destroy()
      else
       q.ActionText="BROWSE"
       q.ObjectText=spec.title
       q.MaxActivationDistance=6
       q.HoldDuration=.05
       q.RequiresLineOfSight=false
      end
     end
    end
   end

   unit:SetAttribute("PremiumRetailGallery","V6")
   unit:SetAttribute("LegacyBoxVisualsRemoved",true)
   unit:SetAttribute("OpenStorefront",true)
   if spec.native then nativeCount+=1 end
   rebuilt+=1
  end
 end
end

-- Replace the giant black directory slabs with narrow hospitality totems while preserving
-- the original prompts on invisible anchors.
local directoryModel=Instance.new("Model")
directoryModel.Name="PremiumDirectoryTotemsV6"
directoryModel.Parent=out
for i=1,4 do
 local board=mall:FindFirstChild("DirectoryBoard"..i)
 local facePart=mall:FindFirstChild("DirectoryFace"..i)
 if board and board:IsA("BasePart") then
  local cf=board.CFrame
  board.Size=Vector3.new(1,1,1)
  board.Transparency=1
  board.CanCollide=false
  board.CanTouch=false
  board.CanQuery=false
  local q=board:FindFirstChildOfClass("ProximityPrompt")
  if q then q.ActionText="DIRECTORY";q.ObjectText="BBYA MALL";q.MaxActivationDistance=7 end
  local totem=part("DirectoryTotem"..i,Vector3.new(5.0,6.6,.34),cf,C.ink,Enum.Material.Metal,directoryModel,false,0)
  local gui=Instance.new("SurfaceGui")
  gui.Face=Enum.NormalId.Front
  gui.PixelsPerStud=64
  gui.LightInfluence=.05
  gui.Parent=totem
  local t=Instance.new("TextLabel")
  t.Size=UDim2.fromScale(1,1)
  t.BackgroundTransparency=1
  t.Text="BBYA MALL\nDIRECTORY"
  t.TextColor3=C.white
  t.Font=Enum.Font.GothamBold
  t.TextScaled=true
  t.Parent=gui
  neon("DirectoryEdge"..i,Vector3.new(4.3,.08,.08),cf*CFrame.new(0,-3.05,-.22),C.champagne,directoryModel,.12)
 end
 if facePart then facePart:Destroy() end
end

-- New central atrium focal point: warm stone inlay + suspended octagonal chandelier.
local atriumV6=Instance.new("Model")
atriumV6.Name="AtriumPremiumFocalV6"
atriumV6.Parent=out
cylinder("AtriumStoneInlay",.10,31,CFrame.new(0,1.04,365),Color3.fromRGB(101,99,96),Enum.Material.Marble,atriumV6,false,0)
cylinder("AtriumBrassInlay",.035,24,CFrame.new(0,1.105,365),C.brass,Enum.Material.Metal,atriumV6,false,.18)
cylinder("AtriumInnerStone",.025,20,CFrame.new(0,1.135,365),Color3.fromRGB(63,63,65),Enum.Material.Marble,atriumV6,false,0)

local function beamBetween(name,a,b,color,parent,thickness)
 local mid=(a+b)/2
 local len=(b-a).Magnitude
 return neon(name,Vector3.new(thickness or .16,thickness or .16,len),CFrame.lookAt(mid,b),color,parent,.10)
end
local function octagonRing(name,r,y,color)
 local points={}
 for i=1,8 do
  local a=math.rad((i-1)*45)
  points[i]=Vector3.new(math.cos(a)*r,y,365+math.sin(a)*r)
 end
 for i=1,8 do
  beamBetween(name.."_"..i,points[i],points[(i%8)+1],color,atriumV6,.18)
 end
 return points
end
local ringA=octagonRing("ChandelierLower",8.2,12.0,C.champagne)
local ringB=octagonRing("ChandelierUpper",5.8,17.0,C.warm)
for _,idx in ipairs({1,3,5,7}) do
 local p=ringB[idx]
 part("Suspension"..idx,Vector3.new(.10,18,.10),CFrame.new(p.X,26,p.Z),C.metal,Enum.Material.Metal,atriumV6,false,0)
end
for _,idx in ipairs({1,3,5,7}) do
 local node=neon("ChandelierNode"..idx,Vector3.new(.22,.22,.22),CFrame.new(ringA[idx]),C.warm,atriumV6,.05)
 localPoint(node,C.warm,.30,10)
end

-- Corridor lighting: local SurfaceLights only. The screenshot showed the L1 mall as a dark box.
local corridorLights=Instance.new("Model")
corridorLights.Name="MallCorridorLocalLightingV6"
corridorLights.Parent=out
for level,y in ipairs({14.55,28.55}) do
 for _,x in ipairs({-43,43}) do
  for _,z in ipairs({326,365,404}) do
   local fixture=neon("CeilingPanel_L"..level.."_"..x.."_"..z,Vector3.new(7.5,.07,1.3),CFrame.new(x,y,z),C.warm,corridorLights,.68)
   local light=Instance.new("SurfaceLight")
   light.Face=Enum.NormalId.Bottom
   light.Color=C.warm
   light.Brightness=1.15
   light.Range=17
   light.Angle=120
   light.Shadows=false
   light.Parent=fixture
  end
 end
end

mall:SetAttribute("StorefrontAuthority","V6")
mall:SetAttribute("MallMobileVisualAuthority","PREMIUM_GALLERY_V6")
mall:SetAttribute("PremiumSecurityUntouchedMall",true)
out:SetAttribute("RebuiltTenants",rebuilt)
out:SetAttribute("NativeStores",nativeCount)
print(string.format("[BBYA] Mall Premium Gallery v6 online: %d tenant visuals rebuilt; %d native R$ stores integrated; legacy slabs/stage/billboards retired",rebuilt,nativeCount))
