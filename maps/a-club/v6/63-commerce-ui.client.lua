-- BBYA V6 — COMMERCE UI BINDING
-- Rebuilds the Sawer body from authoritative config. IDs=0 stay visibly pending.

local MarketplaceService=game:GetService("MarketplaceService")
local mon=ReplicatedStorage:WaitForChild("BBYA_V6_Monetization",10)
local board=net:WaitForChild("SupportBoard",10)

if mon and board then
    -- Destroy placeholder controls/connections from base shell and rebuild against real config values.
    for _,o in ipairs(sawerBody:GetChildren()) do o:Destroy() end

    local tabSupport=button(sawerBody,"SUPPORT",UDim2.new(.48,-4,0,42),UDim2.new(0,3,0,4),C.pink)
    local tabTop=button(sawerBody,"TOP SUPPORTERS",UDim2.new(.48,-4,0,42),UDim2.new(.5,3,0,4),C.panel2)
    local supportPage=Instance.new("Frame");supportPage.Position=UDim2.fromOffset(0,54);supportPage.Size=UDim2.new(1,0,0,365);supportPage.BackgroundTransparency=1;supportPage.Parent=sawerBody
    local topPage=Instance.new("Frame");topPage.Position=UDim2.fromOffset(0,54);topPage.Size=UDim2.new(1,0,0,420);topPage.BackgroundTransparency=1;topPage.Visible=false;topPage.Parent=sawerBody

    local intro=text(supportPage,"Dukung creator & BBYA Social Hub",14,UDim2.fromOffset(5,0),Enum.Font.Gotham,C.muted);intro.Size=UDim2.new(1,-10,0,24)
    local denoms={5,10,25,50,100,250,500}
    for i,amount in ipairs(denoms) do
        local cfg=mon:FindFirstChild("Support_"..amount);local id=cfg and cfg.Value or 0
        local col=(i-1)%3;local row=math.floor((i-1)/3)
        local b=button(supportPage,id>0 and ("R$"..amount.."\nSAWER") or ("R$"..amount.."\nPENDING"),UDim2.new(1/3,-8,0,66),UDim2.new(col/3,3,0,34+row*76),C.panel2)
        b.TextColor3=id>0 and C.pink or C.muted
        b.MouseButton1Click:Connect(function()
            if id<=0 then toast("Developer Product belum dipasang") return end
            MarketplaceService:PromptProductPurchase(player,id)
        end)
    end
    local totalLabel=text(supportPage,"TOTAL SUPPORT  R$"..tostring(player:GetAttribute("TotalDonated") or 0),16,UDim2.fromOffset(5,280),Enum.Font.GothamBold,C.gold);totalLabel.Size=UDim2.new(1,-10,0,28)
    local safe=text(supportPage,"Support tidak memberi keuntungan gameplay.",12,UDim2.fromOffset(5,318),Enum.Font.Gotham,C.muted);safe.Size=UDim2.new(1,-10,0,24)
    player:GetAttributeChangedSignal("TotalDonated"):Connect(function() totalLabel.Text="TOTAL SUPPORT  R$"..tostring(player:GetAttribute("TotalDonated") or 0) end)

    local function refreshBoard()
        for _,o in ipairs(topPage:GetChildren()) do o:Destroy() end
        local title=text(topPage,"TOP SUPPORTERS",16,UDim2.fromOffset(5,0),Enum.Font.GothamBold,C.white);title.Size=UDim2.new(1,-10,0,28)
        local ok,data=pcall(function() return board:InvokeServer() end)
        if not ok or type(data)~="table" or #data==0 then
            local empty=text(topPage,"Belum ada data supporter.",13,UDim2.fromOffset(5,42),Enum.Font.Gotham,C.muted);empty.Size=UDim2.new(1,-10,0,30);return
        end
        for i,item in ipairs(data) do
            local row=Instance.new("Frame");row.Position=UDim2.fromOffset(3,36+(i-1)*38);row.Size=UDim2.new(1,-6,0,32);row.BackgroundColor3=C.panel2;row.Parent=topPage;corner(row,8)
            local n=text(row,string.format("#%d  %s",item.rank or i,item.name or "Supporter"),13,UDim2.fromOffset(10,4),Enum.Font.GothamBold,C.white);n.Size=UDim2.new(.72,-10,0,24)
            local v=text(row,"R$"..tostring(item.total or 0),13,UDim2.new(.72,0,0,4),Enum.Font.GothamBold,C.gold);v.Size=UDim2.new(.28,-10,0,24);v.TextXAlignment=Enum.TextXAlignment.Right
        end
    end
    tabSupport.MouseButton1Click:Connect(function()supportPage.Visible=true;topPage.Visible=false;tabSupport.BackgroundColor3=C.pink;tabTop.BackgroundColor3=C.panel2 end)
    tabTop.MouseButton1Click:Connect(function()supportPage.Visible=false;topPage.Visible=true;tabSupport.BackgroundColor3=C.panel2;tabTop.BackgroundColor3=C.pink;refreshBoard()end)

    player:SetAttribute("BBYAV6CommerceUI","AUTHORITATIVE_CONFIG")
end