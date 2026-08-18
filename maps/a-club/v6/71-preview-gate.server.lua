-- BBYA V6 — PREVIEW CANDIDATE GATE
-- This does not publish anything. It only marks a running preview candidate after runtime QC passes.

workspace:SetAttribute("BBYAV6PreviewCandidate",false)
workspace:SetAttribute("BBYAV6PreviewGate","WAITING_QC")

task.delay(9,function()
    local reasons={}
    if workspace:GetAttribute("BBYAV6RuntimeQC")~="PASS" then table.insert(reasons,"runtime QC not PASS") end
    if (tonumber(workspace:GetAttribute("BBYAV6RuntimeIssueCount")) or 999)>0 then table.insert(reasons,"runtime issues remain") end
    if (tonumber(workspace:GetAttribute("BBYAV6SocialSeatCount")) or 0)<28 then table.insert(reasons,"social seat density below gate") end
    if (tonumber(workspace:GetAttribute("BBYAV6InteractiveFacilityCount")) or 0)<6 then table.insert(reasons,"physical facility interactions below gate") end
    if (tonumber(workspace:GetAttribute("BBYAV6ShowLightCount")) or 0)<14 then table.insert(reasons,"automatic club show rig below gate") end
    if workspace:GetAttribute("BBYAV6ClubLighting")~="AUTO_BRIGHT" then table.insert(reasons,"club automatic lighting inactive") end
    if workspace:GetAttribute("BBYAV6GroundFinish")~="PREMIUM_PASS_1" then table.insert(reasons,"ground finish incomplete") end
    if workspace:GetAttribute("BBYAV6VIPFinish")~="PREMIUM_PASS_1" then table.insert(reasons,"VIP finish incomplete") end
    if workspace:GetAttribute("BBYAV6RooftopFinish")~="TROPICAL_PREMIUM_PASS_1" then table.insert(reasons,"rooftop finish incomplete") end

    local ready=#reasons==0
    workspace:SetAttribute("BBYAV6PreviewCandidate",ready)
    workspace:SetAttribute("BBYAV6PreviewGate",ready and "RUNTIME_PASS" or "REJECTED")
    workspace:SetAttribute("BBYAV6PreviewGateReasons",ready and "" or table.concat(reasons," | "))
    workspace:SetAttribute("BBYAV6PreviewGateChecked",os.time())

    if ready then
        print("[BBYA V6 PREVIEW GATE] RUNTIME_PASS — eligible for isolated founder preview, NOT live publish")
    else
        warn("[BBYA V6 PREVIEW GATE] REJECTED — "..table.concat(reasons,"; "))
    end
end)
