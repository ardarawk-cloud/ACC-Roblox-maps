-- BBYA SOCIAL HUB — LIVE SERVICES OVERLAY
-- Activates resolved Support purchase tiers plus the owner-supplied six-track Hybrid Auto DJ.

local PlayersLive=game:GetService("Players")
local MarketplaceServiceLive=game:GetService("MarketplaceService")
local ReplicatedStorageLive=game:GetService("ReplicatedStorage")
local SoundServiceLive=game:GetService("SoundService")
local TweenServiceLive=game:GetService("TweenService")

local remotesLive=ReplicatedStorageLive:WaitForChild("BBYA REMOTES")
local getSupportConfigLive=remotesLive:WaitForChild("GetSupportConfig")
local getMusicStateLive=remotesLive:WaitForChild("GetMusicState")
local musicStateChangedLive=remotesLive:WaitForChild("MusicStateChanged")
local musicCommandLive=remotesLive:FindFirstChild("MusicCommand") or Instance.new("RemoteFunction")
musicCommandLive.Name="MusicCommand"
musicCommandLive.Parent=remotesLive

-- =========================================================
-- SUPPORT / SAWER — existing Roblox commerce resolved during deploy.
-- Developer Products are preferred; matching Support Game Passes are accepted as a one-time fallback.
-- =========================================================
local commerce=rawget(_G,"BBYA_COMMERCE_RESOLVED") or {}
local resolvedProducts=commerce.supportProducts or {}
local resolvedKinds=commerce.supportKinds or {}
local SUPPORT_ORDER_LIVE={5,10,50,100,500}
local SUPPORT_PRODUCTS_LIVE={}
local SUPPORT_KINDS_LIVE={}
local supportLiveEnabled=false
local resolvedCount=0
for _,amount in ipairs(SUPPORT_ORDER_LIVE) do
    local id=tonumber(resolvedProducts[amount] or resolvedProducts[tostring(amount)]) or 0
    local kind=tostring(resolvedKinds[amount] or resolvedKinds[tostring(amount)] or "none")
    if kind~="developerProduct" and kind~="gamePass" then kind="none" end
    SUPPORT_PRODUCTS_LIVE[amount]=id
    SUPPORT_KINDS_LIVE[amount]=kind
    if id>0 and kind~="none" then supportLiveEnabled=true;resolvedCount+=1 end
end

getSupportConfigLive.OnServerInvoke=function()
    local rows={}
    for _,amount in ipairs(SUPPORT_ORDER_LIVE) do
        local id=SUPPORT_PRODUCTS_LIVE[amount]
        local kind=SUPPORT_KINDS_LIVE[amount]
        table.insert(rows,{amount=amount,productId=id,enabled=id>0 and kind~="none",kind=kind})
    end
    return {
        enabled=supportLiveEnabled,
        products=rows,
        currency="Robux",
        note=supportLiveEnabled and "Support active" or "Support passes/products not resolved from Roblox",
    }
end

-- =========================================================
-- HYBRID AUTO DJ — owner-supplied Roblox audio IDs.
-- Auto DJ runs continuously; one DJ can claim temporary manual NEXT control.
-- =========================================================
local TRACKS_LIVE={
    {id=134073539670673,title="BBYA 01"},
    {id=116255319981650,title="BBYA 02"},
    {id=110691393637838,title="BBYA 03"},
    {id=85427648559465,title="BBYA 04"},
    {id=100787734732008,title="BBYA 05"},
    {id=103491797412309,title="BBYA 06"},
}

task.spawn(function()
    for _,row in ipairs(TRACKS_LIVE) do
        local ok,info=pcall(function() return MarketplaceServiceLive:GetProductInfo(row.id,Enum.InfoType.Asset) end)
        if ok and type(info)=="table" and type(info.Name)=="string" and info.Name~="" then row.title=info.Name end
    end
end)

local clubGroupLive=SoundServiceLive:WaitForChild("BBYA CLUB GROUP")
local roofGroupLive=SoundServiceLive:WaitForChild("BBYA ROOFTOP GROUP")
local musicRootLive=SoundServiceLive:WaitForChild("BBYA MUSIC")
local clubDecksLive={musicRootLive:WaitForChild("CLUB DECK A"),musicRootLive:WaitForChild("CLUB DECK B")}
local roofDecksLive={musicRootLive:WaitForChild("ROOFTOP DECK A"),musicRootLive:WaitForChild("ROOFTOP DECK B")}
clubGroupLive.Volume=.65
roofGroupLive.Volume=.45

local CROSSFADE_LIVE=3.5
local activeDeckLive=1
local trackIndexLive=0
local transitioningLive=false
local currentTitleLive="Starting Auto DJ"
local queuedTitleLive="—"
local activeDJUserId=nil
local activeDJName=nil
local lastDJAction=0
local DJ_IDLE_TIMEOUT=45

local function sid(id) return "rbxassetid://"..tostring(id) end
local function fireMusicState() musicStateChangedLive:FireAllClients() end

local function startHybridTrack(forceNext)
    if transitioningLive or #TRACKS_LIVE==0 then return end
    transitioningLive=true
    trackIndexLive=(trackIndexLive%#TRACKS_LIVE)+1
    local row=TRACKS_LIVE[trackIndexLive]
    local nextRow=TRACKS_LIVE[(trackIndexLive%#TRACKS_LIVE)+1]
    local nextDeck=activeDeckLive==1 and 2 or 1
    local oldClub=clubDecksLive[activeDeckLive]
    local oldRoof=roofDecksLive[activeDeckLive]
    local newClub=clubDecksLive[nextDeck]
    local newRoof=roofDecksLive[nextDeck]

    for _,s in ipairs({newClub,newRoof}) do
        s.SoundId=sid(row.id);s.TimePosition=0;s.Volume=0;s.Looped=false;s:Play()
    end
    local fade=forceNext and 1.25 or CROSSFADE_LIVE
    TweenServiceLive:Create(newClub,TweenInfo.new(fade,Enum.EasingStyle.Linear),{Volume=.58}):Play()
    TweenServiceLive:Create(newRoof,TweenInfo.new(fade,Enum.EasingStyle.Linear),{Volume=.58}):Play()
    for _,old in ipairs({oldClub,oldRoof}) do
        if old.IsPlaying then
            TweenServiceLive:Create(old,TweenInfo.new(fade,Enum.EasingStyle.Linear),{Volume=0}):Play()
            task.delay(fade+.1,function() if old and old.Parent then old:Stop() end end)
        end
    end
    activeDeckLive=nextDeck
    currentTitleLive=row.title
    queuedTitleLive=nextRow.title
    task.delay(fade+.15,function() transitioningLive=false;fireMusicState() end)
end

local function musicStateFor(player)
    return {
        autoDJ=true,
        mode=activeDJUserId and "HYBRID_DJ_OVERRIDE" or "HYBRID_AUTO",
        libraryReady=true,
        djModeAvailable=true,
        djActive=activeDJUserId~=nil,
        djOwnerUserId=activeDJUserId,
        djOwnerName=activeDJName,
        isDJ=player and activeDJUserId==player.UserId or false,
        trackTitle=currentTitleLive,
        crossfadeSeconds=CROSSFADE_LIVE,
        eqPreset="BALANCED",
        club={current=currentTitleLive,queued=queuedTitleLive,queue={TRACKS_LIVE[1].title,TRACKS_LIVE[2].title,TRACKS_LIVE[3].title,TRACKS_LIVE[4].title}},
        rooftop={current=currentTitleLive,queued=queuedTitleLive,queue={TRACKS_LIVE[3].title,TRACKS_LIVE[4].title,TRACKS_LIVE[5].title,TRACKS_LIVE[6].title}},
    }
end

getMusicStateLive.OnServerInvoke=function(player) return musicStateFor(player) end

musicCommandLive.OnServerInvoke=function(player,command)
    command=tostring(command or "")
    if command=="TOGGLE_DJ" then
        if activeDJUserId==nil then
            activeDJUserId=player.UserId;activeDJName=player.DisplayName;lastDJAction=os.clock()
        elseif activeDJUserId==player.UserId then
            activeDJUserId=nil;activeDJName=nil;lastDJAction=0
        else
            return {ok=false,message="DJ booth is currently controlled by "..tostring(activeDJName or "another DJ"),state=musicStateFor(player)}
        end
        fireMusicState()
        return {ok=true,message=activeDJUserId and "DJ MODE ACTIVE" or "AUTO DJ RESUMED",state=musicStateFor(player)}
    elseif command=="NEXT" then
        if activeDJUserId~=player.UserId then return {ok=false,message="Claim DJ MODE first",state=musicStateFor(player)} end
        lastDJAction=os.clock();startHybridTrack(true)
        return {ok=true,message="Crossfading to next track",state=musicStateFor(player)}
    elseif command=="RELEASE_DJ" then
        if activeDJUserId==player.UserId then activeDJUserId=nil;activeDJName=nil;lastDJAction=0;fireMusicState() end
        return {ok=true,message="AUTO DJ ACTIVE",state=musicStateFor(player)}
    end
    return {ok=false,message="Unknown music command",state=musicStateFor(player)}
end

PlayersLive.PlayerRemoving:Connect(function(player)
    if activeDJUserId==player.UserId then activeDJUserId=nil;activeDJName=nil;lastDJAction=0;fireMusicState() end
end)

startHybridTrack(true)
task.spawn(function()
    while true do
        if activeDJUserId and lastDJAction>0 and os.clock()-lastDJAction>=DJ_IDLE_TIMEOUT then
            activeDJUserId=nil;activeDJName=nil;lastDJAction=0;fireMusicState()
        end
        local active=clubDecksLive[activeDeckLive]
        if active and active.IsPlaying and active.TimeLength>0 and active.TimePosition>=math.max(0,active.TimeLength-CROSSFADE_LIVE) then
            startHybridTrack(false)
        elseif active and not active.IsPlaying and not transitioningLive then
            startHybridTrack(false)
        end
        task.wait(.5)
    end
end)

workspace:SetAttribute("BBYASupportProductsReady",supportLiveEnabled)
workspace:SetAttribute("BBYALiveSupportResolvedCount",resolvedCount)
workspace:SetAttribute("BBYAMusicLibraryReady",true)
workspace:SetAttribute("BBYAHybridAutoDJ",true)
workspace:SetAttribute("BBYAHybridTrackCount",#TRACKS_LIVE)
workspace:SetAttribute("BBYADJIdleTimeout",DJ_IDLE_TIMEOUT)
