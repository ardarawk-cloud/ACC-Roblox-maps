-- BBYA SOCIAL HUB — MAIN CLUB AUTHORITY CLEANUP v3
-- Owner screenshot correction after live v406.
-- IMPORTANT: this pass no longer builds a second lounge.
-- It waits for MainClubFinalAuthorityV2, refines that single official former-studio footprint,
-- and removes redundant entrance portal layers so mobile view reads cleanly.
-- No global Lighting, audio, DJ, VIP, Mall, fishing, monetization, restroom or stage changes.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",90)
if not root then return end

local finalAuthority=root:WaitForChild("MainClubFinalAuthorityV2",120)
local premium=root:WaitForChild("MainClubPremiumV4",90)
local beauty=root:WaitForChild("MainClubBeautyV5",90)
local front=root:WaitForChild("Floor1FrontPremium",90)
if not finalAuthority or not premium or not beauty or not front then
 warn("[BBYA] Main Club authority cleanup v3: required passes unavailable")
 return
end

local extension=finalAuthority:WaitForChild("PureClubFrontExtension",45)
if not extension then
 warn("[BBYA] Main Club authority cleanup v3: PureClubFrontExtension unavailable")
 return
end
local bay1=extension:WaitForChild("BuiltInVIPContinuation1",30)
local bay2=extension:WaitForChild("BuiltInVIPContinuation2",30)
if not bay1 or not bay2 then
 warn("[BBYA] Main Club authority cleanup v3: official continuation bays unavailable")
 return
end

-- Remove any prior runtime instance of this pass before applying the corrected authority model.
local old=root:FindFirstChild("MainClubSocialLoungeV1")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="MainClubSocialLoungeV1"
out:SetAttribute("Pass","MAIN_CLUB_AUTHORITY_CLEANUP_V3")
out:SetAttribute("Authority","MAINCLUB_FINAL_AUTHORITY_V2")
out:SetAttribute("SingleLoungeAuthority",true)
out:SetAttribute("NoSecondLoungeBuild",true)
out:SetAttribute("FormerStudioVisualCleanup",true)
out:SetAttribute("PortalStackRemoved",true)
out:SetAttribute("MobileScreenshotCorrection",true)
out:SetAttribute("GlobalLightingUntouched",true)
out:SetAttribute("AudioUntouched",true)
out:SetAttribute("DJUntouched",true)
out:SetAttribute("VIPUntouched",true)
out:SetAttribute("MallUntouched",true)
out:SetAttribute("FishingUntouched",true)
out:SetAttribute("MonetizationUntouched",true)
out:SetAttribute("RestroomUntouched",true)
out:SetAttribute("StageUntouched",true)
out.Parent=root

local C={
 black=Color3.fromRGB(8,8,10),
 ink=Color3.fromRGB(14,13,17),
 charcoal=Color3.fromRGB(28,25,31),
 fabric=Color3.fromRGB(55,47,57),
 fabric2=Color3.fromRGB(67,54,64),
 plum=Color3.fromRGB(79,52,72),
 brass=Color3.fromRGB(184,139,84),
 champagne=Color3.fromRGB(214,177,119),
 warm=Color3.fromRGB(255,216,178),
 pink=Color3.fromRGB(243,53,151),
 cyan=Color3.fromRGB(35,191,216),
 white=Color3.fromRGB(240,237,242),
}

local function block(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.charcoal;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true
 p.CastShadow=material~=Enum.Material.Neon;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end

local function surface(parent,color,brightness,range,angle)
 local l=Instance.new("SurfaceLight")
 l.Name="FormerStudioLocalWash";l.Face=Enum.NormalId.Bottom;l.Color=color;l.Brightness=brightness;l.Range=range;l.Angle=angle or 105;l.Shadows=false;l.Parent=parent
 return l
end

local function textPlate(parent,name,size,cf,textValue,color)
 local plate=block(name,size,cf,C.black,Enum.Material.Glass,.08,parent,false)
 local gui=Instance.new("SurfaceGui")
 gui.Face=Enum.NormalId.Front;gui.LightInfluence=.18;gui.PixelsPerStud=72;gui.Parent=plate
 local text=Instance.new("TextLabel")
 text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text=textValue;text.TextColor3=color or C.white
 text.Font=Enum.Font.GothamBold;text.TextScaled=true;text.Parent=gui
 return plate
end

-- -----------------------------------------------------------------------------
-- A) SINGLE AUTHORITY: CLUB PURITY MUST NOT OWN A SECOND FLOOR-1 LOUNGE
-- 67-photo-studio-lighting.server.lua is MainClubFinalAuthorityV2 and already replaces
-- the old ClubPurity MainClubFrontExtension. Belt-and-suspenders cleanup prevents a
-- race from leaving both geometries alive during boot.
-- -----------------------------------------------------------------------------
local purity=root:FindFirstChild("ClubPurityMallStudiosV1")
if purity then
 local duplicate=purity:FindFirstChild("MainClubFrontExtension")
 if duplicate then duplicate:Destroy() end
end

-- -----------------------------------------------------------------------------
-- B) FORMER PHOTO/SALON FOOTPRINT: REMOVE THE "STUDIO PANEL" LOOK
-- The final-authority coves/reveals were broad planes (6.9 / 7.7 studs along Z),
-- which read from a phone angle as bright softboxes / orange studio slabs.
-- Convert them into narrow architectural lines and brighten the existing official
-- banquettes with local light only. No new sofa/table geometry is created here.
-- -----------------------------------------------------------------------------
for i=1,2 do
 local cove=extension:FindFirstChild("LeftCoveLight"..i)
 if cove and cove:IsA("BasePart") then
  cove.Size=Vector3.new(.045,4.65,.12)
  cove.Transparency=.28
 end
end

local function refineOfficialBay(bay,index)
 local bronze=bay:FindFirstChild("BronzeReveal")
 if bronze and bronze:IsA("BasePart") then
  bronze.Size=Vector3.new(.05,5.15,.12)
  bronze.Color=C.brass
 end
 local panel=bay:FindFirstChild("WallPanel")
 if panel and panel:IsA("BasePart") then
  panel.Color=C.ink
  panel.Material=Enum.Material.Slate
 end
 for n=1,3 do
  local seat=bay:FindFirstChild("SeatCushion"..n)
  if seat and seat:IsA("BasePart") then
   seat.Color=(index==2 and n==2) and C.plum or C.fabric
  end
  local back=bay:FindFirstChild("BackCushion"..n)
  if back and back:IsA("BasePart") then
   back.Color=(index==2 and n==2) and C.plum or C.fabric2
  end
 end
 local table=bay:FindFirstChild("LowTable")
 local lamp=table and table:FindFirstChild("TableLamp")
 if lamp then
  for _,d in ipairs(lamp:GetChildren()) do
   if d:IsA("PointLight") then
    d.Brightness=.40
    d.Range=7.2
    d.Shadows=false
   end
  end
 end
end
refineOfficialBay(bay1,1)
refineOfficialBay(bay2,2)

local loungeLight=Instance.new("Model")
loungeLight.Name="FormerStudioHospitalityLightV3";loungeLight.Parent=out
for i,z in ipairs({-28,-14}) do
 block("CeilingFixture"..i,Vector3.new(4.8,.08,1.05),CFrame.new(-39.0,12.70,z),C.black,Enum.Material.Metal,0,loungeLight,false)
 local diffuser=block("CeilingDiffuser"..i,Vector3.new(4.0,.035,.48),CFrame.new(-39.0,12.64,z),C.warm,Enum.Material.Neon,.63,loungeLight,false)
 diffuser.CastShadow=false
 surface(diffuser,C.warm,.38,10.5,105)
end

textPlate(out,"SocialLoungeMark",Vector3.new(.08,1.18,6.4),CFrame.new(-49.38,8.10,-21.0)*CFrame.Angles(0,math.rad(90),0),"BBYA  SOCIAL  LOUNGE",C.champagne)
block("LoungeEdgeInlay",Vector3.new(.05,.035,27.0),CFrame.new(-26.72,1.135,-21.0),C.champagne,Enum.Material.Metal,0,out,false)

-- -----------------------------------------------------------------------------
-- C) PORTAL STACK CLEANUP
-- Keep Floor1FrontPremium.EntranceToClubTransition as the ONE structural portal.
-- Remove PremiumV4 entrance reveal + BeautyV7 facade/collars, which were layered
-- only inches apart and produced the stacked frames visible in the owner's phone shot.
-- -----------------------------------------------------------------------------
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

print("[BBYA] Main Club authority cleanup v3 online: single FinalAuthority lounge retained; former-studio light slabs narrowed; duplicate portal layers removed; frozen systems untouched")
