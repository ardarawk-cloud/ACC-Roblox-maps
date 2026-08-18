-- BBYA SOCIAL HUB — CLEAN REBUILD QC
-- Reports; never patches geometry.

task.delay(5,function()
    local issues={}
    local function need(name)
        if not workspace:FindFirstChild(name,true) then
            table.insert(issues,"missing: "..name)
        end
    end

    for _,name in ipairs({
        "BBYA CLEAN REBUILD","ARRIVAL PLAZA","MAIN BBYA WORDMARK","DANCE FLOOR","DJ BOOTH","LED WALL",
        "MEZZ LEVEL 1","MEZZ LEVEL 2","VIP FLOOR","VIP SIGN","ROOFTOP DECK","POOL BASIN","POOL WATER",
        "POOL DJ DESK","ROOFTOP POOL SIGN","BBYA QUEEN THRONE","SUPPORT BOARD","BBYA ARRIVAL SPAWN",
        "STAIR G TO MID STEP 27","MID STAIR LANDING","STAIR MID TO ROOF STEP 27","ROOF STAIR LANDING"
    }) do need(name) end

    local seats=0
    local showLights=0
    local criticalFill=0
    local palms=0
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Seat") and o:GetAttribute("BBYASocialSeat") then seats+=1 end
        if o:GetAttribute("BBYAShowLight") then showLights+=1 end
        if o:GetAttribute("BBYACriticalFill") then criticalFill+=1 end
        if o:IsA("BasePart") and o.Name:find("PALM") and o.Name:find("TRUNK") then palms+=1 end
    end
    if seats<24 then table.insert(issues,"social seat count below 24: "..seats) end
    if showLights<15 then table.insert(issues,"show light count below 15: "..showLights) end
    if criticalFill<10 then table.insert(issues,"critical fill count below 10: "..criticalFill) end
    if palms<6 then table.insert(issues,"palm count below 6: "..palms) end

    if workspace:GetAttribute("BBYAArchitecture")~="REFERENCE_MASSING_PHASE_1" then
        table.insert(issues,"architecture phase marker missing")
    end
    if workspace:GetAttribute("BBYAFurnishing")~="PREMIUM_SOCIAL_PASS_1" then
        table.insert(issues,"furnishing marker missing")
    end
    if workspace:GetAttribute("BBYALighting")~="PREMIUM_NIGHT_PASS_1" then
        table.insert(issues,"lighting marker missing")
    end

    workspace:SetAttribute("BBYAPhase1IssueCount",#issues)
    workspace:SetAttribute("BBYAPhase1QC",#issues==0 and "PASS" or "WARN")
    workspace:SetAttribute("BBYASocialSeatCount",seats)
    workspace:SetAttribute("BBYAShowLightCount",showLights)
    workspace:SetAttribute("BBYACriticalFillCount",criticalFill)
    workspace:SetAttribute("BBYAPalmCount",palms)

    if #issues==0 then
        print(string.format("[BBYA CLEAN REBUILD] PHASE 1 PASS — %d seats, %d show lights, %d critical fills, %d palms",seats,showLights,criticalFill,palms))
    else
        warn("[BBYA CLEAN REBUILD] PHASE 1 WARN ("..#issues..")\n - "..table.concat(issues,"\n - "))
    end
end)
