-- BBYA V6 — AUTHORITATIVE VIP / SUPPORT BACKEND
-- Real IDs remain 0 until owner supplies them. No fake transactions, no invented IDs.

local MarketplaceService=game:GetService("MarketplaceService")
local DataStoreService=game:GetService("DataStoreService")
local PhysicsService=game:GetService("PhysicsService")

local QUEEN_USER_ID=4271188557
local VIP_GAMEPASS_ID=0
local SUPPORT_PRODUCTS={
    [5]=0,[10]=0,[25]=0,[50]=0,[100]=0,[250]=0,[500]=0,
}

local donationStore=DataStoreService:GetDataStore("BBYA_Donations_v2")
local supporterStore=DataStoreService:GetOrderedDataStore("BBYA_TopSupporters_v1")

local config=ReplicatedStorage:FindFirstChild("BBYA_V6_Monetization") or Instance.new("Folder")
config.Name="BBYA_V6_Monetization";config.Parent=ReplicatedStorage
local function intValue(name,value)
    local v=config:FindFirstChild(name) or Instance.new("IntValue")
    v.Name=name;v.Value=value or 0;v.Parent=config;return v
end
intValue("VIPGamePassId",VIP_GAMEPASS_ID)
for amount,id in pairs(SUPPORT_PRODUCTS) do intValue("Support_"..amount,id) end

local productToAmount={}
for amount,id in pairs(SUPPORT_PRODUCTS) do if type(id)=="number" and id>0 then productToAmount[id]=amount end end
local vipConfigured=VIP_GAMEPASS_ID>0
local supportConfigured=next(productToAmount)~=nil
workspace:SetAttribute("BBYAV6VIPConfigured",vipConfigured)
workspace:SetAttribute("BBYAV6SupportConfigured",supportConfigured)
workspace:SetAttribute("BBYAV6MonetizationConfigured",vipConfigured or supportConfigured)
workspace:SetAttribute("BBYAV6VIPTargetPrice",10)

-- VIP collision barrier groups. When pass is pending, barriers remain non-collidable preview gates.
pcall(function() PhysicsService:RegisterCollisionGroup("BBYA_VIP_MEMBER") end)
pcall(function() PhysicsService:RegisterCollisionGroup("BBYA_VIP_GATE") end)
pcall(function() PhysicsService:CollisionGroupSetCollidable("BBYA_VIP_MEMBER","BBYA_VIP_GATE",false) end)
pcall(function() PhysicsService:CollisionGroupSetCollidable("Default","BBYA_VIP_GATE",true) end)

local function setCharacterGroup(player)
    local char=player.Character;if not char then return end
    local group=(player:GetAttribute("IsVIP")==true or player:GetAttribute("BBYAAllAccess")==true) and "BBYA_VIP_MEMBER" or "Default"
    for _,o in ipairs(char:GetDescendants()) do if o:IsA("BasePart") then pcall(function() o.CollisionGroup=group end) end end
end

local gates={}
for _,o in ipairs(workspace:GetDescendants()) do
    if o:IsA("BasePart") and o:GetAttribute("BBYAVIPBarrier")==true then
        table.insert(gates,o)
        pcall(function() o.CollisionGroup="BBYA_VIP_GATE" end)
        o.CanCollide=vipConfigured
        if vipConfigured then
            local pr=Instance.new("ProximityPrompt")
            pr.Name="VIP PURCHASE";pr.ActionText="GET VIP";pr.ObjectText="BBYA VIP";pr.MaxActivationDistance=10;pr.HoldDuration=0;pr.RequiresLineOfSight=false;pr.Parent=o
            pr.Triggered:Connect(function(player)
                if player:GetAttribute("IsVIP")==true or player:GetAttribute("BBYAAllAccess")==true then return end
                MarketplaceService:PromptGamePassPurchase(player,VIP_GAMEPASS_ID)
            end)
        end
    end
end
workspace:SetAttribute("BBYAV6VIPGates",vipConfigured and "ACTIVE" or "PREVIEW_OPEN")

local function loadDonation(player)
    player:SetAttribute("TotalDonated",player:GetAttribute("TotalDonated") or 0)
    local ok,data=pcall(function() return donationStore:GetAsync("u"..player.UserId) end)
    if ok and type(data)=="table" then player:SetAttribute("TotalDonated",tonumber(data.Total) or 0) end
end
local function checkVIP(player)
    if player.UserId==QUEEN_USER_ID then
        player:SetAttribute("IsVIP",true);player:SetAttribute("BBYAAllAccess",true);setCharacterGroup(player);return
    end
    if not vipConfigured then player:SetAttribute("IsVIP",false);setCharacterGroup(player);return end
    local ok,owns=pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId,VIP_GAMEPASS_ID) end)
    player:SetAttribute("IsVIP",ok and owns==true);setCharacterGroup(player)
end
local function setupCommercePlayer(player)
    task.spawn(loadDonation,player);task.spawn(checkVIP,player)
    player.CharacterAdded:Connect(function(char)
        task.wait(.4);setCharacterGroup(player)
        char.DescendantAdded:Connect(function(o) if o:IsA("BasePart") then task.defer(setCharacterGroup,player) end end)
    end)
    player:GetAttributeChangedSignal("IsVIP"):Connect(function() setCharacterGroup(player) end)
end
for _,p in ipairs(Players:GetPlayers()) do setupCommercePlayer(p) end
Players.PlayerAdded:Connect(setupCommercePlayer)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
    if vipConfigured and purchased and passId==VIP_GAMEPASS_ID then player:SetAttribute("IsVIP",true);setCharacterGroup(player) end
end)

-- Top Supporters query. Safe when DataStore API is unavailable: returns empty list rather than inventing data.
local board=net:FindFirstChild("SupportBoard") or Instance.new("RemoteFunction")
board.Name="SupportBoard";board.Parent=net
board.OnServerInvoke=function(player)
    local result={}
    local ok,pages=pcall(function() return supporterStore:GetSortedAsync(false,10) end)
    if not ok or not pages then return result end
    for rank,item in ipairs(pages:GetCurrentPage()) do
        local uid=tonumber(tostring(item.key):match("u(%d+)"));local name=uid and ("User "..uid) or tostring(item.key)
        if uid then pcall(function() name=Players:GetNameFromUserIdAsync(uid) end) end
        table.insert(result,{rank=rank,userId=uid or 0,name=name,total=tonumber(item.value) or 0})
    end
    return result
end

-- Exactly one V6 ProcessReceipt owner, and only installed when real support product IDs exist.
if supportConfigured then
    MarketplaceService.ProcessReceipt=function(receiptInfo)
        local amount=productToAmount[receiptInfo.ProductId]
        if not amount then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local player=Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local purchaseId=tostring(receiptInfo.PurchaseId);local grantedNow=false
        local ok,updated=pcall(function()
            return donationStore:UpdateAsync("u"..player.UserId,function(data)
                data=type(data)=="table" and data or {Total=0,Receipts={}}
                data.Total=tonumber(data.Total) or 0;data.Receipts=type(data.Receipts)=="table" and data.Receipts or {}
                if data.Receipts[purchaseId] then return data end
                data.Total+=amount;data.Receipts[purchaseId]=os.time();grantedNow=true;return data
            end)
        end)
        if not ok or type(updated)~="table" then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local total=tonumber(updated.Total) or 0;player:SetAttribute("TotalDonated",total)
        pcall(function() supporterStore:SetAsync("u"..player.UserId,total) end)
        if grantedNow then
            workspace:SetAttribute("BBYALastSupporter",player.DisplayName)
            workspace:SetAttribute("BBYALastSupportAmount",amount)
            workspace:SetAttribute("BBYALastSupportTotal",total)
        end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
end

workspace:SetAttribute("BBYAV6CommerceBackend","DORMANT_SAFE")