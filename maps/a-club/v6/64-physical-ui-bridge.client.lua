-- BBYA V6 — PHYSICAL FACILITY -> UNIFIED UI BRIDGE
-- Opens the correct floating tool from in-world prompts without spawning a second UI system.

local OpenPanel=net:WaitForChild("OpenPanel")
OpenPanel.OnClientEvent:Connect(function(panelName,mode)
    panelName=string.upper(tostring(panelName or ""))
    mode=string.upper(tostring(mode or ""))

    if panelName=="PHOTO" then
        show(photoPanel)
        if mode=="OUTFIT" then outfit(0)
        elseif mode=="FREECAM" then freecam() end
    elseif panelName=="MUSIC" then
        show(musicPanel)
        Music:FireServer("STATE")
    elseif panelName=="DANCE" then
        show(dancePanel)
    elseif panelName=="TP" then
        show(tpPanel)
    end
end)

player:SetAttribute("BBYAV6PhysicalUIBridge",true)
