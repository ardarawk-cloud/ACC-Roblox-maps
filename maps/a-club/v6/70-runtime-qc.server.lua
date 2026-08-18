-- BBYA V6 — RUNTIME MASTER QC
-- Fail-closed runtime inspection markers. Does not patch geometry; it only reports the actual assembled state.

local function findDeep(name)
    return workspace:FindFirstChild(name,true)
end

local function checkClearPad(pad)
    if not pad or not pad:IsA("BasePart") then return false,"missing" end
    local p0=pad.Position;local s0=pad.Size
    for _,p in ipairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p~=pad and p.CanCollide and not p:IsDescendantOf(pad) then
            -- Ignore structural floor below the clear pad. Flag only solid objects entering player clearance above it.
            if p.Position.Y > p0.Y+.5 and p.Position.Y < p0.Y+7 then
                local dx=math.abs(p.Position.X-p0.X);local dz=math.abs(p.Position.Z-p0.Z)
                if dx < (p.Size.X+s0.X)/2*.82 and dz < (p.Size.Z+s0.Z)/2*.82 then
                    return false,p:GetFullName()
                end
            end
        end
    end
    return true,""
end

task.delay(6,function()
    local issues={}
    local root=workspace:FindFirstChild("BBYA V6 CLEANROOM")
    if not root then table.insert(issues,"missing V6 root") end

    local attrs={
        BBYAV6CleanSlate=true,
        BBYAV6GroundShell="COMPLETE",
        BBYAV6LiftShell="SEALED_3_LEVEL",
        BBYAV6LiftFinish="COMPLETE",
        BBYAV6VIPFloor="COMPLETE",
        BBYAV6Rooftop="COMPLETE",
        BBYAV6Service="COMPLETE",
        BBYAV6Circulation="LOCKED_CLEAR",
        BBYAV6SpawnReady=true,
        BBYAV6Systems="ACTIVE",
        BBYAV6LiftRuntime="READY",
    }
    for k,want in pairs(attrs) do
        if workspace:GetAttribute(k)~=want then table.insert(issues,string.format("attr %s expected %s got %s",k,tostring(want),tostring(workspace:GetAttribute(k)))) end
    end

    for _,name in ipairs({
        "A1 BBYA SPAWN","A3 WELCOME BAR BODY","A3 LOOK CYC WALL","A3 SOCIAL ISLAND WEST SEAT",
        "A4 DANCE FLOOR","A4 DJ BOOTH","A5 MAIN BAR BODY","A6 CONVERSATION SOFA A 78 SEAT",
        "B3 SHAFT WEST","B3 G LANDING DOOR L","B3 VIP LANDING DOOR L","B3 ROOF LANDING DOOR L","B3 LIFT CAB CEILING",
        "C3 QUEEN SOFA SEAT","C3 PRW SOFA SEAT","D2 POOL WATER","D2 POOL DJ DESK","D3 SKY BAR COUNTER BODY","D5 CABANA ROOF -33","D6 VIEW PLATFORM",
    }) do
        if not findDeep(name) then table.insert(issues,"missing physical object: "..name) end
    end

    -- V6 true-clean-room should leave no direct legacy venue geometry at Workspace root.
    for _,legacy in ipairs({"Main Floor","Rooftop Floor","DJ Stage","DJ Booth","Dance Floor","Left Wall","Right Wall","Back Wall"}) do
        local o=workspace:FindFirstChild(legacy)
        if o then table.insert(issues,"legacy Workspace object survived: "..legacy) end
    end

    local critical=0
    for _,o in ipairs(workspace:GetDescendants()) do if o:GetAttribute("BBYACriticalFill")==true then critical+=1 end end
    if critical<9 then table.insert(issues,"critical avatar fill count below 9: "..critical) end

    -- Verify the explicit clear landings are actually free above floor height.
    local clearNames={"B3 G CLEAR LANDING","B3 VIP CLEAR LANDING","B3 ROOF CLEAR LANDING","D1 LIFT CLEAR EXIT"}
    for _,name in ipairs(clearNames) do
        local pad=findDeep(name)
        local ok,hit=checkClearPad(pad)
        if not ok then table.insert(issues,"blocked clear landing "..name..": "..hit) end
    end

    workspace:SetAttribute("BBYAV6RuntimeIssueCount",#issues)
    workspace:SetAttribute("BBYAV6RuntimeQC",#issues==0 and "PASS" or "WARN")
    workspace:SetAttribute("BBYAV6CriticalFillCount",critical)
    workspace:SetAttribute("BBYAV6RuntimeQCChecked",os.time())
    if #issues==0 then
        print("[BBYA V6 QC] PASS — clean room, physical program, lift and clear landings verified")
    else
        warn("[BBYA V6 QC] WARN ("..#issues..")\n - "..table.concat(issues,"\n - "))
    end
end)