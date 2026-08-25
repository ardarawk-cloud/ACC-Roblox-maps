-- BBYA SOCIAL HUB — MAIN CLUB FORMER-STUDIO PREMIUM v4
-- Refines the single MainClubFinalAuthorityV2 lounge occupying the retired Photo Studio / Salon footprint.
-- Premium club integration only: smoked mirror, acoustic/brass wall rhythm, ceiling track spots,
-- bottle-service consoles and restrained floor detailing. No duplicate sofa/table shell is built.
-- No global Lighting, DJ/stage, VIP, Mall, fishing, monetization, restroom geometry or other venue changes.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",90)
if not root then return end

local finalAuthority=root:WaitForChild("MainClubFinalAuthorityV2",120)
local premium=root:WaitForChild("MainClubPremiumV4",90)
local beauty=root:WaitForChild("MainClubBeautyV5",90)
local front=root:WaitForChild("Floor1FrontPremium",90)
if not finalAuthority or not premium or not beauty or not front then
 warn("[BBYA] Main Club former-studio premium v4: required Main Club passes unavailable")
 return
end

local extension=finalAuthority:WaitForChild("PureClubFrontExtension",45)
if not extension then
 warn("[BBYA] Main Club former-studio premium v4: PureClubFrontExtension unavailable")
 return
end
local bay1=extension:WaitForChild("BuiltInVIPContinuation1",30)
local bay2=extension:WaitForChild("BuiltInVIPContinuation2",30)
if not bay1 or not bay2 then
 warn("[BBYA] Main Club former-studio premium v4: official continuation bays unavailable")
 return
end

-- Runtime idempotency: this pass owns only refinement/detail layered onto FinalAuthorityV2.
local old=root:FindFirstChild("MainClubSocialLoungeV1")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="MainClubSocialLoungeV1"
out:SetAttribute("Pass","MAIN_CLUB_FORMER_STUDIO_PREMIUM_V4")
out:SetAttribute("Authority","MAINCLUB_FINAL_AUTHORITY_V2")
out:SetAttribute("SingleLoungeAuthority",true)
out:SetAttribute("NoSecondLoungeBuild",true)
out:SetAttribute("FormerStudioPremiumUpgrade",true)
out:SetAttribute("FormerStudioClubIntegrated",true)
out:SetAttribute("MobilePerformanceConscious",true)
out:SetAttribute("PortalStackRemoved",true)
out:SetAttribute("GlobalLightingUntouched",true)
out:SetAttribute("DJUntouched",true)
out:SetAttribute("StageUntouched",true)
out:SetAttribute("VIPUntouched",true)
out:SetAttribute("MallUntouched",true)
out:SetAttribute("FishingUntouched",true)
out:SetAttribute("MonetizationUntouched",true)
out:SetAttribute("RestroomGeometryUntouched",true)
out.Parent=root

local C={
 black=Color3.fromRGB(8,8,10),
 ink=Color3.fromRGB(14,13,17),
 charcoal=Color3.fromRGB(27,25,30),
 graphite=Color3.fromRGB(43,40,47),
 fabric=Color3.fromRGB(51,43,52),
 fabric2=Color3.fromRGB(66,53,63),
 wine=Color3.fromRGB(78,45,64),
 brass=Color3.fromRGB(178,132,79),
 champagne=Color3.fromRGB(214,177,119),
 marble=Color3.fromRGB(111,106,114),
 smoked=Color3.fromRGB(76,84,94),
 bottle=Color3.fromRGB(49,70,58),
 warm=Color3.fromRGB(255,213,176),
 pink=Color3.fromRGB(243,53,151),
 cyan=Color3.fromRGB(35,191,216),
 white=Color3.fromRGB(240,237,242),
}

local function block(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.charcoal
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=true
 p.CastShadow=material~=Enum.Material.Neon
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end

local function point(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="FormerStudioPractical"
 l.Color=color
 l.Brightness=brightness
 l.Range=range
 l.Shadows=false
 l.Parent=parent
 return l
end

local function spot(parent,color,brightness,range,angle)
 local l=Instance.new("SpotLight")
 l.Name="FormerStudioDownlight"
 l.Face=Enum.NormalId.Bottom
 l.Color=color
 l.Brightness=brightness
 l.Range=range
 l.Angle=angle or 68
 l.Shadows=false
 l.Parent=parent
 return l
end

local function textPlate(parent,name,size,cf,textValue,color)
 local plate=block(name,size,cf,C.black,Enum.Material.Glass,.08,parent,false)
 local gui=Instance.new("SurfaceGui")
 gui.Face=Enum.NormalId.Front
 gui.LightInfluence=.18
 gui.PixelsPerStud=72
 gui.Parent=plate
 local text=Instance.new("TextLabel")
 text.Size=UDim2.fromScale(1,1)
 text.BackgroundTransparency=1
 text.Text=textValue
 text.TextColor3=color or C.white
 text.Font=Enum.Font.GothamBold
 text.TextScaled=true
 text.Parent=gui
 return plate
end

-- A) SINGLE AUTHORITY ----------------------------------------------------------
-- ClubPurity's old duplicate front extension must never coexist with the final authority.
local purity=root:FindFirstChild("ClubPurityMallStudiosV1")
if purity then
 local duplicate=purity:FindFirstChild("MainClubFrontExtension")
 if duplicate then duplicate:Destroy() end
end

-- B) RETUNE THE TWO OFFICIAL BAYS ---------------------------------------------
-- Keep the original FinalAuthority furniture/layout, but make its finish read as nightclub hospitality.
for i=1,2 do
 local cove=extension:FindFirstChild("LeftCoveLight"..i)
 if cove and cove:IsA("BasePart") then
  cove.Size=Vector3.new(.045,4.65,.12)
  cove.Transparency=.34
  cove.Color=C.warm
 end
end

local function refineOfficialBay(bay,index)
 local bronze=bay:FindFirstChild("BronzeReveal")
 if bronze and bronze:IsA("BasePart") then
  bronze.Size=Vector3.new(.05,5.15,.12)
  bronze.Color=C.brass
  bronze.Material=Enum.Material.Metal
 end
 local panel=bay:FindFirstChild("WallPanel")
 if panel and panel:IsA("BasePart") then
  panel.Color=C.ink
  panel.Material=Enum.Material.Slate
 end
 local plinth=bay:FindFirstChild("Plinth")
 if plinth and plinth:IsA("BasePart") then
  plinth.Color=C.charcoal
  plinth.Material=Enum.Material.Slate
 end
 local divider=bay:FindFirstChild("Divider")
 if divider and divider:IsA("BasePart") then
  divider.Color=C.smoked
  divider.Transparency=.64
  divider.Material=Enum.Material.Glass
 end
 local dividerCap=bay:FindFirstChild("DividerCap")
 if dividerCap and dividerCap:IsA("BasePart") then
  dividerCap.Color=C.brass
 end
 for n=1,3 do
  local seat=bay:FindFirstChild("SeatCushion"..n)
  if seat and seat:IsA("BasePart") then
   seat.Color=(index==2 and n==2) and C.wine or C.fabric
   seat.Material=Enum.Material.Fabric
  end
  local back=bay:FindFirstChild("BackCushion"..n)
  if back and back:IsA("BasePart") then
   back.Color=(index==2 and n==2) and Color3.fromRGB(86,51,70) or C.fabric2
   back.Material=Enum.Material.Fabric
  end
 end
 local table=bay:FindFirstChild("LowTable")
 local lamp=table and table:FindFirstChild("TableLamp")
 if lamp then
  for _,d in ipairs(lamp:GetChildren()) do
   if d:IsA("PointLight") then
    d.Brightness=.33
    d.Range=6.5
    d.Shadows=false
   end
  end
 end
end
refineOfficialBay(bay1,1)
refineOfficialBay(bay2,2)

-- C) FORMER STUDIO PREMIUM DETAIL ---------------------------------------------
-- Details remain shallow/non-colliding so the mobile sightline and circulation stay open.
local upgrade=Instance.new("Model")
upgrade.Name="FormerStudioPremiumV4"
upgrade:SetAttribute("DesignLanguage","DARK_HOSPITALITY_BRASS_SMOKED_MIRROR")
upgrade:SetAttribute("ReusesOfficialBays",true)
upgrade:SetAttribute("NoDuplicateSeating",true)
upgrade.Parent=out

for bayIndex,z in ipairs({-28,-14}) do
 local feature=Instance.new("Model")
 feature.Name="PremiumBayFeature"..bayIndex
 feature.Parent=upgrade

 -- Smoked mirror inset breaks the old flat studio-wall feeling without becoming a bright softbox.
 local mirror=block("SmokedMirrorPanel"..bayIndex,Vector3.new(.055,3.55,5.85),CFrame.new(-47.67,6.28,z),C.smoked,Enum.Material.Glass,.25,feature,false)
 mirror.Reflectance=.16
 block("MirrorTopRail"..bayIndex,Vector3.new(.07,.08,6.05),CFrame.new(-47.61,8.08,z),C.brass,Enum.Material.Metal,0,feature,false)
 block("MirrorBottomRail"..bayIndex,Vector3.new(.07,.08,6.05),CFrame.new(-47.61,4.47,z),C.brass,Enum.Material.Metal,0,feature,false)

 -- Five slim acoustic/brass fins add nightclub texture while staying almost flush to the wall.
 for fin=1,5 do
  local zz=z-3.45+(fin-1)*1.72
  local finColor=(fin==3) and C.brass or C.graphite
  local finMaterial=(fin==3) and Enum.Material.Metal or Enum.Material.Fabric
  block("AcousticFin_"..bayIndex.."_"..fin,Vector3.new(.08,4.25,.15),CFrame.new(-47.55,6.25,zz),finColor,finMaterial,0,feature,false)
 end

 -- Black ceiling track with three restrained warm spots; local fixtures only.
 block("CeilingTrack"..bayIndex,Vector3.new(9.2,.14,.22),CFrame.new(-39.0,12.62,z),C.black,Enum.Material.Metal,0,feature,false)
 for n,x in ipairs({-42.1,-39.0,-35.9}) do
  local head=block("TrackHead_"..bayIndex.."_"..n,Vector3.new(.56,.24,.56),CFrame.new(x,12.47,z),C.graphite,Enum.Material.Metal,0,feature,false)
  local lens=block("TrackLens_"..bayIndex.."_"..n,Vector3.new(.38,.045,.38),CFrame.new(x,12.32,z),C.warm,Enum.Material.Glass,.36,feature,false)
  lens.CastShadow=false
  spot(lens,C.warm,.34,11.5,66)
 end

 -- Compact bottle-service console hugs the open edge; decorative and non-blocking.
 local console=Instance.new("Model")
 console.Name="ServiceConsole"..bayIndex
 console.Parent=feature
 block("ConsoleBody",Vector3.new(1.18,1.25,4.8),CFrame.new(-29.25,1.72,z),C.charcoal,Enum.Material.Slate,0,console,false)
 local top=block("ConsoleTop",Vector3.new(1.34,.14,5.05),CFrame.new(-29.25,2.42,z),C.marble,Enum.Material.Marble,0,console,false)
 top.Reflectance=.06
 block("ConsoleBrassLine",Vector3.new(.045,.72,4.3),CFrame.new(-28.64,1.80,z),C.brass,Enum.Material.Metal,0,console,false)
 for n,dz in ipairs({-1.35,0,1.35}) do
  local bottle=block("Bottle_"..n,Vector3.new(.30,.88,.30),CFrame.new(-29.22,2.93,z+dz),n==2 and C.bottle or Color3.fromRGB(71,56,49),Enum.Material.Glass,.12,console,false)
  local cap=block("BottleCap_"..n,Vector3.new(.18,.15,.18),CFrame.new(-29.22,3.44,z+dz),C.brass,Enum.Material.Metal,0,console,false)
  cap.CastShadow=false
  if n==2 then point(bottle,C.warm,.08,3.2) end
 end
end

-- Thin floor datum frames the former-studio lounge as one club zone, not two leftover rooms.
for i,z in ipairs({-35.0,-7.3}) do
 block("LoungeCrossInlay"..i,Vector3.new(22.0,.035,.055),CFrame.new(-39.0,1.135,z),C.champagne,Enum.Material.Metal,0,upgrade,false)
end
block("LoungeEdgeInlay",Vector3.new(.05,.035,27.6),CFrame.new(-26.72,1.135,-21.0),C.champagne,Enum.Material.Metal,0,upgrade,false)

-- Low practical markers help depth without flooding the room.
for i,z in ipairs({-31.3,-24.7,-17.3,-10.7}) do
 local marker=block("LowPractical"..i,Vector3.new(.06,.34,.42),CFrame.new(-48.82,1.58,z),C.warm,Enum.Material.Glass,.48,upgrade,false)
 marker.CastShadow=false
 point(marker,C.warm,.11,4.4)
end

textPlate(upgrade,"ClubLoungeMark",Vector3.new(.08,1.05,6.25),CFrame.new(-49.38,8.25,-21.0)*CFrame.Angles(0,math.rad(90),0),"BBYA  CLUB  LOUNGE",C.champagne)

-- D) PORTAL STACK CLEANUP ------------------------------------------------------
-- Keep Floor1FrontPremium.EntranceToClubTransition as the single structural portal.
local entranceReveal=premium:FindFirstChild("MainClubEntranceReveal")
if entranceReveal then entranceReveal:Destroy() end

local facade=beauty:FindFirstChild("MobilePremiumFacadeV7")
if facade then facade:Destroy() end
local collars=beauty:FindFirstChild("SlimPillarFinishingV6")
if collars then collars:Destroy() end

local transition=front:FindFirstChild("EntranceToClubTransition")
if transition then
 local left=transition:FindFirstChild("PortalL")
 local right=transition:FindFirstChild("PortalR")
 local top=transition:FindFirstChild("PortalTop")
 if left and left:IsA("BasePart") then left.Size=Vector3.new(.62,10.4,.86);left.Color=C.black;left.Material=Enum.Material.Metal end
 if right and right:IsA("BasePart") then right.Size=Vector3.new(.62,10.4,.86);right.Color=C.black;right.Material=Enum.Material.Metal end
 if top and top:IsA("BasePart") then top.Size=Vector3.new(27.6,.56,.86);top.Color=C.black;top.Material=Enum.Material.Metal end
 local accentL=transition:FindFirstChild("PortalAccentL")
 local accentR=transition:FindFirstChild("PortalAccentR")
 if accentL and accentL:IsA("BasePart") then accentL.Size=Vector3.new(.05,7.25,.05);accentL.Transparency=.10 end
 if accentR and accentR:IsA("BasePart") then accentR.Size=Vector3.new(.05,7.25,.05);accentR.Transparency=.10 end
end

textPlate(out,"MainClubPortalMark",Vector3.new(8.8,.82,.055),CFrame.new(0,10.95,-5.48),"BBYA  MAIN CLUB",C.champagne)

print("[BBYA] Main Club former-studio premium v4 online: official lounge upgraded with smoked mirror, acoustic/brass wall rhythm, track spots and bottle-service consoles; frozen systems untouched")
