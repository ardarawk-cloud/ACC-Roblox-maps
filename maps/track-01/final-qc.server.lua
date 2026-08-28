local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")

-- TRACK 01 v3.9 final venue QC.
-- Runtime safety/flow guard only: no new assets, no economy changes, no audio changes.
local deadline=os.clock()+75
repeat
    task.wait(0.20)
until (
    Workspace:GetAttribute("ACC_TRACK01_LOBBY_ARRIVAL_READY") and
    Workspace:GetAttribute("ACC_TRACK01_TICKET_ACCESS_READY") and
    Workspace:GetAttribute("ACC_TRACK01_ENDLINE_HERO_READY") and
    Workspace:GetAttribute("ACC_TRACK01_SOCIAL_READY")
) or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_FinalQC_v39")
if old then old:Destroy() end
local qc=Instance.new("Folder")
qc.Name="TRACK01_FinalQC_v39"
qc.Parent=world

local LOBBY_RECOVERY=CFrame.new(-38,4.5,-123)
local FALL_Y=-18
local X_LIMIT=172
local Z_MIN=-190
local Z_MAX=225

local requiredAttributes={
    "ACC_TRACK01_LOBBY_ARRIVAL_READY",
    "ACC_TRACK01_TICKET_ACCESS_READY",
    "ACC_TRACK01_VESTIBULES_READY",
    "ACC_TRACK01_OPERATIONAL_PA_READY",
    "ACC_TRACK01_ENDLINE_HERO_READY",
    "ACC_TRACK01_SOCIAL_READY",
}

local missing={}
for _,name in ipairs(requiredAttributes) do
    if Workspace:GetAttribute(name)~=true then table.insert(missing,name) end
end

local requiredInstances={
    "TRACK01_SPAWN",
    "FirstAidCabinet",
    "FirstAidMount",
    "GangwayFloor",
    "Car01UsableSeat01",
    "NightDrinkTray",
    "Car03DanceZone01",
    "YardPhotoSpot",
}
for _,name in ipairs(requiredInstances) do
    if not root:FindFirstChild(name,true) then table.insert(missing,name) end
end

-- Final aisle collision guard: only touches v3.8 social helper geometry.
-- Protected carriage aisle is approximately x=18.85..25.15.
local social=world:FindFirstChild("TRACK01_Social_v38")
if social then
    for _,obj in ipairs(social:GetDescendants()) do
        if obj:IsA("BasePart") then
            local p=obj.Position
            if p.Z>-82 and p.Z<126 and p.X>18.85 and p.X<25.15 and not obj:IsA("Seat") then
                obj.CanCollide=false
                obj.CanTouch=false
            end
        elseif obj:IsA("ProximityPrompt") then
            obj.MaxActivationDistance=math.min(obj.MaxActivationDistance,8)
            obj.HoldDuration=0
        end
    end
end

local function updateFlow(player)
    local stage="ARRIVAL"
    if player:GetAttribute("TRACK01_TICKET")==true then stage="TICKET" end
    if player:GetAttribute("TRACK01_CHECKED_IN")==true then stage="CHECKED_IN" end
    if player:GetAttribute("TRACK01_BOARDED")==true then stage="BOARDED" end
    player:SetAttribute("TRACK01_FLOW_STAGE",stage)
end

local function setupPlayer(player)
    if player:GetAttribute("TRACK01_RECOVERY_TOKEN")==nil then
        player:SetAttribute("TRACK01_RECOVERY_TOKEN",0)
    end
    updateFlow(player)
    for _,attr in ipairs({"TRACK01_TICKET","TRACK01_CHECKED_IN","TRACK01_BOARDED"}) do
        player:GetAttributeChangedSignal(attr):Connect(function()
            updateFlow(player)
        end)
    end
end

for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

-- Fall / out-of-bounds recovery. Ticket state is preserved; only character position is reset.
task.spawn(function()
    while qc.Parent do
        task.wait(0.65)
        for _,player in ipairs(Players:GetPlayers()) do
            local character=player.Character
            local humanoid=character and character:FindFirstChildOfClass("Humanoid")
            local hrp=character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health>0 and hrp then
                local p=hrp.Position
                local invalid=(p.Y<FALL_Y) or (math.abs(p.X)>X_LIMIT) or (p.Z<Z_MIN) or (p.Z>Z_MAX)
                if invalid then
                    hrp.AssemblyLinearVelocity=Vector3.zero
                    hrp.AssemblyAngularVelocity=Vector3.zero
                    hrp.CFrame=LOBBY_RECOVERY
                    player:SetAttribute("TRACK01_RECOVERY_REASON","RETURNED TO STATION LOBBY")
                    player:SetAttribute("TRACK01_RECOVERY_TOKEN",(player:GetAttribute("TRACK01_RECOVERY_TOKEN") or 0)+1)
                end
            end
        end
    end
end)

root:SetAttribute("FinalQCVersion","3.9.0")
root:SetAttribute("FinalQCMissingCount",#missing)
root:SetAttribute("FinalQCStatus",(#missing==0) and "PASS" or "PASS_WITH_RUNTIME_WARNINGS")
Workspace:SetAttribute("ACC_TRACK01_FINAL_QC_READY",true)
Workspace:SetAttribute("ACC_TRACK01_FEATURE_COMPLETE",#missing==0)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.9.0")

if #missing>0 then
    warn("[TRACK 01] final QC ready with missing markers:",table.concat(missing,", "))
else
    print("[TRACK 01] final venue QC PASS v3.9.0")
end
