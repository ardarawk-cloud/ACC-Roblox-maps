-- BBYA SOCIAL HUB — PHASE 4 SUPPORT + MUSIC SERVER SYSTEMS
-- Authoritative backend. Commerce stays disabled while official Developer Product IDs are zero.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local DataStoreService=game:GetService("DataStoreService")
local SoundService=game:GetService("SoundService")

local remoteRoot=ReplicatedStorage:FindFirstChild("BBYA REMOTES") or Instance.new("Folder")
remoteRoot.Name="BBYA REMOTES"
remoteRoot.Parent=ReplicatedStorage

local function remoteEvent(name)
    local r=remoteRoot:FindFirstChild(name) or Instance.new("RemoteEvent")
    r.Name=name;r.Parent=remoteRoot;return r
end
local function remoteFunction(name)
    local r=remoteRoot:FindFirstChild(name) or Instance.new("RemoteFunction")
    r.Name=name;r.Parent=remoteRoot;return r
end

local openPanel=remoteEvent("OpenPanel")
local getSupportConfig=remoteFunction("GetSupportConfig")
local getSupportBoard=remoteFunction("GetSupportBoard")
local getMusicState=remoteFunction("GetMusicState")

-- =========================================================
-- SUPPORT / SAWER
-- =========================================================
-- Zero is intentional. Never invent commerce IDs.
local SUPPORT_PRODUCTS={
    [5]=0,
    [10]=0,
    [25]=0,
    [50]=0,
    [100]=0,
    [500]=0,
}

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
    for _,amount in ipairs({5,10,25,50,100,500}) do
        table.insert(rows,{amount=amount,productId=SUPPORT_PRODUCTS[amount],enabled=SUPPORT_PRODUCTS[amount]>0})
    end
    return {enabled=supportEnabled,products=rows,currency="Robux",note=supportEnabled and "Support active" or "Support products pending official IDs"}
end

local boardCache={}
local orderedStore
pcall(function() orderedStore=DataStoreService:GetOrderedDataStore("BBYA_SupportTotals_v1") end)

local function refreshBoardCache()
    if not orderedStore then return end
    local ok,pages=pcall(function() return orderedStore:GetSortedAsync(false,10) end)
    if not ok or not pages then return end
    local page=pages:GetCurrentPage()
    local nextRows={}
    for rank,row in ipairs(page) do
        local userId=tonumber(row.key)
        local name="User "..tostring(row.key)
        if userId then pcall(function() name=Players:GetNameFromUserIdAsync(userId) end) end
        table.insert(nextRows,{rank=rank,userId=userId,name=name,total=tonumber(row.value) or 0})
    end
    boardCache=nextRows
end

-- Players is already defined by 00-core.lua in the assembled server runtime.
getSupportBoard.OnServerInvoke=function()
    if #boardCache==0 then refreshBoardCache() end
    return boardCache
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
            if orderedStore then orderedStore:IncrementAsync(tostring(receiptInfo.PlayerId),amount) end
        end)
        if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
        refreshBoardCache()
        renderPhysicalSupportBoard()
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
end
renderPhysicalSupportBoard()

-- =========================================================
-- MUSIC / AUTO DJ
-- =========================================================
local musicRoot=SoundService:FindFirstChild("BBYA MUSIC") or Instance.new("Folder")
musicRoot.Name="BBYA MUSIC"
musicRoot.Parent=SoundService

local function channel(name)
    local s=musicRoot:FindFirstChild(name) or Instance.new("Sound")
    s.Name=name
    s.Looped=true
    s.Volume=.55
    s.RollOffMaxDistance=180
    s.Parent=musicRoot
    return s
end
local clubAudio=channel("CLUB CHANNEL")
local roofAudio=channel("ROOFTOP CHANNEL")

-- Authorized track IDs are intentionally empty until supplied/verified.
local MUSIC_LIBRARY={club={},rooftop={}}
local musicLibraryReady=(#MUSIC_LIBRARY.club>0 or #MUSIC_LIBRARY.rooftop>0)
local musicState={autoDJ=true,mode="AUTO",trackTitle=musicLibraryReady and "Auto DJ" or "Authorized music library pending",libraryReady=musicLibraryReady}

getMusicState.OnServerInvoke=function()
    return {
        autoDJ=musicState.autoDJ,
        mode=musicState.mode,
        trackTitle=musicState.trackTitle,
        libraryReady=musicState.libraryReady,
        clubSoundName=clubAudio.Name,
        rooftopSoundName=roofAudio.Name,
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

workspace:SetAttribute("BBYASocialSystems","PHASE_4_ACTIVE")
workspace:SetAttribute("BBYASupportProductsReady",supportEnabled)
workspace:SetAttribute("BBYAMusicLibraryReady",musicLibraryReady)
workspace:SetAttribute("BBYAPanelPromptCount",prompts)
