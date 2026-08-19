-- BBYA SOCIAL HUB — SUPPORT RECEIPT SAFETY HOTFIX
-- Final support grant owner for both repeatable Developer Products and one-time Support Game Pass fallback.

local MarketplaceServiceReceipt=game:GetService("MarketplaceService")
local DataStoreServiceReceipt=game:GetService("DataStoreService")
local PlayersReceipt=game:GetService("Players")
local ReplicatedStorageReceipt=game:GetService("ReplicatedStorage")

local commerceReceipt=rawget(_G,"BBYA_COMMERCE_RESOLVED") or {}
local resolvedReceipt=commerceReceipt.supportProducts or {}
local kindsReceipt=commerceReceipt.supportKinds or {}
local productToAmountReceipt={}
local passToAmountReceipt={}
for _,amount in ipairs({5,10,50,100,500,10000}) do
    local id=tonumber(resolvedReceipt[amount] or resolvedReceipt[tostring(amount)]) or 0
    local kind=tostring(kindsReceipt[amount] or kindsReceipt[tostring(amount)] or "none")
    if id>0 and kind=="developerProduct" then productToAmountReceipt[id]=amount end
    if id>0 and kind=="gamePass" then passToAmountReceipt[id]=amount end
end

if next(productToAmountReceipt)~=nil or next(passToAmountReceipt)~=nil then
    local ledger=DataStoreServiceReceipt:GetDataStore("BBYA_SupportLedger_v2")
    local totals=DataStoreServiceReceipt:GetOrderedDataStore("BBYA_SupportTotals_v1")
    local remotesReceipt=ReplicatedStorageReceipt:WaitForChild("BBYA REMOTES")
    local changedReceipt=remotesReceipt:WaitForChild("SupportChanged")

    local function grant(playerId,receiptKey,amount)
        local newlyGranted=false
        local ok,data=pcall(function()
            return ledger:UpdateAsync("u"..tostring(playerId),function(current)
                current=type(current)=="table" and current or {total=0,receipts={}}
                current.total=tonumber(current.total) or 0
                current.receipts=type(current.receipts)=="table" and current.receipts or {}
                if current.receipts[receiptKey] then return current end
                current.total+=amount
                current.receipts[receiptKey]=os.time()
                newlyGranted=true
                return current
            end)
        end)
        if not ok or type(data)~="table" then return false,false,0 end
        local totalAfter=tonumber(data.total) or 0
        local okMirror=pcall(function() totals:SetAsync(tostring(playerId),totalAfter) end)
        if not okMirror then return false,false,totalAfter end
        local player=PlayersReceipt:GetPlayerByUserId(playerId)
        if player then player:SetAttribute("TotalDonated",totalAfter) end
        if newlyGranted then changedReceipt:FireAllClients({playerId=playerId,amount=amount,total=totalAfter}) end
        return true,newlyGranted,totalAfter
    end

    if next(productToAmountReceipt)~=nil then
        MarketplaceServiceReceipt.ProcessReceipt=function(receiptInfo)
            local amount=productToAmountReceipt[receiptInfo.ProductId]
            if not amount then return Enum.ProductPurchaseDecision.NotProcessedYet end
            local ok=grant(receiptInfo.PlayerId,"product:"..tostring(receiptInfo.PurchaseId),amount)
            return ok and Enum.ProductPurchaseDecision.PurchaseGranted or Enum.ProductPurchaseDecision.NotProcessedYet
        end
    end

    MarketplaceServiceReceipt.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
        if not purchased then return end
        local amount=passToAmountReceipt[passId]
        if not amount then return end
        grant(player.UserId,"gamepass:"..tostring(passId),amount)
    end)

    workspace:SetAttribute("BBYASupportReceiptLedger","IDEMPOTENT_V2_PRODUCT_OR_PASS")
    workspace:SetAttribute("BBYASupportProductCount",(function() local n=0 for _ in pairs(productToAmountReceipt) do n+=1 end return n end)())
    workspace:SetAttribute("BBYASupportPassCount",(function() local n=0 for _ in pairs(passToAmountReceipt) do n+=1 end return n end)())
end
