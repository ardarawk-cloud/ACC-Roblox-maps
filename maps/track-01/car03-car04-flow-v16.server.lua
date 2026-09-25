local Workspace=game:GetService("Workspace")

-- TRACK 01 v4.2.6 — Car 03 Dance -> Car 04 END OF LINE transition flow
-- Scope: preserve Car 03 dance floor and Car 04 hero booth, simplify vestibule 03,
-- and make Car 04 identity immediate on entry without adding redundant guidance clutter.
local deadline=os.clock()+90
local function dependenciesReady()
    return
        Workspace:GetAttribute("ACC_TRACK01_CAR02_CAR03_FLOW_READY") and
        Workspace:GetAttribute("ACC_TRACK01_VESTIBULES_READY") and
        Workspace:GetAttribute("ACC_TRACK01_INTERIOR_READY") and
        Workspace:GetAttribute("ACC_TRACK01_ENDLINE_HERO_READY")
end
repeat
    task.wait(0.15)
until dependenciesReady() or os.clock()>deadline
if not dependenciesReady() then
    warn("[TRACK 01] Car 03 -> Car 04 flow v1.6 skipped: dependency timeout")
    return
end

local root=Workspace:FindFirstChild("ACC_TRACK01")
local world=root and root:FindFirstChild("World")
if not (root and world) then return end

local old=world:FindFirstChild("TRACK01_Car03Car04Flow_v16")
if old then old:Destroy() end
local flow=Instance.new("Folder")
flow.Name="TRACK01_Car03Car04Flow_v16"
flow.Parent=world

-- Vestibule 03 remains a real enclosed railway gangway.
-- Replace only the glowing threshold accents with restrained railway metal.
local ticketSystem=world:FindFirstChild("TRACK01_TicketAccessVestibule_v37")
local vestibules=ticketSystem and ticketSystem:FindFirstChild("EnclosedInterCarVestibules")
local thirdVestibule=vestibules and vestibules:FindFirstChild("Vestibule_03")
if thirdVestibule then
    for _,name in ipairs({"ThresholdMarkerL","ThresholdMarkerR"}) do
        local marker=thirdVestibule:FindFirstChild(name)
        if marker and marker:IsA("BasePart") then
            marker.Material=Enum.Material.Metal
            marker.Color=Color3.fromRGB(112,111,105)
            marker.Transparency=0.12
            marker.CanCollide=false
            marker.CanTouch=false
            marker.CanQuery=false
        end
    end
end

local C={
    black=Color3.fromRGB(14,15,15),
    red=Color3.fromRGB(181,40,36),
}
local function part(parent,name,size,frame,color,material)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color
    p.Material=material or Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end
local function surfaceText(target,text,color)
    local gui=Instance.new("SurfaceGui")
    gui.Name="Car04EntryPlaqueGui"
    gui.Face=Enum.NormalId.Left
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=58
    gui.LightInfluence=0.15
    gui.Parent=target

    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=C.black
    label.BackgroundTransparency=0.04
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=color
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=Enum.Font.RobotoMono
    label.Parent=gui
end

-- Immediate identity on entry. The existing rear hero sign remains the visual destination.
-- No arrows, floor trail, freestanding board or extra neon field are added.
local plaque=part(
    flow,
    "Car04EntryPlaque",
    Vector3.new(0.14,2.0,7.2),
    CFrame.new(29.12,11.35,80.0),
    C.black,
    Enum.Material.Metal
)
surfaceText(plaque,"CAR 04  /  END OF LINE",C.red)

-- Invisible runtime-QC reference only.
local qc=part(
    flow,
    "Car03ToCar04QCZone",
    Vector3.new(8.0,8.0,12.0),
    CFrame.new(22,8.0,74.5),
    C.black,
    Enum.Material.SmoothPlastic
)
qc.Transparency=1

root:SetAttribute("Car03Car04FlowVersion","1.6.0")
root:SetAttribute("Car04EntryIdentity","CAR 04 / END OF LINE")
root:SetAttribute("Car04HeroDestinationPreserved",true)
Workspace:SetAttribute("ACC_TRACK01_CAR03_CAR04_FLOW_READY",true)
print("[TRACK 01] Car 03 -> Car 04 flow v1.6 ready: railway vestibule + immediate END OF LINE identity")
