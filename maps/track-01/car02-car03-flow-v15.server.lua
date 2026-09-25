local Workspace=game:GetService("Workspace")

-- TRACK 01 v4.2.5 — Car 02 Bar -> Car 03 Dance transition flow
-- Scope: preserve bar function, clear the walking lane, de-neon vestibule 02,
-- and make Car 03 identity immediate after the gangway.
local deadline=os.clock()+90
local function dependenciesReady()
    return
        Workspace:GetAttribute("ACC_TRACK01_CAR01_CAR02_FLOW_READY") and
        Workspace:GetAttribute("ACC_TRACK01_SOCIAL_READY") and
        Workspace:GetAttribute("ACC_TRACK01_VESTIBULES_READY") and
        Workspace:GetAttribute("ACC_TRACK01_INTERIOR_READY")
end
repeat
    task.wait(0.15)
until dependenciesReady() or os.clock()>deadline
if not dependenciesReady() then
    warn("[TRACK 01] Car 02 -> Car 03 flow v1.5 skipped: dependency timeout")
    return
end

local root=Workspace:FindFirstChild("ACC_TRACK01")
local world=root and root:FindFirstChild("World")
if not (root and world) then return end

local old=world:FindFirstChild("TRACK01_Car02Car03Flow_v15")
if old then old:Destroy() end
local flow=Instance.new("Folder")
flow.Name="TRACK01_Car02Car03Flow_v15"
flow.Parent=world

-- CAR 02: keep the service bar, but pull the collidable counter/top fully out of
-- the central keep-clear lane. Cosmetic taps, shelves, drinks and standing tables remain unchanged.
local train=world:FindFirstChild("TrainCars")
local car2=train and train:FindFirstChild("CAR_02_BAR")
local resized=0
if car2 then
    local counter=car2:FindFirstChild("BarCounter")
    if counter and counter:IsA("BasePart") then
        counter.Size=Vector3.new(3.6,4.2,31)
        counter.CFrame=CFrame.new(27.0,6.4,-5)
        resized+=1
    end
    local top=car2:FindFirstChild("BarTop")
    if top and top:IsA("BasePart") then
        top.Size=Vector3.new(4.1,0.45,32)
        top.CFrame=CFrame.new(27.25,8.7,-5)
        resized+=1
    end
end

-- Vestibule 02 stays as a real enclosed railway gangway.
-- Replace only the glowing threshold accents with subdued railway metal.
local ticketSystem=world:FindFirstChild("TRACK01_TicketAccessVestibule_v37")
local vestibules=ticketSystem and ticketSystem:FindFirstChild("EnclosedInterCarVestibules")
local secondVestibule=vestibules and vestibules:FindFirstChild("Vestibule_02")
if secondVestibule then
    for _,name in ipairs({"ThresholdMarkerL","ThresholdMarkerR"}) do
        local marker=secondVestibule:FindFirstChild(name)
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
    black=Color3.fromRGB(17,18,18),
    cream=Color3.fromRGB(176,157,119),
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
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end
local function surfaceText(target,text,color)
    local gui=Instance.new("SurfaceGui")
    gui.Name="Car03EntryPlaqueGui"
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

-- One restrained wall plaque just inside Car 03. No floor arrows or additional neon field.
local plaque=part(
    flow,
    "Car03EntryPlaque",
    Vector3.new(0.14,2.0,6.8),
    CFrame.new(29.12,11.35,27.0),
    C.black,
    Enum.Material.Metal
)
surfaceText(plaque,"DANCE CAR  /  03",C.cream)

-- Invisible QC reference only.
local qc=part(
    flow,
    "Car02ToCar03QCZone",
    Vector3.new(8.0,8.0,12.0),
    CFrame.new(22,8.0,21.5),
    C.black,
    Enum.Material.SmoothPlastic
)
qc.Transparency=1

root:SetAttribute("Car02Car03FlowVersion","1.5.0")
root:SetAttribute("Car02BarCollisionAdjusted",resized)
root:SetAttribute("Car03EntryIdentity","DANCE CAR / 03")
Workspace:SetAttribute("ACC_TRACK01_CAR02_CAR03_FLOW_READY",true)
print("[TRACK 01] Car 02 -> Car 03 flow v1.5 ready; bar parts adjusted:",resized)
