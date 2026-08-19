-- BBYA SOCIAL HUB — V7 CLEAN SOCIAL SYSTEMS
-- Fail-closed support/music shell. No fake product IDs, no unverified audio IDs.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local MarketplaceService=game:GetService("MarketplaceService")
local DataStoreService=game:GetService("DataStoreService")
local PlayersSocial=game:GetService("Players")

local remotes=ReplicatedStorage:FindFirstChild("BBYA REMOTES") or Instance.new("Folder")
remotes.Name="BBYA REMOTES"
remotes.Parent=ReplicatedStorage
local function ev(name)
    local r=remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
    r.Name=name;r.Parent=remotes;return r
end
local function fn(name)
    local r=remotes:FindFirstChild(name) or Instance.new("RemoteFunction")
    r.Name=name;r.Parent=remotes;return r
end

local OpenPanel=ev("OpenPanel")
local SupportChanged=ev("SupportChanged")
local MusicStateChanged=ev("MusicStateChanged")
local GetSupportConfig=fn("GetSupportConfig")
local GetSupportBoard=fn("GetSupportBoard")
local GetSupportSelf=fn("GetSupportSelf")
local GetMusicState=fn("GetMusicState")

-- Official Developer Product IDs intentionally remain zero until supplied by owner.
local SUPPORT_PRODUCTS={[5]=0,[10]=0,[50]=0,[100]=0,[500]=0}
local SUPPORT_ORDER={5,10,50,100,500}
local PRODUCT_TO_AMOUNT={}
local supportEnabled=false
for amount,id in pairs(SUPPORT_PRODUCTS) do
    if id>0 then PRODUCT_TO_AMOUNT[id]=amount;supportEnabled=true end
end

GetSupportConfig.OnServerInvoke=function()
    local products={}
    for _,amount in ipairs(SUPPORT_ORDER) do
        local id=SUPPORT_PRODUCTS[amount]
        table.insert(products,{amount=amount,productId=id,enabled=id>0})
    end
    return {enabled=supportEnabled,products=products,currency="Robux",note=supportEnabled and "Support active" or "Support products pending official IDs"}
end

local store
pcall(function() store=DataStoreService:GetOrderedDataStore("BBYA_SupportTotals_v1") end)
local board={}
local function resolveName(id)
    local name="User "..tostring(id)
    pcall(function() name=PlayersSocial:GetNameFromUserIdAsync(id) end)
    return name
end
local function refreshBoard()
    if not store then board={};return end
    local ok,pages=pcall(function() return store:GetSortedAsync(false,10) end)
    if not ok or not pages then return end
    local rows={}
    for rank,row in ipairs(pages:GetCurrentPage()) do
        local id=tonumber(row.key)
        table.insert(rows,{rank=rank,userId=id,name=resolveName(id or 0),total=tonumber(row.value) or 0})
    end
    board=rows
end
GetSupportBoard.OnServerInvoke=function() if #board==0 then refreshBoard() end return board end
GetSupportSelf.OnServerInvoke=function(player)
    local total=0
    if store then pcall(function() total=tonumber(store:GetAsync(tostring(player.UserId))) or 0 end) end
    local rank
    for _,row in ipairs(board) do if row.userId==player.UserId then rank=row.rank break end end
    return {total=total,rank=rank}
end

local physicalBoard=workspace:FindFirstChild("SUPPORT BOARD",true)
local function renderBoard()
    if not physicalBoard then return end
    local gui=physicalBoard:FindFirstChild("DISPLAY")
    local label=gui and gui:FindFirstChildOfClass("TextLabel")
    if not label then return end
    local lines={"TOP SUPPORTERS"}
    if #board==0 then table.insert(lines,"No supporters yet") end
    for i=1,math.min(5,#board) do
        local row=board[i]
        table.insert(lines,string.format("%d. %s  R$%d",i,row.name,row.total))
    end
    label.Text=table.concat(lines,"\n")
end
refreshBoard();renderBoard()

if supportEnabled then
    MarketplaceService.ProcessReceipt=function(receipt)
        local amount=PRODUCT_TO_AMOUNT[receipt.ProductId]
        if not amount or not store then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local ok=pcall(function() store:IncrementAsync(tostring(receipt.PlayerId),amount) end)
        if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
        refreshBoard();renderBoard();SupportChanged:FireAllClients({playerId=receipt.PlayerId,amount=amount})
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
end

-- Two-zone audio topology exists, but library remains empty until authorized Roblox audio is supplied.
local musicRoot=SoundService:FindFirstChild("BBYA MUSIC") or Instance.new("Folder")
musicRoot.Name="BBYA MUSIC";musicRoot.Parent=SoundService
local function group(name)
    local g=SoundService:FindFirstChild(name) or Instance.new("SoundGroup")
    g.Name=name;g.Volume=1;g.Parent=SoundService
    if not g:FindFirstChild("BBYA EQ") then
        local eq=Instance.new("EqualizerSoundEffect");eq.Name="BBYA EQ";eq.Parent=g
    end
    return g
end
local clubGroup=group("BBYA CLUB GROUP")
local roofGroup=group("BBYA ROOFTOP GROUP")
local function deck(name,g)
    local s=musicRoot:FindFirstChild(name) or Instance.new("Sound")
    s.Name=name;s.Volume=0;s.Looped=false;s.SoundGroup=g;s.Parent=musicRoot
    return s
end
deck("CLUB DECK A",clubGroup);deck("CLUB DECK B",clubGroup);deck("ROOFTOP DECK A",roofGroup);deck("ROOFTOP DECK B",roofGroup)
local musicLibraryReady=false
GetMusicState.OnServerInvoke=function()
    return {autoDJ=true,mode="AUTO",libraryReady=false,djModeAvailable=false,trackTitle="Authorized music library pending",crossfadeSeconds=3.5,eqPreset="BALANCED",club={current="Library pending",queued="—",queue={}},rooftop={current="Library pending",queued="—",queue={}}}
end

local function bindPrompt(targetName,actionText,panelName)
    local target=workspace:FindFirstChild(targetName,true)
    if not target or not target:IsA("BasePart") then return false end
    local prompt=target:FindFirstChild("BBYA PANEL PROMPT") or Instance.new("ProximityPrompt")
    prompt.Name="BBYA PANEL PROMPT";prompt.ActionText=actionText;prompt.ObjectText="BBYA";prompt.HoldDuration=0;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=target
    prompt.Triggered:Connect(function(player) OpenPanel:FireClient(player,panelName) end)
    return true
end
local prompts=0
if bindPrompt("SUPPORT WALL PANEL","Open Support","SUPPORT") then prompts+=1 end
if bindPrompt("DJ BOOTH","Open Music","MUSIC") then prompts+=1 end
if bindPrompt("POOL DJ DESK","Open Pool Music","MUSIC") then prompts+=1 end
if bindPrompt("SELFIE PLATFORM","Open Social Tools","PHOTO") then prompts+=1 end

workspace:SetAttribute("BBYASocialSystems","V7_CLEAN_FAIL_CLOSED")
workspace:SetAttribute("BBYASupportProductsReady",supportEnabled)
workspace:SetAttribute("BBYASupportTierCount",#SUPPORT_ORDER)
workspace:SetAttribute("BBYAMusicLibraryReady",musicLibraryReady)
workspace:SetAttribute("BBYAMusicDeckCount",4)
workspace:SetAttribute("BBYAMusicCrossfadeSeconds",3.5)
workspace:SetAttribute("BBYAPanelPromptCount",prompts)
MusicStateChanged:FireAllClients()
