local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")

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

    part(g,"GangwayFloor",Vector3.new(4.4,0.35,4.15),cf(22,4.525,data.z),C.steelDark,Enum.Material.DiamondPlate,0,true)
    part(g,"BellowsLeft",Vector3.new(0.34,9.7,4.20),cf(19.55,9.35,data.z),C.rubber,Enum.Material.SmoothPlastic,0,true)
    part(g,"BellowsRight",Vector3.new(0.34,9.7,4.20),cf(24.45,9.35,data.z),C.rubber,Enum.Material.SmoothPlastic,0,true)
    part(g,"GangwayRoof",Vector3.new(4.55,0.38,4.20),cf(22,14.35,data.z),C.steelDark,Enum.Material.CorrodedMetal,0,true)

    for _,dz in ipairs({-1.55,-0.75,0,0.75,1.55}) do
        part(g,"BellowsRibL",Vector3.new(0.18,9.5,0.18),cf(19.76,9.35,data.z+dz),C.steel,Enum.Material.Metal,0,false)
        part(g,"BellowsRibR",Vector3.new(0.18,9.5,0.18),cf(24.24,9.35,data.z+dz),C.steel,Enum.Material.Metal,0,false)
        part(g,"RoofRib",Vector3.new(4.15,0.16,0.18),cf(22,14.08,data.z+dz),C.steel,Enum.Material.Metal,0,false)
    end

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

-- Car 01 entry guidance v1.2: intentionally minimal. One blinking native Roblox
-- amber arrow is mounted on the carriage body to the LEFT of the side door and points
-- RIGHT into the actual doorway. No freestanding boards, floor trail or image assets.
local entryGuidance=Instance.new("Folder")
entryGuidance.Name="Car01EntryGuidance"
entryGuidance.Parent=folder
local car01DoorZ=carCenters[1]+0.5

local arrowMount=part(entryGuidance,"Car01BlinkArrowMount",Vector3.new(0.14,2.5,4.4),cf(13.22,9.25,car01DoorZ-5.4),C.black,Enum.Material.CorrodedMetal,0.22,false)
local arrowGui=Instance.new("SurfaceGui")
arrowGui.Name="Car01BlinkArrowGui"
arrowGui.Face=Enum.NormalId.Left
arrowGui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
arrowGui.PixelsPerStud=64
arrowGui.LightInfluence=0.04
arrowGui.Parent=arrowMount
local arrowLabel=Instance.new("TextLabel")
arrowLabel.Name="Arrow"
arrowLabel.Size=UDim2.fromScale(1,1)
arrowLabel.BackgroundTransparency=1
arrowLabel.BorderSizePixel=0
arrowLabel.Text="→"
arrowLabel.TextColor3=C.amber
arrowLabel.TextStrokeColor3=Color3.fromRGB(78,43,16)
arrowLabel.TextStrokeTransparency=0.18
arrowLabel.TextScaled=true
arrowLabel.Font=Enum.Font.RobotoMono
arrowLabel.Parent=arrowGui
TweenService:Create(
    arrowLabel,
    TweenInfo.new(0.72,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
    {TextTransparency=0.58,TextStrokeTransparency=0.72}
):Play()

-- A restrained doorway outline is the only secondary cue so the arrow has an obvious
-- destination without adding visual clutter to Platform 01.
part(entryGuidance,"Car01DoorFrameNear",Vector3.new(0.12,7.6,0.14),cf(13.17,8.75,car01DoorZ-3.62),C.amber,Enum.Material.Neon,0.34,false)
part(entryGuidance,"Car01DoorFrameFar",Vector3.new(0.12,7.6,0.14),cf(13.17,8.75,car01DoorZ+3.62),C.amber,Enum.Material.Neon,0.34,false)
part(entryGuidance,"Car01DoorFrameTop",Vector3.new(0.12,0.14,7.36),cf(13.17,12.55,car01DoorZ),C.amber,Enum.Material.Neon,0.34,false)

root:SetAttribute("Car01EntryGuidanceVersion","1.2.0")
Workspace:SetAttribute("ACC_TRACK01_CAR01_ARROW_GUIDANCE_READY","v1.2")

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
