local Workspace=game:GetService("Workspace")

-- TRACK 01 v4.2.4 — Car 01 interior -> Car 02 transition flow
-- Scope: clear Car 01 aisle, keep seating, de-neon first vestibule, make Car 02 identity immediate.
local deadline=os.clock()+90
repeat
    task.wait(0.15)
until (
    Workspace:GetAttribute("ACC_TRACK01_CAR01_BOARDING_FLOW_READY") and
    Workspace:GetAttribute("ACC_TRACK01_SOCIAL_READY") and
    Workspace:GetAttribute("ACC_TRACK01_VESTIBULES_READY")
) or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
local world=root and root:FindFirstChild("World")
if not (root and world) then return end

local old=world:FindFirstChild("TRACK01_Car01Car02Flow_v14")
if old then old:Destroy() end
local flow=Instance.new("Folder")
flow.Name="TRACK01_Car01Car02Flow_v14"
flow.Parent=world

local function destroyDirectNamed(parent,name)
    if not parent then return 0 end
    local removed=0
    for _,obj in ipairs(parent:GetChildren()) do
        if obj.Name==name then
            obj:Destroy()
            removed+=1
        end
    end
    return removed
end

-- CAR 01: the original three center-aisle tables narrow the walking lane.
-- Keep both seating zones and all social prompts; remove only the duplicate center table geometry.
local train=world:FindFirstChild("TrainCars")
local car1=train and train:FindFirstChild("CAR_01_SOCIAL")
local removedTables=0
removedTables+=destroyDirectNamed(car1,"Table")
removedTables+=destroyDirectNamed(car1,"TableStem")

local interior=world:FindFirstChild("TRACK01_Interior_v25")
local car1Detail=interior and interior:FindFirstChild("Car01SocialDetail")
removedTables+=destroyDirectNamed(car1Detail,"TableRim")

-- First vestibule: preserve the enclosed railway gangway and collision geometry,
-- but remove the arcade-like neon threshold treatment.
local ticketSystem=world:FindFirstChild("TRACK01_TicketAccessVestibule_v37")
local vestibules=ticketSystem and ticketSystem:FindFirstChild("EnclosedInterCarVestibules")
local firstVestibule=vestibules and vestibules:FindFirstChild("Vestibule_01")
if firstVestibule then
    for _,name in ipairs({"ThresholdMarkerL","ThresholdMarkerR"}) do
        local marker=firstVestibule:FindFirstChild(name)
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
    amber=Color3.fromRGB(235,153,72),
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
    gui.Name="Car02EntryPlaqueGui"
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

-- CAR 02 identity appears immediately after the Car 01 -> Car 02 gangway.
-- One small railway-style wall plaque only; no arrow field, floor trail or freestanding board.
local plaque=part(
    flow,
    "Car02EntryPlaque",
    Vector3.new(0.14,2.0,6.4),
    CFrame.new(29.12,11.35,-26.2),
    C.black,
    Enum.Material.Metal
)
surfaceText(plaque,"BAR CAR  /  02",C.amber)

local qc=part(
    flow,
    "Car01ToCar02QCZone",
    Vector3.new(8.0,8.0,12.0),
    CFrame.new(22,8.0,-31.0),
    C.black,
    Enum.Material.SmoothPlastic
)
qc.Transparency=1

root:SetAttribute("Car01Car02FlowVersion","1.4.0")
root:SetAttribute("Car01AisleTablesRemoved",removedTables)
root:SetAttribute("Car02EntryIdentity","BAR CAR / 02")
Workspace:SetAttribute("ACC_TRACK01_CAR01_CAR02_FLOW_READY",true)
print("[TRACK 01] Car 01 -> Car 02 flow v1.4 ready; removed center-table parts:",removedTables)
