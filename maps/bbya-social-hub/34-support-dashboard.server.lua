-- BBYA SOCIAL HUB — ENTRANCE COMMUNITY HONOR WALLS v5
-- Full-wall dual entrance displays.
-- Left: Top Supporters / Hall of Fame.
-- Right: Live Community / dynamic welcome + recent arrivals.

local W = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local root = W:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder")
root.Name = "BBYA_ZERO_BUILD"
root.Parent = W

local old = root:FindFirstChild("SupportDashboard")
if old then old:Destroy() end

local model = Instance.new("Model")
model.Name = "SupportDashboard"
model:SetAttribute("Pass", "ENTRANCE_COMMUNITY_HONOR_V5")
model.Parent = root

local PINK = Color3.fromRGB(255,38,155)
local CYAN = Color3.fromRGB(0,205,235)
local WHITE = Color3.fromRGB(244,241,247)
local MUTED = Color3.fromRGB(151,145,161)
local DARK = Color3.fromRGB(8,8,11)
local PANEL = Color3.fromRGB(20,18,24)
local PANEL2 = Color3.fromRGB(29,25,34)
local GOLD = Color3.fromRGB(238,190,94)
local SILVER = Color3.fromRGB(201,205,214)
local BRONZE = Color3.fromRGB(201,129,84)

local function part(name,size,cf,color,material,transparency,parent)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    p.Transparency=transparency or 0
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true
    p.CastShadow=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or model
    return p
end
local function corner(obj,px)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,px or 10);c.Parent=obj end
local function stroke(obj,color,transparency,thickness)local s=Instance.new("UIStroke");s.Color=color;s.Thickness=thickness or 1;s.Transparency=transparency or 0;s.Parent=obj end
local function frame(parent,pos,size,color,transparency,radius)
    local f=Instance.new("Frame");f.Position=pos;f.Size=size;f.BackgroundColor3=color;f.BackgroundTransparency=transparency or 0;f.BorderSizePixel=0;f.Parent=parent
    if radius then corner(f,radius) end
    return f
end
local function label(parent,textValue,pos,size,color,font,align,scaled)
    local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=textValue;t.TextColor3=color or WHITE
    t.Font=font or Enum.Font.GothamMedium;t.TextScaled=scaled~=false;t.TextWrapped=true;t.TextXAlignment=align or Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Center;t.Parent=parent
    return t
end

local function makeBoard(name,x,accentTop,accentBottom)
    local holder=Instance.new("Model");holder.Name=name;holder.Parent=model
    local cf=CFrame.new(x,7.0,-44.50)
    -- Glass opening is ~16x13. Fill almost the entire field while preserving a slim architectural reveal.
    part("Recess",Vector3.new(16.10,13.05,.34),cf*CFrame.new(0,0,.10),Color3.fromRGB(4,4,6),Enum.Material.Metal,0,holder)
    local face=part("DisplayGlass",Vector3.new(15.72,12.68,.10),cf*CFrame.new(0,0,-.15),Color3.fromRGB(10,9,13),Enum.Material.Glass,.04,holder)
    face.Reflectance=.07
    part("TopTrim",Vector3.new(15.78,.12,.12),cf*CFrame.new(0,6.39,-.22),accentTop,Enum.Material.Neon,0,holder)
    part("BottomTrim",Vector3.new(15.78,.09,.12),cf*CFrame.new(0,-6.39,-.22),accentBottom,Enum.Material.Neon,0,holder)
    part("LeftTrim",Vector3.new(.09,12.55,.12),cf*CFrame.new(-7.91,0,-.22),accentBottom,Enum.Material.Neon,0,holder)
    part("RightTrim",Vector3.new(.09,12.55,.12),cf*CFrame.new(7.91,0,-.22),accentTop,Enum.Material.Neon,0,holder)
    local light=Instance.new("PointLight");light.Color=accentTop;light.Brightness=.25;light.Range=8;light.Shadows=false;light.Parent=face
    local gui=Instance.new("SurfaceGui");gui.Name="CommunityWallUI";gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=false;gui.LightInfluence=.18;gui.PixelsPerStud=76;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.Parent=face
    local bg=frame(gui,UDim2.fromScale(0,0),UDim2.fromScale(1,1),DARK,0)
    local grad=Instance.new("UIGradient")
    grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(36,13,31)),ColorSequenceKeypoint.new(.50,Color3.fromRGB(11,10,14)),ColorSequenceKeypoint.new(1,Color3.fromRGB(6,17,21))})
    grad.Rotation=14;grad.Parent=bg
    return holder,face,bg
end

-- LEFT — HALL OF FAME ----------------------------------------------------------
local _,leftFace,left=makeBoard("TopSupportersWall",-33,GOLD,PINK)
label(left,"BBYA",UDim2.fromScale(.045,.040),UDim2.fromScale(.17,.055),WHITE,Enum.Font.GothamBlack)
label(left,"COMMUNITY HALL OF FAME",UDim2.fromScale(.045,.105),UDim2.fromScale(.83,.085),GOLD,Enum.Font.GothamBlack)
label(left,"The people who help keep the room alive",UDim2.fromScale(.045,.190),UDim2.fromScale(.70,.040),MUTED,Enum.Font.GothamMedium)
local dl=frame(left,UDim2.fromScale(.045,.245),UDim2.fromScale(.91,.004),GOLD,.08)
local dlg=Instance.new("UIGradient");dlg.Color=ColorSequence.new(GOLD,PINK);dlg.Parent=dl
local rankColors={GOLD,SILVER,BRONZE};local rankNames={"#1","#2","#3"}
for i=1,3 do
    local y=.285+(i-1)*.205
    local card=frame(left,UDim2.fromScale(.045,y),UDim2.fromScale(.91,.170),PANEL2,.02,12);stroke(card,rankColors[i],.25,i==1 and 2 or 1)
    local badge=frame(card,UDim2.fromScale(.025,.13),UDim2.fromScale(.16,.74),Color3.fromRGB(11,10,14),0,99);stroke(badge,rankColors[i],.12,2)
    label(badge,rankNames[i],UDim2.fromScale(.07,.07),UDim2.fromScale(.86,.86),rankColors[i],Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
    label(card,"OPEN HONOR SLOT",UDim2.fromScale(.22,.18),UDim2.fromScale(.55,.27),WHITE,Enum.Font.GothamBold)
    label(card,"Ready for a BBYA supporter",UDim2.fromScale(.22,.49),UDim2.fromScale(.62,.22),MUTED,Enum.Font.GothamMedium)
end
local footL=frame(left,UDim2.fromScale(.045,.915),UDim2.fromScale(.91,.045),Color3.fromRGB(20,17,24),.05,8)
label(footL,"EVERY GUEST COUNTS  •  EVERY SUPPORTER IS REMEMBERED",UDim2.fromScale(.03,.08),UDim2.fromScale(.94,.84),Color3.fromRGB(206,197,211),Enum.Font.GothamBold,Enum.TextXAlignment.Center)

-- RIGHT — LIVE COMMUNITY / WELCOME --------------------------------------------
local _,rightFace,right=makeBoard("LiveCommunityWall",33,PINK,CYAN)
label(right,"BBYA",UDim2.fromScale(.045,.040),UDim2.fromScale(.17,.055),WHITE,Enum.Font.GothamBlack)
label(right,"LIVE COMMUNITY",UDim2.fromScale(.045,.105),UDim2.fromScale(.62,.085),PINK,Enum.Font.GothamBlack)
label(right,"You are part of the room the moment you arrive",UDim2.fromScale(.045,.190),UDim2.fromScale(.80,.040),MUTED,Enum.Font.GothamMedium)
local dr=frame(right,UDim2.fromScale(.045,.245),UDim2.fromScale(.91,.004),PINK,.08)
local drg=Instance.new("UIGradient");drg.Color=ColorSequence.new(PINK,CYAN);drg.Parent=dr

local hero=frame(right,UDim2.fromScale(.045,.285),UDim2.fromScale(.91,.205),Color3.fromRGB(28,16,28),.02,14);stroke(hero,PINK,.18,2)
local heroGrad=Instance.new("UIGradient");heroGrad.Color=ColorSequence.new(Color3.fromRGB(75,18,55),Color3.fromRGB(18,45,57));heroGrad.Parent=hero
label(hero,"WELCOME TO BBYA",UDim2.fromScale(.035,.12),UDim2.fromScale(.60,.18),Color3.fromRGB(255,218,239),Enum.Font.GothamBold)
local welcomeName=label(hero,"YOU BELONG HERE",UDim2.fromScale(.035,.33),UDim2.fromScale(.90,.34),WHITE,Enum.Font.GothamBlack)
local welcomeSub=label(hero,"Thanks for showing up tonight.",UDim2.fromScale(.035,.69),UDim2.fromScale(.88,.18),Color3.fromRGB(211,201,216),Enum.Font.GothamMedium)

label(right,"RECENT ARRIVALS",UDim2.fromScale(.045,.525),UDim2.fromScale(.50,.045),WHITE,Enum.Font.GothamBold)
local arrivalLabels={}
for i=1,3 do
    local y=.585+(i-1)*.095
    local card=frame(right,UDim2.fromScale(.045,y),UDim2.fromScale(.91,.073),PANEL,.02,9)
    local dot=frame(card,UDim2.fromScale(.028,.27),UDim2.fromScale(.045,.46),i==1 and PINK or CYAN,0,99)
    arrivalLabels[i]=label(card,i==1 and "Waiting for the next guest" or "Open community slot",UDim2.fromScale(.095,.12),UDim2.fromScale(.79,.38),WHITE,Enum.Font.GothamBold)
    label(card,"BBYA community member",UDim2.fromScale(.095,.51),UDim2.fromScale(.62,.25),MUTED,Enum.Font.GothamMedium)
end

local action=frame(right,UDim2.fromScale(.045,.887),UDim2.fromScale(.91,.073),Color3.fromRGB(56,16,43),0,10);stroke(action,PINK,.12,1)
local ag=Instance.new("UIGradient");ag.Color=ColorSequence.new(Color3.fromRGB(102,18,70),Color3.fromRGB(20,58,69));ag.Parent=action
label(action,"OPEN SUPPORT  •  LEAVE YOUR MARK",UDim2.fromScale(.03,.12),UDim2.fromScale(.94,.76),WHITE,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)

-- Dynamic guest recognition ----------------------------------------------------
local recent={}
local stamped={}
local function cleanName(player)
    local display=(player.DisplayName and player.DisplayName~="") and player.DisplayName or player.Name
    return tostring(display)
end
local function refreshArrivals()
    for i=1,3 do
        arrivalLabels[i].Text=recent[i] and recent[i] or (i==1 and "Waiting for the next guest" or "Open community slot")
    end
end
local function recognize(player,reason)
    if not player or not player.Parent then return end
    local now=os.clock();local last=stamped[player.UserId] or 0
    if now-last<8 then return end
    stamped[player.UserId]=now
    local name=cleanName(player)
    welcomeName.Text=string.upper(name)
    welcomeSub.Text=(reason=="checkin") and "Checked in. Welcome to the BBYA community." or "Thanks for showing up tonight."
    table.insert(recent,1,name)
    while #recent>3 do table.remove(recent) end
    refreshArrivals()
end
local function wirePlayer(player)
    task.delay(1.5,function() if player.Parent then recognize(player,"join") end end)
    player:GetAttributeChangedSignal("BBYACheckedIn"):Connect(function()
        if player:GetAttribute("BBYACheckedIn") then recognize(player,"checkin") end
    end)
end
for _,p in ipairs(Players:GetPlayers()) do wirePlayer(p) end
Players.PlayerAdded:Connect(wirePlayer)
Players.PlayerRemoving:Connect(function(player)stamped[player.UserId]=nil end)

-- Both walls open the unified Support panel -----------------------------------
local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state=remotes and remotes:FindFirstChild("State")
for _,face in ipairs({leftFace,rightFace}) do
    local prompt=Instance.new("ProximityPrompt")
    prompt.Name="OpenSupportMenu";prompt.ActionText="Open Support";prompt.ObjectText="BBYA Community Wall";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=0;prompt.MaxActivationDistance=11;prompt.RequiresLineOfSight=false;prompt.Parent=face
    prompt.Triggered:Connect(function(player)if state then state:FireClient(player,"openSupport",true) end end)
end

print("[BBYA] Full-wall community honor system online: hall of fame + live guest recognition")