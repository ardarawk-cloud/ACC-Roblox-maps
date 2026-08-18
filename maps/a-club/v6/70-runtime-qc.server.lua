-- BBYA V6 — RUNTIME MASTER QC
-- Fail-closed runtime inspection markers. Does not patch geometry; it only reports the actual assembled state.

local function findDeep(name)
    return workspace:FindFirstChild(name,true)
end

local function checkClearPad(pad)
    if not pad or not pad:IsA("BasePart") then return false,"missing" end
    local p0=pad.Position;local s0=pad.Size
    for _,p in ipairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p~=pad and p.CanCollide then
            -- Ignore structural floor below the pad. Flag solids entering player clearance above it.
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

local function countAttr(attr,value)
    local n=0
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:GetAttribute(attr)==value then n+=1 end
    end
    return n
end

task.delay(7,function()
    local issues={}
    local root=workspace:FindFirstChild("BBYA V6 CLEANROOM")
    if not root then table.insert(issues,"missing V6 root") end

    local attrs={
        BBYAV6CleanSlate=true,
        BBYAV6GroundShell="COMPLETE",
        BBYAV6GroundFinish="PREMIUM_PASS_1",
        BBYAV6LiftShell="SEALED_3_LEVEL",
        BBYAV6LiftFinish="COMPLETE",
        BBYAV6VIPFloor="COMPLETE",
        BBYAV6VIPFinish="PREMIUM_PASS_1",
        BBYAV6VIPLiftThreshold=true,
        BBYAV6Rooftop="COMPLETE",
        BBYAV6RooftopFinish="TROPICAL_PREMIUM_PASS_1",
        BBYAV6FunctionalSocialSeats=true,
        BBYAV6Service="COMPLETE",
        BBYAV6Circulation="LOCKED_CLEAR",
        BBYAV6SpawnReady=true,
        BBYAV6Systems="ACTIVE",
        BBYAV6LiftRuntime="READY",
    }
    for k,want in pairs(attrs) do
        if workspace:GetAttribute(k)~=want then
            table.insert(issues,string.format("attr %s expected %s got %s",k,tostring(want),tostring(workspace:GetAttribute(k))))
        end
    end

    local prompts=tonumber(workspace:GetAttribute("BBYAV6PhysicalUIPrompts")) or 0
    if prompts<6 then table.insert(issues,"physical UI prompt count below 6: "..prompts) end

    for _,name in ipairs({
        "A1 BBYA SPAWN","A1 WARM BOLLARD -58","A2 CANOPY SLAT -40",
        "A3 WELCOME BAR BODY","A3 LOOK CYC WALL","A3 SOCIAL ISLAND WEST SEAT","A3 CEILING BEAM 23",
        "A4 DANCE FLOOR","A4 DJ BOOTH","A4 CEILING TRUSS X 74",
        "A5 MAIN BAR BODY","A5 BACKBAR SHELF 3.8",
        "A6 CONVERSATION SOFA A 78 SEAT","A6 ACOUSTIC PANEL 72",
        "B3 SHAFT WEST","B3 G LANDING DOOR L","B3 VIP LANDING DOOR L","B3 ROOF LANDING DOOR L","B3 LIFT CAB CEILING",
        "C2 LIFT VIP BARRIER","C3 QUEEN SOFA SEAT","C3 QUEEN CROWN BASE","C3 PRW SOFA SEAT",
        "D2 POOL WATER","D2 POOL DJ DESK","D2 RESORT PALM -43 69",
        "D3 SKY BAR COUNTER BODY","D3 BACKBAR SHELF 43",
        "D5 CABANA ROOF -33","D5 CABANA CURTAIN L -33","D6 VIEW PLATFORM","D6 CITY BLOCK 1",
    }) do
        if not findDeep(name) then table.insert(issues,"missing physical/finish object: "..name) end
    end

    -- True-clean-room guard: direct old venue geometry may not survive at Workspace root.
    for _,legacy in ipairs({"Main Floor","Rooftop Floor","DJ Stage","DJ Booth","Dance Floor","Left Wall","Right Wall","Back Wall","BBYA Visual v1.2","BBYA Social Systems"}) do
        local o=workspace:FindFirstChild(legacy)
        if o then table.insert(issues,"legacy Workspace object survived: "..legacy) end
    end

    local critical=countAttr("BBYACriticalFill",true)
    if critical<8 then table.insert(issues,"critical avatar fill count below 8: "..critical) end

    local socialSeats=countAttr("BBYASocialSeat",true)
    if socialSeats<28 then table.insert(issues,"functional social seat count below 28: "..socialSeats) end

    local facilities=countAttr("BBYAInteractiveFacility","PHOTO") + countAttr("BBYAInteractiveFacility","MUSIC") + countAttr("BBYAInteractiveFacility","DANCE")
    if facilities<6 then table.insert(issues,"interactive facility coverage below 6: "..facilities) end

    -- Explicit landings must remain clear of furniture/walls after every finish pass.
    local clearNames={"B3 G CLEAR LANDING","B3 VIP CLEAR LANDING","B3 ROOF CLEAR LANDING","D1 LIFT CLEAR EXIT","C2 LIFT CLEAR LANDING"}
    for _,name in ipairs(clearNames) do
        local pad=findDeep(name)
        local ok,hit=checkClearPad(pad)
        if not ok then table.insert(issues,"blocked clear landing "..name..": "..hit) end
    end

    workspace:SetAttribute("BBYAV6RuntimeIssueCount",#issues)
    workspace:SetAttribute("BBYAV6RuntimeQC",#issues==0 and "PASS" or "WARN")
    workspace:SetAttribute("BBYAV6CriticalFillCount",critical)
    workspace:SetAttribute("BBYAV6SocialSeatCount",socialSeats)
    workspace:SetAttribute("BBYAV6InteractiveFacilityCount",facilities)
    workspace:SetAttribute("BBYAV6RuntimeQCChecked",os.time())

    if #issues==0 then
        print(string.format("[BBYA V6 QC] PASS — clean room + finishes + %d social seats + %d facility prompts verified",socialSeats,prompts))
    else
        warn("[BBYA V6 QC] WARN ("..#issues..")\n - "..table.concat(issues,"\n - "))
    end
end)
