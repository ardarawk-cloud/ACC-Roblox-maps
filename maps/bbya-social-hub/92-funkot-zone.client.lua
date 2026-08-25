-- BBYA SOCIAL HUB — FUNKOT DISKOTIK AUDIO ZONE v1
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local inside=false
local mainGroup,underGroup,funkotGroup

local function groups()
 mainGroup=SoundService:FindFirstChild("BBYAClubMaster") or mainGroup
 underGroup=SoundService:FindFirstChild("BBYABasementMaster") or underGroup
 funkotGroup=SoundService:FindFirstChild("BBYAFunkotMaster") or funkotGroup
end
local function inFunkot()
 local ch=player.Character
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 local p=hrp.Position
 return p.Y>-4 and p.Y<34 and math.abs(p.X)<61 and p.Z>157 and p.Z<253
end
local guarding=false
local function enforce()
 if guarding then return end
 guarding=true
 groups();inside=inFunkot()
 if funkotGroup then funkotGroup.Volume=inside and .96 or 0 end
 if inside then
  if mainGroup then mainGroup.Volume=0 end
  if underGroup then underGroup.Volume=0 end
 end
 guarding=false
end

task.spawn(function()
 while task.wait(.15) do enforce() end
end)
SoundService.ChildAdded:Connect(function()task.defer(enforce)end)
RunService.Heartbeat:Connect(function()if inside then enforce()end end)

-- Visible identity only: keep internal Funkot keys/audio group names unchanged.
local pg=player:WaitForChild("PlayerGui")
local function relabel(o)
 if not (o:IsA("TextLabel") or o:IsA("TextButton")) then return end
 if o.Text=="FUNKOT CLUB" then
  o.Text="FUNKOT DISKOTIK"
 elseif o.Text=="FUNKOT CLUB  •  10 R$" then
  o.Text="FUNKOT DISKOTIK  •  10 R$"
 end
end
for _,d in ipairs(pg:GetDescendants()) do relabel(d) end
pg.DescendantAdded:Connect(function(d)task.defer(function()if d.Parent then relabel(d) end end)end)
task.spawn(function()
 for _=1,40 do
  for _,d in ipairs(pg:GetDescendants()) do relabel(d) end
  task.wait(.5)
 end
end)

-- Dedicated Funkot request acknowledgement v5.
-- Uses FunkotMusic directly so the old global State toast cannot display the same
-- request twice through multiple music UI listeners.
task.spawn(function()
 local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
 local remote=remotes and remotes:WaitForChild("FunkotMusic",30)
 if not remote then return end

 local old=pg:FindFirstChild("BBYAFunkotAckUIV5")
 if old then old:Destroy() end
 local gui=Instance.new("ScreenGui")
 gui.Name="BBYAFunkotAckUIV5"
 gui.ResetOnSpawn=false
 gui.IgnoreGuiInset=true
 gui.DisplayOrder=890
 gui.Parent=pg

 local box=Instance.new("TextLabel")
 box.Name="Ack"
 box.AnchorPoint=Vector2.new(.5,1)
 box.Position=UDim2.new(.5,0,1,-68)
 box.Size=UDim2.new(.62,0,0,46)
 box.BackgroundColor3=Color3.fromRGB(13,13,18)
 box.BackgroundTransparency=.08
 box.BorderSizePixel=0
 box.TextColor3=Color3.fromRGB(255,195,235)
 box.TextStrokeTransparency=.72
 box.Font=Enum.Font.GothamBold
 box.TextSize=12
 box.TextWrapped=true
 box.Visible=false
 box.ZIndex=990
 box.Parent=gui
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,10);corner.Parent=box
 local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(232,38,165);stroke.Transparency=.52;stroke.Thickness=1;stroke.Parent=box
 local token=0
 local function showAck(msg)
  token+=1
  local mine=token
  box.Text=tostring(msg or "")
  box.Visible=true
  task.delay(1.8,function()if token==mine then box.Visible=false end end)
 end
 remote.OnClientEvent:Connect(function(kind,data)
  if kind=="ack" then showAck(data) end
 end)
end)

-- -----------------------------------------------------------------------------
-- FUNKOT DISKOTIK MOVING VISIBLE BEAMS v2.2
-- Roblox SpotLight illuminates surfaces but does not draw a volumetric shaft in air.
-- These client-local Beam ribbons follow the existing server-driven moving heads so
-- the pink/cyan/violet shafts visibly sweep the dance floor without touching audio,
-- global Lighting, travel or any other venue.
-- -----------------------------------------------------------------------------
task.spawn(function()
 local root=workspace:WaitForChild("BBYA_ZERO_BUILD",30)
 local club=root and root:WaitForChild("FunkotClub",30)
 local moving=club and club:WaitForChild("MovingHeads",30)
 if not moving then
  warn("[BBYA] Funkot moving beams v2.2 skipped: moving-head rig not found")
  return
 end

 local old=club:FindFirstChild("FunkotMovingBeamsClientV22")
 if old then old:Destroy() end
 local fx=Instance.new("Model")
 fx.Name="FunkotMovingBeamsClientV22"
 fx.Parent=club
 fx:SetAttribute("FunkotOnly",true)
 fx:SetAttribute("ClientVisualOnly",true)
 fx:SetAttribute("AudioUntouched",true)
 fx:SetAttribute("GlobalLightingUntouched",true)

 local rows={}
 for i=1,7 do
  local head=moving:FindFirstChild("MoverHead"..i)
  if head and head:IsA("BasePart") then
   local spot=head:FindFirstChildOfClass("SpotLight")
   local color=spot and spot.Color or Color3.fromRGB(245,50,170)

   local source=head:FindFirstChild("VisibleBeamSourceV22")
   if not source then
    source=Instance.new("Attachment")
    source.Name="VisibleBeamSourceV22"
    source.Position=Vector3.new(0,-1.08,0)
    source.Parent=head
   end

   local target=Instance.new("Part")
   target.Name="VisibleBeamTarget"..i
   target.Size=Vector3.new(.12,.12,.12)
   target.Transparency=1
   target.Anchored=true
   target.CanCollide=false
   target.CanTouch=false
   target.CanQuery=false
   target.CastShadow=false
   target.Parent=fx

   local finish=Instance.new("Attachment")
   finish.Name="VisibleBeamTargetAttachment"
   finish.Parent=target

   local outer=Instance.new("Beam")
   outer.Name="MovingBeamOuter"..i
   outer.Attachment0=source
   outer.Attachment1=finish
   outer.FaceCamera=true
   outer.Width0=.34
   outer.Width1=1.75
   outer.Segments=3
   outer.LightEmission=.92
   outer.LightInfluence=0
   outer.Color=ColorSequence.new(color)
   outer.Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,.28),
    NumberSequenceKeypoint.new(.45,.40),
    NumberSequenceKeypoint.new(1,.72),
   })
   outer.Parent=head

   local core=Instance.new("Beam")
   core.Name="MovingBeamCore"..i
   core.Attachment0=source
   core.Attachment1=finish
   core.FaceCamera=true
   core.Width0=.08
   core.Width1=.48
   core.Segments=3
   core.LightEmission=1
   core.LightInfluence=0
   core.Color=ColorSequence.new(color)
   core.Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,.08),
    NumberSequenceKeypoint.new(.60,.28),
    NumberSequenceKeypoint.new(1,.58),
   })
   core.Parent=head

   local hitLight=Instance.new("PointLight")
   hitLight.Name="MovingBeamFloorGlow"..i
   hitLight.Color=color
   hitLight.Brightness=.42
   hitLight.Range=5.5
   hitLight.Shadows=false
   hitLight.Enabled=false
   hitLight.Parent=target

   table.insert(rows,{head=head,target=target,outer=outer,core=core,hit=hitLight,phase=i*.73})
  end
 end

 local connection
 connection=RunService.RenderStepped:Connect(function()
  if not club.Parent or not fx.Parent then
   if connection then connection:Disconnect() end
   return
  end

  local active=inFunkot()
  local now=os.clock()
  for _,row in ipairs(rows) do
   row.outer.Enabled=active
   row.core.Enabled=active
   row.hit.Enabled=active
   if active and row.head.Parent then
    local origin=row.outer.Attachment0.WorldPosition
    local direction=-row.head.CFrame.UpVector
    local distance=48
    if direction.Y<-.08 then
     distance=(1.34-origin.Y)/direction.Y
    end
    distance=math.clamp(distance,10,62)
    local targetPos=origin+direction*distance
    row.target.CFrame=CFrame.new(targetPos)

    -- Small breathing pulse keeps the shaft alive without strobing the whole room.
    local pulse=.82+.18*math.sin(now*3.1+row.phase)
    row.outer.LightEmission=.78+.18*pulse
    row.core.LightEmission=.92+.08*pulse
    row.hit.Brightness=.30+.24*pulse
   end
  end
 end)

 print(string.format("[BBYA] Funkot moving visible beams v2.2 online: %d moving shafts follow existing heads",#rows))
end)

print("[BBYA] Funkot Diskotik audio zone v1 online: isolated rear diskotik feed / visible naming locked")

-- -----------------------------------------------------------------------------
-- FUNKOT DISKOTIK PREMIUM VISUAL ENHANCEMENT v3
-- Client-local decorative pass layered onto the existing v2/v2.1 architecture.
-- No shell replacement, no audio/SoundId/routing mutation, no global Lighting edit,
-- and no Underground/Mall/Rooftop/monetization mutation. Effects sleep outside Funkot.
-- -----------------------------------------------------------------------------
task.spawn(function()
 local root=workspace:WaitForChild("BBYA_ZERO_BUILD",30)
 local club=root and root:WaitForChild("FunkotClub",30)
 if not club then return end

 local deadline=os.clock()+45
 repeat
  if club:FindFirstChild("FunkotDiskotikPremiumV2") then break end
  task.wait(.20)
 until os.clock()>=deadline

 local premium=club:FindFirstChild("FunkotDiskotikPremiumV2")
 if not premium then
  warn("[BBYA] Funkot premium visual v3 skipped: premium v2 authority not ready")
  return
 end

 local old=club:FindFirstChild("FunkotVisualPremiumV3")
 if old then old:Destroy() end
 local fx=Instance.new("Model")
 fx.Name="FunkotVisualPremiumV3"
 fx.Parent=club
 fx:SetAttribute("FunkotOnly",true)
 fx:SetAttribute("ClientVisualOnly",true)
 fx:SetAttribute("SingleEnhancementAuthority",true)
 fx:SetAttribute("AudioUntouched",true)
 fx:SetAttribute("SoundIdsUntouched",true)
 fx:SetAttribute("UndergroundUntouched",true)
 fx:SetAttribute("GlobalLightingUntouched",true)
 fx:SetAttribute("MallUntouched",true)
 fx:SetAttribute("RooftopUntouched",true)
 fx:SetAttribute("MonetizationUntouched",true)
 fx:SetAttribute("Profile","FUNKOT_DISKOTIK_PREMIUM_VISUAL_V3")

 local C={
  black=Color3.fromRGB(7,8,11),
  graphite=Color3.fromRGB(31,33,39),
  silver=Color3.fromRGB(164,170,180),
  smoke=Color3.fromRGB(57,64,74),
  brass=Color3.fromRGB(157,112,59),
  pink=Color3.fromRGB(244,40,157),
  cyan=Color3.fromRGB(29,195,222),
  violet=Color3.fromRGB(142,76,236),
  warm=Color3.fromRGB(255,194,132),
 }

 local function part(name,size,cf,color,material,transparency,parent)
  local p=Instance.new("Part")
  p.Name=name
  p.Size=size
  p.CFrame=cf
  p.Color=color or C.graphite
  p.Material=material or Enum.Material.Metal
  p.Transparency=transparency or 0
  p.Anchored=true
  p.CanCollide=false
  p.CanTouch=false
  p.CanQuery=false
  p.CastShadow=false
  p.TopSurface=Enum.SurfaceType.Smooth
  p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=parent or fx
  return p
 end

 local dynamicLights={}
 local function localPoint(parent,color,brightness,range)
  local l=Instance.new("PointLight")
  l.Name="FunkotLocalV3"
  l.Color=color
  l.Brightness=brightness
  l.Range=range
  l.Shadows=false
  l.Enabled=false
  l.Parent=parent
  table.insert(dynamicLights,l)
  return l
 end

 -- Premium ceiling raster: metallic ribs + restrained local luminous cells.
 local ceiling=Instance.new("Model")
 ceiling.Name="CeilingRasterV3"
 ceiling.Parent=fx
 for i,z in ipairs({186.5,195.5,204.5,213.5,222.5}) do
  part("CeilingRib"..i,Vector3.new(49,.18,.28),CFrame.new(0,20.55,z),C.silver,Enum.Material.Metal,.05,ceiling)
  local col=({C.pink,C.violet,C.cyan,C.violet,C.pink})[i]
  local cell=part("CeilingCell"..i,Vector3.new(35,.06,.10),CFrame.new(0,20.34,z),col,Enum.Material.Neon,.14,ceiling)
  localPoint(cell,col,.13,13)
 end
 for _,x in ipairs({-23.8,23.8}) do
  part("CeilingSpine"..x,Vector3.new(.24,.18,40),CFrame.new(x,20.55,204.5),C.brass,Enum.Material.Metal,.08,ceiling)
 end

 -- Smoked mirror + brass/acoustic rhythm on the side walls; decorative only.
 local walls=Instance.new("Model")
 walls.Name="WallPrestigeV3"
 walls.Parent=fx
 for _,side in ipairs({-1,1}) do
  for i,z in ipairs({184,196,208,220,232}) do
   local mirror=part("SmokedMirror"..side.."_"..i,Vector3.new(.12,6.5,6.4),CFrame.new(side*54.25,12.8,z),C.smoke,Enum.Material.Glass,.28,walls)
   mirror.Reflectance=.28
   part("BrassFin"..side.."_"..i,Vector3.new(.20,7.3,.30),CFrame.new(side*53.98,12.8,z-3.5),C.brass,Enum.Material.Metal,.02,walls)
   part("BrassFinB"..side.."_"..i,Vector3.new(.20,7.3,.30),CFrame.new(side*53.98,12.8,z+3.5),C.brass,Enum.Material.Metal,.02,walls)
  end
 end

 -- Low-level perimeter practicals create depth without lifting the whole room.
 local practicals=Instance.new("Model")
 practicals.Name="LowPracticalsV3"
 practicals.Parent=fx
 for i,z in ipairs({184,194,204,214,224,234}) do
  for _,side in ipairs({-1,1}) do
   local col=((i+((side+1)/2))%2==0) and C.pink or C.cyan
   local lens=part("LowLens"..side.."_"..i,Vector3.new(.16,.70,.22),CFrame.new(side*52.9,2.15,z),col,Enum.Material.Glass,.08,practicals)
   localPoint(lens,col,.16,6.5)
  end
 end

 -- Mirror-ball facets + reflected shafts. Existing server mirror ball remains authority.
 local ball=premium:FindFirstChild("MirrorBall",true)
 if not (ball and ball:IsA("BasePart")) then
  warn("[BBYA] Funkot premium visual v3: mirror ball not found; architectural v3 stays active")
 end

 local mirrorFx=Instance.new("Model")
 mirrorFx.Name="ActiveMirrorBallV3"
 mirrorFx.Parent=fx
 local facets={}
 local rayRows={}
 local facetRadius=2.08
 if ball then
  for latIndex,latDeg in ipairs({-38,0,38}) do
   local lat=math.rad(latDeg)
   for lonIndex=0,7 do
    local lon=math.rad(lonIndex*45)
    local offset=Vector3.new(
     math.cos(lat)*math.cos(lon)*facetRadius,
     math.sin(lat)*facetRadius,
     math.cos(lat)*math.sin(lon)*facetRadius
    )
    local f=part("MirrorFacet"..latIndex.."_"..lonIndex,Vector3.new(.28,.28,.10),CFrame.new(ball.Position+offset),C.silver,Enum.Material.Glass,.03,mirrorFx)
    f.Reflectance=.55
    table.insert(facets,{part=f,lat=lat,lon=lon,seed=(latIndex*8)+lonIndex})
   end
  end

  local source=Instance.new("Attachment")
  source.Name="MirrorRaySourceV3"
  source.Parent=ball
  local rayColors={C.pink,C.cyan,C.violet,C.warm}
  for i=1,4 do
   local target=part("MirrorRayTarget"..i,Vector3.new(.10,.10,.10),CFrame.new(0,1.55,204.5),C.black,Enum.Material.SmoothPlastic,1,mirrorFx)
   local finish=Instance.new("Attachment")
   finish.Name="MirrorRayFinishV3"
   finish.Parent=target
   local beam=Instance.new("Beam")
   beam.Name="MirrorRay"..i
   beam.Attachment0=source
   beam.Attachment1=finish
   beam.FaceCamera=true
   beam.Width0=.045
   beam.Width1=.14
   beam.Segments=2
   beam.LightEmission=.95
   beam.LightInfluence=0
   beam.Color=ColorSequence.new(rayColors[i])
   beam.Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,.34),
    NumberSequenceKeypoint.new(.55,.52),
    NumberSequenceKeypoint.new(1,.78),
   })
   beam.Enabled=false
   beam.Parent=ball
   local hit=Instance.new("PointLight")
   hit.Name="MirrorHit"..i
   hit.Color=rayColors[i]
   hit.Brightness=.20
   hit.Range=4.2
   hit.Shadows=false
   hit.Enabled=false
   hit.Parent=target
   table.insert(rayRows,{target=target,beam=beam,hit=hit,phase=(i-1)*(math.pi/2)})
  end
 end

 local accum=0
 local conn
 conn=RunService.RenderStepped:Connect(function(dt)
  if not club.Parent or not fx.Parent then
   if conn then conn:Disconnect() end
   return
  end
  local active=inFunkot()
  for _,l in ipairs(dynamicLights) do l.Enabled=active end
  for _,row in ipairs(rayRows) do
   row.beam.Enabled=active
   row.hit.Enabled=active
  end
  if not active or not ball or not ball.Parent then return end

  accum+=dt
  if accum<(1/30) then return end
  local step=accum
  accum=0
  local now=os.clock()
  local spin=now*.34
  local center=ball.Position

  for _,row in ipairs(facets) do
   local lon=row.lon+spin
   local offset=Vector3.new(
    math.cos(row.lat)*math.cos(lon)*facetRadius,
    math.sin(row.lat)*facetRadius,
    math.cos(row.lat)*math.sin(lon)*facetRadius
   )
   local pos=center+offset
   row.part.CFrame=CFrame.lookAt(pos,center)*CFrame.Angles(math.rad(90),0,0)
   row.part.Transparency=.02+.10*(.5+.5*math.sin(now*1.7+row.seed*.61))
  end

  for i,row in ipairs(rayRows) do
   local a=now*.46+row.phase
   local radiusX=27+4*math.sin(now*.31+i)
   local radiusZ=17+3*math.cos(now*.27+i*.7)
   row.target.CFrame=CFrame.new(math.cos(a)*radiusX,1.48,204.5+math.sin(a)*radiusZ)
   row.hit.Brightness=.14+.12*(.5+.5*math.sin(now*2.0+i))
  end

  -- Gentle room breathing only on local v3 lights; no global strobe or Lighting mutation.
  local pulse=.82+.18*math.sin(now*.85)
  for _,l in ipairs(dynamicLights) do
   l.Brightness=math.max(.08,l.Brightness*(.997)+(.16*pulse)*.003)
  end
 end)

 club:SetAttribute("FunkotVisualEnhancement","PREMIUM_V3_CLIENT")
 print("[BBYA] Funkot Diskotik premium visual v3 online: active mirror ball / ceiling raster / smoked wall prestige / local practical choreography")
end)
