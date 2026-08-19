-- BBYA SOCIAL HUB — V7 CLEAN RUNTIME QC
-- Read-only checks. Never patches geometry.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")

task.delay(8,function()
    local issues={}
    local function issue(msg) table.insert(issues,msg) end
    local function need(name)
        if not workspace:FindFirstChild(name,true) then issue("missing: "..name) end
    end
    local function forbid(name)
        if workspace:FindFirstChild(name,true) then issue("removed legacy object survived: "..name) end
    end

    -- Only objects that belong to the current reference composition are required.
    for _,name in ipairs({
        "BBYA CLEAN REBUILD","ARRIVAL PLAZA","MAIN BBYA WORDMARK","DANCE FLOOR","DJ BOOTH","LED WALL",
        "MEZZ LEVEL 1","MEZZ LEVEL 2","VIP FLOOR","VIP SIGN","ROOFTOP DECK","POOL BASIN","POOL WATER",
        "POOL DJ DESK","ROOFTOP POOL SIGN","BBYA QUEEN THRONE","SUPPORT WALL PANEL","SUPPORT BOARD",
        "BBYA ARRIVAL SPAWN","STAIR G TO MID STEP 27","MID STAIR LANDING","STAIR MID TO ROOF STEP 27","ROOF STAIR LANDING",
        "ATRIUM HERO CANOPY","CLUB WING BRAND","VIP PORTAL BRAND","POOL PARTY BILLBOARD","WELCOME BAR BODY",
        "SELFIE WALL","VIP BACKBAR","SKY BAR BODY","CLEAR ARRIVAL CENTER","CLEAR ATRIUM CENTER","CLEAR CLUB THRESHOLD",
        "CLEAR VIP THRESHOLD","CLEAR MID LANDING","CLEAR ROOF LANDING","CLEAR ROOF SOCIAL SPINE","CLEAR POOL WEST WALK"
    }) do need(name) end

    -- These were intentionally deleted because they fought the reference composition.
    for _,name in ipairs({"QUEEN PODIUM","SUPPORT BOARD BODY","COURT FLOOR","HERO FACADE PLINTH","BRAND TOWER","INFINITY EDGE LOWER","ROOF FRONT FASCIA"}) do
        forbid(name)
    end

    local seats,showLights,criticalFill,palms,facadeWash,clearLanes,circulationLights,panelPrompts=0,0,0,0,0,0,0,0
    local clearMarkers={}
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Seat") and o:GetAttribute("BBYASocialSeat") then seats+=1 end
        if o:GetAttribute("BBYAShowLight") then showLights+=1 end
        if o:GetAttribute("BBYACriticalFill") then criticalFill+=1 end
        if o:GetAttribute("BBYAFacadeWash") then facadeWash+=1 end
        if o:GetAttribute("BBYACirculationLight") then circulationLights+=1 end
        if o:IsA("ProximityPrompt") and o.Name=="BBYA PANEL PROMPT" then panelPrompts+=1 end
        if o:IsA("BasePart") and o:GetAttribute("BBYAClearLane") then clearLanes+=1;table.insert(clearMarkers,o) end
        if o:IsA("BasePart") and o.Name:find("PALM") and o.Name:find("TRUNK") then palms+=1 end
    end
    if seats<30 then issue("social seat count below 30: "..seats) end
    if showLights<10 then issue("show-light anchors below 10: "..showLights) end
    if criticalFill<10 then issue("critical avatar fill below 10: "..criticalFill) end
    if palms<8 then issue("palm count below 8: "..palms) end
    if facadeWash<4 then issue("hero facade wash below 4: "..facadeWash) end
    if clearLanes<8 then issue("clear circulation markers below 8: "..clearLanes) end
    if circulationLights<7 then issue("circulation lights below 7: "..circulationLights) end
    if panelPrompts<4 then issue("physical panel prompts below 4: "..panelPrompts) end

    -- Check standing volume over each invisible clear-lane marker.
    local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude
    for _,marker in ipairs(clearMarkers) do
        overlap.FilterDescendantsInstances={marker}
        local boxCF=marker.CFrame*CFrame.new(0,3.2,0)
        local boxSize=Vector3.new(math.max(2,marker.Size.X*.72),4.6,math.max(2,marker.Size.Z*.72))
        local blockers={}
        for _,hit in ipairs(workspace:GetPartBoundsInBox(boxCF,boxSize,overlap)) do
            if hit:IsA("BasePart") and hit.CanCollide and hit.Transparency<.98 then
                table.insert(blockers,hit.Name)
                if #blockers>=3 then break end
            end
        end
        if #blockers>0 then issue("blocked clear lane "..marker.Name..": "..table.concat(blockers,", ")) end
    end

    if workspace:GetAttribute("BBYAReferenceSilhouette")~="LEFT_CLUB_CENTER_SOCIAL_RIGHT_VIP_UPPER_POOL" then issue("reference silhouette marker missing") end
    if workspace:GetAttribute("BBYACirculation")~="PHASE_3_LOCKED_CLEAR" then issue("circulation marker missing") end
    if workspace:GetAttribute("BBYALighting")~="PREMIUM_NIGHT_PASS_2" then issue("lighting marker missing") end
    if workspace:GetAttribute("BBYACleanRebuild")~=true then issue("clean rebuild marker missing") end
    if workspace:GetAttribute("BBYASocialSystems")~="V7_CLEAN_FAIL_CLOSED" then issue("V7 social systems marker missing") end
    if workspace:GetAttribute("BBYARuntime")~="V7_CLEAN_PREVIEW" then issue("V7 runtime marker missing") end

    local remoteRoot=ReplicatedStorage:FindFirstChild("BBYA REMOTES")
    if not remoteRoot then issue("BBYA REMOTES missing") else
        for _,name in ipairs({"OpenPanel","SupportChanged","MusicStateChanged","GetSupportConfig","GetSupportBoard","GetSupportSelf","GetMusicState"}) do
            if not remoteRoot:FindFirstChild(name) then issue("remote missing: "..name) end
        end
    end

    local musicRoot=SoundService:FindFirstChild("BBYA MUSIC")
    if not musicRoot then issue("BBYA MUSIC missing") else
        for _,name in ipairs({"CLUB DECK A","CLUB DECK B","ROOFTOP DECK A","ROOFTOP DECK B"}) do
            if not musicRoot:FindFirstChild(name) then issue("music deck missing: "..name) end
        end
    end
    if workspace:GetAttribute("BBYASupportTierCount")~=5 then issue("support tier count must be 5") end
    if workspace:GetAttribute("BBYAMusicDeckCount")~=4 then issue("music deck count must be 4") end
    if workspace:GetAttribute("BBYAPanelPromptCount")~=4 then issue("panel prompt count must be 4") end

    local rootCount=0
    for _,o in ipairs(workspace:GetChildren()) do
        if o.Name=="BBYA CLEAN REBUILD" then rootCount+=1 end
        if o.Name:find("V5") or o.Name:find("V6 CLEANROOM") or o.Name=="BBYA Mega Architecture v2" then issue("archived runtime root survived: "..o.Name) end
    end
    if rootCount~=1 then issue("expected exactly one BBYA CLEAN REBUILD root, got "..rootCount) end

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
        print(string.format("[BBYA V7 QC] PASS — %d seats, %d lanes, %d prompts",seats,clearLanes,panelPrompts))
    else
        warn("[BBYA V7 QC] WARN ("..#issues..")\n - "..table.concat(issues,"\n - "))
    end
end)
