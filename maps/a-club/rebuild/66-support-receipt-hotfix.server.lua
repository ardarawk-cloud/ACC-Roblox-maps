-- BBYA SOCIAL HUB — SUPPORT RECEIPT SAFETY HOTFIX
-- Final ProcessReceipt owner: idempotent per-player ledger, then mirrors total to OrderedDataStore.

local MarketplaceServiceReceipt=game:GetService("MarketplaceService")
local DataStoreServiceReceipt=game:GetService("DataStoreService")
local PlayersReceipt=game:GetService("Players")
local ReplicatedStorageReceipt=game:GetService("ReplicatedStorage")

local commerceReceipt=rawget(_G,"BBYA_COMMERCE_RESOLVED") or {}
local resolvedReceipt=commerceReceipt.supportProducts or {}
local productToAmountReceipt={}
for _,amount in ipairs({5,10,50,100,500}) do
    local id=tonumber(resolvedReceipt[amount] or resolvedReceipt[tostring(amount)]) or 0
    if id>0 then productToAmountReceipt[id]=amount end
end

if next(productToAmountReceipt)~=nil then
    local ledger=DataStoreServiceReceipt:GetDataStore("BBYA_SupportLedger_v2")
    local totals=DataStoreServiceReceipt:GetOrderedDataStore("BBYA_SupportTotals_v1")
    local remotesReceipt=ReplicatedStorageReceipt:WaitForChild("BBYA REMOTES")
    local changedReceipt=remotesReceipt:WaitForChild("SupportChanged")

    MarketplaceServiceReceipt.ProcessReceipt=function(receiptInfo)
        local amount=productToAmountReceipt[receiptInfo.ProductId]
        if not amount then return Enum.ProductPurchaseDecision.NotProcessedYet end

        local totalAfter=0
        local newlyGranted=false
        local ok,data=pcall(function()
            return ledger:UpdateAsync("u"..tostring(receiptInfo.PlayerId),function(current)
                current=type(current)=="table" and current or {total=0,receipts={}}
                current.total=tonumber(current.total) or 0
                current.receipts=type(current.receipts)=="table" and current.receipts or {}
                local purchaseId=tostring(receiptInfo.PurchaseId)
                if current.receipts[purchaseId] then return current end
                current.total+=amount
                current.receipts[purchaseId]=os.time()
                newlyGranted=true
                return current
            end)
        end)
        if not ok or type(data)~="table" then return Enum.ProductPurchaseDecision.NotProcessedYet end

        totalAfter=tonumber(data.total) or 0
        local okMirror=pcall(function()
            totals:SetAsync(tostring(receiptInfo.PlayerId),totalAfter)
        end)
        if not okMirror then return Enum.ProductPurchaseDecision.NotProcessedYet end

        local player=PlayersReceipt:GetPlayerByUserId(receiptInfo.PlayerId)
        if player then player:SetAttribute("TotalDonated",totalAfter) end
        if newlyGranted then
            changedReceipt:FireAllClients({playerId=receiptInfo.PlayerId,amount=amount,total=totalAfter})
        end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    workspace:SetAttribute("BBYASupportReceiptLedger","IDEMPOTENT_V2")
end
