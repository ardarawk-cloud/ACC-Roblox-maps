-- BBYA SOCIAL HUB — MALL NATIVE ROBUX COMMERCE v1
-- Turns selected Mall tenants into native Roblox catalog storefronts.
-- Checkout is ALWAYS handled by Roblox MarketplaceService on the client.
-- No BBYA coins, fake currency, manual Robux transfer or off-platform payment.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",90)
if not root then return end
local mall=root:WaitForChild("BBYAMall",120)
if not mall then return end

-- Wait until base tenant shells are created.
mall:WaitForChild("Tenant_luma",60)
mall:WaitForChild("Tenant_stride",60)
task.wait(1)

local old=mall:FindFirstChild("MallRobuxCommerceV1")
if old then old:Destroy() end
local runtime=Instance.new("Model")
runtime.Name="MallRobuxCommerceV1"
runtime:SetAttribute("Pass","MALL_NATIVE_ROBUX_COMMERCE_V1")
runtime:SetAttribute("NativeRobloxCheckout",true)
runtime:SetAttribute("CustomCurrency",false)
runtime:SetAttribute("CatalogMarketplace",true)
runtime:SetAttribute("OffPlatformPayment",false)
runtime.Parent=mall

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"
remotes.Parent=ReplicatedStorage
local remote=remotes:FindFirstChild("MallRobuxCommerce") or Instance.new("RemoteEvent")
remote.Name="MallRobuxCommerce"
remote.Parent=remotes

local STORES={
 {tenant="Tenant_luma",key="FASHION",title="LUMA FASHION",subtitle="ROBUX FASHION MARKET",accent=Color3.fromRGB(235,56,147)},
 {tenant="Tenant_stride",key="SHOES",title="STRIDE SNEAKERS",subtitle="ROBUX SHOE MARKET",accent=Color3.fromRGB(229,125,62)},
 {tenant="Tenant_muse",key="BEAUTY",title="MUSE BEAUTY",subtitle="ROBUX BEAUTY MARKET",accent=Color3.fromRGB(137,82,220)},
 {tenant="Tenant_north",key="STREET",title="NORTH LABEL",subtitle="ROBUX STREET MARKET",accent=Color3.fromRGB(62,116,217)},
}

local function addBadge(parent,textValue,accent)
 local badge=Instance.new("BillboardGui")
 badge.Name="NativeRobuxBadge"
 badge.Size=UDim2.fromOffset(210,44)
 badge.StudsOffset=Vector3.new(0,5.7,0)
 badge.AlwaysOnTop=false
 badge.MaxDistance=65
 badge.LightInfluence=.15
 badge.Parent=parent

 local frame=Instance.new("Frame")
 frame.Size=UDim2.fromScale(1,1)
 frame.BackgroundColor3=Color3.fromRGB(12,13,16)
 frame.BackgroundTransparency=.08
 frame.BorderSizePixel=0
 frame.Parent=badge
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,10);corner.Parent=frame
 local stroke=Instance.new("UIStroke");stroke.Color=accent;stroke.Thickness=1;stroke.Transparency=.25;stroke.Parent=frame

 local label=Instance.new("TextLabel")
 label.Size=UDim2.fromScale(1,1)
 label.BackgroundTransparency=1
 label.Text="R$  "..textValue
 label.TextColor3=Color3.fromRGB(245,243,239)
 label.Font=Enum.Font.GothamBold
 label.TextSize=15
 label.Parent=frame
end

local activated=0
for _,store in ipairs(STORES) do
 local unit=mall:FindFirstChild(store.tenant)
 if unit and unit:IsA("Model") then
  unit:SetAttribute("NativeRobuxShop",true)
  unit:SetAttribute("CommerceCategory",store.key)
  unit:SetAttribute("Checkout","ROBLOX_MARKETPLACE")

  local door=unit:FindFirstChild("StoreDoor") or unit:FindFirstChild("Interact") or unit:FindFirstChildWhichIsA("BasePart")
  if door and door:IsA("BasePart") then
   -- Remove only a prior instance created by this system.
   local prior=door:FindFirstChild("NativeRobuxShopPrompt")
   if prior then prior:Destroy() end

   local prompt=Instance.new("ProximityPrompt")
   prompt.Name="NativeRobuxShopPrompt"
   prompt.ActionText="SHOP WITH ROBUX"
   prompt.ObjectText=store.title
   prompt.KeyboardKeyCode=Enum.KeyCode.E
   prompt.GamepadKeyCode=Enum.KeyCode.ButtonX
   prompt.MaxActivationDistance=12
   prompt.HoldDuration=.05
   prompt.RequiresLineOfSight=false
   prompt.Parent=door

   addBadge(door,store.subtitle,store.accent)

   prompt.Triggered:Connect(function(player)
    remote:FireClient(player,"open",{
     key=store.key,
     title=store.title,
     subtitle=store.subtitle,
    })
   end)
   activated+=1
  end
 end
end

runtime:SetAttribute("ActiveStores",activated)
print(string.format("[BBYA] Mall Native Robux Commerce v1 online: %d catalog shops use Roblox-native checkout; no custom currency",activated))

-- =============================================================================
-- MALL PREMIUM ATMOSPHERE v9
-- Narrow visual/hospitality pass layered on top of Gallery v6 + Visual Cleanup v8.
-- Kept in this already-mapped Mall server entry so canonical Rojo project structure is unchanged.
-- Scope: Mall only. No global Lighting, audio, fishing, economy, VIP or Night Market changes.
-- =============================================================================

local galleryAuthority=mall:WaitForChild("MallPremiumGalleryV6",120)
local live=mall:WaitForChild("MallLiveUpgradeV2",120)
if galleryAuthority and live then
 task.wait(.6)

 local oldV9=mall:FindFirstChild("MallPremiumAtmosphereV9")
 if oldV9 then oldV9:Destroy() end

 local out=Instance.new("Model")
 out.Name="MallPremiumAtmosphereV9"
 out:SetAttribute("Pass","MALL_PREMIUM_ATMOSPHERE_V9")
 out:SetAttribute("LegacyAtriumSeatsRemoved",true)
 out:SetAttribute("LegacyFrontPlantersRemoved",true)
 out:SetAttribute("RetailThresholdWarmth",true)
 out:SetAttribute("AtriumHospitalityLounge",true)
 out:SetAttribute("ArrivalLightingRefined",true)
 out:SetAttribute("GlobalLightingUntouched",true)
 out:SetAttribute("AudioUntouched",true)
 out:SetAttribute("FishingUntouched",true)
 out.Parent=mall

 local C={
  ink=Color3.fromRGB(35,36,39),graphite=Color3.fromRGB(57,57,59),metal=Color3.fromRGB(86,88,92),
  stone=Color3.fromRGB(116,112,106),brass=Color3.fromRGB(194,153,91),champagne=Color3.fromRGB(222,187,127),
  warm=Color3.fromRGB(255,226,198),fabric=Color3.fromRGB(53,50,52),leaf=Color3.fromRGB(61,91,66),
  soil=Color3.fromRGB(59,47,39),glass=Color3.fromRGB(117,143,154),
 }

 local function v9part(name,size,cf,color,material,collide,parent,transparency)
  local p=Instance.new("Part")
  p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
  p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false;p.Transparency=transparency or 0
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p.CastShadow=p.Material~=Enum.Material.Neon and p.Transparency<.9
  p.Parent=parent or out
  return p
 end

 local function v9neon(name,size,cf,color,parent,transparency)
  local p=v9part(name,size,cf,color or C.champagne,Enum.Material.Neon,false,parent,transparency or 0)
  p.CastShadow=false
  return p
 end

 local function v9cylinder(name,height,diameter,cf,color,material,collide,parent,transparency)
  local p=v9part(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,collide,parent,transparency)
  p.Shape=Enum.PartType.Cylinder
  return p
 end

 local function v9ball(name,size,cf,color,parent)
  local p=v9part(name,size,cf,color,Enum.Material.SmoothPlastic,false,parent,0)
  p.Shape=Enum.PartType.Ball
  return p
 end

 local function v9downLight(parent,brightness,range)
  local light=Instance.new("SurfaceLight")
  light.Name="MallV9LocalLight";light.Face=Enum.NormalId.Bottom;light.Color=C.warm
  light.Brightness=brightness;light.Range=range;light.Angle=105;light.Shadows=false;light.Parent=parent
  return light
 end

 -- Retire primitive first-generation dressing that survived later authorities.
 local atriumExperience=mall:FindFirstChild("AtriumExperience")
 if atriumExperience then
  for _,child in ipairs(atriumExperience:GetChildren()) do
   if child.Name=="AtriumSeat" then child:Destroy() end
  end
 end
 for _,child in ipairs(mall:GetChildren()) do
  if child.Name:match("^FrontPlanter") then child:Destroy() end
 end

 -- Refine arrival identity without replacing working text GUIs or door logic.
 for _,name in ipairs({"MallHeroSign","MallSubSign"}) do
  local p=mall:FindFirstChild(name)
  if p and p:IsA("BasePart") then
   p.Color=name=="MallHeroSign" and C.ink or C.graphite
   p.Material=Enum.Material.Metal;p.Reflectance=.02;p.CastShadow=false
  end
 end

 local connector=mall:FindFirstChild("FunkotMallConnector")
 if connector then
  local sign=connector:FindFirstChild("ConnectorSign")
  if sign and sign:IsA("BasePart") then sign.Color=C.graphite;sign.Material=Enum.Material.Metal;sign.Reflectance=.01 end
 end

 local doors=mall:FindFirstChild("AutomaticEntrance")
 if doors then
  for _,name in ipairs({"EntryDoorL","EntryDoorR"}) do
   local door=doors:FindFirstChild(name)
   if door and door:IsA("BasePart") then
    door.Color=C.glass;door.Material=Enum.Material.Glass;door.Transparency=.34;door.Reflectance=.10;door.CastShadow=false
   end
  end
 end

 local arrival=Instance.new("Model");arrival.Name="PremiumArrivalAtmosphereV9";arrival.Parent=out
 v9neon("ArrivalFloorReveal",Vector3.new(34,.045,.16),CFrame.new(0,1.11,300.5),C.champagne,arrival,.28)
 for _,x in ipairs({-10,10}) do
  for _,z in ipairs({307,321}) do
   local fixture=v9neon("ArrivalCeiling_"..x.."_"..z,Vector3.new(6.2,.055,.72),CFrame.new(x,14.42,z),C.warm,arrival,.78)
   v9downLight(fixture,.26,9)
  end
 end

 -- Warm threshold lines make every rebuilt tenant read as a deliberate open storefront.
 local retail=Instance.new("Model");retail.Name="RetailThresholdWarmthV9";retail.Parent=out
 local thresholdCount=0
 for _,unit in ipairs(mall:GetChildren()) do
  if unit:IsA("Model") and unit.Name:match("^Tenant_") then
   local gallery=unit:FindFirstChild("PremiumRetailGalleryV6")
   local floor=unit:FindFirstChild("Floor")
   if gallery and floor and floor:IsA("BasePart") then
    local cx=floor.Position.X;local z=floor.Position.Z;local width=floor.Size.X;local depth=floor.Size.Z
    local inward=cx<0 and 1 or -1
    local frontX=cx+inward*(width/2-.55)
    local accent=C.champagne
    local underline=gallery:FindFirstChild("IdentityUnderline")
    if underline and underline:IsA("BasePart") then accent=underline.Color end
    v9neon("Threshold_"..unit.Name,Vector3.new(.07,.045,math.max(8,depth-4)),CFrame.new(frontX-inward*.16,floor.Position.Y+.54,z),accent,retail,.30)
    thresholdCount+=1
   end
  end
 end

 -- Two compact social lounge islands replace the primitive standalone atrium seats.
 local lounge=Instance.new("Model");lounge.Name="AtriumHospitalityLoungeV9";lounge.Parent=out
 local function loungeSeat(name,x,z,yaw)
  local m=Instance.new("Model");m.Name=name;m.Parent=lounge
  local cf=CFrame.new(x,1.65,z)*CFrame.Angles(0,math.rad(yaw),0)
  local seat=Instance.new("Seat")
  seat.Name="SocialSeat";seat.Size=Vector3.new(7,.64,2.15);seat.CFrame=cf;seat.Color=C.fabric;seat.Material=Enum.Material.Fabric
  seat.Anchored=true;seat.CanCollide=true;seat.CanTouch=true;seat.TopSurface=Enum.SurfaceType.Smooth;seat.BottomSurface=Enum.SurfaceType.Smooth;seat.Parent=m
  v9part("Back",Vector3.new(7,1.9,.38),cf*CFrame.new(0,1.12,.98)*CFrame.Angles(math.rad(-7),0,0),C.fabric,Enum.Material.Fabric,true,m,0)
  for _,xo in ipairs({-3,3}) do v9part("Leg",Vector3.new(.28,.72,.28),cf*CFrame.new(xo,-.55,0),C.brass,Enum.Material.Metal,true,m,0) end
 end
 local function loungePlanter(name,x,z)
  local m=Instance.new("Model");m.Name=name;m.Parent=lounge
  v9cylinder("Planter",1.25,3.1,CFrame.new(x,1.75,z),C.graphite,Enum.Material.Concrete,true,m,0)
  v9cylinder("Soil",.16,2.55,CFrame.new(x,2.42,z),C.soil,Enum.Material.Ground,false,m,0)
  for i=1,4 do
   local a=math.rad((i-1)*90+45);local px=x+math.cos(a)*.54;local pz=z+math.sin(a)*.54
   v9part("Stem"..i,Vector3.new(.12,1.5,.12),CFrame.new(px,3.25,pz),C.stone,Enum.Material.Wood,false,m,0)
   v9ball("Leaf"..i,Vector3.new(1.05,1.45,.88),CFrame.new(px,4.15+(i%2)*.18,pz),C.leaf,m)
  end
 end

 loungeSeat("WestLounge",-23.3,365,-90);loungePlanter("WestPlanter",-28,365)
 loungeSeat("EastLounge",23.3,365,90);loungePlanter("EastPlanter",28,365)
 for _,x in ipairs({-20.6,20.6}) do
  for _,z in ipairs({359,371}) do
   v9cylinder("SideTable",.16,1.55,CFrame.new(x,2,z),C.brass,Enum.Material.Metal,true,lounge,0)
   v9cylinder("SideTableBase",1.05,.34,CFrame.new(x,1.42,z),C.metal,Enum.Material.Metal,true,lounge,0)
  end
 end

 -- Restrained metallic caps make the upper atrium floors read more clearly from mobile.
 local rails=Instance.new("Model");rails.Name="AtriumRailCapsV9";rails.Parent=out
 for level=2,4 do
  local y=({[2]=19.55,[3]=33.55,[4]=47.55})[level]
  for _,x in ipairs({-30.15,30.15}) do
   v9part("RailCapX_L"..level,Vector3.new(.12,.12,53.4),CFrame.new(x,y,365),C.brass,Enum.Material.Metal,false,rails,.08)
  end
  for _,z in ipairs({338,392}) do
   v9part("RailCapZ_L"..level,Vector3.new(59.7,.12,.12),CFrame.new(0,y,z),C.brass,Enum.Material.Metal,false,rails,.08)
  end
 end

 mall:SetAttribute("MallPremiumAtmosphere","V9")
 mall:SetAttribute("MallFirstImpression","PREMIUM_HOSPITALITY_V9")
 mall:SetAttribute("MallRetailThresholds",thresholdCount)
 out:SetAttribute("RetailThresholdCount",thresholdCount)
 print(string.format("[BBYA] Mall Premium Atmosphere v9 online: %d tenant thresholds, refined arrival, social atrium lounge; global Lighting/audio/fishing untouched",thresholdCount))
else
 warn("[BBYA] Mall Premium Atmosphere v9 skipped: Gallery v6 / Visual Cleanup v8 unavailable")
end
