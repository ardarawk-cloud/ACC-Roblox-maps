-- BBYA SOCIAL HUB — PHASE 4 MOBILE SOCIAL UI
-- One client shell for Support, Music and lightweight social/photo controls.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local SoundService=game:GetService("SoundService")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("BBYA REMOTES")
local openPanel=remotes:WaitForChild("OpenPanel")
local getSupportConfig=remotes:WaitForChild("GetSupportConfig")
local getSupportBoard=remotes:WaitForChild("GetSupportBoard")
local getMusicState=remotes:WaitForChild("GetMusicState")

local old=playerGui:FindFirstChild("BBYA SOCIAL UI")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="BBYA SOCIAL UI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=20
gui.Parent=playerGui

local C={bg=Color3.fromRGB(12,13,20),panel=Color3.fromRGB(24,25,34),pink=Color3.fromRGB(255,42,174),cyan=Color3.fromRGB(35,206,255),gold=Color3.fromRGB(255,192,82),white=Color3.fromRGB(245,245,248),muted=Color3.fromRGB(158,160,176),green=Color3.fromRGB(85,215,142)}

local function corner(o,r)
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o
end
local function stroke(o,color,t)
    local s=Instance.new("UIStroke");s.Color=color or C.cyan;s.Thickness=t or 1;s.Transparency=.25;s.Parent=o
end
local function label(parent,text,size,pos,fontSize,color)
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1;t.Size=size;t.Position=pos;t.Text=text;t.TextColor3=color or C.white;t.Font=Enum.Font.GothamSemibold;t.TextSize=fontSize or 14;t.TextXAlignment=Enum.TextXAlignment.Left;t.Parent=parent
    return t
end
local function button(parent,text,size,pos,color)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=true;b.Size=size;b.Position=pos;b.Text=text;b.TextColor3=C.white;b.Font=Enum.Font.GothamBold;b.TextSize=13;b.BackgroundColor3=color or C.panel;b.Parent=parent
    corner(b,9);stroke(b,color or C.cyan,1)
    return b
end

-- Compact launchers stay high enough to avoid Roblox joystick/jump zones.
local supportLaunch=button(gui,"SUPPORT",UDim2.fromOffset(96,38),UDim2.new(0,14,.19,0),C.pink)
local musicLaunch=button(gui,"MUSIC",UDim2.fromOffset(96,38),UDim2.new(1,-110,.19,0),C.cyan)
local photoLaunch=button(gui,"PHOTO",UDim2.fromOffset(96,38),UDim2.new(0,14,.19,46),C.gold)

local panel=Instance.new("Frame")
panel.Name="FLOATING PANEL"
panel.Size=UDim2.fromOffset(330,420)
panel.Position=UDim2.new(.5,-165,.5,-190)
panel.BackgroundColor3=C.bg
panel.BackgroundTransparency=.06
panel.Visible=false
panel.Parent=gui
corner(panel,14);stroke(panel,C.pink,1.3)

local title=label(panel,"BBYA",UDim2.new(1,-58,0,44),UDim2.fromOffset(18,7),20,C.white)
local close=button(panel,"×",UDim2.fromOffset(36,32),UDim2.new(1,-45,0,8),C.panel)
close.TextSize=22
local body=Instance.new("Frame")
body.BackgroundTransparency=1;body.Size=UDim2.new(1,-24,1,-60);body.Position=UDim2.fromOffset(12,52);body.Parent=panel

-- Mobile scale.
local function rescale()
    local cam=workspace.CurrentCamera
    local width=cam and cam.ViewportSize.X or 900
    local scale=math.clamp(width/430,.72,1)
    local u=panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
    u.Scale=scale;u.Parent=panel
end
rescale()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale) end

-- Drag by title area; clamp to viewport so the window is always recoverable.
local dragging=false;local dragStart;local startPos
panel.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
        if input.Position.Y <= panel.AbsolutePosition.Y+48 then dragging=true;dragStart=input.Position;startPos=panel.Position end
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local delta=input.Position-dragStart
    panel.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    task.defer(function()
        local vp=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(900,700)
        local p=panel.AbsolutePosition;local s=panel.AbsoluteSize
        local x=math.clamp(p.X,8,math.max(8,vp.X-s.X-8));local y=math.clamp(p.Y,54,math.max(54,vp.Y-s.Y-8))
        panel.Position=UDim2.fromOffset(x,y)
    end)
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

local function clearBody()
    for _,c in ipairs(body:GetChildren()) do c:Destroy() end
end
local function showPanel(name)
    panel.Visible=true
    clearBody()
    title.Text="BBYA • "..name
end

local function showSupport()
    showPanel("SUPPORT")
    local ok,config=pcall(function() return getSupportConfig:InvokeServer() end)
    if not ok then config={enabled=false,products={},note="Support service unavailable"} end
    label(body,"Support the BBYA Social Hub",UDim2.new(1,0,0,28),UDim2.fromOffset(4,0),17,C.white)
    label(body,config.note or "",UDim2.new(1,0,0,42),UDim2.fromOffset(4,29),12,config.enabled and C.green or C.muted).TextWrapped=true

    for i,row in ipairs(config.products or {}) do
        local col=(i-1)%2;local r=math.floor((i-1)/2)
        local b=button(body,"R$ "..tostring(row.amount),UDim2.new(.5,-8,0,42),UDim2.new(col*.5,col==0 and 0 or 8,0,80+r*50),row.enabled and C.pink or C.panel)
        if not row.enabled then b.TextColor3=C.muted;b.AutoButtonColor=false end
        b.MouseButton1Click:Connect(function()
            if row.enabled and row.productId and row.productId>0 then MarketplaceService:PromptProductPurchase(player,row.productId) end
        end)
    end

    label(body,"TOP SUPPORTERS",UDim2.new(1,0,0,26),UDim2.fromOffset(4,240),14,C.cyan)
    local okBoard,rows=pcall(function() return getSupportBoard:InvokeServer() end)
    if not okBoard then rows={} end
    if #rows==0 then
        label(body,"No supporter data yet.",UDim2.new(1,0,0,30),UDim2.fromOffset(4,270),13,C.muted)
    else
        for i,row in ipairs(rows) do
            if i>5 then break end
            label(body,string.format("%d. %s",i,row.name),UDim2.new(.72,0,0,25),UDim2.fromOffset(4,264+(i-1)*27),13,C.white)
            local amt=label(body,"R$ "..tostring(row.total),UDim2.new(.28,-4,0,25),UDim2.new(.72,0,0,264+(i-1)*27),13,C.gold)
            amt.TextXAlignment=Enum.TextXAlignment.Right
        end
    end
end

local localMusicMode="AUTO"
local localVolume=.55
local function applyMusicVolume()
    local root=SoundService:FindFirstChild("BBYA MUSIC")
    if not root then return end
    local club=root:FindFirstChild("CLUB CHANNEL")
    local roof=root:FindFirstChild("ROOFTOP CHANNEL")
    if club then club.Volume=(localMusicMode=="ROOFTOP") and 0 or localVolume end
    if roof then roof.Volume=(localMusicMode=="CLUB") and 0 or localVolume end
end

local function showMusic()
    showPanel("MUSIC")
    local ok,state=pcall(function() return getMusicState:InvokeServer() end)
    if not ok then state={autoDJ=true,mode="AUTO",trackTitle="Music service unavailable",libraryReady=false} end
    label(body,"MUSIC CONTROLLER",UDim2.new(1,0,0,28),UDim2.fromOffset(4,0),17,C.cyan)
    local status=label(body,state.trackTitle or "",UDim2.new(1,0,0,44),UDim2.fromOffset(4,32),13,state.libraryReady and C.white or C.muted)
    status.TextWrapped=true

    local auto=button(body,"AUTO DJ",UDim2.new(.32,-4,0,42),UDim2.fromOffset(0,88),localMusicMode=="AUTO" and C.pink or C.panel)
    local club=button(body,"CLUB",UDim2.new(.32,-4,0,42),UDim2.new(.34,0,0,88),localMusicMode=="CLUB" and C.cyan or C.panel)
    local roof=button(body,"ROOFTOP",UDim2.new(.32,-4,0,42),UDim2.new(.68,0,0,88),localMusicMode=="ROOFTOP" and C.gold or C.panel)
    auto.MouseButton1Click:Connect(function() localMusicMode="AUTO";applyMusicVolume();showMusic() end)
    club.MouseButton1Click:Connect(function() localMusicMode="CLUB";applyMusicVolume();showMusic() end)
    roof.MouseButton1Click:Connect(function() localMusicMode="ROOFTOP";applyMusicVolume();showMusic() end)

    label(body,"LISTENER VOLUME",UDim2.new(1,0,0,24),UDim2.fromOffset(4,154),13,C.white)
    local minus=button(body,"−",UDim2.fromOffset(48,38),UDim2.fromOffset(0,184),C.panel)
    local vol=label(body,string.format("%d%%",math.floor(localVolume*100+.5)),UDim2.fromOffset(100,38),UDim2.fromOffset(58,184),16,C.cyan)
    vol.TextXAlignment=Enum.TextXAlignment.Center
    local plus=button(body,"+",UDim2.fromOffset(48,38),UDim2.fromOffset(168,184),C.panel)
    minus.MouseButton1Click:Connect(function() localVolume=math.max(0,localVolume-.1);applyMusicVolume();showMusic() end)
    plus.MouseButton1Click:Connect(function() localVolume=math.min(1,localVolume+.1);applyMusicVolume();showMusic() end)

    label(body,"DJ MODE",UDim2.new(1,0,0,24),UDim2.fromOffset(4,244),13,C.white)
    local dj=button(body,state.libraryReady and "DJ MODE" or "DJ MODE • LIBRARY PENDING",UDim2.new(1,0,0,44),UDim2.fromOffset(0,274),state.libraryReady and C.pink or C.panel)
    if not state.libraryReady then dj.AutoButtonColor=false;dj.TextColor3=C.muted end
    local note=label(body,"World music only activates after authorized Roblox audio IDs are added. No fake track IDs are used.",UDim2.new(1,0,0,62),UDim2.fromOffset(4,330),12,C.muted)
    note.TextWrapped=true
end

local cleanView=false
local function showPhoto()
    showPanel("PHOTO")
    label(body,"SOCIAL / PHOTO TOOLS",UDim2.new(1,0,0,28),UDim2.fromOffset(4,0),17,C.gold)
    label(body,"Clean View hides the BBYA launch buttons for screenshots. The panel stays recoverable with the Roblox reset/spawn cycle.",UDim2.new(1,0,0,64),UDim2.fromOffset(4,34),13,C.muted).TextWrapped=true
    local clean=button(body,cleanView and "RESTORE UI" or "CLEAN VIEW",UDim2.new(1,0,0,44),UDim2.fromOffset(0,112),C.gold)
    clean.MouseButton1Click:Connect(function()
        cleanView=not cleanView
        supportLaunch.Visible=not cleanView;musicLaunch.Visible=not cleanView;photoLaunch.Visible=not cleanView
        panel.Visible=false
        if cleanView then
            task.delay(8,function() cleanView=false;supportLaunch.Visible=true;musicLaunch.Visible=true;photoLaunch.Visible=true end)
        end
    end)
end

supportLaunch.MouseButton1Click:Connect(showSupport)
musicLaunch.MouseButton1Click:Connect(showMusic)
photoLaunch.MouseButton1Click:Connect(showPhoto)
close.MouseButton1Click:Connect(function() panel.Visible=false end)
openPanel.OnClientEvent:Connect(function(name)
    if name=="SUPPORT" then showSupport() elseif name=="MUSIC" then showMusic() else showPhoto() end
end)

applyMusicVolume()
