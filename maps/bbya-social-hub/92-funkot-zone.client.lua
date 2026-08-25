-- BBYA SOCIAL HUB — FUNKOT DISKOTIK AUDIO ZONE v1
local Players=game:GetService("Players")
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
