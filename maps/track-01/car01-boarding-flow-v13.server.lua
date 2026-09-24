local Workspace=game:GetService("Workspace")

-- TRACK 01 Platform 01 -> Car 01 boarding flow v1.3
-- Scope: boarding approach only. Preserve ticket/security, audio, interiors, yard and other cars.
local deadline=os.clock()+90
repeat
    task.wait(0.15)
until (
    Workspace:GetAttribute("ACC_TRACK01_TICKET_ACCESS_READY") and
    Workspace:GetAttribute("ACC_TRACK01_CAR01_ARROW_GUIDANCE_READY")
) or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_Car01BoardingFlow_v13")
if old then old:Destroy() end
local flow=Instance.new("Folder")
flow.Name="TRACK01_Car01BoardingFlow_v13"
flow.Parent=world

local function destroyNamed(parent,names)
    if not parent then return end
    local wanted={}
    for _,name in ipairs(names) do wanted[name]=true end
    for _,obj in ipairs(parent:GetDescendants()) do
        if wanted[obj.Name] then obj:Destroy() end
    end
end

-- Retire old hall/platform guidance that competes with the approved arrow-only Car 01 cue.
local props=world:FindFirstChild("Props")
destroyNamed(props,{"EntryMarker","EntryText"})
local operations=world:FindFirstChild("TRACK01_Operations_v27")
local wayfinding=operations and operations:FindFirstChild("Wayfinding")
destroyNamed(wayfinding,{"PlatformWayfinder"})

-- Keep exactly the approved restrained blinking amber arrow at Car 01.
-- Remove the rigid neon doorway outline; the real railway door frame remains untouched.
local accessFolder=world:FindFirstChild("TRACK01_TicketAccessVestibule_v37")
local guidance=accessFolder and accessFolder:FindFirstChild("Car01EntryGuidance",true)
if guidance then
    destroyNamed(guidance,{"Car01DoorFrameNear","Car01DoorFrameFar","Car01DoorFrameTop"})
    local arrow=guidance:FindFirstChild("Car01BlinkArrowMount",true)
    if arrow and arrow:IsA("BasePart") then
        arrow.CanCollide=false
        arrow.CanTouch=false
        arrow.CanQuery=false
        arrow.CastShadow=false
    end
end

-- Close the small physical gap between Platform 01 and the actual Car 01 side-door step.
-- This is functional aged railway steel, not a decorative floor marker.
local bridge=Instance.new("Part")
bridge.Name="Car01BoardingBridge"
bridge.Size=Vector3.new(1.30,0.34,5.80)
bridge.CFrame=CFrame.new(13.42,4.02,-57.50)
bridge.Color=Color3.fromRGB(91,92,88)
bridge.Material=Enum.Material.DiamondPlate
bridge.Anchored=true
bridge.CanCollide=true
bridge.CanTouch=false
bridge.CanQuery=true
bridge.CastShadow=true
bridge.TopSurface=Enum.SurfaceType.Smooth
bridge.BottomSurface=Enum.SurfaceType.Smooth
bridge.Parent=flow

-- Invisible reference zone for runtime QC only; it never blocks the player.
local qc=Instance.new("Part")
qc.Name="Car01BoardingQCZone"
qc.Size=Vector3.new(6.0,8.0,7.0)
qc.CFrame=CFrame.new(11.5,7.0,-57.5)
qc.Transparency=1
qc.Anchored=true
qc.CanCollide=false
qc.CanTouch=false
qc.CanQuery=false
qc.CastShadow=false
qc.Parent=flow

root:SetAttribute("Car01BoardingFlowVersion","1.3.0")
root:SetAttribute("Car01BoardingCue","BLINKING_AMBER_ARROW_ONLY")
root:SetAttribute("Car01BoardingBridge",true)
Workspace:SetAttribute("ACC_TRACK01_CAR01_BOARDING_FLOW_READY",true)
print("[TRACK 01] Platform 01 -> Car 01 boarding v1.3 ready: arrow-only cue + clear steel threshold")
