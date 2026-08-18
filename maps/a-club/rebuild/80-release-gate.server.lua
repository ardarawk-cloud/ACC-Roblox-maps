-- BBYA SOCIAL HUB — PHASE 6 PREVIEW / RELEASE GATE
-- Read-only readiness gate. Never patches geometry, never publishes, never invents external IDs.

local function add(list,message)
    table.insert(list,message)
end

workspace:SetAttribute("BBYAInspectionPhase","PHASE_6_PREVIEW_GATE")
workspace:SetAttribute("BBYAReleaseGate","WAITING_FOR_RUNTIME_QC")

-- Phase 5 QC executes after 8s. Evaluate shortly after it so this gate reports the actual assembled runtime state.
task.delay(10,function()
    local blockers={}
    local pending={}

    if workspace:GetAttribute("BBYAPhase5QC")~="PASS" then
        add(blockers,"phase 5 runtime QC is not PASS")
    end
    if workspace:GetAttribute("BBYAPhase5IssueCount")~=0 then
        add(blockers,"phase 5 runtime QC still reports issues")
    end
    if workspace:GetAttribute("BBYABuildPhase")~="PHASE_5_REFERENCE_UI_QC" then
        add(blockers,"unexpected build phase marker")
    end
    if workspace:GetAttribute("BBYACirculation")~="PHASE_3_LOCKED_CLEAR" then
        add(blockers,"circulation is not locked clear")
    end
    if workspace:GetAttribute("BBYASocialSystems")~="PHASE_5_REFERENCE_FIDELITY" then
        add(blockers,"support/music systems are not on phase 5 reference fidelity")
    end
    if workspace:GetAttribute("BBYAReferenceSilhouette")~="LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL" then
        add(blockers,"owner-reference silhouette marker is missing")
    end
    if workspace:GetAttribute("BBYASupportTierCount")~=5 then
        add(blockers,"support tiers are not the exact five reference tiers")
    end
    if workspace:GetAttribute("BBYAMusicDeckCount")~=4 then
        add(blockers,"music deck topology is incomplete")
    end
    if workspace:GetAttribute("BBYAMusicCrossfadeSeconds")~=3.5 then
        add(blockers,"music crossfade contract changed")
    end
    if (workspace:GetAttribute("BBYAPanelPromptRuntimeCount") or 0)<4 then
        add(blockers,"physical panel prompts are incomplete")
    end
    if (workspace:GetAttribute("BBYAClearLaneRuntimeCount") or 0)<8 then
        add(blockers,"runtime clear-lane coverage is incomplete")
    end

    local rootCount=0
    for _,child in ipairs(workspace:GetChildren()) do
        if child.Name=="BBYA CLEAN REBUILD" then rootCount+=1 end
        if child.Name:find("V5") or child.Name:find("V6 CLEANROOM") or child.Name=="BBYA Mega Architecture v2" then
            add(blockers,"archived runtime root survived: "..child.Name)
        end
    end
    if rootCount~=1 then add(blockers,"expected exactly one clean rebuild root") end

    -- These are intentionally external-data pending states, not code/runtime failures.
    if workspace:GetAttribute("BBYASupportProductsReady")~=true then
        add(pending,"official Developer Product IDs pending")
    end
    if workspace:GetAttribute("BBYAMusicLibraryReady")~=true then
        add(pending,"authorized Roblox audio library pending")
    end

    local state
    if #blockers>0 then
        state="BLOCKED"
    elseif #pending>0 then
        state="RUNTIME_QC_PASS_PENDING_EXTERNAL_IDS_AND_OWNER_PLAYTEST"
    else
        state="RUNTIME_QC_PASS_PENDING_OWNER_PLAYTEST"
    end

    workspace:SetAttribute("BBYAReleaseGate",state)
    workspace:SetAttribute("BBYAReleaseBlockerCount",#blockers)
    workspace:SetAttribute("BBYAReleasePendingExternalCount",#pending)
    workspace:SetAttribute("BBYAOwnerPlaytestRequired",true)
    ROOT:SetAttribute("InspectionPhase","PHASE_6_PREVIEW_GATE")
    ROOT:SetAttribute("ReleaseGate",state)

    if #blockers>0 then
        warn("[BBYA RELEASE GATE] BLOCKED ("..#blockers..")\n - "..table.concat(blockers,"\n - "))
    else
        print("[BBYA RELEASE GATE] "..state)
        if #pending>0 then
            print("[BBYA RELEASE GATE] Pending external data:\n - "..table.concat(pending,"\n - "))
        end
    end
end)
