-- BBYA SOCIAL HUB — HYBRID DJ CLIENT OVERLAY
-- Keeps one MENU launcher while making DJ MODE and NEXT TRACK functional.

local musicCommandUI=remotes:WaitForChild("MusicCommand")

-- AUTO listens to the main Club mix only; switching to Rooftop swaps to the synchronized rooftop deck.
applyMusicMix=function()
    local clubGroup,roofGroup=getGroups()
    if localMusicMode=="ROOFTOP" then
        if clubGroup then clubGroup.Volume=0 end
        if roofGroup then roofGroup.Volume=localVolume end
    elseif localMusicMode=="CLUB" then
        if clubGroup then clubGroup.Volume=localVolume end
        if roofGroup then roofGroup.Volume=0 end
    else
        if clubGroup then clubGroup.Volume=localVolume end
        if roofGroup then roofGroup.Volume=0 end
    end
end
applyMusicMix()

local baseShowMusic=showMusic
showMusic=function()
    baseShowMusic()

    local djButton=nil
    local nextButton=nil
    for _,obj in ipairs(body:GetChildren()) do
        if obj:IsA("TextButton") then
            if string.find(obj.Text,"DJ MODE",1,true) then djButton=obj end
            if string.find(obj.Text,"SFX",1,true) then nextButton=obj end
        end
    end

    local state=cachedMusicState
    if not state then
        local ok,result=pcall(function() return getMusicState:InvokeServer() end)
        if ok then state=result;cachedMusicState=result end
    end

    if djButton then
        if state and state.isDJ then
            djButton.Text="DJ MODE • ACTIVE"
            djButton.BackgroundColor3=C.pink
        elseif state and state.djActive then
            djButton.Text="DJ • "..tostring(state.djOwnerName or "BUSY")
            djButton.BackgroundColor3=C.panel
        else
            djButton.Text="DJ MODE"
            djButton.BackgroundColor3=C.pink
        end
        djButton.AutoButtonColor=true
        djButton.TextColor3=C.white
        djButton.MouseButton1Click:Connect(function()
            local ok,result=pcall(function() return musicCommandUI:InvokeServer("TOGGLE_DJ") end)
            if ok and result then
                cachedMusicState=result.state
                showToast(result.message or "DJ MODE updated",result.ok and C.green or C.gold)
            else
                showToast("DJ control unavailable",C.red)
            end
            task.defer(showMusic)
        end)
    end

    if nextButton then
        nextButton.Text="NEXT TRACK"
        nextButton.AutoButtonColor=true
        nextButton.TextColor3=C.white
        nextButton.BackgroundColor3=(state and state.isDJ) and C.gold or C.panel
        nextButton.MouseButton1Click:Connect(function()
            local ok,result=pcall(function() return musicCommandUI:InvokeServer("NEXT") end)
            if ok and result then
                cachedMusicState=result.state
                showToast(result.message or "Music updated",result.ok and C.green or C.gold)
            else
                showToast("Music control unavailable",C.red)
            end
            task.defer(showMusic)
        end)
    end
end

musicStateChanged.OnClientEvent:Connect(function()
    cachedMusicState=nil
    if panel.Visible and currentPanel=="MUSIC" then
        task.defer(showMusic)
    end
end)

workspace:SetAttribute("BBYAHybridDJUI",true)
