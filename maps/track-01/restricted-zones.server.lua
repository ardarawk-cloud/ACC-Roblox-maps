local Workspace=game:GetService("Workspace")

-- TRACK 01 v3.1 restricted-zone visual pass.
-- Decorative POLICE LINE / RESTRICTED AREA tape only. Nothing here blocks player circulation.
local deadline=os.clock()+55
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_PREMIUM_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_RestrictedZones_v31")
if old then old:Destroy() end
local folder=Instance.new("Folder")
folder.Name="TRACK01_RestrictedZones_v31"
folder.Parent=world

local YELLOW=Color3.fromRGB(226,184,41)
local BLACK=Color3.fromRGB(20,20,18)
local RED=Color3.fromRGB(123,31,32)
local STEEL=Color3.fromRGB(63,64,61)

local function tape(name,size,frame,text)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=YELLOW
    p.Material=Enum.Material.SmoothPlastic
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=folder

    for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
        local gui=Instance.new("SurfaceGui")
        gui.Name="PoliceLineLabel"
        gui.Face=face
        gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud=48
        gui.LightInfluence=0.15
        gui.AlwaysOnTop=false
        gui.Parent=p
        local label=Instance.new("TextLabel")
        label.Size=UDim2.fromScale(1,1)
        label.BackgroundColor3=YELLOW
        label.BorderSizePixel=0
        label.Text=text or "POLICE LINE  •  DO NOT CROSS  •  POLICE LINE"
        label.TextColor3=BLACK
        label.TextScaled=true
        label.TextWrapped=false
        label.Font=Enum.Font.GothamBlack
        label.Parent=gui
    end
    return p
end

local function warningPlate(name,size,frame,title,sub)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=BLACK
    p.Material=Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=false
    p.Parent=folder
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=48
    gui.LightInfluence=0.15
    gui.Parent=p
    local bg=Instance.new("Frame")
    bg.Size=UDim2.fromScale(1,1)
    bg.BackgroundColor3=BLACK
    bg.BorderSizePixel=0
    bg.Parent=gui
    local top=Instance.new("TextLabel")
    top.Size=UDim2.new(1,-10,0.58,0)
    top.Position=UDim2.fromOffset(5,2)
    top.BackgroundTransparency=1
    top.Text=title
    top.TextColor3=YELLOW
    top.TextScaled=true
    top.Font=Enum.Font.GothamBlack
    top.Parent=bg
    local small=Instance.new("TextLabel")
    small.Size=UDim2.new(1,-10,0.34,0)
    small.Position=UDim2.new(0,5,0.63,0)
    small.BackgroundTransparency=1
    small.Text=sub
    small.TextColor3=Color3.fromRGB(210,207,194)
    small.TextScaled=true
    small.Font=Enum.Font.RobotoMono
    small.Parent=bg
    return p
end

-- Closed station facility doors. They currently have no playable interiors, so the tape explains the closure.
for _,spec in ipairs({
    {-24,-148.30,"TEMPORARILY CLOSED"},
    {-51,-148.30,"STAFF / OPERATIONS ONLY"},
}) do
    local x,z,subtitle=spec[1],spec[2],spec[3]
    tape("FacilityPoliceLineA",Vector3.new(8.8,0.55,0.08),CFrame.new(x,6.2,z)*CFrame.Angles(0,0,math.rad(13)))
    tape("FacilityPoliceLineB",Vector3.new(8.8,0.55,0.08),CFrame.new(x,4.7,z-0.01)*CFrame.Angles(0,0,math.rad(-12)))
    warningPlate("FacilityRestrictedPlate",Vector3.new(5.8,2.1,0.12),CFrame.new(x,8.3,z-0.02),"RESTRICTED AREA",subtitle)
end

-- Old ticket/service window: visually sealed until a future interactive counter is implemented.
tape("TicketCounterPoliceLine",Vector3.new(18.0,0.50,0.08),CFrame.new(-54,7.3,-132.35)*CFrame.Angles(0,0,math.rad(-4)),"POLICE LINE  •  COUNTER CLOSED  •  POLICE LINE")
warningPlate("TicketCounterClosed",Vector3.new(7.2,2.0,0.12),CFrame.new(-54,10.0,-132.30),"COUNTER CLOSED","USE MAIN CHECK-IN")

-- End-of-line buffer / track beyond Car 04. This is intentionally inaccessible railway infrastructure.
tape("EndOfLinePoliceTape",Vector3.new(17.2,0.62,0.10),CFrame.new(22,5.1,133.45),"POLICE LINE  •  NO FURTHER SERVICE  •  DO NOT CROSS")
warningPlate("EndOfLineRestricted",Vector3.new(8.0,2.4,0.14),CFrame.new(22,7.1,133.40),"TRACK CLOSED","END OF LINE")

-- Signal-maintenance pocket near the far rail end: detail-only zone, never a gameplay route.
for _,x in ipairs({31.5,38.5}) do
    local post=Instance.new("Part")
    post.Name="RestrictedPost"
    post.Size=Vector3.new(0.35,4.8,0.35)
    post.CFrame=CFrame.new(x,3.0,143.5)
    post.Color=STEEL
    post.Material=Enum.Material.CorrodedMetal
    post.Anchored=true
    post.CanCollide=false
    post.CanTouch=false
    post.CanQuery=false
    post.CastShadow=false
    post.Parent=folder
end
tape("SignalPocketPoliceLine",Vector3.new(7.2,0.48,0.08),CFrame.new(35,4.5,143.45),"POLICE LINE  •  SIGNAL MAINTENANCE")

-- Small crossed-tape accents on unused back-wall panels make dead geometry feel intentional.
for _,spec in ipairs({
    {-67.7,7.2,-111.0,12},
    {-67.7,7.2,-121.0,-11},
}) do
    local x,y,z,ang=spec[1],spec[2],spec[3],spec[4]
    tape("BackWallPoliceSticker",Vector3.new(5.5,0.42,0.07),CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(90),math.rad(ang)),"RESTRICTED  •  RESTRICTED")
end

root:SetAttribute("RestrictedZoneVersion","3.1.0")
Workspace:SetAttribute("ACC_TRACK01_RESTRICTED_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.1.0")
print("[TRACK 01] restricted-zone police line treatment ready v3.1.0")
