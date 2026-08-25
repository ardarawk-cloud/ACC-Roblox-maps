local W=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")
local root=W:WaitForChild("BBYA_ZERO_BUILD")
-- Runtime QC: keep decorative parts non-collidable, validate critical zones, and avoid loose physics.
local critical={"Entrance","Floor1Core","UpperLevels","BasementBOH"}
for _,name in ipairs(critical) do if not root:FindFirstChild(name) then warn("[BBYA QC] Missing critical model: "..name) end end
for _,d in ipairs(root:GetDescendants()) do
 if d:IsA("BasePart") then
  d.Anchored=true
  local n=d.Name:lower()
  if n:find("neon") or n:find("glow") or n:find("accent") or n:find("rail") or n:find("light") or n:find("trim") or n:find("sightline") then d.CanCollide=false end
 end
end
-- Invisible fall protection below public footprint; does not alter visible architecture.
local safety=root:FindFirstChild("SafetyFloor")
if safety then safety:Destroy() end
safety=Instance.new("Part");safety.Name="SafetyFloor";safety.Anchored=true;safety.CanCollide=true;safety.Transparency=1;safety.Size=Vector3.new(150,1,120);safety.CFrame=CFrame.new(0,-18,0);safety.Parent=root
print("[BBYA QC] runtime validation complete")

-- -----------------------------------------------------------------------------
-- REAL WITA WORLD CLOCK v1
-- Synchronizes only Lighting.ClockTime to Bali/WITA real time (UTC+8).
-- Existing venue brightness, ambience, local lights and post-processing stay untouched.
-- This intentionally overrides the old fixed 21.2 ClockTime from Venue Lighting v3.
-- -----------------------------------------------------------------------------
local WITA_OFFSET_SECONDS=8*60*60
local function syncWitaClock()
 local shifted=os.time()+WITA_OFFSET_SECONDS
 local t=os.date("!*t",shifted)
 local clock=t.hour+(t.min/60)+(t.sec/3600)
 Lighting.ClockTime=clock
 Lighting:SetAttribute("BBYARealTimeClock","WITA_UTC_PLUS_8_V1")
 Lighting:SetAttribute("BBYAWitaHour",t.hour)
 Lighting:SetAttribute("BBYAWitaMinute",t.min)
 return clock,t
end

task.spawn(function()
 -- Let one-shot venue lighting initialization finish first, then become the clock authority.
 task.wait(2)
 while true do
  local clock,t=syncWitaClock()
  if not Lighting:GetAttribute("BBYARealTimeClockAnnounced") then
   Lighting:SetAttribute("BBYARealTimeClockAnnounced",true)
   print(string.format("[BBYA] Real WITA clock v1 online: %02d:%02d WITA / ClockTime %.2f",t.hour,t.min,clock))
  end
  task.wait(15)
 end
end)

-- -----------------------------------------------------------------------------
-- FUNKOT DISKOTIK PREMIUM v2
-- Late, Funkot-only visual/interactivity pass. The v1 builder remains the authority
-- for shell, existing truss/moving heads/lasers and the approved Funkot audio feed.
-- This pass adds the missing real-diskotik layer without touching audio/playlists.
-- -----------------------------------------------------------------------------
task.spawn(function()
 local club=root:WaitForChild("FunkotClub",60)
 if not club then return end
 local deadline=os.clock()+45
 repeat
  if club:GetAttribute("Pass")=="FUNKOT_CLUB_V1"
   and club:FindFirstChild("CeilingTruss")
   and club:FindFirstChild("MovingHeads")
   and club:FindFirstChild("LaserRig") then break end
  task.wait(.2)
 until os.clock()>=deadline
 if club:GetAttribute("Pass")~="FUNKOT_CLUB_V1" then
  warn("[BBYA] Funkot Diskotik v2 skipped: Funkot v1 not ready")
  return
 end
 task.wait(.75)

 local old=club:FindFirstChild("FunkotDiskotikPremiumV2")
 if old then old:Destroy() end
 local out=Instance.new("Model")
 out.Name="FunkotDiskotikPremiumV2"
 out.Parent=club
 out:SetAttribute("FunkotOnly",true)
 out:SetAttribute("AudioUntouched",true)
 out:SetAttribute("GlobalLightingUntouched",true)
 out:SetAttribute("Profile","INDONESIAN_DISKOTIK_PREMIUM_V2")
 out:SetAttribute("DaylightShieldedEntrance",true)
 out:SetAttribute("NativeSeating",true)

 local C={
  black=Color3.fromRGB(8,9,12),
  ink=Color3.fromRGB(16,17,21),
  charcoal=Color3.fromRGB(28,29,34),
  graphite=Color3.fromRGB(48,50,56),
  silver=Color3.fromRGB(105,110,118),
  velvet=Color3.fromRGB(72,24,42),
  fabric=Color3.fromRGB(67,62,66),
  wood=Color3.fromRGB(76,53,38),
  brass=Color3.fromRGB(161,122,68),
  pink=Color3.fromRGB(242,42,148),
  cyan=Color3.fromRGB(20,188,220),
  violet=Color3.fromRGB(132,72,230),
  amber=Color3.fromRGB(255,183,90),
  warm=Color3.fromRGB(255,220,181),
  white=Color3.fromRGB(228,228,224),
  glass=Color3.fromRGB(68,76,88),
 }

 local function part(name,size,cf,color,material,collide,parent,transparency)
  local p=Instance.new("Part")
  p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.charcoal
  p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0
  p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
  p.CastShadow=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent or out
  return p
 end
 local function cylinder(name,height,diameter,cf,color,material,parent,collide,transparency)
  local p=part(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,collide,parent,transparency)
  p.Shape=Enum.PartType.Cylinder
  return p
 end
 local function localLight(parent,color,brightness,range)
  local l=Instance.new("PointLight")
  l.Name="DiskotikLocalLight";l.Color=color or C.warm;l.Brightness=brightness or .35;l.Range=range or 10;l.Shadows=false;l.Parent=parent
  return l
 end
 local function downLight(parent,color,brightness,range,angle)
  local l=Instance.new("SurfaceLight")
  l.Name="DiskotikDownlight";l.Face=Enum.NormalId.Bottom;l.Color=color or C.warm;l.Brightness=brightness or .35;l.Range=range or 10;l.Angle=angle or 115;l.Shadows=false;l.Parent=parent
  return l
 end
 local touchLocks={}
 local function nativeSeat(name,pos,target,size,parent)
  local s=Instance.new("Seat")
  s.Name=name;s.Size=size or Vector3.new(2.1,.20,2.0);s.CFrame=CFrame.lookAt(pos,target)
  s.Transparency=1;s.Anchored=true;s.CanCollide=false;s.CanTouch=true;s.CanQuery=false;s.CastShadow=false;s.Disabled=false;s.Parent=parent or out
  s.Touched:Connect(function(hit)
   local ch=hit and hit:FindFirstAncestorOfClass("Model")
   local hum=ch and ch:FindFirstChildOfClass("Humanoid")
   if not hum or hum.Health<=0 or hum.SeatPart then return end
   local now=os.clock();if now-(touchLocks[hum] or 0)<.65 then return end
   touchLocks[hum]=now;s:Sit(hum)
  end)
  return s
 end

 -- 1) DARK ARRIVAL VESTIBULE ---------------------------------------------------
 -- The original 24-stud opening let daytime spill straight into the hall. A short
 -- black vestibule keeps the real-WITA exterior while the Funkot interior stays club-dark.
 local entry=Instance.new("Model");entry.Name="DiskotikArrivalV2";entry.Parent=out
 part("EntryCeiling",Vector3.new(20,.55,15),CFrame.new(0,9.4,169),C.black,Enum.Material.Metal,true,entry)
 part("EntryWallL",Vector3.new(1.2,8.5,15),CFrame.new(-9.4,5.2,169),C.ink,Enum.Material.Concrete,true,entry)
 part("EntryWallR",Vector3.new(1.2,8.5,15),CFrame.new(9.4,5.2,169),C.ink,Enum.Material.Concrete,true,entry)
 part("EntryCurtainL",Vector3.new(5.0,8.2,.26),CFrame.new(-6.7,5.1,175.7),C.black,Enum.Material.Fabric,false,entry)
 part("EntryCurtainR",Vector3.new(5.0,8.2,.26),CFrame.new(6.7,5.1,175.7),C.black,Enum.Material.Fabric,false,entry)
 for _,x in ipairs({-8.4,8.4}) do
  local lamp=part("EntrySconce"..x,Vector3.new(.22,3.6,.32),CFrame.new(x,5.5,168),C.amber,Enum.Material.Glass,false,entry,.12)
  localLight(lamp,C.warm,.28,8)
 end
 part("EntryHeader",Vector3.new(14,1.05,.38),CFrame.new(0,8.0,175.45),C.graphite,Enum.Material.Metal,false,entry)
 for _,x in ipairs({-5.2,5.2}) do
  cylinder("QueuePost"..x,2.2,.34,CFrame.new(x,2.15,165.2),C.brass,Enum.Material.Metal,entry,true)
 end
 part("QueueRope",Vector3.new(10.4,.13,.13),CFrame.new(0,2.65,165.2),C.velvet,Enum.Material.Fabric,false,entry)

 -- 2) PREMIUM MAIN DANCE FLOOR ------------------------------------------------
 local dance=Instance.new("Model");dance.Name="MainDanceFloorV2";dance.Parent=out
 part("DanceFloorPlinth",Vector3.new(66,.18,46),CFrame.new(0,1.13,204.5),C.black,Enum.Material.Metal,true,dance)
 local tileX={-25,-15,-5,5,15,25}
 local tileZ={188.5,199.2,209.9,220.6}
 for zi,z in ipairs(tileZ) do
  for xi,x in ipairs(tileX) do
   local col=((xi+zi)%2==0) and Color3.fromRGB(34,37,44) or Color3.fromRGB(23,25,31)
   local tile=part("DanceTile_"..xi.."_"..zi,Vector3.new(9.2,.10,9.5),CFrame.new(x,1.27,z),col,Enum.Material.Glass,true,dance,.04)
   tile.Reflectance=.10
  end
 end
 for i,z in ipairs({183.0,194.0,205.0,216.0,227.0}) do
  local col=(i%2==0) and C.cyan or C.pink
  local strip=part("DanceAccent"..i,Vector3.new(61,.07,.10),CFrame.new(0,1.36,z),col,Enum.Material.Neon,false,dance,.10)
  strip.CastShadow=false
 end
 for i,x in ipairs({-30.5,30.5}) do
  local strip=part("DanceEdge"..i,Vector3.new(.10,.07,44),CFrame.new(x,1.36,204.5),(i==1) and C.violet or C.cyan,Enum.Material.Neon,false,dance,.13)
  strip.CastShadow=false
 end

 -- 3) STAGE AUDIO-VISUAL ARCHITECTURE ----------------------------------------
 -- Speaker arrays are decorative/visual only; existing approved audio remains untouched.
 local stage=Instance.new("Model");stage.Name="StagePrestigeV2";stage.Parent=out
 local function speakerTower(side)
  local x=side*38.5
  part("SpeakerTowerFrame"..side,Vector3.new(5.6,17,4.2),CFrame.new(x,10.3,237.2),C.black,Enum.Material.Metal,true,stage)
  for i=1,6 do
   local y=3.7+(i-1)*2.45
   local box=part("LineArray"..side.."_"..i,Vector3.new(4.7,2.05,2.6),CFrame.new(x,y,234.85),C.charcoal,Enum.Material.Metal,false,stage)
   part("SpeakerFace"..side.."_"..i,Vector3.new(3.8,1.35,.10),CFrame.new(x,y,233.50),C.ink,Enum.Material.SmoothPlastic,false,stage)
  end
  for _,xo in ipairs({-1.45,1.45}) do
   cylinder("Sub"..side.."_"..xo,1.0,2.45,CFrame.new(x+xo,2.55,235.0)*CFrame.Angles(math.rad(90),0,0),C.ink,Enum.Material.SmoothPlastic,stage,false)
  end
 end
 speakerTower(-1);speakerTower(1)
 part("DJFacadeV2",Vector3.new(30,3.1,.34),CFrame.new(0,5.15,235.55),C.black,Enum.Material.Glass,false,stage,.03)
 for i,x in ipairs({-11,-5.5,0,5.5,11}) do
  local bar=part("DJFacadeBar"..i,Vector3.new(.26,2.35,.12),CFrame.new(x,5.15,235.34),(i%2==0) and C.cyan or C.pink,Enum.Material.Neon,false,stage,.06)
  bar.CastShadow=false
 end

 -- 4) SUSPENDED CEILING FOCAL + MIRROR BALL ---------------------------------
 local ceiling=Instance.new("Model");ceiling.Name="DiskotikCeilingFocalV2";ceiling.Parent=out
 part("HaloFront",Vector3.new(55,.34,.34),CFrame.new(0,21.0,186.5),C.silver,Enum.Material.Metal,false,ceiling)
 part("HaloRear",Vector3.new(55,.34,.34),CFrame.new(0,21.0,222.5),C.silver,Enum.Material.Metal,false,ceiling)
 part("HaloLeft",Vector3.new(.34,.34,36),CFrame.new(-27.5,21.0,204.5),C.silver,Enum.Material.Metal,false,ceiling)
 part("HaloRight",Vector3.new(.34,.34,36),CFrame.new(27.5,21.0,204.5),C.silver,Enum.Material.Metal,false,ceiling)
 local ball=part("MirrorBall",Vector3.new(3.8,3.8,3.8),CFrame.new(0,18.3,204.5),Color3.fromRGB(176,182,190),Enum.Material.Metal,false,ceiling)
 ball.Shape=Enum.PartType.Ball;ball.Reflectance=.58
 cylinder("MirrorBallDrop",3.0,.14,CFrame.new(0,20.7,204.5),C.silver,Enum.Material.Metal,ceiling,false)
 localLight(ball,Color3.fromRGB(190,205,255),.13,9)
 for i,data in ipairs({{-22,194,C.pink},{22,194,C.cyan},{-22,215,C.violet},{22,215,C.pink}}) do
  local lamp=part("CeilingWash"..i,Vector3.new(1.15,.35,1.15),CFrame.new(data[1],20.72,data[2]),C.black,Enum.Material.Metal,false,ceiling)
  downLight(lamp,data[3],.42,20,105)
 end

 -- 5) EAST WALL FULL SERVICE BAR ----------------------------------------------
 local bar=Instance.new("Model");bar.Name="DiskotikBarV2";bar.Parent=out
 part("BarBack",Vector3.new(2.2,7.5,31),CFrame.new(53.3,4.8,221.5),C.ink,Enum.Material.Concrete,true,bar)
 part("BarBody",Vector3.new(6.6,3.5,31),CFrame.new(49.5,2.65,221.5),C.wood,Enum.Material.WoodPlanks,true,bar)
 part("BarFront",Vector3.new(.24,2.65,29.5),CFrame.new(46.08,2.75,221.5),C.charcoal,Enum.Material.Metal,false,bar)
 part("BarTop",Vector3.new(7.2,.40,32),CFrame.new(49.2,4.55,221.5),C.brass,Enum.Material.Metal,true,bar)
 for _,y in ipairs({5.9,7.45}) do
  part("BottleShelf"..y,Vector3.new(.45,.16,28),CFrame.new(52.0,y,221.5),C.brass,Enum.Material.Metal,false,bar)
 end
 local bottleColors={C.pink,C.cyan,C.amber,C.violet,Color3.fromRGB(93,150,95)}
 local bi=0
 for _,z in ipairs({210,213.5,217,220.5,224,227.5,231}) do
  for _,y in ipairs({6.35,7.9}) do
   bi+=1
   cylinder("Bottle"..bi,1.0,.42,CFrame.new(51.65,y,z),bottleColors[((bi-1)%#bottleColors)+1],Enum.Material.Glass,bar,false,.10)
  end
 end
 for i,z in ipairs({210.5,216,221.5,227,232.5}) do
  cylinder("BarStoolBase"..i,.20,2.6,CFrame.new(44.0,1.25,z),C.black,Enum.Material.Metal,bar,true)
  cylinder("BarStoolStem"..i,2.0,.26,CFrame.new(44.0,2.15,z),C.silver,Enum.Material.Metal,bar,true)
  cylinder("BarStoolPad"..i,.38,2.1,CFrame.new(44.0,3.25,z),C.velvet,Enum.Material.Fabric,bar,true)
  nativeSeat("BarSeat"..i,Vector3.new(44.0,3.22,z),Vector3.new(49.5,3.2,z),Vector3.new(1.8,.18,1.8),bar)
 end
 for _,z in ipairs({211,221.5,232}) do
  local lamp=part("BarPendant"..z,Vector3.new(.65,.65,.65),CFrame.new(47.2,11,z),C.amber,Enum.Material.Glass,false,bar,.10)
  lamp.Shape=Enum.PartType.Ball;localLight(lamp,C.warm,.42,10)
 end

 -- 6) WEST BOTTLE-SERVICE BOOTHS ----------------------------------------------
 local vip=Instance.new("Model");vip.Name="BottleServiceV2";vip.Parent=out
 local function booth(name,z,accent)
  local base=Instance.new("Model");base.Name=name;base.Parent=vip
  part("Platform",Vector3.new(16,.30,12.5),CFrame.new(-45.5,1.26,z),C.ink,Enum.Material.Metal,true,base)
  part("BackBanquette",Vector3.new(3.0,3.2,10.5),CFrame.new(-51.0,3.0,z),C.velvet,Enum.Material.Fabric,true,base)
  part("SeatBanquette",Vector3.new(5.2,1.1,10.5),CFrame.new(-48.8,1.85,z),C.fabric,Enum.Material.Fabric,true,base)
  part("BottleTable",Vector3.new(4.2,.44,5.0),CFrame.new(-43.1,2.25,z),C.brass,Enum.Material.Metal,true,base)
  local line=part("BoothAccent",Vector3.new(.16,.12,10.2),CFrame.new(-47.25,1.35,z),accent,Enum.Material.Neon,false,base,.09)
  line.CastShadow=false
  local lamp=part("BoothLamp",Vector3.new(.55,.55,.55),CFrame.new(-48.5,6.8,z),C.amber,Enum.Material.Glass,false,base,.10)
  lamp.Shape=Enum.PartType.Ball;localLight(lamp,C.warm,.25,8)
  for i,zo in ipairs({-3.1,0,3.1}) do
   nativeSeat("VIPSeat"..name..i,Vector3.new(-48.35,2.15,z+zo),Vector3.new(-42,2.15,z+zo),Vector3.new(2.1,.18,2.2),base)
  end
 end
 booth("BoothA",220.0,C.pink)
 booth("BoothB",238.0,C.cyan)

 -- 7) SIDE-WALL ACOUSTIC/UPLIGHT TREATMENT -----------------------------------
 local walls=Instance.new("Model");walls.Name="DiskotikWallTreatmentV2";walls.Parent=out
 for _,side in ipairs({-1,1}) do
  for i,z in ipairs({180,192,204,216}) do
   local panel=part("AcousticPanel"..side.."_"..i,Vector3.new(.30,7.2,7.2),CFrame.new(side*54.65,12,z),((i+side)%2==0) and C.velvet or C.charcoal,Enum.Material.Fabric,false,walls)
   panel.CastShadow=true
   local foot=part("WallFoot"..side.."_"..i,Vector3.new(.40,.30,.40),CFrame.new(side*53.8,2.0,z),C.black,Enum.Material.Metal,false,walls)
   localLight(foot,(i%2==0) and C.violet or C.pink,.18,9)
  end
 end

 club:SetAttribute("VisualPass","FUNKOT_DISKOTIK_PREMIUM_V2")
 club:SetAttribute("AudioPolicy","UNCHANGED_BY_VISUAL_V2")
 club:SetAttribute("DiskotikBar",true)
 club:SetAttribute("BottleService",true)
 club:SetAttribute("PremiumDanceFloor",true)
 club:SetAttribute("DaylightVestibule",true)
 print("[BBYA] Funkot Diskotik Premium v2 online: dark arrival / premium dance floor / line arrays / bar / bottle service / mirror ball")
end)
