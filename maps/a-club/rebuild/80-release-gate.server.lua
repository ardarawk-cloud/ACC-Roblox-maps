-- BBYA SOCIAL HUB — V7 CLEAN PREVIEW / RELEASE GATE
-- Read-only. Never publishes automatically.

local function add(list,message) table.insert(list,message) end
workspace:SetAttribute("BBYAInspectionPhase","PHASE_6_PREVIEW_GATE")
workspace:SetAttribute("BBYAReleaseGate","WAITING_FOR_RUNTIME_QC")

task.delay(10,function()
    local blockers,pending={},{}
    if workspace:GetAttribute("BBYAPhase5QC")~="PASS" then add(blockers,"runtime QC is not PASS") end
    if workspace:GetAttribute("BBYAPhase5IssueCount")~=0 then add(blockers,"runtime QC still reports issues") end
    if workspace:GetAttribute("BBYACirculation")~="PHASE_3_LOCKED_CLEAR" then add(blockers,"circulation is not locked clear") end
    if workspace:GetAttribute("BBYASocialSystems")~="V7_CLEAN_FAIL_CLOSED" then add(blockers,"V7 social system contract missing") end
    if workspace:GetAttribute("BBYARuntime")~="V7_CLEAN_PREVIEW" then add(blockers,"V7 runtime contract missing") end
    if workspace:GetAttribute("BBYAReferenceSilhouette")~="LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL" then add(blockers,"reference silhouette marker missing") end
    if workspace:GetAttribute("BBYASupportTierCount")~=5 then add(blockers,"support tier topology incomplete") end
    if workspace:GetAttribute("BBYAMusicDeckCount")~=4 then add(blockers,"music deck topology incomplete") end
    if (workspace:GetAttribute("BBYAPanelPromptRuntimeCount") or 0)<4 then add(blockers,"physical panel prompts incomplete") end
    if (workspace:GetAttribute("BBYAClearLaneRuntimeCount") or 0)<8 then add(blockers,"clear-lane coverage incomplete") end

    local rootCount=0
    for _,child in ipairs(workspace:GetChildren()) do
        if child.Name=="BBYA CLEAN REBUILD" then rootCount+=1 end
        if child.Name:find("V5") or child.Name:find("V6 CLEANROOM") or child.Name=="BBYA Mega Architecture v2" then add(blockers,"archived runtime root survived: "..child.Name) end
    end
    if rootCount~=1 then add(blockers,"expected exactly one clean rebuild root") end

    if workspace:GetAttribute("BBYASupportProductsReady")~=true then add(pending,"official Developer Product IDs pending") end
    if workspace:GetAttribute("BBYAMusicLibraryReady")~=true then add(pending,"authorized Roblox audio library pending") end

    local state
    if #blockers>0 then state="BLOCKED"
    elseif #pending>0 then state="RUNTIME_QC_PASS_PENDING_EXTERNAL_IDS_AND_OWNER_PLAYTEST"
    else state="RUNTIME_QC_PASS_PENDING_OWNER_PLAYTEST" end

    workspace:SetAttribute("BBYAReleaseGate",state)
    workspace:SetAttribute("BBYAReleaseBlockerCount",#blockers)
    workspace:SetAttribute("BBYAReleasePendingExternalCount",#pending)
    workspace:SetAttribute("BBYAOwnerPlaytestRequired",true)
    ROOT:SetAttribute("InspectionPhase","PHASE_6_PREVIEW_GATE")
    ROOT:SetAttribute("ReleaseGate",state)

    if #blockers>0 then warn("[BBYA RELEASE GATE] BLOCKED ("..#blockers..")\n - "..table.concat(blockers,"\n - "))
    else
        print("[BBYA RELEASE GATE] "..state)
        if #pending>0 then print("[BBYA RELEASE GATE] Pending external data:\n - "..table.concat(pending,"\n - ")) end
    end
end)
