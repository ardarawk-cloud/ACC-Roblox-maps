-- BBYA SOCIAL HUB — LIVE SERVICES OVERLAY
-- Activates resolved Support developer products and the owner-supplied 6-track Hybrid Auto DJ.
-- The static phase-5 source remains fail-closed; this overlay receives commerce IDs from the deploy resolver.

local PlayersLive=game:GetService("Players")
local MarketplaceServiceLive=game:GetService("MarketplaceService")
local DataStoreServiceLive=game:GetService("DataStoreService")
local ReplicatedStorageLive=game:GetService("ReplicatedStorage")
local SoundServiceLive=game:GetService("SoundService")
local TweenServiceLive=game:GetService("TweenService")

local remotesLive=ReplicatedStorageLive:WaitForChild("BBYA REMOTES")
local getSupportConfigLive=remotesLive:WaitForChild("GetSupportConfig")
local supportChangedLive=remotesLive:WaitForChild("SupportChanged")
local getMusicStateLive=remotesLive:WaitForChild("GetMusicState")
local musicStateChangedLive=remotesLive:WaitForChild("MusicStateChanged")
local musicCommandLive=remotesLive:FindFirstChild("MusicCommand") or Instance.new("RemoteFunction")
musicCommandLive.Name="MusicCommand"
musicCommandLive.Parent=remotesLive

-- =========================================================
-- SUPPORT / SAWER — IDs resolved from Roblox Open Cloud during deploy.
-- =========================================================
local commerce=rawget(_G,"BBYA_COMMERCE_RESOLVED") or {}
local resolvedProducts=commerce.supportProducts or {}
local SUPPORT_ORDER_LIVE={5,10,50,100,500}
local SUPPORT_PRODUCTS_LIVE={}
local PRODUCT_TO_AMOUNT_LIVE={}
for _,amount in ipairs(SUPPORT_ORDER_LIVE) do
    local id=tonumber(resolvedProducts[amount] or resolvedProducts[tostring(amount)]) or 0
    SUPPORT_PRODUCTS_LIVE[amount]=id
    if id>0 then PRODUCT_TO_AMOUNT_LIVE[id]=amount end
end
local supportLiveEnabled=next(PRODUCT_TO_AMOUNT_LIVE)~=nil

getSupportConfigLive.OnServerInvoke=function()
    local rows={}
    for _,amount in ipairs(SUPPORT_ORDER_LIVE) do
        local productId=SUPPORT_PRODUCTS_LIVE[amount]
        table.insert(rows,{amount=amount,productId=productId,enabled=productId>0,kind="developerProduct"})
    end
    return {
        enabled=supportLiveEnabled,
        products=rows,
        currency="Robux",
        note=supportLiveEnabled and "Support active" or "Support products not resolved from Roblox",
    }
end

local supportTotalsLive=DataStoreServiceLive:GetOrderedDataStore("BBYA_SupportTotals_v1")
local receiptStoreLive=DataStoreServiceLive:GetDataStore("BBYA_SupportReceipts_v1")

if supportLiveEnabled then
    MarketplaceServiceLive.ProcessReceipt=function(receiptInfo)
        local amount=PRODUCT_TO_AMOUNT_LIVE[receiptInfo.ProductId]
        if not amount then return Enum.ProductPurchaseDecision.NotProcessedYet end

        local grantedNow=false
        local okReceipt=pcall(function()
            receiptStoreLive:UpdateAsync(tostring(receiptInfo.PurchaseId),function(existing)
                if existing then return existing end
                grantedNow=true
                return {playerId=receiptInfo.PlayerId,amount=amount,at=os.time()}
            end)
        end)
        if not okReceipt then return Enum.ProductPurchaseDecision.NotProcessedYet end

        if grantedNow then
            local okTotal=pcall(function()
                supportTotalsLive:IncrementAsync(tostring(receiptInfo.PlayerId),amount)
            end)
            if not okTotal then return Enum.ProductPurchaseDecision.NotProcessedYet end
        end

        local player=PlayersLive:GetPlayerByUserId(receiptInfo.PlayerId)
        if player then
            local total=0
            pcall(function() total=tonumber(supportTotalsLive:GetAsync(tostring(player.UserId))) or 0 end)
            player:SetAttribute("TotalDonated",total)
        end
        supportChangedLive:FireAllClients({playerId=receiptInfo.PlayerId,amount=amount})
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
end

-- =========================================================
-- HYBRID AUTO DJ — owner-supplied Roblox audio IDs.
-- Auto DJ runs continuously; one DJ can claim temporary manual NEXT control.
-- Both zone decks stay synchronized so listener mode can switch Club/Rooftop without restarting a track.
-- =========================================================
local TRACKS_LIVE={
    {id=134073539670673,title="BBYA 01"},
    {id=116255319981650,title="BBYA 02"},
    {id=110691393637838,title="BBYA 03"},
    {id=85427648559465,title="BBYA 04"},
    {id=100787734732008,title="BBYA 05"},
    {id=103491797412309,title="BBYA 06"},
}

-- Resolve display names when Roblox exposes metadata; generic titles remain safe fallback.
task.spawn(function()
    for _,row in ipairs(TRACKS_LIVE) do
        local ok,info=pcall(function()
            return MarketplaceServiceLive:GetProductInfo(row.id,Enum.InfoType.Asset)
        end)
        if ok and type(info)=="table" and type(info.Name)=="string" and info.Name~="" then
            row.title=info.Name
        end
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

local function fireMusicState()
    musicStateChangedLive:FireAllClients()
end

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
        s.SoundId=sid(row.id)
        s.TimePosition=0
        s.Volume=0
        s.Looped=false
        s:Play()
    end

    local fade=forceNext and 1.25 or CROSSFADE_LIVE
    TweenServiceLive:Create(newClub,TweenInfo.new(fade,Enum.EasingStyle.Linear),{Volume=.58}):Play()
    TweenServiceLive:Create(newRoof,TweenInfo.new(fade,Enum.EasingStyle.Linear),{Volume=.58}):Play()

    for _,old in ipairs({oldClub,oldRoof}) do
        if old.IsPlaying then
            TweenServiceLive:Create(old,TweenInfo.new(fade,Enum.EasingStyle.Linear),{Volume=0}):Play()
            task.delay(fade+.1,function()
                if old and old.Parent then old:Stop() end
            end)
        end
    end

    activeDeckLive=nextDeck
    currentTitleLive=row.title
    queuedTitleLive=nextRow.title
    task.delay(fade+.15,function()
        transitioningLive=false
        fireMusicState()
    end)
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

getMusicStateLive.OnServerInvoke=function(player)
    return musicStateFor(player)
end

musicCommandLive.OnServerInvoke=function(player,command)
    command=tostring(command or "")
    if command=="TOGGLE_DJ" then
        if activeDJUserId==nil then
            activeDJUserId=player.UserId
            activeDJName=player.DisplayName
            lastDJAction=os.clock()
        elseif activeDJUserId==player.UserId then
            activeDJUserId=nil
            activeDJName=nil
            lastDJAction=0
        else
            return {ok=false,message="DJ booth is currently controlled by "..tostring(activeDJName or "another DJ"),state=musicStateFor(player)}
        end
        fireMusicState()
        return {ok=true,message=activeDJUserId and "DJ MODE ACTIVE" or "AUTO DJ RESUMED",state=musicStateFor(player)}
    elseif command=="NEXT" then
        if activeDJUserId~=player.UserId then
            return {ok=false,message="Claim DJ MODE first",state=musicStateFor(player)}
        end
        lastDJAction=os.clock()
        startHybridTrack(true)
        return {ok=true,message="Crossfading to next track",state=musicStateFor(player)}
    elseif command=="RELEASE_DJ" then
        if activeDJUserId==player.UserId then
            activeDJUserId=nil
            activeDJName=nil
            lastDJAction=0
            fireMusicState()
        end
        return {ok=true,message="AUTO DJ ACTIVE",state=musicStateFor(player)}
    end
    return {ok=false,message="Unknown music command",state=musicStateFor(player)}
end

PlayersLive.PlayerRemoving:Connect(function(player)
    if activeDJUserId==player.UserId then
        activeDJUserId=nil
        activeDJName=nil
        lastDJAction=0
        fireMusicState()
    end
end)

startHybridTrack(true)
task.spawn(function()
    while true do
        if activeDJUserId and lastDJAction>0 and os.clock()-lastDJAction>=DJ_IDLE_TIMEOUT then
            activeDJUserId=nil
            activeDJName=nil
            lastDJAction=0
            fireMusicState()
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
workspace:SetAttribute("BBYALiveSupportResolvedCount",(function() local n=0 for _ in pairs(PRODUCT_TO_AMOUNT_LIVE) do n+=1 end return n end)())
workspace:SetAttribute("BBYAMusicLibraryReady",true)
workspace:SetAttribute("BBYAHybridAutoDJ",true)
workspace:SetAttribute("BBYAHybridTrackCount",#TRACKS_LIVE)
workspace:SetAttribute("BBYADJIdleTimeout",DJ_IDLE_TIMEOUT)
