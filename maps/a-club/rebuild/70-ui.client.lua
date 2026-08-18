-- BBYA SOCIAL HUB — PHASE 5 MOBILE SOCIAL UI
-- One recoverable mobile-first shell for Support, Music and Photo tools.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local SoundService=game:GetService("SoundService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYA REMOTES")
local openPanel=remotes:WaitForChild("OpenPanel")
local supportChanged=remotes:WaitForChild("SupportChanged")
local musicStateChanged=remotes:WaitForChild("MusicStateChanged")
local getSupportConfig=remotes:WaitForChild("GetSupportConfig")
local getSupportBoard=remotes:WaitForChild("GetSupportBoard")
local getSupportSelf=remotes:WaitForChild("GetSupportSelf")
local getMusicState=remotes:WaitForChild("GetMusicState")

local old=playerGui:FindFirstChild("BBYA SOCIAL UI")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="BBYA SOCIAL UI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=20
gui.Parent=playerGui

local C={
    bg=Color3.fromRGB(11,12,19),panel=Color3.fromRGB(23,24,34),panel2=Color3.fromRGB(31,32,45),
    pink=Color3.fromRGB(255,42,174),cyan=Color3.fromRGB(35,206,255),gold=Color3.fromRGB(255,192,82),
    white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(158,160,176),green=Color3.fromRGB(85,215,142),red=Color3.fromRGB(245,92,112),
}

local function corner(o,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 10)
    c.Parent=o
end
local function stroke(o,color,t,transparency)
    local s=Instance.new("UIStroke")
    s.Color=color or C.cyan
    s.Thickness=t or 1
    s.Transparency=transparency or .25
    s.Parent=o
end
local function label(parent,text,size,pos,fontSize,color)
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1
    t.Size=size
    t.Position=pos
    t.Text=text
    t.TextColor3=color or C.white
    t.Font=Enum.Font.GothamSemibold
    t.TextSize=fontSize or 14
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.TextYAlignment=Enum.TextYAlignment.Center
    t.Parent=parent
    return t
end
local function button(parent,text,size,pos,color)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=true
    b.Size=size
    b.Position=pos
    b.Text=text
    b.TextColor3=C.white
    b.Font=Enum.Font.GothamBold
    b.TextSize=13
    b.BackgroundColor3=color or C.panel
    b.Parent=parent
    corner(b,9)
    stroke(b,color or C.cyan,1,.3)
    return b
end
local function card(parent,size,pos,color)
    local f=Instance.new("Frame")
    f.Size=size
    f.Position=pos
    f.BackgroundColor3=color or C.panel2
    f.BackgroundTransparency=.08
    f.Parent=parent
    corner(f,10)
    return f
end

-- Compact launchers stay above the Roblox joystick/jump zones.
local supportLaunch=button(gui,"SUPPORT",UDim2.fromOffset(96,38),UDim2.new(0,14,.19,0),C.pink)
local musicLaunch=button(gui,"MUSIC",UDim2.fromOffset(96,38),UDim2.new(1,-110,.19,0),C.cyan)
local photoLaunch=button(gui,"PHOTO",UDim2.fromOffset(96,38),UDim2.new(0,14,.19,46),C.gold)

-- Mini player is always available unless Clean View is active.
local mini=button(gui,"AUTO DJ • LIBRARY PENDING",UDim2.fromOffset(270,38),UDim2.new(.5,-135,0,18),C.panel)
mini.Name="MINI PLAYER"
mini.TextSize=12

local toast=card(gui,UDim2.fromOffset(300,48),UDim2.new(.5,-150,0,64),C.panel)
toast.Name="BBYA TOAST"
toast.Visible=false
stroke(toast,C.pink,1,.2)
local toastText=label(toast,"",UDim2.new(1,-20,1,0),UDim2.fromOffset(10,0),13,C.white)
toastText.TextWrapped=true
toastText.TextXAlignment=Enum.TextXAlignment.Center
local toastTicket=0
local function showToast(text,color)
    toastTicket+=1
    local ticket=toastTicket
    toastText.Text=text
    local s=toast:FindFirstChildOfClass("UIStroke")
    if s then s.Color=color or C.pink end
    toast.Visible=true
    task.delay(3.5,function() if ticket==toastTicket then toast.Visible=false end end)
end

local panel=Instance.new("Frame")
panel.Name="FLOATING PANEL"
panel.Size=UDim2.fromOffset(356,480)
panel.Position=UDim2.new(.5,-178,.5,-220)
panel.BackgroundColor3=C.bg
panel.BackgroundTransparency=.04
panel.Visible=false
panel.Parent=gui
corner(panel,14)
stroke(panel,C.pink,1.3,.15)

local title=label(panel,"BBYA",UDim2.new(1,-58,0,44),UDim2.fromOffset(18,7),20,C.white)
local close=button(panel,"×",UDim2.fromOffset(36,32),UDim2.new(1,-45,0,8),C.panel)
close.TextSize=22
local body=Instance.new("Frame")
body.BackgroundTransparency=1
body.Size=UDim2.new(1,-24,1,-60)
body.Position=UDim2.fromOffset(12,52)
body.Parent=panel

local currentPanel=""
local cleanView=false
local localMusicMode="AUTO"
local localVolume=.55
local eqPreset="BALANCED"
local cachedMusicState=nil

local function rescale()
    local cam=workspace.CurrentCamera
    local width=cam and cam.ViewportSize.X or 900
    local scale=math.clamp(width/430,.72,1)
    local u=panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
    u.Scale=scale
    u.Parent=panel
end
rescale()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale) end

-- Drag by title area; clamp to viewport so the panel remains recoverable.
local dragging=false
local dragStart
local startPos
panel.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
        if input.Position.Y<=panel.AbsolutePosition.Y+48 then
            dragging=true
            dragStart=input.Position
            startPos=panel.Position
        end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local delta=input.Position-dragStart
    panel.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    task.defer(function()
        local vp=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900,700)
        local p=panel.AbsolutePosition
        local s=panel.AbsoluteSize
        local x=math.clamp(p.X,8,math.max(8,vp.X-s.X-8))
        local y=math.clamp(p.Y,54,math.max(54,vp.Y-s.Y-8))
        panel.Position=UDim2.fromOffset(x,y)
    end)
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

local function clearBody()
    for _,c in ipairs(body:GetChildren()) do c:Destroy() end
end

local showSupport
local showMusic
local showPhoto

local function tabs(active)
    local names={{"SUPPORT",C.pink},{"MUSIC",C.cyan},{"PHOTO",C.gold}}
    for i,row in ipairs(names) do
        local x=(i-1)/3
        local b=button(body,row[1],UDim2.new(1/3,-5,0,36),UDim2.new(x,i==1 and 0 or 5,0,0),active==row[1] and row[2] or C.panel)
        b.MouseButton1Click:Connect(function()
            if row[1]=="SUPPORT" then showSupport() elseif row[1]=="MUSIC" then showMusic() else showPhoto() end
        end)
    end
end

local function showPanel(name)
    currentPanel=name
    panel.Visible=true
    clearBody()
    title.Text="BBYA • "..name
    tabs(name)
end

local function getGroups()
    return SoundService:FindFirstChild("BBYA CLUB GROUP"),SoundService:FindFirstChild("BBYA ROOFTOP GROUP")
end
local function applyMusicMix()
    local clubGroup,roofGroup=getGroups()
    if clubGroup then clubGroup.Volume=(localMusicMode=="ROOFTOP") and 0 or localVolume end
    if roofGroup then roofGroup.Volume=(localMusicMode=="CLUB") and 0 or localVolume end
end
local function applyEq()
    local gains={BALANCED={0,0,0},BASS={4,0,-1},CLARITY={-1,1,4}}
    local values=gains[eqPreset] or gains.BALANCED
    for _,group in ipairs({getGroups()}) do
        if group then
            local eq=group:FindFirstChild("BBYA EQ")
            if eq and eq:IsA("EqualizerSoundEffect") then
                eq.LowGain=values[1]
                eq.MidGain=values[2]
                eq.HighGain=values[3]
            end
        end
    end
end

local function refreshMini()
    local state=cachedMusicState
    if not state then
        local ok,result=pcall(function() return getMusicState:InvokeServer() end)
        if ok then state=result;cachedMusicState=result end
    end
    if state and state.libraryReady then
        local selected=localMusicMode=="ROOFTOP" and state.rooftop or state.club
        if localMusicMode=="AUTO" then mini.Text="AUTO DJ • "..tostring(state.trackTitle or "ACTIVE")
        else mini.Text=localMusicMode.." • "..tostring(selected and selected.current or "AUTO DJ") end
    else
        mini.Text="AUTO DJ • LIBRARY PENDING"
    end
end

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
        local width=(i==5) and UDim2.new(1/3,-5,0,40) or UDim2.new(1/3,-5,0,40)
        local pos=UDim2.new(col/3,col==0 and 0 or 5,0,184+r*46)
        local b=button(body,"R$ "..tostring(row.amount),width,pos,row.enabled and C.pink or C.panel)
        if not row.enabled then b.TextColor3=C.muted;b.AutoButtonColor=false end
        b.MouseButton1Click:Connect(function()
            if row.enabled and row.productId and row.productId>0 then
                MarketplaceService:PromptProductPurchase(player,row.productId)
            else
                showToast("Developer Product ID belum dipasang.",C.muted)
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

showMusic=function()
    showPanel("MUSIC")
    local ok,state=pcall(function() return getMusicState:InvokeServer() end)
    if not ok then
        state={autoDJ=true,trackTitle="Music service unavailable",libraryReady=false,djModeAvailable=false,crossfadeSeconds=3.5,club={current="—",queued="—",queue={}},rooftop={current="—",queued="—",queue={}}}
    end
    cachedMusicState=state
    refreshMini()

    label(body,"MUSIC CONTROLLER",UDim2.new(1,0,0,26),UDim2.fromOffset(4,46),17,C.cyan)
    local status=label(body,state.trackTitle or "",UDim2.new(1,0,0,34),UDim2.fromOffset(4,70),12,state.libraryReady and C.white or C.muted)
    status.TextWrapped=true

    local auto=button(body,"AUTO DJ",UDim2.new(.32,-4,0,38),UDim2.fromOffset(0,108),localMusicMode=="AUTO" and C.pink or C.panel)
    local club=button(body,"CLUB",UDim2.new(.32,-4,0,38),UDim2.new(.34,0,0,108),localMusicMode=="CLUB" and C.cyan or C.panel)
    local roof=button(body,"ROOFTOP",UDim2.new(.32,-4,0,38),UDim2.new(.68,0,0,108),localMusicMode=="ROOFTOP" and C.gold or C.panel)
    auto.MouseButton1Click:Connect(function() localMusicMode="AUTO";applyMusicMix();refreshMini();showMusic() end)
    club.MouseButton1Click:Connect(function() localMusicMode="CLUB";applyMusicMix();refreshMini();showMusic() end)
    roof.MouseButton1Click:Connect(function() localMusicMode="ROOFTOP";applyMusicMix();refreshMini();showMusic() end)

    label(body,"LISTENER VOLUME",UDim2.new(1,0,0,20),UDim2.fromOffset(4,154),11,C.white)
    local minus=button(body,"−",UDim2.fromOffset(44,34),UDim2.fromOffset(0,176),C.panel)
    local vol=label(body,string.format("%d%%",math.floor(localVolume*100+.5)),UDim2.fromOffset(86,34),UDim2.fromOffset(50,176),15,C.cyan)
    vol.TextXAlignment=Enum.TextXAlignment.Center
    local plus=button(body,"+",UDim2.fromOffset(44,34),UDim2.fromOffset(142,176),C.panel)
    minus.MouseButton1Click:Connect(function() localVolume=math.max(0,localVolume-.1);applyMusicMix();showMusic() end)
    plus.MouseButton1Click:Connect(function() localVolume=math.min(1,localVolume+.1);applyMusicMix();showMusic() end)
    label(body,"CROSSFADE  "..tostring(state.crossfadeSeconds or 3.5).."s",UDim2.fromOffset(130,34),UDim2.new(1,-130,0,176),11,C.gold).TextXAlignment=Enum.TextXAlignment.Right

    label(body,"EQUALIZER",UDim2.new(1,0,0,20),UDim2.fromOffset(4,220),11,C.white)
    for i,name in ipairs({"BALANCED","BASS","CLARITY"}) do
        local b=button(body,name,UDim2.new(1/3,-5,0,34),UDim2.new((i-1)/3,i==1 and 0 or 5,0,242),eqPreset==name and C.cyan or C.panel)
        b.TextSize=11
        b.MouseButton1Click:Connect(function() eqPreset=name;applyEq();showMusic() end)
    end

    local selected=localMusicMode=="ROOFTOP" and state.rooftop or state.club
    if localMusicMode=="AUTO" then selected=state.club end
    label(body,"NOW  "..tostring(selected and selected.current or "—"),UDim2.new(1,0,0,22),UDim2.fromOffset(4,286),11,C.white)
    label(body,"NEXT  "..tostring(selected and selected.queued or "—"),UDim2.new(1,0,0,22),UDim2.fromOffset(4,308),11,C.muted)

    local dj=button(body,state.djModeAvailable and "DJ MODE" or "DJ MODE • LIBRARY PENDING",UDim2.new(.62,-5,0,38),UDim2.fromOffset(0,338),state.djModeAvailable and C.pink or C.panel)
    if not state.djModeAvailable then dj.AutoButtonColor=false;dj.TextColor3=C.muted end
    local sfx=button(body,"SFX • SAFE MODE",UDim2.new(.38,-5,0,38),UDim2.new(.62,5,0,338),C.panel)
    sfx.AutoButtonColor=false;sfx.TextColor3=C.muted

    local queue=(selected and selected.queue) or {}
    local queueText=#queue>0 and table.concat(queue,"  ›  ") or "QUEUE • authorized tracks pending"
    local q=label(body,queueText,UDim2.new(1,0,0,40),UDim2.fromOffset(4,382),11,C.muted)
    q.TextWrapped=true
end

showPhoto=function()
    showPanel("PHOTO")
    label(body,"SOCIAL / PHOTO TOOLS",UDim2.new(1,0,0,26),UDim2.fromOffset(4,46),17,C.gold)
    local expl=label(body,"Clean View hides BBYA launchers and mini player for screenshots, then automatically restores them after 8 seconds.",UDim2.new(1,0,0,64),UDim2.fromOffset(4,78),13,C.muted)
    expl.TextWrapped=true
    local clean=button(body,cleanView and "RESTORE UI" or "CLEAN VIEW",UDim2.new(1,0,0,44),UDim2.fromOffset(0,154),C.gold)
    clean.MouseButton1Click:Connect(function()
        cleanView=not cleanView
        supportLaunch.Visible=not cleanView
        musicLaunch.Visible=not cleanView
        photoLaunch.Visible=not cleanView
        mini.Visible=not cleanView
        panel.Visible=false
        if cleanView then
            task.delay(8,function()
                cleanView=false
                supportLaunch.Visible=true
                musicLaunch.Visible=true
                photoLaunch.Visible=true
                mini.Visible=true
            end)
        end
    end)
    label(body,"OUTFIT CAM / FREECAM",UDim2.new(1,0,0,28),UDim2.fromOffset(4,220),13,C.white)
    label(body,"Reserved for the next camera-control pass. No camera override is enabled until mobile behavior is QC'd.",UDim2.new(1,0,0,54),UDim2.fromOffset(4,250),12,C.muted).TextWrapped=true
end

supportLaunch.MouseButton1Click:Connect(showSupport)
musicLaunch.MouseButton1Click:Connect(showMusic)
photoLaunch.MouseButton1Click:Connect(showPhoto)
mini.MouseButton1Click:Connect(showMusic)
close.MouseButton1Click:Connect(function() panel.Visible=false end)
openPanel.OnClientEvent:Connect(function(name)
    if name=="SUPPORT" then showSupport() elseif name=="MUSIC" then showMusic() else showPhoto() end
end)
supportChanged.OnClientEvent:Connect(function(payload)
    if payload and payload.amount then
        showToast("Support masuk • R$ "..tostring(payload.amount),C.pink)
        if currentPanel=="SUPPORT" and panel.Visible then task.defer(showSupport) end
    end
end)
musicStateChanged.OnClientEvent:Connect(function()
    cachedMusicState=nil
    refreshMini()
    if currentPanel=="MUSIC" and panel.Visible then task.defer(showMusic) end
end)

applyMusicMix()
applyEq()
refreshMini()
