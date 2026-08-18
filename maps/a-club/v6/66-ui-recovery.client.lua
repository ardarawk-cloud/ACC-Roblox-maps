-- BBYA V6 — TOP UI RECOVERY TAB
-- The top status strip may park upward, but its recovery control must remain fully tappable.

local topRestore=button(gui,"⌄ BBYA",UDim2.fromOffset(82,30),UDim2.new(.5,-41,0,0),C.bg)
topRestore.Name="TOP_RECOVERY"
topRestore.TextColor3=C.pink
topRestore.ZIndex=60
topRestore.Visible=false
stroke(topRestore,C.pink,1,.18)

local function syncTopRecovery()
    topRestore.Visible=topPark and not cleanMode
end

topToggle.MouseButton1Click:Connect(function()
    task.defer(syncTopRecovery)
end)

topRestore.MouseButton1Click:Connect(function()
    topPark=false
    status.Position=UDim2.new(.5,0,0,8)
    topToggle.Text="⌃"
    topRestore.Visible=false
end)

-- Keep clean-view visually clean; RETURN UI remains the only emergency control there.
clean.MouseButton1Click:Connect(function() topRestore.Visible=false end)
cleanRestore.MouseButton1Click:Connect(function() task.defer(syncTopRecovery) end)

-- Settings reset must always restore the header to a recoverable default.
resetUI.MouseButton1Click:Connect(function()
    topPark=false
    status.Position=UDim2.new(.5,0,0,8)
    topToggle.Text="⌃"
    topRestore.Visible=false
end)

player:SetAttribute("BBYAV6TopUIRecovery",true)
