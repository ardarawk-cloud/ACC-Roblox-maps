local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")

-- TRACK 01 v4.2.7 — Car 04 / END OF LINE -> The Yard final-route pass
-- Scope: preserve all prior venue systems, add one restrained exit cue,
-- and add runtime-only checkpoints for END OF LINE then YARD.
local deadline=os.clock()+90
local function dependenciesReady()
    return
        Workspace:GetAttribute("ACC_TRACK01_CAR03_CAR04_FLOW_READY") and
        Workspace:GetAttribute("ACC_TRACK01_ENDLINE_HERO_READY") and
        Workspace:GetAttribute("ACC_TRACK01_FINAL_QC_READY")
end
repeat
    task.wait(0.15)
until dependenciesReady() or os.clock()>deadline
if not dependenciesReady() then
    warn("[TRACK 01] Car 04 -> Yard final route v1.7 skipped: dependency timeout")
    return
end

local root=Workspace:FindFirstChild("ACC_TRACK01")
local world=root and root:FindFirstChild("World")
if not (root and world) then return end

local old=world:FindFirstChild("TRACK01_Car04YardFinal_v17")
if old then old:Destroy() end
local flow=Instance.new("Folder")
flow.Name="TRACK01_Car04YardFinal_v17"
flow.Parent=world

local C={
    black=Color3.fromRGB(14,15,15),
    amber=Color3.fromRGB(211,143,69),
}

local function part(parent,name,size,frame,color,material,transparency,canTouch)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color
    p.Material=material or Enum.Material.Metal
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=canTouch==true
    p.CanQuery=false
    p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function surfaceText(target,text,color)
    local gui=Instance.new("SurfaceGui")
    gui.Name="YardExitPlaqueGui"
    gui.Face=Enum.NormalId.Right
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

-- One small railway-style exit cue inside Car 04 near its Platform 01 side door.
-- The physical route already exists: Car 04 side door -> Platform 01 -> The Yard.
local exitPlaque=part(
    flow,
    "YardExitPlaque",
    Vector3.new(0.14,2.0,7.0),
    CFrame.new(14.28,11.2,95.0),
    C.black,
    Enum.Material.Metal,
    0,
    false
)
surfaceText(exitPlaque,"THE YARD  ←  EXIT",C.amber)

local endZone=part(
    flow,
    "EndOfLineRuntimeZone",
    Vector3.new(12.0,8.0,12.0),
    CFrame.new(22,8.0,110.0),
    C.black,
    Enum.Material.SmoothPlastic,
    1,
    true
)

local yardZone=part(
    flow,
    "YardEntryRuntimeZone",
    Vector3.new(10.0,8.0,14.0),
    CFrame.new(-13.0,4.5,101.5),
    C.black,
    Enum.Material.SmoothPlastic,
    1,
    true
)

local debounce={}

local function playerFromHit(hit)
    local character=hit and hit:FindFirstAncestorOfClass("Model")
    if not character then return nil end
    return Players:GetPlayerFromCharacter(character)
end

endZone.Touched:Connect(function(hit)
    local player=playerFromHit(hit)
    if not player then return end
    local key="END_"..player.UserId
    local now=os.clock()
    if debounce[key] and now-debounce[key]<1.0 then return end
    debounce[key]=now

    player:SetAttribute("TRACK01_REACHED_ENDLINE",true)
    player:SetAttribute("TRACK01_FLOW_STAGE","END_OF_LINE")
end)

yardZone.Touched:Connect(function(hit)
    local player=playerFromHit(hit)
    if not player then return end
    if player:GetAttribute("TRACK01_REACHED_ENDLINE")~=true then return end

    local key="YARD_"..player.UserId
    local now=os.clock()
    if debounce[key] and now-debounce[key]<1.0 then return end
    debounce[key]=now

    player:SetAttribute("TRACK01_REACHED_YARD",true)
    player:SetAttribute("TRACK01_FLOW_STAGE","YARD")
    player:SetAttribute("TRACK01_FINAL_ROUTE_COMPLETE",true)
end)

Players.PlayerRemoving:Connect(function(player)
    debounce["END_"..player.UserId]=nil
    debounce["YARD_"..player.UserId]=nil
end)

root:SetAttribute("Car04YardFinalVersion","1.7.0")
root:SetAttribute("FinalRouteExpected","LOBBY>TICKET>SECURITY>PLATFORM01>CAR01>CAR02>CAR03>CAR04>END_OF_LINE>YARD")
Workspace:SetAttribute("ACC_TRACK01_CAR04_YARD_FLOW_READY",true)
Workspace:SetAttribute("ACC_TRACK01_END_TO_END_ROUTE_READY",true)
print("[TRACK 01] Car 04 -> The Yard final route v1.7 ready")
