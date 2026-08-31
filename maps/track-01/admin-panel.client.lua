local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")

local player=Players.LocalPlayer
if not player then return end
local playerGui=player:WaitForChild("PlayerGui",20)
if not playerGui then return end

local deadline=os.clock()+20
while player:GetAttribute("TRACK01_ADMIN_AUTHORIZED")==nil and os.clock()<deadline do task.wait(0.15) end
if player:GetAttribute("TRACK01_ADMIN_AUTHORIZED")~=true then return end

local remoteFolder=ReplicatedStorage:WaitForChild("TRACK01_Admin",15)
if not remoteFolder then return end
local command=remoteFolder:WaitForChild("Command",10)
local stateEvent=remoteFolder:WaitForChild("State",10)
local query=remoteFolder:WaitForChild("Query",10)
if not (command and stateEvent and query) then return end

local C={
    bg=Color3.fromRGB(12,13,13),bg2=Color3.fromRGB(20,21,21),panel=Color3.fromRGB(27,28,28),
    steel=Color3.fromRGB(78,80,78),cream=Color3.fromRGB(235,226,208),muted=Color3.fromRGB(166,166,158),
    amber=Color3.fromRGB(211,157,86),red=Color3.fromRGB(153,47,42),green=Color3.fromRGB(90,137,96),
}
local TAB_HELP={
    STATUS="Server, operator & event operations",
    MUSIC="DJ / venue music transport",
    PA="Station announcement controls",
    LIGHTS="Venue lighting presets",
    PLAYERS="Player recovery tools",
}

local function corner(parent,r)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 5); c.Parent=parent; return c
end
local function stroke(parent,color,transparency)
    local s=Instance.new("UIStroke"); s.Color=color or C.steel; s.Thickness=1; s.Transparency=transparency or 0.3; s.Parent=parent; return s
end

local gui=Instance.new("ScreenGui")
gui.Name="TRACK01_AdminPanel"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=120
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets; gui.ClipToDeviceSafeArea=true end)
gui.Parent=playerGui

local toggle=Instance.new("TextButton")
toggle.Name="Toggle"
toggle.AnchorPoint=Vector2.new(0.5,0)
toggle.Position=UDim2.new(0.5,0,0,8)
toggle.Size=UDim2.fromOffset(116,32)
toggle.BackgroundColor3=C.bg
toggle.BackgroundTransparency=0.06
toggle.BorderSizePixel=0
toggle.Text="TRACK 01 • OPS"
toggle.TextColor3=C.amber
toggle.TextSize=11
toggle.Font=Enum.Font.RobotoMono
toggle.Parent=gui
corner(toggle,5); stroke(toggle,C.amber,0.45)

local panel=Instance.new("Frame")
panel.Name="Panel"
panel.AnchorPoint=Vector2.new(0.5,0.5)
panel.Position=UDim2.fromScale(0.5,0.50)
panel.Size=UDim2.fromScale(0.88,0.67)
panel.BackgroundColor3=C.bg
panel.BackgroundTransparency=0.03
panel.BorderSizePixel=0
panel.Visible=false
panel.ClipsDescendants=true
panel.Parent=gui
corner(panel,7); stroke(panel,Color3.fromRGB(111,82,55),0.22)
local panelSize=Instance.new("UISizeConstraint")
panelSize.MinSize=Vector2.new(300,330)
panelSize.MaxSize=Vector2.new(450,480)
panelSize.Parent=panel

local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,50)
header.BackgroundColor3=C.bg2
header.BorderSizePixel=0
header.Parent=panel
corner(header,7)

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromOffset(14,6)
title.Size=UDim2.new(1,-62,0,20)
title.Font=Enum.Font.GothamBold
title.Text="TRACK 01 OPS"
title.TextColor3=C.cream
title.TextSize=15
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=header

local subtitle=Instance.new("TextLabel")
subtitle.BackgroundTransparency=1
subtitle.Position=UDim2.fromOffset(14,26)
subtitle.Size=UDim2.new(1,-62,0,16)
subtitle.Font=Enum.Font.RobotoMono
subtitle.Text=TAB_HELP.STATUS
subtitle.TextColor3=C.amber
subtitle.TextSize=9
subtitle.TextXAlignment=Enum.TextXAlignment.Left
subtitle.Parent=header

local close=Instance.new("TextButton")
close.AnchorPoint=Vector2.new(1,0.5)
close.Position=UDim2.new(1,-10,0.5,0)
close.Size=UDim2.fromOffset(30,30)
close.BackgroundColor3=C.panel
close.BorderSizePixel=0
close.Text="×"
close.TextColor3=C.cream
close.TextSize=20
close.Font=Enum.Font.GothamBold
close.Parent=header
corner(close,5)

local tabBar=Instance.new("Frame")
tabBar.Position=UDim2.fromOffset(7,56)
tabBar.Size=UDim2.new(1,-14,0,32)
tabBar.BackgroundTransparency=1
tabBar.Parent=panel
local tabLayout=Instance.new("UIListLayout")
tabLayout.FillDirection=Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment=Enum.VerticalAlignment.Center
tabLayout.Padding=UDim.new(0,3)
tabLayout.Parent=tabBar

local content=Instance.new("Frame")
content.Position=UDim2.fromOffset(8,94)
content.Size=UDim2.new(1,-16,1,-104)
content.BackgroundTransparency=1
content.ClipsDescendants=true
content.Parent=panel

local toast=Instance.new("TextLabel")
toast.AnchorPoint=Vector2.new(0.5,1)
toast.Position=UDim2.new(0.5,0,1,-7)
toast.Size=UDim2.new(0.86,0,0,30)
toast.BackgroundColor3=C.bg2
toast.BackgroundTransparency=0.06
toast.BorderSizePixel=0
toast.Font=Enum.Font.GothamMedium
toast.Text=""
toast.TextColor3=C.cream
toast.TextSize=10
toast.Visible=false
toast.ZIndex=20
toast.Parent=panel
corner(toast,5); stroke(toast,C.steel,0.45)

local toastToken=0
local function notify(text)
    toastToken+=1
    local token=toastToken
    toast.Text=text; toast.TextTransparency=0; toast.BackgroundTransparency=0.06; toast.Visible=true
    task.delay(2.2,function()
        if token~=toastToken or not toast.Visible then return end
        TweenService:Create(toast,TweenInfo.new(0.3),{TextTransparency=1,BackgroundTransparency=1}):Play()
        task.wait(0.35)
        if token==toastToken then toast.Visible=false end
    end)
end

local pages={}
local tabButtons={}
local latestState={}

local function createPage(name,canvasHeight)
    local page=Instance.new("ScrollingFrame")
    page.Name=name
    page.Size=UDim2.fromScale(1,1)
    page.BackgroundTransparency=1
    page.BorderSizePixel=0
    page.ScrollBarThickness=3
    page.ScrollBarImageColor3=C.steel
    page.ScrollingDirection=Enum.ScrollingDirection.Y
    page.CanvasSize=UDim2.fromOffset(0,canvasHeight or 320)
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
    b.TextSize=10
    b.TextWrapped=true
    b.AutoButtonColor=true
    b.Parent=parent
    corner(b,5); stroke(b,accent or C.steel,0.48)
    b.Activated:Connect(callback)
    return b
end

local function sectionLabel(parent,text,y)
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1
    l.Position=UDim2.new(0,2,0,y)
    l.Size=UDim2.new(1,-8,0,20)
    l.Font=Enum.Font.RobotoMono
    l.Text=text
    l.TextColor3=C.amber
    l.TextSize=10
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=parent
    return l
end

local function helperText(parent,text)
    local l=Instance.new("TextLabel")
    l.Name="HelperText"
    l.BackgroundTransparency=1
    l.Position=UDim2.fromOffset(2,0)
    l.Size=UDim2.new(1,-10,0,32)
    l.Font=Enum.Font.Gotham
    l.Text=text
    l.TextColor3=C.muted
    l.TextSize=10
    l.TextWrapped=true
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextYAlignment=Enum.TextYAlignment.Top
    l.Parent=parent
    return l
end

local function selectTab(name)
    subtitle.Text=TAB_HELP[name] or "TRACK 01 operations"
    for pageName,page in pairs(pages) do
        page.Visible=(pageName==name)
        if pageName==name then page.CanvasPosition=Vector2.zero end
    end
    for tabName,b in pairs(tabButtons) do
        b.TextColor3=(tabName==name) and C.amber or C.muted
        b.BackgroundColor3=(tabName==name) and Color3.fromRGB(35,31,26) or C.bg2
    end
end

for _,name in ipairs({"STATUS","MUSIC","PA","LIGHTS","PLAYERS"}) do
    local b=Instance.new("TextButton")
    b.Name=name
    b.Size=UDim2.new(0.2,-3,1,0)
    b.BackgroundColor3=C.bg2
    b.BorderSizePixel=0
    b.Font=Enum.Font.RobotoMono
    b.Text=name
    b.TextColor3=C.muted
    b.TextSize=(name=="PLAYERS") and 8 or 9
    b.Parent=tabBar
    corner(b,4)
    tabButtons[name]=b
    b.Activated:Connect(function() selectTab(name) end)
end

local statusPage=createPage("STATUS",430)
local musicPage=createPage("MUSIC",340)
local paPage=createPage("PA",310)
local lightsPage=createPage("LIGHTS",300)
local playersPage=createPage("PLAYERS",320)

helperText(statusPage,"Live server state plus one-tap event presets. Event presets coordinate venue mode, PA, lighting and club pulse.")
local statusCard=Instance.new("Frame")
statusCard.Position=UDim2.fromOffset(2,36)
statusCard.Size=UDim2.new(1,-10,0,118)
statusCard.BackgroundColor3=C.bg2
statusCard.BorderSizePixel=0
statusCard.Parent=statusPage
corner(statusCard,5); stroke(statusCard,C.steel,0.55)
local statusTitle=Instance.new("TextLabel")
statusTitle.BackgroundTransparency=1
statusTitle.Position=UDim2.fromOffset(10,8)
statusTitle.Size=UDim2.new(1,-20,0,18)
statusTitle.Font=Enum.Font.GothamBold
statusTitle.Text="LIVE OPERATIONS STATUS"
statusTitle.TextColor3=C.cream
statusTitle.TextSize=12
statusTitle.TextXAlignment=Enum.TextXAlignment.Left
statusTitle.Parent=statusCard
local statusBody=Instance.new("TextLabel")
statusBody.BackgroundTransparency=1
statusBody.Position=UDim2.fromOffset(10,30)
statusBody.Size=UDim2.new(1,-20,0,80)
statusBody.Font=Enum.Font.RobotoMono
statusBody.Text="LOADING..."
statusBody.TextColor3=C.muted
statusBody.TextSize=9
statusBody.TextWrapped=true
statusBody.TextXAlignment=Enum.TextXAlignment.Left
statusBody.TextYAlignment=Enum.TextYAlignment.Top
statusBody.Parent=statusCard

sectionLabel(statusPage,"EVENT OPS • COORDINATED PRESETS",166)
actionButton(statusPage,"NORMAL NIGHT",UDim2.new(0,2,0,190),UDim2.new(0.5,-7,0,40),C.green,function()
    command:FireServer("EVENT_PRESET","NORMAL"); notify("Preset: Normal Night")
end)
actionButton(statusPage,"BOARDING HOLD",UDim2.new(0.5,3,0,190),UDim2.new(0.5,-9,0,40),C.amber,function()
    command:FireServer("EVENT_PRESET","BOARDING_HOLD"); notify("Preset: Boarding Hold")
end)
actionButton(statusPage,"END OF LINE",UDim2.new(0,2,0,238),UDim2.new(0.5,-7,0,40),C.red,function()
    command:FireServer("EVENT_PRESET","END_OF_LINE"); notify("Preset: End of Line")
end)
actionButton(statusPage,"LAST TRAIN",UDim2.new(0.5,3,0,238),UDim2.new(0.5,-9,0,40),C.amber,function()
    command:FireServer("EVENT_PRESET","LAST_TRAIN"); notify("Preset: Last Train")
end)
actionButton(statusPage,"CLOSING",UDim2.new(0,2,0,286),UDim2.new(0.5,-7,0,40),C.red,function()
    command:FireServer("EVENT_PRESET","CLOSING"); notify("Preset: Closing")
end)
actionButton(statusPage,"RESET OPS",UDim2.new(0.5,3,0,286),UDim2.new(0.5,-9,0,40),C.muted,function()
    command:FireServer("OPS_RESET"); notify("Operations reset to safe baseline")
end)
local eventNote=Instance.new("TextLabel")
eventNote.BackgroundTransparency=1
eventNote.Position=UDim2.new(0,2,0,340)
eventNote.Size=UDim2.new(1,-10,0,58)
eventNote.Font=Enum.Font.Gotham
eventNote.Text="NORMAL = standard night • HOLD = readable + pulse off • END OF LINE = low-night + pulse • LAST/CLOSING = readable + pulse off"
eventNote.TextColor3=C.muted
eventNote.TextSize=9
eventNote.TextWrapped=true
eventNote.TextXAlignment=Enum.TextXAlignment.Left
eventNote.TextYAlignment=Enum.TextYAlignment.Top
eventNote.Parent=statusPage

helperText(musicPage,"Control the server-authoritative venue music channel. Audio source stays fail-closed until an approved Roblox sound is explicitly installed.")
local musicCard=Instance.new("Frame")
musicCard.Position=UDim2.fromOffset(2,42)
musicCard.Size=UDim2.new(1,-10,0,102)
musicCard.BackgroundColor3=C.bg2
musicCard.BorderSizePixel=0
musicCard.Parent=musicPage
corner(musicCard,5); stroke(musicCard,C.steel,0.55)
local musicTitle=Instance.new("TextLabel")
musicTitle.BackgroundTransparency=1
musicTitle.Position=UDim2.fromOffset(10,8)
musicTitle.Size=UDim2.new(1,-20,0,18)
musicTitle.Font=Enum.Font.GothamBold
musicTitle.Text="DJ / VENUE MUSIC"
musicTitle.TextColor3=C.cream
musicTitle.TextSize=12
musicTitle.TextXAlignment=Enum.TextXAlignment.Left
musicTitle.Parent=musicCard
local musicBody=Instance.new("TextLabel")
musicBody.BackgroundTransparency=1
musicBody.Position=UDim2.fromOffset(10,30)
musicBody.Size=UDim2.new(1,-20,0,64)
musicBody.Font=Enum.Font.RobotoMono
musicBody.Text="SOURCE  CHECKING..."
musicBody.TextColor3=C.muted
musicBody.TextSize=9
musicBody.TextWrapped=true
musicBody.TextXAlignment=Enum.TextXAlignment.Left
musicBody.TextYAlignment=Enum.TextYAlignment.Top
musicBody.Parent=musicCard

sectionLabel(musicPage,"TRANSPORT",156)
local function musicAvailable()
    if latestState.musicConfigured==true then return true end
    notify("No approved music source installed yet")
    return false
end
actionButton(musicPage,"PLAY",UDim2.new(0,2,0,180),UDim2.new(0.33,-5,0,42),C.green,function()
    if musicAvailable() then command:FireServer("MUSIC_PLAY"); notify("Music play") end
end)
actionButton(musicPage,"PAUSE",UDim2.new(0.33,2,0,180),UDim2.new(0.34,-5,0,42),C.amber,function()
    command:FireServer("MUSIC_PAUSE"); notify("Music paused")
end)
actionButton(musicPage,"RESTART",UDim2.new(0.67,2,0,180),UDim2.new(0.33,-8,0,42),C.muted,function()
    if musicAvailable() then command:FireServer("MUSIC_RESTART"); notify("Music restarted") end
end)
sectionLabel(musicPage,"VENUE VOLUME",232)
actionButton(musicPage,"VOL −",UDim2.new(0,2,0,256),UDim2.new(0.5,-7,0,40),C.muted,function()
    command:FireServer("MUSIC_VOLUME",-0.1); notify("Music volume down")
end)
actionButton(musicPage,"VOL +",UDim2.new(0.5,3,0,256),UDim2.new(0.5,-9,0,40),C.amber,function()
    command:FireServer("MUSIC_VOLUME",0.1); notify("Music volume up")
end)

helperText(paPage,"Trigger approved station announcements using the existing Roblox TTS + ding-dong system.")
sectionLabel(paPage,"ANNOUNCEMENTS",40)
actionButton(paPage,"BOARDING CALL",UDim2.new(0,2,0,64),UDim2.new(0.5,-7,0,48),C.amber,function() command:FireServer("PA_PRESET","BOARDING"); notify("Boarding PA queued") end)
actionButton(paPage,"NIGHT SERVICE",UDim2.new(0.5,3,0,64),UDim2.new(0.5,-9,0,48),C.green,function() command:FireServer("PA_PRESET","NIGHT_SERVICE"); notify("Night Service PA queued") end)
actionButton(paPage,"END OF LINE",UDim2.new(0,2,0,120),UDim2.new(0.5,-7,0,48),C.red,function() command:FireServer("PA_PRESET","END_OF_LINE"); notify("End of Line PA queued") end)
actionButton(paPage,"CLOSING",UDim2.new(0.5,3,0,120),UDim2.new(0.5,-9,0,48),C.red,function() command:FireServer("PA_PRESET","CLOSING"); notify("Closing PA queued") end)
local paNote=Instance.new("TextLabel")
paNote.BackgroundColor3=C.bg2
paNote.BackgroundTransparency=0.2
paNote.BorderSizePixel=0
paNote.Position=UDim2.new(0,2,0,180)
paNote.Size=UDim2.new(1,-10,0,82)
paNote.Font=Enum.Font.Gotham
paNote.Text="PA CONTROL\nManual presets only. No uploaded audio asset is added. Event Ops can also trigger coordinated PA automatically."
paNote.TextColor3=C.muted
paNote.TextSize=10
paNote.TextWrapped=true
paNote.TextXAlignment=Enum.TextXAlignment.Left
paNote.TextYAlignment=Enum.TextYAlignment.Top
paNote.Parent=paPage
corner(paNote,5)
local paPad=Instance.new("UIPadding"); paPad.PaddingTop=UDim.new(0,8); paPad.PaddingLeft=UDim.new(0,9); paPad.PaddingRight=UDim.new(0,9); paPad.Parent=paNote

helperText(lightsPage,"Adjust venue readability and mood. Club pulse remains separate from the music source.")
sectionLabel(lightsPage,"LIGHTING PRESETS",40)
actionButton(lightsPage,"STANDARD",UDim2.new(0,2,0,64),UDim2.new(0.33,-5,0,46),C.green,function() command:FireServer("LIGHTING_PRESET","STANDARD"); notify("Lighting: Standard") end)
actionButton(lightsPage,"READABLE",UDim2.new(0.33,2,0,64),UDim2.new(0.34,-5,0,46),C.amber,function() command:FireServer("LIGHTING_PRESET","READABLE"); notify("Lighting: Readable") end)
actionButton(lightsPage,"LOW NIGHT",UDim2.new(0.67,2,0,64),UDim2.new(0.33,-8,0,46),C.muted,function() command:FireServer("LIGHTING_PRESET","LOW_NIGHT"); notify("Lighting: Low Night") end)
sectionLabel(lightsPage,"DJ / CLUB PULSE",122)
actionButton(lightsPage,"PULSE ON",UDim2.new(0,2,0,146),UDim2.new(0.5,-7,0,44),C.amber,function() command:FireServer("PULSE",true); notify("Club pulse enabled") end)
actionButton(lightsPage,"PULSE OFF",UDim2.new(0.5,3,0,146),UDim2.new(0.5,-9,0,44),C.muted,function() command:FireServer("PULSE",false); notify("Club pulse disabled") end)
local lightNote=Instance.new("TextLabel")
lightNote.BackgroundTransparency=1
lightNote.Position=UDim2.new(0,2,0,204)
lightNote.Size=UDim2.new(1,-10,0,54)
lightNote.Font=Enum.Font.Gotham
lightNote.Text="STANDARD = verified night balance • READABLE = brighter mobile view • LOW NIGHT = darker mood"
lightNote.TextColor3=C.muted
lightNote.TextSize=10
lightNote.TextWrapped=true
lightNote.TextXAlignment=Enum.TextXAlignment.Left
lightNote.TextYAlignment=Enum.TextYAlignment.Top
lightNote.Parent=lightsPage

helperText(playersPage,"View active players and use safe recovery tools. No kick button is provided.")
sectionLabel(playersPage,"ACTIVE PLAYERS • LOBBY / RESPAWN",40)
local function rebuildPlayers()
    for _,child in ipairs(playersPage:GetChildren()) do if child.Name=="PlayerRow" then child:Destroy() end end
    local y=66
    for _,target in ipairs(Players:GetPlayers()) do
        local row=Instance.new("Frame")
        row.Name="PlayerRow"
        row.Position=UDim2.fromOffset(2,y)
        row.Size=UDim2.new(1,-10,0,46)
        row.BackgroundColor3=C.bg2
        row.BorderSizePixel=0
        row.Parent=playersPage
        corner(row,5); stroke(row,C.steel,0.58)
        local name=Instance.new("TextLabel")
        name.BackgroundTransparency=1
        name.Position=UDim2.fromOffset(9,4)
        name.Size=UDim2.new(0.46,-12,1,-8)
        name.Font=Enum.Font.GothamMedium
        name.Text=target.DisplayName.."  @"..target.Name
        name.TextColor3=(target==player) and C.amber or C.cream
        name.TextSize=10
        name.TextXAlignment=Enum.TextXAlignment.Left
        name.TextTruncate=Enum.TextTruncate.AtEnd
        name.Parent=row
        actionButton(row,"LOBBY",UDim2.new(0.47,0,0,6),UDim2.new(0.25,-5,0,34),C.amber,function() command:FireServer("RETURN_LOBBY",target.UserId); notify("Returned "..target.DisplayName.." to lobby") end)
        actionButton(row,"RESPAWN",UDim2.new(0.72,2,0,6),UDim2.new(0.28,-7,0,34),C.red,function() command:FireServer("RESPAWN",target.UserId); notify("Respawn requested for "..target.DisplayName) end)
        y+=52
    end
    playersPage.CanvasSize=UDim2.fromOffset(0,math.max(300,y+12))
end
Players.PlayerAdded:Connect(rebuildPlayers)
Players.PlayerRemoving:Connect(function() task.defer(rebuildPlayers) end)

local function uptimeText(seconds)
    seconds=math.max(0,tonumber(seconds) or 0)
    local h=math.floor(seconds/3600)
    local m=math.floor((seconds%3600)/60)
    return string.format("%02dh %02dm",h,m)
end

local function applyState(data)
    if type(data)~="table" then return end
    latestState=data
    local venue=tostring(data.venueStatus or "UNKNOWN"):gsub("_"," ")
    local event=tostring(data.eventMode or "NONE"):gsub("_"," ")
    local preset=tostring(data.eventPreset or "NORMAL"):gsub("_"," ")
    local lights=tostring(data.lightingPreset or "STANDARD"):gsub("_"," ")
    local pulse=(data.pulseEnabled==false) and "OFF" or "ON"
    local feature=data.featureComplete and "READY" or "CHECK"
    statusBody.Text=string.format("PRESET  %s   •   VENUE  %s\nEVENT  %s   •   LIGHTS  %s   •   PULSE  %s\nPLAYERS  %s   •   UPTIME  %s\nOPERATOR  %s   •   RUNTIME  %s",preset,venue,event,lights,pulse,tostring(data.playerCount or #Players:GetPlayers()),uptimeText(data.uptimeSeconds),tostring(data.operatorName or "NONE"),feature)
    local configured=data.musicConfigured==true
    local playing=data.musicPlaying==true
    local vol=math.floor(((tonumber(data.musicVolume) or 0)*100)+0.5)
    musicBody.Text=string.format("SOURCE  %s\nSTATE   %s   •   VOLUME  %d%%\nTRACK   %s",configured and "APPROVED / READY" or "PENDING APPROVAL",playing and "PLAYING" or "PAUSED",vol,tostring(data.musicTrack or "NO APPROVED SOURCE"))
    musicBody.TextColor3=configured and C.cream or C.muted
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

print("[TRACK 01] compact admin panel ready v4.1.0 DJ/music + event operations")
