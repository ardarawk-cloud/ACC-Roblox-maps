local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
if not player then return end
local playerGui=player:WaitForChild("PlayerGui",20)
if not playerGui then return end

local deadline=os.clock()+20
while player:GetAttribute("TRACK01_ADMIN_AUTHORIZED")==nil and os.clock()<deadline do
    task.wait(0.15)
end
if player:GetAttribute("TRACK01_ADMIN_AUTHORIZED")~=true then return end

local remoteFolder=ReplicatedStorage:WaitForChild("TRACK01_Admin",15)
if not remoteFolder then return end
local command=remoteFolder:WaitForChild("Command",10)
local stateEvent=remoteFolder:WaitForChild("State",10)
local query=remoteFolder:WaitForChild("Query",10)
if not (command and stateEvent and query) then return end

local C={
    bg=Color3.fromRGB(12,13,13),
    bg2=Color3.fromRGB(20,21,21),
    panel=Color3.fromRGB(27,28,28),
    steel=Color3.fromRGB(78,80,78),
    cream=Color3.fromRGB(235,226,208),
    muted=Color3.fromRGB(166,166,158),
    amber=Color3.fromRGB(211,157,86),
    red=Color3.fromRGB(153,47,42),
    green=Color3.fromRGB(90,137,96),
}

local function corner(parent,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 5)
    c.Parent=parent
    return c
end

local function stroke(parent,color,transparency)
    local s=Instance.new("UIStroke")
    s.Color=color or C.steel
    s.Thickness=1
    s.Transparency=transparency or 0.3
    s.Parent=parent
    return s
end

local gui=Instance.new("ScreenGui")
gui.Name="TRACK01_AdminPanel"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=120
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=playerGui

local toggle=Instance.new("TextButton")
toggle.Name="Toggle"
toggle.AnchorPoint=Vector2.new(0.5,0)
toggle.Position=UDim2.new(0.5,0,0,10)
toggle.Size=UDim2.fromOffset(122,36)
toggle.BackgroundColor3=C.bg
toggle.BackgroundTransparency=0.06
toggle.BorderSizePixel=0
toggle.Text="TRACK 01 • OPS"
toggle.TextColor3=C.amber
toggle.TextSize=12
toggle.Font=Enum.Font.RobotoMono
toggle.AutoButtonColor=true
toggle.Parent=gui
corner(toggle,5)
stroke(toggle,C.amber,0.45)

local panel=Instance.new("Frame")
panel.Name="Panel"
panel.AnchorPoint=Vector2.new(0.5,0.5)
panel.Position=UDim2.fromScale(0.5,0.52)
panel.Size=UDim2.fromScale(0.86,0.72)
panel.BackgroundColor3=C.bg
panel.BackgroundTransparency=0.03
panel.BorderSizePixel=0
panel.Visible=false
panel.Parent=gui
corner(panel,7)
stroke(panel,Color3.fromRGB(111,82,55),0.22)
local panelSize=Instance.new("UISizeConstraint")
panelSize.MinSize=Vector2.new(310,360)
panelSize.MaxSize=Vector2.new(520,540)
panelSize.Parent=panel

local header=Instance.new("Frame")
header.Name="Header"
header.Size=UDim2.new(1,0,0,54)
header.BackgroundColor3=C.bg2
header.BorderSizePixel=0
header.Parent=panel
corner(header,7)

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromOffset(16,8)
title.Size=UDim2.new(1,-70,0,22)
title.Font=Enum.Font.GothamBold
title.Text="TRACK 01 — OPERATIONS"
title.TextColor3=C.cream
title.TextSize=16
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=header

local subtitle=Instance.new("TextLabel")
subtitle.BackgroundTransparency=1
subtitle.Position=UDim2.fromOffset(16,29)
subtitle.Size=UDim2.new(1,-70,0,17)
subtitle.Font=Enum.Font.RobotoMono
subtitle.Text="NO DESTINATION. JUST THE NIGHT."
subtitle.TextColor3=C.amber
subtitle.TextSize=10
subtitle.TextXAlignment=Enum.TextXAlignment.Left
subtitle.Parent=header

local close=Instance.new("TextButton")
close.AnchorPoint=Vector2.new(1,0.5)
close.Position=UDim2.new(1,-12,0.5,0)
close.Size=UDim2.fromOffset(34,34)
close.BackgroundColor3=C.panel
close.BorderSizePixel=0
close.Text="×"
close.TextColor3=C.cream
close.TextSize=22
close.Font=Enum.Font.GothamBold
close.Parent=header
corner(close,5)

local tabBar=Instance.new("Frame")
tabBar.Position=UDim2.fromOffset(10,64)
tabBar.Size=UDim2.new(1,-20,0,38)
tabBar.BackgroundTransparency=1
tabBar.Parent=panel
local tabLayout=Instance.new("UIListLayout")
tabLayout.FillDirection=Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment=Enum.VerticalAlignment.Center
tabLayout.Padding=UDim.new(0,5)
tabLayout.Parent=tabBar

local content=Instance.new("Frame")
content.Position=UDim2.fromOffset(10,108)
content.Size=UDim2.new(1,-20,1,-118)
content.BackgroundTransparency=1
content.ClipsDescendants=true
content.Parent=panel

local toast=Instance.new("TextLabel")
toast.AnchorPoint=Vector2.new(0.5,1)
toast.Position=UDim2.new(0.5,0,1,-8)
toast.Size=UDim2.new(0.82,0,0,32)
toast.BackgroundColor3=C.bg2
toast.BackgroundTransparency=0.06
toast.BorderSizePixel=0
toast.Font=Enum.Font.GothamMedium
toast.Text=""
toast.TextColor3=C.cream
toast.TextSize=11
toast.Visible=false
toast.ZIndex=20
toast.Parent=panel
corner(toast,5)
stroke(toast,C.steel,0.45)

local toastToken=0
local function notify(text)
    toastToken+=1
    local token=toastToken
    toast.Text=text
    toast.TextTransparency=0
    toast.BackgroundTransparency=0.06
    toast.Visible=true
    task.delay(2.3,function()
        if token~=toastToken or not toast.Visible then return end
        TweenService:Create(toast,TweenInfo.new(0.35),{TextTransparency=1,BackgroundTransparency=1}):Play()
        task.wait(0.4)
        if token==toastToken then toast.Visible=false end
    end)
end

local pages={}
local tabButtons={}
local currentTab

local function createPage(name)
    local page=Instance.new("Frame")
    page.Name=name
    page.Size=UDim2.fromScale(1,1)
    page.BackgroundTransparency=1
    page.Visible=false
    page.Parent=content
    pages[name]=page
    return page
end

local function actionButton(parent,text,pos,size,accent,callback)
    local b=Instance.new("TextButton")
    b.BackgroundColor3=C.panel
    b.BorderSizePixel=0
    b.Position=pos
    b.Size=size
    b.Font=Enum.Font.GothamMedium
    b.Text=text
    b.TextColor3=accent or C.cream
    b.TextSize=12
    b.TextWrapped=true
    b.AutoButtonColor=true
    b.Parent=parent
    corner(b,5)
    stroke(b,accent or C.steel,0.48)
    b.Activated:Connect(callback)
    return b
end

local function sectionLabel(parent,text,y)
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1
    l.Position=UDim2.new(0,2,0,y)
    l.Size=UDim2.new(1,-4,0,22)
    l.Font=Enum.Font.RobotoMono
    l.Text=text
    l.TextColor3=C.amber
    l.TextSize=11
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=parent
    return l
end

local function selectTab(name)
    currentTab=name
    for pageName,page in pairs(pages) do page.Visible=(pageName==name) end
    for tabName,b in pairs(tabButtons) do
        b.TextColor3=(tabName==name) and C.amber or C.muted
        b.BackgroundColor3=(tabName==name) and Color3.fromRGB(35,31,26) or C.bg2
    end
end

for _,name in ipairs({"STATUS","PA","LIGHTS","PLAYERS"}) do
    local b=Instance.new("TextButton")
    b.Name=name
    b.Size=UDim2.new(0.25,-4,1,0)
    b.BackgroundColor3=C.bg2
    b.BorderSizePixel=0
    b.Font=Enum.Font.RobotoMono
    b.Text=name
    b.TextColor3=C.muted
    b.TextSize=11
    b.Parent=tabBar
    corner(b,4)
    tabButtons[name]=b
    b.Activated:Connect(function() selectTab(name) end)
end

local statusPage=createPage("STATUS")
local paPage=createPage("PA")
local lightsPage=createPage("LIGHTS")
local playersPage=createPage("PLAYERS")

local statusCard=Instance.new("Frame")
statusCard.Position=UDim2.fromOffset(2,2)
statusCard.Size=UDim2.new(1,-4,0,104)
statusCard.BackgroundColor3=C.bg2
statusCard.BorderSizePixel=0
statusCard.Parent=statusPage
corner(statusCard,5)
stroke(statusCard,C.steel,0.55)

local statusTitle=Instance.new("TextLabel")
statusTitle.BackgroundTransparency=1
statusTitle.Position=UDim2.fromOffset(12,10)
statusTitle.Size=UDim2.new(1,-24,0,20)
statusTitle.Font=Enum.Font.GothamBold
statusTitle.Text="VENUE STATUS"
statusTitle.TextColor3=C.cream
statusTitle.TextSize=13
statusTitle.TextXAlignment=Enum.TextXAlignment.Left
statusTitle.Parent=statusCard

local statusBody=Instance.new("TextLabel")
statusBody.BackgroundTransparency=1
statusBody.Position=UDim2.fromOffset(12,34)
statusBody.Size=UDim2.new(1,-24,0,58)
statusBody.Font=Enum.Font.RobotoMono
statusBody.Text="LOADING..."
statusBody.TextColor3=C.muted
statusBody.TextSize=11
statusBody.TextWrapped=true
statusBody.TextXAlignment=Enum.TextXAlignment.Left
statusBody.TextYAlignment=Enum.TextYAlignment.Top
statusBody.Parent=statusCard

sectionLabel(statusPage,"VENUE MODE",116)
actionButton(statusPage,"NIGHT SERVICE",UDim2.new(0,2,0,140),UDim2.new(0.33,-5,0,42),C.green,function()
    command:FireServer("VENUE_STATUS","NIGHT_SERVICE"); notify("Venue: Night Service")
end)
actionButton(statusPage,"BOARDING HOLD",UDim2.new(0.33,2,0,140),UDim2.new(0.34,-5,0,42),C.amber,function()
    command:FireServer("VENUE_STATUS","BOARDING_HOLD"); notify("Venue: Boarding Hold")
end)
actionButton(statusPage,"CLOSING",UDim2.new(0.67,2,0,140),UDim2.new(0.33,-4,0,42),C.red,function()
    command:FireServer("VENUE_STATUS","CLOSING"); notify("Closing PA queued")
end)

sectionLabel(statusPage,"EVENT MODE",192)
actionButton(statusPage,"END OF LINE",UDim2.new(0,2,0,216),UDim2.new(0.33,-5,0,42),C.red,function()
    command:FireServer("EVENT_MODE","END_OF_LINE"); notify("Event: End of Line")
end)
actionButton(statusPage,"LAST TRAIN",UDim2.new(0.33,2,0,216),UDim2.new(0.34,-5,0,42),C.amber,function()
    command:FireServer("EVENT_MODE","LAST_TRAIN"); notify("Event: Last Train")
end)
actionButton(statusPage,"CLEAR",UDim2.new(0.67,2,0,216),UDim2.new(0.33,-4,0,42),C.muted,function()
    command:FireServer("EVENT_MODE","NONE"); notify("Event mode cleared")
end)

sectionLabel(paPage,"MANUAL STATION PA • FIXED APPROVED PRESETS",4)
actionButton(paPage,"BOARDING CALL",UDim2.new(0,2,0,32),UDim2.new(0.5,-6,0,56),C.amber,function()
    command:FireServer("PA_PRESET","BOARDING"); notify("Boarding PA queued")
end)
actionButton(paPage,"NIGHT SERVICE",UDim2.new(0.5,4,0,32),UDim2.new(0.5,-6,0,56),C.green,function()
    command:FireServer("PA_PRESET","NIGHT_SERVICE"); notify("Night Service PA queued")
end)
actionButton(paPage,"END OF LINE",UDim2.new(0,2,0,96),UDim2.new(0.5,-6,0,56),C.red,function()
    command:FireServer("PA_PRESET","END_OF_LINE"); notify("End of Line PA queued")
end)
actionButton(paPage,"CLOSING",UDim2.new(0.5,4,0,96),UDim2.new(0.5,-6,0,56),C.red,function()
    command:FireServer("PA_PRESET","CLOSING"); notify("Closing PA queued")
end)
local paNote=Instance.new("TextLabel")
paNote.BackgroundTransparency=1
paNote.Position=UDim2.new(0,4,0,166)
paNote.Size=UDim2.new(1,-8,0,78)
paNote.Font=Enum.Font.Gotham
paNote.Text="Uses the existing Roblox TTS + ding-dong system. No uploaded audio asset is added. Manual PA waits briefly if another announcement is already speaking."
paNote.TextColor3=C.muted
paNote.TextSize=12
paNote.TextWrapped=true
paNote.TextXAlignment=Enum.TextXAlignment.Left
paNote.TextYAlignment=Enum.TextYAlignment.Top
paNote.Parent=paPage

sectionLabel(lightsPage,"NIGHT LIGHTING PRESETS",4)
actionButton(lightsPage,"STANDARD\nv3.9.1",UDim2.new(0,2,0,32),UDim2.new(0.33,-5,0,58),C.green,function()
    command:FireServer("LIGHTING_PRESET","STANDARD"); notify("Lighting: Standard")
end)
actionButton(lightsPage,"READABLE\nMOBILE",UDim2.new(0.33,2,0,32),UDim2.new(0.34,-5,0,58),C.amber,function()
    command:FireServer("LIGHTING_PRESET","READABLE"); notify("Lighting: Readable")
end)
actionButton(lightsPage,"LOW NIGHT",UDim2.new(0.67,2,0,32),UDim2.new(0.33,-4,0,58),C.muted,function()
    command:FireServer("LIGHTING_PRESET","LOW_NIGHT"); notify("Lighting: Low Night")
end)

sectionLabel(lightsPage,"DJ / CLUB PULSE",106)
actionButton(lightsPage,"PULSE ON",UDim2.new(0,2,0,134),UDim2.new(0.5,-6,0,52),C.amber,function()
    command:FireServer("PULSE",true); notify("Club pulse enabled")
end)
actionButton(lightsPage,"PULSE OFF",UDim2.new(0.5,4,0,134),UDim2.new(0.5,-6,0,52),C.muted,function()
    command:FireServer("PULSE",false); notify("Club pulse disabled")
end)
local lightNote=Instance.new("TextLabel")
lightNote.BackgroundTransparency=1
lightNote.Position=UDim2.new(0,4,0,200)
lightNote.Size=UDim2.new(1,-8,0,76)
lightNote.Font=Enum.Font.Gotham
lightNote.Text="Music source remains intentionally untouched. This tab controls only existing lighting and pulse behavior; it does not upload or replace audio."
lightNote.TextColor3=C.muted
lightNote.TextSize=12
lightNote.TextWrapped=true
lightNote.TextXAlignment=Enum.TextXAlignment.Left
lightNote.TextYAlignment=Enum.TextYAlignment.Top
lightNote.Parent=lightsPage

local playersHeader=Instance.new("TextLabel")
playersHeader.BackgroundTransparency=1
playersHeader.Position=UDim2.fromOffset(2,2)
playersHeader.Size=UDim2.new(1,-4,0,24)
playersHeader.Font=Enum.Font.RobotoMono
playersHeader.Text="PLAYER OPERATIONS • NO KICK BUTTON"
playersHeader.TextColor3=C.amber
playersHeader.TextSize=11
playersHeader.TextXAlignment=Enum.TextXAlignment.Left
playersHeader.Parent=playersPage

local playerList=Instance.new("ScrollingFrame")
playerList.Position=UDim2.fromOffset(2,30)
playerList.Size=UDim2.new(1,-4,1,-34)
playerList.BackgroundTransparency=1
playerList.BorderSizePixel=0
playerList.ScrollBarThickness=3
playerList.ScrollBarImageColor3=C.steel
playerList.CanvasSize=UDim2.fromOffset(0,0)
playerList.AutomaticCanvasSize=Enum.AutomaticSize.Y
playerList.Parent=playersPage
local playerLayout=Instance.new("UIListLayout")
playerLayout.Padding=UDim.new(0,6)
playerLayout.Parent=playerList

local function rebuildPlayers()
    for _,child in ipairs(playerList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _,target in ipairs(Players:GetPlayers()) do
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,-4,0,48)
        row.BackgroundColor3=C.bg2
        row.BorderSizePixel=0
        row.Parent=playerList
        corner(row,5)
        stroke(row,C.steel,0.58)

        local name=Instance.new("TextLabel")
        name.BackgroundTransparency=1
        name.Position=UDim2.fromOffset(10,5)
        name.Size=UDim2.new(0.46,-12,1,-10)
        name.Font=Enum.Font.GothamMedium
        name.Text=target.DisplayName.."  @"..target.Name
        name.TextColor3=(target==player) and C.amber or C.cream
        name.TextSize=11
        name.TextXAlignment=Enum.TextXAlignment.Left
        name.TextTruncate=Enum.TextTruncate.AtEnd
        name.Parent=row

        actionButton(row,"LOBBY",UDim2.new(0.47,0,0,7),UDim2.new(0.25,-5,0,34),C.amber,function()
            command:FireServer("RETURN_LOBBY",target.UserId); notify("Returned "..target.DisplayName.." to lobby")
        end)
        actionButton(row,"RESPAWN",UDim2.new(0.72,2,0,7),UDim2.new(0.28,-7,0,34),C.red,function()
            command:FireServer("RESPAWN",target.UserId); notify("Respawn requested for "..target.DisplayName)
        end)
    end
end
Players.PlayerAdded:Connect(rebuildPlayers)
Players.PlayerRemoving:Connect(function() task.defer(rebuildPlayers) end)

local function applyState(data)
    if type(data)~="table" then return end
    local venue=tostring(data.venueStatus or "UNKNOWN"):gsub("_"," ")
    local event=tostring(data.eventMode or "NONE"):gsub("_"," ")
    local lights=tostring(data.lightingPreset or "STANDARD"):gsub("_"," ")
    local pulse=(data.pulseEnabled==false) and "OFF" or "ON"
    local feature=data.featureComplete and "FEATURE COMPLETE" or "CHECK RUNTIME"
    statusBody.Text=string.format("VENUE  %s\nEVENT  %s   •   LIGHTS  %s   •   PULSE  %s\nSERVER  %s   •   PLAYERS  %s",venue,event,lights,pulse,feature,tostring(data.playerCount or #Players:GetPlayers()))
end

stateEvent.OnClientEvent:Connect(applyState)

local ok,data=pcall(function() return query:InvokeServer() end)
if ok and type(data)=="table" and data.authorized~=false then applyState(data) end

local function setOpen(open)
    panel.Visible=open
    toggle.Text=open and "TRACK 01 • CLOSE" or "TRACK 01 • OPS"
    if open then
        rebuildPlayers()
        local good,fresh=pcall(function() return query:InvokeServer() end)
        if good then applyState(fresh) end
    end
end

toggle.Activated:Connect(function() setOpen(not panel.Visible) end)
close.Activated:Connect(function() setOpen(false) end)
selectTab("STATUS")

print("[TRACK 01] compact admin panel client ready v4.0.0")
