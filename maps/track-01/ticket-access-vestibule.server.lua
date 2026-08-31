local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")

-- TRACK 01 v3.7 ticket access + enclosed inter-car vestibules.
-- A valid Night Ticket is required before entering any carriage from Platform 01.
-- Inter-car gaps are converted into enclosed railway-style gangways so players cannot
-- slip outside between carriages. No audio assets are used here.
local deadline=os.clock()+60
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_INTERACTIVE_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_TicketAccessVestibule_v37")
if old then old:Destroy() end
local folder=Instance.new("Folder")
folder.Name="TRACK01_TicketAccessVestibule_v37"
folder.Parent=world

local C={
    black=Color3.fromRGB(15,16,16),
    rubber=Color3.fromRGB(27,28,28),
    steel=Color3.fromRGB(87,89,87),
    steelDark=Color3.fromRGB(48,50,49),
    amber=Color3.fromRGB(205,132,58),
    cream=Color3.fromRGB(219,205,177),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end

local function part(parent,name,size,frame,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.steel
    p.Material=material or Enum.Material.Metal
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=collide==true
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=collide==true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function surfaceText(target,face,text,color)
    local gui=Instance.new("SurfaceGui")
    gui.Name="TicketAccessSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=42
    gui.LightInfluence=0.18
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=C.black
    label.BackgroundTransparency=0.08
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=color or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=Enum.Font.RobotoMono
    label.Parent=gui
end

local function sightlineText(target,face,headline,subline)
    local gui=Instance.new("SurfaceGui")
    gui.Name="Car01SightlineSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=52
    gui.LightInfluence=0.08
    gui.Parent=target

    local headlineLabel=Instance.new("TextLabel")
    headlineLabel.Size=UDim2.fromScale(0.94,0.62)
    headlineLabel.Position=UDim2.fromScale(0.03,0.04)
    headlineLabel.BackgroundColor3=C.black
    headlineLabel.BackgroundTransparency=0.04
    headlineLabel.BorderSizePixel=0
    headlineLabel.Text=headline
    headlineLabel.TextColor3=C.amber
    headlineLabel.TextScaled=true
    headlineLabel.TextWrapped=true
    headlineLabel.Font=Enum.Font.RobotoMono
    headlineLabel.Parent=gui

    local subLabel=Instance.new("TextLabel")
    subLabel.Size=UDim2.fromScale(0.94,0.25)
    subLabel.Position=UDim2.fromScale(0.03,0.69)
    subLabel.BackgroundTransparency=1
    subLabel.BorderSizePixel=0
    subLabel.Text=subline
    subLabel.TextColor3=C.cream
    subLabel.TextScaled=true
    subLabel.TextWrapped=false
    subLabel.Font=Enum.Font.RobotoMono
    subLabel.Parent=gui
end

-- Convert the three 4-stud gaps between the 50-stud railcars into proper enclosed
-- gangways. The opening in each carriage end is about 4.6 studs wide, so the new
-- corridor stays centered inside that opening and does not intrude into the aisle.
local connectors={
    {z=-31.5,label="CAR 01  ↔  CAR 02"},
    {z=21.5,label="CAR 02  ↔  CAR 03"},
    {z=74.5,label="CAR 03  ↔  CAR 04"},
}

local vestibules=Instance.new("Folder")
vestibules.Name="EnclosedInterCarVestibules"
vestibules.Parent=folder

for i,data in ipairs(connectors) do
    local g=Instance.new("Folder")
    g.Name=string.format("Vestibule_%02d",i)
    g.Parent=vestibules

    -- Floor aligns with carriage floor top (~Y 4.7).
    part(g,"GangwayFloor",Vector3.new(4.4,0.35,4.15),cf(22,4.525,data.z),C.steelDark,Enum.Material.DiamondPlate,0,true)
    -- Dark flexible-looking side bellows close the exterior gaps.
    part(g,"BellowsLeft",Vector3.new(0.34,9.7,4.20),cf(19.55,9.35,data.z),C.rubber,Enum.Material.SmoothPlastic,0,true)
    part(g,"BellowsRight",Vector3.new(0.34,9.7,4.20),cf(24.45,9.35,data.z),C.rubber,Enum.Material.SmoothPlastic,0,true)
    part(g,"GangwayRoof",Vector3.new(4.55,0.38,4.20),cf(22,14.35,data.z),C.steelDark,Enum.Material.CorrodedMetal,0,true)

    -- Visible steel accordion ribs. Non-colliding: structural walls above own safety.
    for _,dz in ipairs({-1.55,-0.75,0,0.75,1.55}) do
        part(g,"BellowsRibL",Vector3.new(0.18,9.5,0.18),cf(19.76,9.35,data.z+dz),C.steel,Enum.Material.Metal,0,false)
        part(g,"BellowsRibR",Vector3.new(0.18,9.5,0.18),cf(24.24,9.35,data.z+dz),C.steel,Enum.Material.Metal,0,false)
        part(g,"RoofRib",Vector3.new(4.15,0.16,0.18),cf(22,14.08,data.z+dz),C.steel,Enum.Material.Metal,0,false)
    end

    -- Restrained amber threshold markers improve night readability without neon overload.
    part(g,"ThresholdMarkerL",Vector3.new(0.12,0.08,3.75),cf(19.92,4.73,data.z),C.amber,Enum.Material.Neon,0.18,false)
    part(g,"ThresholdMarkerR",Vector3.new(0.12,0.08,3.75),cf(24.08,4.73,data.z),C.amber,Enum.Material.Neon,0.18,false)

    local plate=part(g,"ConnectorPlate",Vector3.new(3.8,0.95,0.12),cf(22,13.25,data.z-1.94),C.black,Enum.Material.Metal,0,false)
    surfaceText(plate,Enum.NormalId.Back,data.label,C.cream)
end

-- Every carriage has a Platform 01 side door around X 13.85 and Z center+0.5.
-- Per-player checkpoints enforce the ticket without a global door that one player could
-- open for everyone. A second full-interior zone prevents bypass through windows/edges.
local carCenters={-58,-5,48,101}
local access=Instance.new("Folder")
access.Name="TicketEntryCheckpoints"
access.Parent=folder

-- Car 01 is the public boarding entry in the intended venue flow. Native Roblox
-- signage makes that entrance obvious from Platform 01 without using image assets.
local entryGuidance=Instance.new("Folder")
entryGuidance.Name="Car01EntryGuidance"
entryGuidance.Parent=folder
local car01DoorZ=carCenters[1]+0.5
local doorMarker=part(entryGuidance,"Car01EnterDoorMarker",Vector3.new(0.18,2.6,7.4),cf(13.34,15.05,car01DoorZ),C.black,Enum.Material.CorrodedMetal,0,false)
surfaceText(doorMarker,Enum.NormalId.Left,"ENTER CAR 01\n↓",C.amber)
local approachBoard=part(entryGuidance,"Car01ApproachBoard",Vector3.new(7.8,3.2,0.28),cf(7.0,7.2,car01DoorZ-7.5),C.black,Enum.Material.CorrodedMetal,0,false)
surfaceText(approachBoard,Enum.NormalId.Front,"ENTER CAR 01  →",C.amber)
surfaceText(approachBoard,Enum.NormalId.Back,"←  ENTER CAR 01",C.amber)
part(entryGuidance,"ApproachPostL",Vector3.new(0.28,5.7,0.28),cf(4.2,4.25,car01DoorZ-7.5),C.steelDark,Enum.Material.CorrodedMetal,0,false)
part(entryGuidance,"ApproachPostR",Vector3.new(0.28,5.7,0.28),cf(9.8,4.25,car01DoorZ-7.5),C.steelDark,Enum.Material.CorrodedMetal,0,false)
local floorGuide=part(entryGuidance,"Car01FloorArrow",Vector3.new(5.2,0.08,2.0),cf(9.5,2.96,car01DoorZ),C.black,Enum.Material.SmoothPlastic,0,false)
surfaceText(floorGuide,Enum.NormalId.Top,"ENTER  →",C.amber)
part(entryGuidance,"Car01ThresholdGuide",Vector3.new(0.16,0.12,6.0),cf(12.72,3.03,car01DoorZ),C.amber,Enum.Material.Neon,0.18,false)
root:SetAttribute("Car01EntryGuidanceVersion","1.0.0")

-- v1.1 sightline pass: the first guidance worked at the door but was hidden by the
-- carriage body from the actual player approach. These non-colliding railway boards
-- sit ahead of the Car 01 end and on the platform side, then hand the player off to a
-- short floor trail and a restrained amber doorway frame. No image assets are used.
local staleSightline=world:FindFirstChild("TRACK01_Car01SightlineGuidance")
if staleSightline then staleSightline:Destroy() end
local sightline=Instance.new("Model")
sightline.Name="TRACK01_Car01SightlineGuidance"
sightline.Parent=folder

local longRangeZ=car01DoorZ-27.0
local longRangeBoard=part(sightline,"LongRangeEntryBoard",Vector3.new(9.4,4.2,0.34),cf(9.6,9.0,longRangeZ),C.black,Enum.Material.CorrodedMetal,0,false)
sightlineText(longRangeBoard,Enum.NormalId.Front,"CAR 01 ENTRY  →","PLATFORM SIDE")
sightlineText(longRangeBoard,Enum.NormalId.Back,"←  CAR 01 ENTRY","PLATFORM SIDE")
part(sightline,"LongRangePostL",Vector3.new(0.32,7.0,0.32),cf(5.7,5.45,longRangeZ),C.steelDark,Enum.Material.CorrodedMetal,0,false)
part(sightline,"LongRangePostR",Vector3.new(0.32,7.0,0.32),cf(13.5,5.45,longRangeZ),C.steelDark,Enum.Material.CorrodedMetal,0,false)
part(sightline,"LongRangeAmberCap",Vector3.new(9.7,0.12,0.40),cf(9.6,11.15,longRangeZ),C.amber,Enum.Material.Metal,0,false)

local midRangeZ=car01DoorZ-15.5
local midRangeBoard=part(sightline,"PlatformSideEntryBoard",Vector3.new(7.4,2.8,0.30),cf(9.4,7.1,midRangeZ),C.black,Enum.Material.CorrodedMetal,0,false)
sightlineText(midRangeBoard,Enum.NormalId.Front,"ENTER CAR 01  →","SIDE DOOR")
sightlineText(midRangeBoard,Enum.NormalId.Back,"←  ENTER CAR 01","SIDE DOOR")
part(sightline,"MidRangePostL",Vector3.new(0.28,5.5,0.28),cf(6.5,4.25,midRangeZ),C.steelDark,Enum.Material.CorrodedMetal,0,false)
part(sightline,"MidRangePostR",Vector3.new(0.28,5.5,0.28),cf(12.3,4.25,midRangeZ),C.steelDark,Enum.Material.CorrodedMetal,0,false)

local trail={
    {x=8.3,z=car01DoorZ-21.5,text="→"},
    {x=8.9,z=car01DoorZ-17.0,text="→"},
    {x=9.6,z=car01DoorZ-12.5,text="→"},
    {x=10.5,z=car01DoorZ-8.2,text="→"},
    {x=11.4,z=car01DoorZ-4.2,text="ENTER  →"},
}
for i,mark in ipairs(trail) do
    local floorMark=part(sightline,string.format("EntryTrail_%02d",i),Vector3.new(i==#trail and 4.2 or 2.5,0.07,1.35),cf(mark.x,2.965,mark.z),C.black,Enum.Material.SmoothPlastic,0,false)
    surfaceText(floorMark,Enum.NormalId.Top,mark.text,C.amber)
end

-- Outline the real Platform 01 side doorway so it reads as an entrance instead of a
-- dark section of the retired maroon carriage. The glow is deliberately restrained.
part(sightline,"DoorFrameNear",Vector3.new(0.14,7.8,0.18),cf(13.18,8.75,car01DoorZ-3.65),C.amber,Enum.Material.Neon,0.28,false)
part(sightline,"DoorFrameFar",Vector3.new(0.14,7.8,0.18),cf(13.18,8.75,car01DoorZ+3.65),C.amber,Enum.Material.Neon,0.28,false)
part(sightline,"DoorFrameTop",Vector3.new(0.14,0.18,7.48),cf(13.18,12.65,car01DoorZ),C.amber,Enum.Material.Neon,0.28,false)
local doorCallout=part(sightline,"DoorEntryCallout",Vector3.new(0.16,1.5,7.1),cf(13.15,13.55,car01DoorZ),C.black,Enum.Material.CorrodedMetal,0,false)
surfaceText(doorCallout,Enum.NormalId.Left,"CAR 01  •  ENTER",C.amber)

root:SetAttribute("Car01EntryGuidanceVersion","1.1.0")
Workspace:SetAttribute("ACC_TRACK01_CAR01_SIGHTLINE_GUIDANCE_READY","v1.1")

local deniedAt={}

local function bouncePlayer(plr,carIndex,doorZ)
    local now=os.clock()
    if deniedAt[plr] and now-deniedAt[plr]<1.5 then return end
    deniedAt[plr]=now
    local character=plr.Character
    local hrp=character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local safe=Vector3.new(8.6,5.6,doorZ)
        local look=Vector3.new(14.0,5.6,doorZ)
        hrp.CFrame=CFrame.lookAt(safe,look)
        hrp.AssemblyLinearVelocity=Vector3.zero
        hrp.AssemblyAngularVelocity=Vector3.zero
    end
    local token=(plr:GetAttribute("TRACK01_ACCESS_DENIED_TOKEN") or 0)+1
    plr:SetAttribute("TRACK01_ACCESS_DENIED_CAR",carIndex)
    plr:SetAttribute("TRACK01_ACCESS_DENIED_TOKEN",token)
end

local function handleTicketTouch(hit,carIndex,doorZ)
    local character=hit and hit:FindFirstAncestorOfClass("Model")
    if not character then return end
    local plr=Players:GetPlayerFromCharacter(character)
    if not plr then return end
    if plr:GetAttribute("TRACK01_TICKET")==true then
        plr:SetAttribute("TRACK01_ACCESS_GRANTED",true)
        return
    end
    bouncePlayer(plr,carIndex,doorZ)
end

for i,centerZ in ipairs(carCenters) do
    local doorZ=centerZ+0.5

    local zone=Instance.new("Part")
    zone.Name=string.format("Car%02dTicketCheckpoint",i)
    zone.Size=Vector3.new(4.4,8.8,7.2)
    zone.CFrame=cf(14.25,8.35,doorZ)
    zone.Transparency=1
    zone.Anchored=true
    zone.CanCollide=false
    zone.CanTouch=true
    zone.CanQuery=false
    zone.CastShadow=false
    zone.Parent=access
    zone.Touched:Connect(function(hit) handleTicketTouch(hit,i,doorZ) end)

    -- Backup enforcement volume covers the walkable interior of the carriage.
    local interiorZone=Instance.new("Part")
    interiorZone.Name=string.format("Car%02dInteriorTicketZone",i)
    interiorZone.Size=Vector3.new(14.0,7.8,46.5)
    interiorZone.CFrame=cf(22,8.5,centerZ)
    interiorZone.Transparency=1
    interiorZone.Anchored=true
    interiorZone.CanCollide=false
    interiorZone.CanTouch=true
    interiorZone.CanQuery=false
    interiorZone.CastShadow=false
    interiorZone.Parent=access
    interiorZone.Touched:Connect(function(hit) handleTicketTouch(hit,i,doorZ) end)

    local plate=part(access,string.format("Car%02dTicketPlate",i),Vector3.new(0.18,1.15,5.6),cf(13.43,13.55,doorZ),C.black,Enum.Material.Metal,0,false)
    surfaceText(plate,Enum.NormalId.Left,"NIGHT TICKET REQUIRED\nCAR "..string.format("%02d",i),C.amber)
end

Players.PlayerRemoving:Connect(function(plr)
    deniedAt[plr]=nil
end)

root:SetAttribute("TicketAccessVersion","3.7.0")
root:SetAttribute("VestibuleCount",#connectors)
root:SetAttribute("TicketProtectedCarCount",#carCenters)
Workspace:SetAttribute("ACC_TRACK01_TICKET_ACCESS_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VESTIBULES_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.7.0")
print("[TRACK 01] v3.7 ticket access + enclosed vestibules ready")
