local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")

-- TRACK 01 lobby functional cleanup.
-- Scope: lobby/ticket/security/platform approach only. No audio, train-car, yard,
-- admin, PA, signage-system, or unrelated gameplay changes.
local deadline=os.clock()+90
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_SIGNAL_NIGHT_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local architecture=world and world:FindFirstChild("Architecture")
if not (world and architecture) then return end

local old=world:FindFirstChild("TRACK01_LobbyFlowCleanup_v1")
if old then old:Destroy() end
local cleanup=Instance.new("Folder")
cleanup.Name="TRACK01_LobbyFlowCleanup_v1"
cleanup.Parent=world

local C={
    black=Color3.fromRGB(16,17,17),
    charcoal=Color3.fromRGB(31,32,31),
    steel=Color3.fromRGB(91,92,88),
    cream=Color3.fromRGB(205,190,157),
    amber=Color3.fromRGB(223,145,62),
    red=Color3.fromRGB(154,40,35),
    green=Color3.fromRGB(74,126,83),
    warm=Color3.fromRGB(232,215,188),
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

local function surfaceText(target,face,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="LobbyFlowSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=48
    gui.LightInfluence=0.18
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Name="StatusText"
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bgColor or C.black
    label.BackgroundTransparency=0.06
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=font or Enum.Font.RobotoMono
    label.Parent=gui
    return label
end

local function prompt(parent,action,objectText,hold)
    local p=Instance.new("ProximityPrompt")
    p.Name="TRACK01LobbyPrompt"
    p.ActionText=action
    p.ObjectText=objectText
    p.HoldDuration=hold or 0.25
    p.MaxActivationDistance=10
    p.RequiresLineOfSight=false
    p.KeyboardKeyCode=Enum.KeyCode.E
    p.GamepadKeyCode=Enum.KeyCode.ButtonX
    p.Parent=parent
    return p
end

local function flash(partObj,label,text,color,seconds,defaultText,defaultColor)
    partObj.Color=color
    label.Text=text
    label.TextColor3=color
    task.delay(seconds or 1.8,function()
        if partObj.Parent and label.Parent then
            partObj.Color=defaultColor or C.black
            label.Text=defaultText
            label.TextColor3=C.cream
        end
    end)
end

local function destroyNamed(parent,names)
    if not parent then return end
    local wanted={}
    for _,name in ipairs(names) do wanted[name]=true end
    for _,obj in ipairs(parent:GetDescendants()) do
        if wanted[obj.Name] then obj:Destroy() end
    end
end

-- Remove the old respawn fixture set. Those lamps were positioned from spawn offsets,
-- not from actual wall/ceiling attachment points, so after the lobby spawn moved they
-- could read as floating decorative objects. Keep only one invisible functional fill.
local respawnLighting=world:FindFirstChild("RespawnLighting_v231")
if respawnLighting then respawnLighting:Destroy() end
local fillAnchor=part(cleanup,"LobbyReadabilityFill",Vector3.new(0.3,0.3,0.3),cf(-38,13.5,-116),C.warm,Enum.Material.SmoothPlastic,1,false)
local fill=Instance.new("PointLight")
fill.Name="LobbyReadabilityLight"
fill.Color=C.warm
fill.Brightness=0.48
fill.Range=28
fill.Shadows=false
fill.Parent=fillAnchor

-- Remove the previous zig-zag security desk/queue layout and decorative floor lights.
local operations=world:FindFirstChild("TRACK01_Operations_v27")
if operations then
    local security=operations:FindFirstChild("SecurityCheckIn")
    if security then security:Destroy() end
    local wayfinding=operations:FindFirstChild("Wayfinding")
    if wayfinding then
        destroyNamed(wayfinding,{"FloorGuide","HallWayfinder"})
    end
end

-- The ticket counter is now functional, so old CLOSED / POLICE LINE treatment and its
-- warning beacon are contradictory and are removed only from the lobby ticket area.
local restricted=world:FindFirstChild("TRACK01_RestrictedZones_v31")
if restricted then
    destroyNamed(restricted,{"TicketCounterPoliceLine","TicketCounterClosed","BackWallPoliceSticker"})
end
local signalNight=world:FindFirstChild("TRACK01_SignalNight_v33")
if signalNight then
    destroyNamed(signalNight,{"TicketCounterWarningHousing","TicketCounterWarningRedBeacon"})
end

-- Remove the three disconnected interaction stations from the older flow:
-- freestanding ticket machine -> separate check-in terminal -> distant platform scan.
local interactive=world:FindFirstChild("TRACK01_InteractiveStation_v32")
if interactive then
    destroyNamed(interactive,{
        "NightTicketMachine","TicketMachineTop","TicketScreen",
        "CheckInTerminal","CheckInScreen","InteractiveBoardingGate"
    })
end

-- STEP 1: use the actual old-station ticket counter as the only ticket source.
local station=architecture:FindFirstChild("OldStation")
local ticketCounter=station and station:FindFirstChild("TicketCounter")
if ticketCounter and ticketCounter:IsA("BasePart") then
    for _,child in ipairs(ticketCounter:GetChildren()) do
        if child:IsA("ProximityPrompt") then child:Destroy() end
    end

    local ticketStatus=part(cleanup,"TicketStatus",Vector3.new(10.5,1.7,0.16),cf(-54,7.0,-132.75),C.black,Enum.Material.Metal,0,false)
    local ticketLabel=surfaceText(ticketStatus,Enum.NormalId.Front,"NIGHT TICKET  •  CLAIM HERE",C.amber,C.black,Enum.Font.GothamBold)
    local ticketPrompt=prompt(ticketCounter,"CLAIM TICKET","TICKETS • TRACK 01",0.30)
    ticketPrompt.Triggered:Connect(function(plr)
        if plr:GetAttribute("TRACK01_TICKET")==true then
            flash(ticketStatus,ticketLabel,"TICKET ALREADY ISSUED",C.amber,1.5,"NIGHT TICKET  •  CLAIM HERE",C.black)
            return
        end
        plr:SetAttribute("TRACK01_TICKET",true)
        flash(ticketStatus,ticketLabel,"TICKET ISSUED  →  SECURITY",C.green,2.0,"NIGHT TICKET  •  CLAIM HERE",C.black)
    end)
end

-- STEP 2: one security checkpoint is placed directly beside the real right-wall opening
-- to Platform 01. Player route is now: ticket counter -> security scan -> platform.
local security=Instance.new("Folder")
security.Name="LobbySecurityCheckpoint"
security.Parent=cleanup

-- Arch follows the east-west walking direction through the opening at X ~= -5,
-- spanning Z so it reads as a doorway rather than a wall across the hall.
for _,z in ipairs({-121.0,-109.0}) do
    part(security,"SecurityArchPost",Vector3.new(0.58,7.8,0.58),cf(-10.0,5.0,z),C.charcoal,Enum.Material.Metal,0,false)
end
part(security,"SecurityArchTop",Vector3.new(0.58,0.58,12.6),cf(-10.0,8.9,-115.0),C.charcoal,Enum.Material.Metal,0,false)
local securitySign=part(security,"SecuritySign",Vector3.new(0.18,1.8,10.8),cf(-9.65,7.55,-115.0),C.black,Enum.Material.Metal,0,false)
surfaceText(securitySign,Enum.NormalId.Left,"SECURITY  /  TICKET SCAN",C.cream,C.black,Enum.Font.GothamBold)

-- One staffed desk sits off the passage, on the south edge of the opening.
local desk=part(security,"SecurityDesk",Vector3.new(6.2,3.2,2.2),cf(-16.0,2.8,-125.0),C.charcoal,Enum.Material.Metal,0,true)
part(security,"SecurityDeskTop",Vector3.new(6.5,0.24,2.5),cf(-16.0,4.52,-125.0),C.steel,Enum.Material.Metal,0,false)
local scanScreen=part(security,"SecurityScanScreen",Vector3.new(3.8,1.35,0.15),cf(-16.0,5.25,-126.28),C.black,Enum.Material.Glass,0,false)
local scanLabel=surfaceText(scanScreen,Enum.NormalId.Front,"SCAN TICKET",C.amber,C.black,Enum.Font.GothamBold)
local scanPrompt=prompt(desk,"SCAN TICKET","SECURITY • TRACK 01",0.30)
scanPrompt.Triggered:Connect(function(plr)
    if plr:GetAttribute("TRACK01_TICKET")~=true then
        flash(scanScreen,scanLabel,"NO TICKET  •  USE COUNTER",C.red,2.0,"SCAN TICKET",C.black)
        return
    end
    plr:SetAttribute("TRACK01_CHECKED_IN",true)
    plr:SetAttribute("TRACK01_BOARDED",true)
    plr:SetAttribute("TRACK01_ACCESS_GRANTED",true)
    flash(scanScreen,scanLabel,"ACCESS VERIFIED  →  PLATFORM 01",C.green,2.2,"SCAN TICKET",C.black)
end)

-- Small non-glowing directional plate at the actual opening; no floor trail, no extra lamps.
local platformPlate=part(security,"Platform01Direction",Vector3.new(0.16,1.4,7.6),cf(-5.75,7.0,-115.0),C.black,Enum.Material.Metal,0,false)
surfaceText(platformPlate,Enum.NormalId.Left,"PLATFORM 01  →",C.cream,C.black,Enum.Font.RobotoMono)

root:SetAttribute("LobbyFlowVersion","1.0.0")
root:SetAttribute("LobbyFlowMode","TICKET_COUNTER_SECURITY_PLATFORM")
Workspace:SetAttribute("ACC_TRACK01_LOBBY_FLOW_CLEANUP_READY",true)
print("[TRACK 01] lobby flow cleanup ready: ticket counter -> security scan -> Platform 01")
