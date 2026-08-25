-- BBYA SOCIAL HUB — WORLD PROMPT CLEANUP v2
-- Menu-first UX: Travel is the only navigation authority for duplicate world teleports.
local Workspace=game:GetService("Workspace")

local function shouldRemovePrompt(p)
 if not p:IsA("ProximityPrompt") then return false end
 if p.Name=="CreatePrestigeMessage" or p.Name=="RooftopAccessPrompt" then return true end
 local action=tostring(p.ActionText or "")
 local object=tostring(p.ObjectText or "")
 if action=="Go Up" or action=="Go Down" then
  if object=="VIP Level" or object=="Rooftop" or object=="Rooftop Pool" or object=="Main Club" or object=="Basement" then return true end
 end
 return false
end

local function shouldRemoveAccessPart(o)
 return o:IsA("BasePart") and o.Name=="RooftopAccess"
end

local function removeIfDuplicate(o)
 if not o or not o.Parent then return false end
 if shouldRemovePrompt(o) or shouldRemoveAccessPart(o) then
  o:Destroy()
  return true
 end
 return false
end

local function sweep()
 local removed=0
 for _,d in ipairs(Workspace:GetDescendants()) do
  if removeIfDuplicate(d) then removed+=1 end
 end
 return removed
end

task.defer(function()
 local total=sweep()
 print("[BBYA] Menu-first prompt cleanup v2 removed "..total.." duplicate world navigation objects")
end)

Workspace.DescendantAdded:Connect(function(d)
 if shouldRemovePrompt(d) or shouldRemoveAccessPart(d) then
  task.defer(function()
   if d.Parent then removeIfDuplicate(d) end
  end)
 end
end)

-- -----------------------------------------------------------------------------
-- ROOFTOP SEATING POLISH v3.1
-- Live mobile QC showed the invisible native seats sitting too high/forward above
-- cushions. Keep all Rooftop v3 visuals and lighting intact; only refine seat
-- placement and make the sit trigger non-blocking/reliable.
-- -----------------------------------------------------------------------------
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
 if not root then return end
 local upper=root:WaitForChild("UpperLevels",30)
 if not upper then return end
 local roof=upper:WaitForChild("R_Rooftop",30)
 if not roof then return end

 local deadline=os.clock()+35
 repeat
  if roof:GetAttribute("Pass")=="ROOFTOP_RESORT_PREMIUM_V3"
   and roof:FindFirstChild("PremiumCabanasV3")
   and roof:FindFirstChild("PoolsideLoungersV3")
   and roof:FindFirstChild("RooftopBarV3")
   and roof:FindFirstChild("SunsetSocialLoungeV3") then
   break
  end
  task.wait(.15)
 until os.clock()>=deadline

 if roof:GetAttribute("Pass")~="ROOFTOP_RESORT_PREMIUM_V3" then
  warn("[BBYA] Rooftop seating polish skipped: premium rooftop not ready")
  return
 end
 task.wait(.45)

 local old=roof:FindFirstChild("RooftopSeatingPolishV31")
 if old then old:Destroy() end
 local marker=Instance.new("Model")
 marker.Name="RooftopSeatingPolishV31"
 marker.Parent=roof
 marker:SetAttribute("RooftopOnly",true)
 marker:SetAttribute("GlobalLightingUntouched",true)
 marker:SetAttribute("VisualGeometryUntouched",true)
 marker:SetAttribute("NaturalSeatAlignment",true)

 local tuned=0
 local touchLocks={}
 local function findHumanoid(hit)
  if not hit then return nil end
  local character=hit:FindFirstAncestorOfClass("Model")
  return character and character:FindFirstChildOfClass("Humanoid") or nil
 end

 local function tuneSeat(seat)
  if not seat:IsA("Seat") then return end
  local name=seat.Name
  local down=.16
  local back=.20
  local size=Vector3.new(2.2,.20,2.0)

  if name:match("^DaybedSeat") then
   down=.30;back=.95;size=Vector3.new(2.75,.20,2.45)
  elseif name=="LoungerSeat" then
   down=.23;back=.65;size=Vector3.new(2.25,.20,2.25)
  elseif name=="BarSeat" then
   down=.18;back=.12;size=Vector3.new(1.90,.20,1.90)
  elseif name:match("^LoungeSeat") then
   down=.22;back=.38;size=Vector3.new(2.15,.20,2.10)
  elseif name=="ArrivalSeat" then
   down=.18;back=.28;size=Vector3.new(4.8,.20,1.45)
  end

  local oldCf=seat.CFrame
  local look=oldCf.LookVector
  local up=oldCf.UpVector
  local newPos=oldCf.Position-(look*back)-Vector3.new(0,down,0)
  seat.CFrame=CFrame.lookAt(newPos,newPos+look,up)
  seat.Size=size
  seat.Transparency=1
  seat.Anchored=true
  seat.CanCollide=false
  seat.CanTouch=true
  seat.CanQuery=false
  seat.CastShadow=false
  seat.Disabled=false
  seat:SetAttribute("BBYANaturalSeat",true)
  seat:SetAttribute("SeatProfile","ROOFTOP_V31")

  seat.Touched:Connect(function(hit)
   local hum=findHumanoid(hit)
   if not hum or hum.Health<=0 or hum.SeatPart then return end
   local now=os.clock()
   local last=touchLocks[hum] or 0
   if now-last<.65 then return end
   touchLocks[hum]=now
   seat:Sit(hum)
  end)
  tuned+=1
 end

 for _,obj in ipairs(roof:GetDescendants()) do
  if obj:IsA("Seat") then tuneSeat(obj) end
 end
 roof:SetAttribute("SeatAlignmentProfile","ROOFTOP_V31_NATURAL")
 roof:SetAttribute("SeatPolishCount",tuned)
 roof:SetAttribute("SeatPolishLive",true)
 print(string.format("[BBYA] Rooftop seating polish v3.1 online: %d seats aligned naturally / Rooftop visuals unchanged",tuned))
end)

-- -----------------------------------------------------------------------------
-- ROOFTOP TROPICAL EDGE POLISH v3.2
-- Mobile QC: west edge read too empty and the pool coping gap exposed lower-club
-- lighting. Add premium potted palms, upgrade the pool shower backdrop and seal
-- only the under-coping gaps. Infinity water, seats, access and lighting profile stay.
-- -----------------------------------------------------------------------------
task.spawn(function()
 local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
 if not root then return end
 local upper=root:WaitForChild("UpperLevels",30)
 if not upper then return end
 local roof=upper:WaitForChild("R_Rooftop",30)
 if not roof then return end

 local deadline=os.clock()+35
 repeat
  if roof:GetAttribute("Pass")=="ROOFTOP_RESORT_PREMIUM_V3"
   and roof:FindFirstChild("RooftopInfinityPoolV3")
   and roof:FindFirstChild("RooftopLandscapeV3") then break end
  task.wait(.15)
 until os.clock()>=deadline
 if roof:GetAttribute("Pass")~="ROOFTOP_RESORT_PREMIUM_V3" then
  warn("[BBYA] Rooftop tropical edge polish skipped: premium rooftop not ready")
  return
 end
 task.wait(.55)

 local old=roof:FindFirstChild("RooftopTropicalEdgeV32")
 if old then old:Destroy() end
 local out=Instance.new("Model")
 out.Name="RooftopTropicalEdgeV32"
 out.Parent=roof
 out:SetAttribute("RooftopOnly",true)
 out:SetAttribute("GlobalLightingUntouched",true)
 out:SetAttribute("InfinityPoolPreserved",true)
 out:SetAttribute("TropicalLandscape",true)
 out:SetAttribute("PoolGapSealed",true)

 local C={
  stone=Color3.fromRGB(126,119,109),
  stoneDark=Color3.fromRGB(83,80,76),
  charcoal=Color3.fromRGB(34,35,37),
  teak=Color3.fromRGB(103,72,49),
  trunk=Color3.fromRGB(91,67,45),
  leaf=Color3.fromRGB(43,92,55),
  leaf2=Color3.fromRGB(62,116,67),
  soil=Color3.fromRGB(43,34,28),
  brass=Color3.fromRGB(164,129,78),
  warm=Color3.fromRGB(255,211,164),
  metal=Color3.fromRGB(66,68,70),
 }

 local function part(name,size,cf,color,material,transparency,collide,parent)
  local p=Instance.new("Part")
  p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.stone
  p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0
  p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
  p.CastShadow=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent or out
  return p
 end

 local function cylinder(name,height,diameter,cf,color,material,parent,collide)
  local p=part(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,0,collide,parent)
  p.Shape=Enum.PartType.Cylinder
  return p
 end

 local function palm(name,x,z,height,leanX,leanZ,scale)
  scale=scale or 1
  local m=Instance.new("Model");m.Name=name;m.Parent=out
  local deckY=45.16
  local potH=2.15*scale
  cylinder("StonePot",potH,4.1*scale,CFrame.new(x,deckY+potH/2,z),C.stoneDark,Enum.Material.Concrete,m,true)
  cylinder("Soil",.18,3.55*scale,CFrame.new(x,deckY+potH+.05,z),C.soil,Enum.Material.Slate,m,false)

  local trunkBase=deckY+potH+.12
  local segments=4
  local segH=(height*scale)/segments
  for i=1,segments do
   local t=(i-.5)/segments
   local px=x+(leanX or 0)*t
   local pz=z+(leanZ or 0)*t
   cylinder("Trunk"..i,segH+.12,.78*scale,CFrame.new(px,trunkBase+segH*(i-.5),pz),C.trunk,Enum.Material.Wood,m,false)
  end

  local crown=Vector3.new(x+(leanX or 0),trunkBase+height*scale,z+(leanZ or 0))
  local crownBall=part("Crown",Vector3.new(1.15,1.15,1.15),CFrame.new(crown),C.leaf,Enum.Material.SmoothPlastic,0,false,m)
  crownBall.Shape=Enum.PartType.Ball
  for i=1,11 do
   local yaw=math.rad((i-1)*(360/11)+((i%2)*8))
   local pitch=math.rad(14+((i%3)*5))
   local cf=CFrame.new(crown)*CFrame.Angles(0,yaw,0)*CFrame.Angles(-pitch,0,0)*CFrame.new(0,0,-2.65*scale)
   local leaf=part("PalmFrond"..i,Vector3.new(.52*scale,.12*scale,5.4*scale),cf,(i%2==0) and C.leaf2 or C.leaf,Enum.Material.SmoothPlastic,0,false,m)
   leaf.CastShadow=true
  end
  for i=1,3 do
   local a=math.rad(i*120)
   local coco=part("Coconut"..i,Vector3.new(.72,.72,.72),CFrame.new(crown+Vector3.new(math.cos(a)*.58,-.48,math.sin(a)*.58)),Color3.fromRGB(82,58,39),Enum.Material.SmoothPlastic,0,false,m)
   coco.Shape=Enum.PartType.Ball
  end
  local uplight=Instance.new("PointLight")
  uplight.Name="PalmUplight";uplight.Color=C.warm;uplight.Brightness=.12;uplight.Range=7;uplight.Shadows=false;uplight.Parent=crownBall
 end

 -- Remove the three primitive west-edge planters from v3 before replacing them.
 local landscape=roof:FindFirstChild("RooftopLandscapeV3")
 if landscape then
  for i=1,3 do
   local oldPlanter=landscape:FindFirstChild("Planter"..i)
   if oldPlanter then oldPlanter:Destroy() end
  end
 end

 -- Staggered palms keep the skyline visible while giving the west side a Bali/tropical identity.
 palm("WestPalmA",-53.3,-29.0,8.4,.55,.20,1.00)
 palm("WestPalmB",-54.0,-11.0,9.4,-.35,.55,1.05)
 palm("WestPalmC",-53.4,7.0,8.8,.45,-.35,.96)
 palm("WestPalmD",-53.1,37.0,10.0,-.45,-.25,1.08)

 -- Seal the small structural void between the pool walls and surrounding coping.
 -- These panels sit outside the water volume and below the walking surface.
 local fascia=Instance.new("Model");fascia.Name="PoolPerimeterFasciaV32";fascia.Parent=out
 part("PoolGapSealWest",Vector3.new(.72,3.25,31.2),CFrame.new(-29.18,43.45,12),C.stoneDark,Enum.Material.Limestone,0,true,fascia)
 part("PoolGapSealEast",Vector3.new(.72,3.25,31.2),CFrame.new(29.18,43.45,12),C.stoneDark,Enum.Material.Limestone,0,true,fascia)
 part("PoolGapSealNorth",Vector3.new(58.2,2.65,.58),CFrame.new(0,43.65,27.95),C.stoneDark,Enum.Material.Limestone,0,true,fascia)
 -- Keep the south infinity edge visually open; only mask the lower sightline to the club below.
 part("InfinityShadowSkirt",Vector3.new(55.5,1.18,.36),CFrame.new(0,42.15,-4.04),C.charcoal,Enum.Material.Metal,0,false,fascia)
 part("WestCopingReveal",Vector3.new(.18,.18,31.0),CFrame.new(-29.48,44.96,12),C.brass,Enum.Material.Metal,.08,false,fascia)
 part("EastCopingReveal",Vector3.new(.18,.18,31.0),CFrame.new(29.48,44.96,12),C.brass,Enum.Material.Metal,.08,false,fascia)

 -- The two exposed shower poles read unfinished in mobile view. Give them a small teak privacy screen.
 local service=roof:FindFirstChild("PoolServiceV3")
 if service then
  for _,obj in ipairs(service:GetDescendants()) do
   if obj.Name:match("^ShowerPost") or obj.Name:match("^ShowerHead") then obj:Destroy() end
  end
 end
 local shower=Instance.new("Model");shower.Name="TropicalPoolShowerV32";shower.Parent=out
 part("ShowerPad",Vector3.new(8.5,.22,4.5),CFrame.new(22,45.34,35.2),C.stone,Enum.Material.Limestone,0,true,shower)
 for i=-3,3 do
  part("ScreenSlat"..i,Vector3.new(.42,6.0,.34),CFrame.new(22+i*.92,48.2,37.05),C.teak,Enum.Material.WoodPlanks,0,true,shower)
 end
 for _,x in ipairs({20.4,23.6}) do
  part("RainRiser"..x,Vector3.new(.18,4.9,.18),CFrame.new(x,48.0,35.95),C.metal,Enum.Material.Metal,0,true,shower)
  part("RainArm"..x,Vector3.new(.18,.18,1.25),CFrame.new(x,50.35,35.38),C.metal,Enum.Material.Metal,0,false,shower)
  local head=part("RainHead"..x,Vector3.new(1.15,.16,1.15),CFrame.new(x,50.28,34.78),C.metal,Enum.Material.Metal,0,false,shower)
  head.Shape=Enum.PartType.Cylinder
 end

 roof:SetAttribute("RooftopTropicalProfile","TROPICAL_EDGE_V32")
 roof:SetAttribute("PoolPerimeterFascia",true)
 roof:SetAttribute("WestPalmCount",4)
 roof:SetAttribute("TropicalShowerUpgrade",true)
 print("[BBYA] Rooftop tropical edge v3.2 online: west palms / pool gap fascia / tropical shower / infinity preserved")
end)
