-- BBYA SOCIAL HUB — SUPPORT PURCHASE UI OVERLAY
-- Replaces the MENU launch connection so Support can use either repeatable Developer Products
-- or already-existing Support Game Passes resolved from Roblox.

-- Recreate the single MENU button to remove the old direct connection to the phase-5 Support renderer.
local oldMenu=supportLaunch
local newMenu=oldMenu:Clone()
newMenu.Name="BBYA MENU"
newMenu.Text="MENU"
newMenu.Parent=oldMenu.Parent
oldMenu:Destroy()
supportLaunch=newMenu

showSupport=function()
    showPanel("SUPPORT")
    local ok,config=pcall(function() return getSupportConfig:InvokeServer() end)
    if not ok then config={enabled=false,products={},note="Support service unavailable"} end
    local okSelf,selfStats=pcall(function() return getSupportSelf:InvokeServer() end)
    if not okSelf then selfStats={total=0,rank=nil} end

    label(body,"SUPPORT / SAWER",UDim2.new(1,0,0,26),UDim2.fromOffset(4,46),17,C.pink)
    local note=label(body,config.note or "",UDim2.new(1,0,0,30),UDim2.fromOffset(4,70),12,config.enabled and C.green or C.muted)
    note.TextWrapped=true

    local totalCard=card(body,UDim2.new(.5,-5,0,48),UDim2.fromOffset(0,102),C.panel2)
    label(totalCard,"YOUR SUPPORT",UDim2.new(1,-10,0,18),UDim2.fromOffset(8,4),10,C.muted)
    label(totalCard,"R$ "..tostring(selfStats.total or 0),UDim2.new(1,-10,0,22),UDim2.fromOffset(8,22),16,C.gold)
    local rankCard=card(body,UDim2.new(.5,-5,0,48),UDim2.new(.5,5,0,102),C.panel2)
    label(rankCard,"YOUR RANK",UDim2.new(1,-10,0,18),UDim2.fromOffset(8,4),10,C.muted)
    label(rankCard,selfStats.rank and ("#"..selfStats.rank) or "—",UDim2.new(1,-10,0,22),UDim2.fromOffset(8,22),16,C.cyan)

    label(body,"CHOOSE SUPPORT",UDim2.new(1,0,0,22),UDim2.fromOffset(4,158),12,C.white)
    for i,row in ipairs(config.products or {}) do
        local col=(i-1)%3
        local r=math.floor((i-1)/3)
        local pos=UDim2.new(col/3,col==0 and 0 or 5,0,184+r*46)
        local b=button(body,"R$ "..tostring(row.amount),UDim2.new(1/3,-5,0,40),pos,row.enabled and C.pink or C.panel)
        if not row.enabled then b.TextColor3=C.muted;b.AutoButtonColor=false end
        b.MouseButton1Click:Connect(function()
            if not row.enabled or not row.productId or row.productId<=0 then
                showToast("Support tier belum tersedia.",C.muted)
                return
            end
            if row.kind=="gamePass" then
                MarketplaceService:PromptGamePassPurchase(player,row.productId)
            else
                MarketplaceService:PromptProductPurchase(player,row.productId)
            end
        end)
    end

    label(body,"TOP SUPPORTERS",UDim2.new(1,0,0,24),UDim2.fromOffset(4,282),13,C.cyan)
    local okBoard,rows=pcall(function() return getSupportBoard:InvokeServer() end)
    if not okBoard then rows={} end
    if #rows==0 then
        label(body,"No supporter data yet.",UDim2.new(1,0,0,28),UDim2.fromOffset(4,310),13,C.muted)
    else
        for i,row in ipairs(rows) do
            if i>4 then break end
            label(body,string.format("%d. %s",i,row.name),UDim2.new(.72,0,0,24),UDim2.fromOffset(4,306+(i-1)*25),12,C.white)
            local amt=label(body,"R$ "..tostring(row.total),UDim2.new(.28,-4,0,24),UDim2.new(.72,0,0,306+(i-1)*25),12,C.gold)
            amt.TextXAlignment=Enum.TextXAlignment.Right
        end
    end
end

supportLaunch.MouseButton1Click:Connect(showSupport)

workspace:SetAttribute("BBYASupportPurchaseUI","PRODUCT_OR_PASS_ACTIVE")
