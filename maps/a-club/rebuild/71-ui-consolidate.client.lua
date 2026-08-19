-- BBYA SOCIAL HUB — UI CONSOLIDATION
-- Keep one launcher only. Support/Music/Photo remain inside the same panel tabs.

supportLaunch.Name="BBYA MENU"
supportLaunch.Text="MENU"
supportLaunch.Size=UDim2.fromOffset(92,38)
supportLaunch.Position=UDim2.new(1,-108,0,18)
supportLaunch.BackgroundColor3=C.panel
local menuStroke=supportLaunch:FindFirstChildOfClass("UIStroke")
if menuStroke then menuStroke.Color=C.pink end

local function keepHidden(button)
    button.Visible=false
    button:GetPropertyChangedSignal("Visible"):Connect(function()
        if button.Visible then button.Visible=false end
    end)
end

keepHidden(musicLaunch)
keepHidden(photoLaunch)
keepHidden(mini)

workspace:SetAttribute("BBYAUISingleLauncher",true)
