-- BBYA SOCIAL HUB — PHASE 5 SUPPORT + MUSIC SERVER SYSTEMS
-- Authoritative backend. Commerce and world audio stay fail-closed until official IDs are supplied.

local PlayersSocial=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local DataStoreService=game:GetService("DataStoreService")
local SoundService=game:GetService("SoundService")
local TweenServiceMusic=game:GetService("TweenService")

local remoteRoot=ReplicatedStorage:FindFirstChild("BBYA REMOTES") or Instance.new("Folder")
remoteRoot.Name="BBYA REMOTES"
remoteRoot.Parent=ReplicatedStorage

local function remoteEvent(name)
    local r=remoteRoot:FindFirstChild(name) or Instance.new("RemoteEvent")
    r.Name=name
    r.Parent=remoteRoot
    return r
end
local function remoteFunction(name)
    local r=remoteRoot:FindFirstChild(name) or Instance.new("RemoteFunction")
    r.Name=name
    r.Parent=remoteRoot
    return r
end

local openPanel=remoteEvent("OpenPanel")
local supportChanged=remoteEvent("SupportChanged")
local musicStateChanged=remoteEvent("MusicStateChanged")
local getSupportConfig=remoteFunction("GetSupportConfig")
local getSupportBoard=remoteFunction("GetSupportBoard")
local getSupportSelf=remoteFunction("GetSupportSelf")
local getMusicState=remoteFunction("GetMusicState")

-- =========================================================
-- SUPPORT / SAWER — OWNER REFERENCE IMAGE 2
-- =========================================================
-- Exact visual tiers from the reference. Zero is intentional; never invent commerce IDs.
local SUPPORT_PRODUCTS={
    [5]=0,
    [10]=0,
    [50]=0,
    [100]=0,
    [500]=0,
}
local SUPPORT_ORDER={5,10,50,100,500}
local PRODUCT_TO_AMOUNT={}
local supportEnabled=false
for amount,id in pairs(SUPPORT_PRODUCTS) do
    if id and id>0 then
        PRODUCT_TO_AMOUNT[id]=amount
        supportEnabled=true
    end
end

getSupportConfig.OnServerInvoke=function()
    local rows={}
    for _,amount in ipairs(SUPPORT_ORDER) do
        local productId=SUPPORT_PRODUCTS[amount]
        table.insert(rows,{amount=amount,productId=productId,enabled=productId>0})
    end
    return {
        enabled=supportEnabled,
        products=rows,
        currency="Robux",
        note=supportEnabled and "Support active" or "Support products pending official IDs",
    }
end

local boardCache={}
local orderedStore
pcall(function()
    orderedStore=DataStoreService:GetOrderedDataStore("BBYA_SupportTotals_v1")
end)

local function resolveName(userId)
    local name="User "..tostring(userId)
    if userId then
        pcall(function() name=PlayersSocial:GetNameFromUserIdAsync(userId) end)
    end
    return name
end

local function refreshBoardCache()
    if not orderedStore then
        boardCache={}
        return
    end
    local ok,pages=pcall(function() return orderedStore:GetSortedAsync(false,10) end)
    if not ok or not pages then return end
    local nextRows={}
    for rank,row in ipairs(pages:GetCurrentPage()) do
        local userId=tonumber(row.key)
        table.insert(nextRows,{
            rank=rank,
            userId=userId,
            name=resolveName(userId or row.key),
            total=tonumber(row.value) or 0,
        })
    end
    boardCache=nextRows
end

local function getSelfStats(player)
    local total=0
    if orderedStore then
        pcall(function() total=tonumber(orderedStore:GetAsync(tostring(player.UserId))) or 0 end)
    end
    local rank=nil
    for _,row in ipairs(boardCache) do
        if row.userId==player.UserId then rank=row.rank break end
    end
    return {total=total,rank=rank}
end

getSupportBoard.OnServerInvoke=function()
    if #boardCache==0 then refreshBoardCache() end
    return boardCache
end
getSupportSelf.OnServerInvoke=function(player)
    if #boardCache==0 then refreshBoardCache() end
    return getSelfStats(player)
end

local supportBoard=workspace:FindFirstChild("SUPPORT BOARD",true)
local function renderPhysicalSupportBoard()
    if not supportBoard then return end
    local gui=supportBoard:FindFirstChild("DISPLAY")
    local label=gui and gui:FindFirstChildOfClass("TextLabel")
    if not label then return end
    local lines={"SUPPORT","TOP SUPPORTERS"}
    if #boardCache==0 then
        table.insert(lines,"No supporters yet")
    else
        for i=1,math.min(5,#boardCache) do
            local row=boardCache[i]
            table.insert(lines,string.format("%d. %s  R$%d",i,row.name,row.total))
        end
    end
    label.Text=table.concat(lines,"\n")
end

if supportEnabled then
    MarketplaceService.ProcessReceipt=function(receiptInfo)
        local amount=PRODUCT_TO_AMOUNT[receiptInfo.ProductId]
        if not amount then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local ok=pcall(function()
            if not orderedStore then error("support store unavailable") end
            orderedStore:IncrementAsync(tostring(receiptInfo.PlayerId),amount)
        end)
        if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
        refreshBoardCache()
        renderPhysicalSupportBoard()
        supportChanged:FireAllClients({playerId=receiptInfo.PlayerId,amount=amount})
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
end
refreshBoardCache()
renderPhysicalSupportBoard()

-- =========================================================
-- MUSIC / AUTO DJ — OWNER REFERENCE IMAGE 3
-- =========================================================
local musicRoot=SoundService:FindFirstChild("BBYA MUSIC") or Instance.new("Folder")
musicRoot.Name="BBYA MUSIC"
musicRoot.Parent=SoundService

local function soundGroup(name)
    local group=SoundService:FindFirstChild(name)
    if not group then
        group=Instance.new("SoundGroup")
        group.Name=name
        group.Volume=1
        group.Parent=SoundService
    end
    local eq=group:FindFirstChild("BBYA EQ")
    if not eq then
        eq=Instance.new("EqualizerSoundEffect")
        eq.Name="BBYA EQ"
        eq.LowGain=0
        eq.MidGain=0
        eq.HighGain=0
        eq.Parent=group
    end
    return group
end

local clubGroup=soundGroup("BBYA CLUB GROUP")
local roofGroup=soundGroup("BBYA ROOFTOP GROUP")

local function deck(name,group)
    local s=musicRoot:FindFirstChild(name) or Instance.new("Sound")
    s.Name=name
    s.Looped=false
    s.Volume=0
    s.RollOffMaxDistance=180
    s.SoundGroup=group
    s.Parent=musicRoot
    return s
end

local clubA=deck("CLUB DECK A",clubGroup)
local clubB=deck("CLUB DECK B",clubGroup)
local roofA=deck("ROOFTOP DECK A",roofGroup)
local roofB=deck("ROOFTOP DECK B",roofGroup)

-- Authorized Roblox audio IDs only. Keep arrays empty until rights/availability are verified.
-- Track row shape when populated: {id=123456789,title="Track Title"}
local MUSIC_LIBRARY={club={},rooftop={}}
local musicLibraryReady=(#MUSIC_LIBRARY.club>0 or #MUSIC_LIBRARY.rooftop>0)
local CROSSFADE_SECONDS=3.5

local zones={
    club={key="club",decks={clubA,clubB},active=1,index=0,transitioning=false,currentTitle="Library pending",queuedTitle="—"},
    rooftop={key="rooftop",decks={roofA,roofB},active=1,index=0,transitioning=false,currentTitle="Library pending",queuedTitle="—"},
}

local function soundId(id)
    return "rbxassetid://"..tostring(id)
end

local function queueTitles(zoneKey,limit)
    local lib=MUSIC_LIBRARY[zoneKey]
    local rows={}
    for i=1,math.min(limit or 4,#lib) do table.insert(rows,lib[i].title or ("Track "..i)) end
    return rows
end

local function startTrack(zone,firstStart)
    local lib=MUSIC_LIBRARY[zone.key]
    if #lib==0 or zone.transitioning then return end
    zone.transitioning=true
    zone.index=(zone.index%#lib)+1
    local row=lib[zone.index]
    local nextIndex=(zone.index%#lib)+1
    local oldDeck=zone.decks[zone.active]
    local newActive=zone.active==1 and 2 or 1
    local newDeck=zone.decks[newActive]
    newDeck.SoundId=soundId(row.id)
    newDeck.TimePosition=0
    newDeck.Volume=0
    newDeck:Play()
    local fade=firstStart and .8 or CROSSFADE_SECONDS
    TweenServiceMusic:Create(newDeck,TweenInfo.new(fade,Enum.EasingStyle.Linear),{Volume=.58}):Play()
    if oldDeck.IsPlaying then
        local out=TweenServiceMusic:Create(oldDeck,TweenInfo.new(fade,Enum.EasingStyle.Linear),{Volume=0})
        out:Play()
        task.delay(fade+.1,function() if oldDeck then oldDeck:Stop() end end)
    end
    zone.active=newActive
    zone.currentTitle=row.title or "BBYA Track"
    zone.queuedTitle=lib[nextIndex] and (lib[nextIndex].title or "Next track") or "—"
    task.delay(fade+.15,function()
        zone.transitioning=false
        musicStateChanged:FireAllClients()
    end)
end

if musicLibraryReady then
    if #MUSIC_LIBRARY.club>0 then startTrack(zones.club,true) end
    if #MUSIC_LIBRARY.rooftop>0 then startTrack(zones.rooftop,true) end
    task.spawn(function()
        while musicLibraryReady do
            for _,zone in pairs(zones) do
                local active=zone.decks[zone.active]
                if active and active.IsPlaying and active.TimeLength>0 and active.TimePosition>=math.max(0,active.TimeLength-CROSSFADE_SECONDS) then
                    startTrack(zone,false)
                elseif active and not active.IsPlaying and #MUSIC_LIBRARY[zone.key]>0 and not zone.transitioning then
                    startTrack(zone,false)
                end
            end
            task.wait(.5)
        end
    end)
end

getMusicState.OnServerInvoke=function()
    return {
        autoDJ=true,
        mode="AUTO",
        libraryReady=musicLibraryReady,
        djModeAvailable=musicLibraryReady,
        trackTitle=musicLibraryReady and "Auto DJ active" or "Authorized music library pending",
        crossfadeSeconds=CROSSFADE_SECONDS,
        eqPreset="BALANCED",
        club={current=zones.club.currentTitle,queued=zones.club.queuedTitle,queue=queueTitles("club",4)},
        rooftop={current=zones.rooftop.currentTitle,queued=zones.rooftop.queuedTitle,queue=queueTitles("rooftop",4)},
    }
end

-- =========================================================
-- PHYSICAL FACILITY PROMPTS -> SAME CLIENT PANELS
-- =========================================================
local function bindPrompt(targetName,actionText,panelName)
    local target=workspace:FindFirstChild(targetName,true)
    if not target or not target:IsA("BasePart") then return false end
    local prompt=target:FindFirstChild("BBYA PANEL PROMPT") or Instance.new("ProximityPrompt")
    prompt.Name="BBYA PANEL PROMPT"
    prompt.ActionText=actionText
    prompt.ObjectText="BBYA"
    prompt.HoldDuration=0
    prompt.MaxActivationDistance=10
    prompt.RequiresLineOfSight=false
    prompt.Parent=target
    prompt.Triggered:Connect(function(player) openPanel:FireClient(player,panelName) end)
    return true
end

local prompts=0
if bindPrompt("SUPPORT BOARD BODY","Open Support","SUPPORT") then prompts+=1 end
if bindPrompt("DJ BOOTH","Open Music","MUSIC") then prompts+=1 end
if bindPrompt("POOL DJ DESK","Open Pool Music","MUSIC") then prompts+=1 end
if bindPrompt("SELFIE PLATFORM","Open Social Tools","PHOTO") then prompts+=1 end

workspace:SetAttribute("BBYASocialSystems","PHASE_5_REFERENCE_FIDELITY")
workspace:SetAttribute("BBYASupportProductsReady",supportEnabled)
workspace:SetAttribute("BBYASupportTierCount",#SUPPORT_ORDER)
workspace:SetAttribute("BBYAMusicLibraryReady",musicLibraryReady)
workspace:SetAttribute("BBYAMusicDeckCount",4)
workspace:SetAttribute("BBYAMusicCrossfadeSeconds",CROSSFADE_SECONDS)
workspace:SetAttribute("BBYAPanelPromptCount",prompts)
