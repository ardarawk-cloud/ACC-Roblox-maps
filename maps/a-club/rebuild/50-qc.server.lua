-- BBYA SOCIAL HUB — CLEAN REBUILD PHASE 2 QC
-- Reports only; never patches geometry.

task.delay(6,function()
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
        "STAIR G TO MID STEP 27","MID STAIR LANDING","STAIR MID TO ROOF STEP 27","ROOF STAIR LANDING",
        "HERO FACADE PLINTH","ATRIUM HERO CANOPY","BRAND TOWER","CLUB WING BRAND","VIP PORTAL BRAND",
        "POOL PARTY BILLBOARD","ROOF FRONT FASCIA","WELCOME BAR BODY","SELFIE WALL","VIP BACKBAR",
        "SKY BAR BODY","COURT FLOOR"
    }) do need(name) end

    local seats=0
    local showLights=0
    local criticalFill=0
    local palms=0
    local facadeWash=0
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Seat") and o:GetAttribute("BBYASocialSeat") then seats+=1 end
        if o:GetAttribute("BBYAShowLight") then showLights+=1 end
        if o:GetAttribute("BBYACriticalFill") then criticalFill+=1 end
        if o:GetAttribute("BBYAFacadeWash") then facadeWash+=1 end
        if o:IsA("BasePart") and o.Name:find("PALM") and o.Name:find("TRUNK") then palms+=1 end
    end
    if seats<28 then table.insert(issues,"social seat count below 28: "..seats) end
    if showLights<20 then table.insert(issues,"show light count below 20: "..showLights) end
    if criticalFill<13 then table.insert(issues,"critical fill count below 13: "..criticalFill) end
    if palms<10 then table.insert(issues,"palm count below 10: "..palms) end
    if facadeWash<4 then table.insert(issues,"hero facade wash count below 4: "..facadeWash) end

    if workspace:GetAttribute("BBYAArchitecture")~="REFERENCE_MASSING_PHASE_1" then table.insert(issues,"architecture phase marker missing") end
    if workspace:GetAttribute("BBYAPremiumExterior")~="PHASE_2_COMPLETE" then table.insert(issues,"premium exterior marker missing") end
    if workspace:GetAttribute("BBYAFurnishing")~="PREMIUM_SOCIAL_PASS_1" then table.insert(issues,"furnishing marker missing") end
    if workspace:GetAttribute("BBYAPremiumInterior")~="PHASE_2_COMPLETE" then table.insert(issues,"premium interior marker missing") end
    if workspace:GetAttribute("BBYALighting")~="PREMIUM_NIGHT_PASS_2" then table.insert(issues,"phase 2 lighting marker missing") end
    if workspace:GetAttribute("BBYAReferenceSilhouette")~="LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL" then table.insert(issues,"owner-reference silhouette marker missing") end
    if workspace:GetAttribute("BBYACleanRebuild")~=true then table.insert(issues,"clean rebuild marker missing") end

    -- Runtime must contain exactly one BBYA build root. Any archived runtime geometry is rejected.
    local rebuildRoots=0
    for _,o in ipairs(workspace:GetChildren()) do
        if o.Name=="BBYA CLEAN REBUILD" then rebuildRoots+=1 end
        if o.Name:find("V5") or o.Name:find("V6 CLEANROOM") or o.Name=="BBYA Mega Architecture v2" then
            table.insert(issues,"archived runtime root survived: "..o.Name)
        end
    end
    if rebuildRoots~=1 then table.insert(issues,"expected exactly one clean rebuild root, got "..rebuildRoots) end

    workspace:SetAttribute("BBYAPhase2IssueCount",#issues)
    workspace:SetAttribute("BBYAPhase2QC",#issues==0 and "PASS" or "WARN")
    workspace:SetAttribute("BBYASocialSeatCount",seats)
    workspace:SetAttribute("BBYAShowLightCount",showLights)
    workspace:SetAttribute("BBYACriticalFillCount",criticalFill)
    workspace:SetAttribute("BBYAPalmCount",palms)
    workspace:SetAttribute("BBYAFacadeWashCount",facadeWash)

    if #issues==0 then
        print(string.format("[BBYA CLEAN REBUILD] PHASE 2 PASS — %d seats, %d show lights, %d critical fills, %d palms, %d facade washes",seats,showLights,criticalFill,palms,facadeWash))
    else
        warn("[BBYA CLEAN REBUILD] PHASE 2 WARN ("..#issues..")\n - "..table.concat(issues,"\n - "))
    end
end)
