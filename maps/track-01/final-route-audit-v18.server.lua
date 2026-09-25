local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")

-- TRACK 01 v4.2.8 — final end-to-end route audit
-- This script distinguishes static/source readiness from actual player runtime completion.
local deadline=os.clock()+120

local requiredReady={
    "ACC_TRACK01_LOBBY_FLOW_CLEANUP_READY",
    "ACC_TRACK01_TICKET_FORWARD_FLOW_READY",
    "ACC_TRACK01_CAR01_BOARDING_FLOW_READY",
    "ACC_TRACK01_CAR01_CAR02_FLOW_READY",
    "ACC_TRACK01_CAR02_CAR03_FLOW_READY",
    "ACC_TRACK01_CAR03_CAR04_FLOW_READY",
    "ACC_TRACK01_CAR04_YARD_FLOW_READY",
    "ACC_TRACK01_END_TO_END_ROUTE_READY",
    "ACC_TRACK01_FINAL_QC_READY",
}

local function dependenciesReady()
    for _,name in ipairs(requiredReady) do
        if Workspace:GetAttribute(name)~=true then return false end
    end
    return true
end

repeat
    task.wait(0.20)
until dependenciesReady() or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
local world=root and root:FindFirstChild("World")
if not (root and world) then return end

local old=world:FindFirstChild("TRACK01_FinalRouteAudit_v18")
if old then old:Destroy() end
local audit=Instance.new("Folder")
audit.Name="TRACK01_FinalRouteAudit_v18"
audit.Parent=world

local warnings={}

if not dependenciesReady() then
    table.insert(warnings,"DEPENDENCY_TIMEOUT")
end

local requiredInstances={
    "TRACK01_SPAWN",
    "TicketForwardValidator",
    "Car01BoardingBridge",
    "Car02EntryPlaque",
    "Car03EntryPlaque",
    "Car04EntryPlaque",
    "YardExitPlaque",
    "EndOfLineRuntimeZone",
    "YardEntryRuntimeZone",
    "YardPhotoSpot",
}
for _,name in ipairs(requiredInstances) do
    if not root:FindFirstChild(name,true) then
        table.insert(warnings,"MISSING:"..name)
    end
end

-- Confirm the cleanup chain stayed intact.
for _,name in ipairs({"EntryMarker","EntryText","PlatformWayfinder","Car01DoorFrameNear","Car01DoorFrameFar","Car01DoorFrameTop"}) do
    if world:FindFirstChild(name,true) then
        table.insert(warnings,"LEGACY_PRESENT:"..name)
    end
end

local train=world:FindFirstChild("TrainCars")
local car1=train and train:FindFirstChild("CAR_01_SOCIAL")
if car1 then
    if car1:FindFirstChild("Table") then table.insert(warnings,"CAR01_CENTER_TABLE_PRESENT") end
    if car1:FindFirstChild("TableStem") then table.insert(warnings,"CAR01_CENTER_TABLE_STEM_PRESENT") end
else
    table.insert(warnings,"MISSING:CAR_01_SOCIAL")
end

local car2=train and train:FindFirstChild("CAR_02_BAR")
if car2 then
    local counter=car2:FindFirstChild("BarCounter")
    local top=car2:FindFirstChild("BarTop")
    if not counter then
        table.insert(warnings,"MISSING:BarCounter")
    elseif counter.Size.X>3.61 then
        table.insert(warnings,"CAR02_COUNTER_TOO_WIDE")
    end
    if not top then
        table.insert(warnings,"MISSING:BarTop")
    elseif top.Size.X>4.11 then
        table.insert(warnings,"CAR02_TOP_TOO_WIDE")
    end
else
    table.insert(warnings,"MISSING:CAR_02_BAR")
end

local ticketSystem=world:FindFirstChild("TRACK01_TicketAccessVestibule_v37")
local vestibules=ticketSystem and ticketSystem:FindFirstChild("EnclosedInterCarVestibules")
for i=1,3 do
    local g=vestibules and vestibules:FindFirstChild(string.format("Vestibule_%02d",i))
    if not g then
        table.insert(warnings,"MISSING:Vestibule_"..string.format("%02d",i))
    else
        for _,name in ipairs({"ThresholdMarkerL","ThresholdMarkerR"}) do
            local marker=g:FindFirstChild(name)
            if not marker then
                table.insert(warnings,"MISSING:Vestibule_"..string.format("%02d",i)..":"..name)
            elseif marker:IsA("BasePart") and marker.Material==Enum.Material.Neon then
                table.insert(warnings,"NEON_THRESHOLD:Vestibule_"..string.format("%02d",i)..":"..name)
            end
        end
    end
end

local status=(#warnings==0) and "READY_FOR_RUNTIME_QC" or "READY_WITH_SOURCE_WARNINGS"
root:SetAttribute("EndToEndAuditVersion","1.8.0")
root:SetAttribute("EndToEndAuditStatus",status)
root:SetAttribute("EndToEndAuditWarningCount",#warnings)
root:SetAttribute("EndToEndAuditWarnings",table.concat(warnings," | "))
root:SetAttribute("EndToEndRuntimePassCount",0)
Workspace:SetAttribute("ACC_TRACK01_FINAL_ROUTE_AUDIT_READY",true)

local counted={}
local function recordPass(player)
    if counted[player] then return end
    if player:GetAttribute("TRACK01_FINAL_ROUTE_COMPLETE")~=true then return end
    counted[player]=true
    local count=(root:GetAttribute("EndToEndRuntimePassCount") or 0)+1
    root:SetAttribute("EndToEndRuntimePassCount",count)
    root:SetAttribute("EndToEndAuditStatus","RUNTIME_PASS_RECORDED")
    Workspace:SetAttribute("ACC_TRACK01_RUNTIME_ROUTE_PASS",true)
    print("[TRACK 01] end-to-end runtime route PASS recorded")
end

local function setupPlayer(player)
    recordPass(player)
    player:GetAttributeChangedSignal("TRACK01_FINAL_ROUTE_COMPLETE"):Connect(function()
        recordPass(player)
    end)
end

for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
    counted[player]=nil
end)

if #warnings>0 then
    warn("[TRACK 01] final route audit ready with source warnings:",table.concat(warnings,", "))
else
    print("[TRACK 01] final route audit READY FOR RUNTIME QC v1.8.0")
end
