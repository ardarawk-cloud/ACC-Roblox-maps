-- BBYA SOCIAL HUB — CLEAN REBUILD PHASE 5 QC
-- Reports only; never patches geometry.

local ReplicatedStorageQC=game:GetService("ReplicatedStorage")
local SoundServiceQC=game:GetService("SoundService")

task.delay(8,function()
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
        "SKY BAR BODY","COURT FLOOR",
        "CLEAR ARRIVAL CENTER","CLEAR ATRIUM CENTER","CLEAR CLUB THRESHOLD","CLEAR VIP THRESHOLD",
        "CLEAR MID LANDING","CLEAR ROOF LANDING","CLEAR ROOF SOCIAL SPINE","CLEAR POOL WEST WALK",
        "MID LANDING RAIL WEST","MID LANDING RAIL EAST","ROOF LANDING RAIL WEST","ROOF LANDING RAIL EAST",
        "CLUB ENTRY WAYFIND","ROOF ARRIVAL SIGN"
    }) do need(name) end

    local seats=0
    local showLights=0
    local criticalFill=0
    local palms=0
    local facadeWash=0
    local clearLanes=0
    local circulationLights=0
    local panelPrompts=0
    local clearMarkers={}
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Seat") and o:GetAttribute("BBYASocialSeat") then seats+=1 end
        if o:GetAttribute("BBYAShowLight") then showLights+=1 end
        if o:GetAttribute("BBYACriticalFill") then criticalFill+=1 end
        if o:GetAttribute("BBYAFacadeWash") then facadeWash+=1 end
        if o:GetAttribute("BBYACirculationLight") then circulationLights+=1 end
        if o:IsA("ProximityPrompt") and o.Name=="BBYA PANEL PROMPT" then panelPrompts+=1 end
        if o:IsA("BasePart") and o:GetAttribute("BBYAClearLane") then
            clearLanes+=1
            table.insert(clearMarkers,o)
        end
        if o:IsA("BasePart") and o.Name:find("PALM") and o.Name:find("TRUNK") then palms+=1 end
    end
    if seats<28 then table.insert(issues,"social seat count below 28: "..seats) end
    if showLights<20 then table.insert(issues,"show light count below 20: "..showLights) end
    if criticalFill<13 then table.insert(issues,"critical fill count below 13: "..criticalFill) end
    if palms<10 then table.insert(issues,"palm count below 10: "..palms) end
    if facadeWash<4 then table.insert(issues,"hero facade wash count below 4: "..facadeWash) end
    if clearLanes<8 then table.insert(issues,"clear circulation marker count below 8: "..clearLanes) end
    if circulationLights<7 then table.insert(issues,"circulation light count below 7: "..circulationLights) end
    if panelPrompts<4 then table.insert(issues,"physical panel prompt count below 4: "..panelPrompts) end

    -- Reduced standing volume above every clear marker. Floors below and side rails are excluded by volume placement.
    local overlap=OverlapParams.new()
    overlap.FilterType=Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances={}
    for _,marker in ipairs(clearMarkers) do
        overlap.FilterDescendantsInstances={marker}
        local boxCF=marker.CFrame*CFrame.new(0,3.3,0)
        local boxSize=Vector3.new(math.max(2,marker.Size.X*.78),4.8,math.max(2,marker.Size.Z*.78))
        local blockers={}
        for _,hit in ipairs(workspace:GetPartBoundsInBox(boxCF,boxSize,overlap)) do
            if hit:IsA("BasePart") and hit.CanCollide and hit.Transparency<.98 then
                table.insert(blockers,hit:GetFullName())
                if #blockers>=3 then break end
            end
        end
        if #blockers>0 then table.insert(issues,"blocked clear lane "..marker.Name..": "..table.concat(blockers,", ")) end
    end

    if workspace:GetAttribute("BBYAArchitecture")~="REFERENCE_MASSING_PHASE_1" then table.insert(issues,"architecture phase marker missing") end
    if workspace:GetAttribute("BBYAPremiumExterior")~="PHASE_2_COMPLETE" then table.insert(issues,"premium exterior marker missing") end
    if workspace:GetAttribute("BBYAFurnishing")~="PREMIUM_SOCIAL_PASS_1" then table.insert(issues,"furnishing marker missing") end
    if workspace:GetAttribute("BBYAPremiumInterior")~="PHASE_2_COMPLETE" then table.insert(issues,"premium interior marker missing") end
    if workspace:GetAttribute("BBYALighting")~="PREMIUM_NIGHT_PASS_2" then table.insert(issues,"phase 2 lighting marker missing") end
    if workspace:GetAttribute("BBYACirculation")~="PHASE_3_LOCKED_CLEAR" then table.insert(issues,"phase 3 circulation marker missing") end
    if workspace:GetAttribute("BBYAReferenceSilhouette")~="LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL" then table.insert(issues,"owner-reference silhouette marker missing") end
    if workspace:GetAttribute("BBYACleanRebuild")~=true then table.insert(issues,"clean rebuild marker missing") end
    if workspace:GetAttribute("BBYABuildPhase")~="PHASE_5_REFERENCE_UI_QC" then table.insert(issues,"build phase is not phase 5") end
    if workspace:GetAttribute("BBYASocialSystems")~="PHASE_5_REFERENCE_FIDELITY" then table.insert(issues,"phase 5 social systems marker missing") end

    -- Server remotes must expose the same support/music data used by physical prompts and mobile UI.
    local remoteRoot=ReplicatedStorageQC:FindFirstChild("BBYA REMOTES")
    if not remoteRoot then
        table.insert(issues,"BBYA REMOTES missing")
    else
        for _,name in ipairs({"OpenPanel","SupportChanged","MusicStateChanged","GetSupportConfig","GetSupportBoard","GetSupportSelf","GetMusicState"}) do
            if not remoteRoot:FindFirstChild(name) then table.insert(issues,"remote missing: "..name) end
        end
    end

    -- Music deck topology exists even while the authorized library is intentionally empty.
    local musicRoot=SoundServiceQC:FindFirstChild("BBYA MUSIC")
    if not musicRoot then
        table.insert(issues,"BBYA MUSIC folder missing")
    else
        for _,name in ipairs({"CLUB DECK A","CLUB DECK B","ROOFTOP DECK A","ROOFTOP DECK B"}) do
            if not musicRoot:FindFirstChild(name) then table.insert(issues,"music deck missing: "..name) end
        end
    end
    for _,groupName in ipairs({"BBYA CLUB GROUP","BBYA ROOFTOP GROUP"}) do
        local group=SoundServiceQC:FindFirstChild(groupName)
        if not group or not group:IsA("SoundGroup") then
            table.insert(issues,"sound group missing: "..groupName)
        elseif not group:FindFirstChild("BBYA EQ") then
            table.insert(issues,"equalizer missing: "..groupName)
        end
    end

    -- Pending commerce/music data is valid only when all fail-closed metadata is coherent.
    if workspace:GetAttribute("BBYASupportProductsReady")==nil then table.insert(issues,"support readiness attribute missing") end
    if workspace:GetAttribute("BBYAMusicLibraryReady")==nil then table.insert(issues,"music readiness attribute missing") end
    if workspace:GetAttribute("BBYASupportTierCount")~=5 then table.insert(issues,"support tier count is not exact reference count 5") end
    if workspace:GetAttribute("BBYAMusicDeckCount")~=4 then table.insert(issues,"music deck count is not 4") end
    if workspace:GetAttribute("BBYAMusicCrossfadeSeconds")~=3.5 then table.insert(issues,"music crossfade value is not 3.5") end
    if (workspace:GetAttribute("BBYAPanelPromptCount") or 0)<4 then table.insert(issues,"panel prompt attribute below 4") end

    -- Runtime must contain exactly one clean build root. Archived visual roots are rejected.
    local rebuildRoots=0
    for _,o in ipairs(workspace:GetChildren()) do
        if o.Name=="BBYA CLEAN REBUILD" then rebuildRoots+=1 end
        if o.Name:find("V5") or o.Name:find("V6 CLEANROOM") or o.Name=="BBYA Mega Architecture v2" then
            table.insert(issues,"archived runtime root survived: "..o.Name)
        end
    end
    if rebuildRoots~=1 then table.insert(issues,"expected exactly one clean rebuild root, got "..rebuildRoots) end

    workspace:SetAttribute("BBYAPhase5IssueCount",#issues)
    workspace:SetAttribute("BBYAPhase5QC",#issues==0 and "PASS" or "WARN")
    workspace:SetAttribute("BBYASocialSeatCount",seats)
    workspace:SetAttribute("BBYAShowLightCount",showLights)
    workspace:SetAttribute("BBYACriticalFillCount",criticalFill)
    workspace:SetAttribute("BBYAPalmCount",palms)
    workspace:SetAttribute("BBYAFacadeWashCount",facadeWash)
    workspace:SetAttribute("BBYAClearLaneRuntimeCount",clearLanes)
    workspace:SetAttribute("BBYACirculationLightCount",circulationLights)
    workspace:SetAttribute("BBYAPanelPromptRuntimeCount",panelPrompts)

    if #issues==0 then
        print(string.format("[BBYA CLEAN REBUILD] PHASE 5 PASS — %d seats, %d clear lanes, %d prompts; exact support tiers + dual-deck music shell verified",seats,clearLanes,panelPrompts))
    else
        warn("[BBYA CLEAN REBUILD] PHASE 5 WARN ("..#issues..")\n - "..table.concat(issues,"\n - "))
    end
end)
