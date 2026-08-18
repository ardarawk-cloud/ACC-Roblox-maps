-- BBYA V6 — FUNCTIONAL SYSTEMS CORE
-- Server-authoritative remotes, music, lift, inspection teleport, profile badge.
-- IMPORTANT: this runtime is self-contained and does not call architecture-local helper functions.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local TweenService=game:GetService("TweenService")

local QUEEN_ID=4271188557
local net=ReplicatedStorage:FindFirstChild("BBYA_V6") or Instance.new("Folder")
net.Name="BBYA_V6";net.Parent=ReplicatedStorage
local function remote(name,class)
    local r=net:FindFirstChild(name) or Instance.new(class or "RemoteEvent")
    r.Name=name;r.Parent=net;return r
end
local Notice=remote("Notice")
local Music=remote("Music")
local MusicState=remote("MusicState")
local Lift=remote("Lift")
local Teleport=remote("Teleport")
local Dance=remote("Dance")
local SyncDance=remote("SyncDance")

-- Small avatar title only; no giant REGULAR text.
local function roleFor(p)
    if p.UserId==QUEEN_ID then return "BBYA QUEEN" end
    if p:GetAttribute("IsVIP")==true then return "VIP" end
    return "SOCIALITE"
end
local function titleTag(p,char)
    local head=char:WaitForChild("Head",8);if not head then return end
    local old=head:FindFirstChild("BBYA V6 TITLE");if old then old:Destroy() end
    local gui=Instance.new("BillboardGui")
    gui.Name="BBYA V6 TITLE";gui.Size=UDim2.fromOffset(130,24);gui.StudsOffset=Vector3.new(0,2.7,0)
    gui.AlwaysOnTop=false;gui.MaxDistance=55;gui.Parent=head
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=roleFor(p)
    t.TextColor3=Color3.fromRGB(255,83,204);t.TextStrokeTransparency=.7;t.Font=Enum.Font.GothamBold;t.TextSize=14;t.Parent=gui
end
local function setupPlayer(p)
    if p.UserId==QUEEN_ID then p:SetAttribute("BBYAQueen",true);p:SetAttribute("BBYAAllAccess",true);p:SetAttribute("IsVIP",true) end
    p.CharacterAdded:Connect(function(c) task.defer(titleTag,p,c) end)
    if p.Character then task.defer(titleTag,p,p.Character) end
end
for _,p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)

-- Inspection/navigation destinations. These are clear circulation pads, not furniture centers.
local TP={
 A1=CFrame.new(0,4,-26),A2=CFrame.new(0,4,4),A3=CFrame.new(0,4,30),A4=CFrame.new(0,4,75),A5=CFrame.new(52,4,72),A6=CFrame.new(-52,4,72),
 B1=CFrame.new(-56,4,136),B2=CFrame.new(33,4,136),B3=CFrame.new(59,4,112),
 C1=CFrame.new(-35,24,72),C2=CFrame.new(28,24,72),C3=CFrame.new(0,24,132),
 D1=CFrame.new(59,44,112),D2=CFrame.new(0,44,64),D3=CFrame.new(52,44,70),D4=CFrame.new(-52,44,70),D5=CFrame.new(0,44,126),D6=CFrame.new(0,44,53),
}
Teleport.OnServerEvent:Connect(function(p,code)
    local cf=TP[string.upper(tostring(code or ""))];if not cf then return end
    local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if hrp then hrp.CFrame=cf;Notice:FireClient(p,"Moved to "..string.upper(code)) end
end)

-- Dance uses Roblox built-in emote names only. No invented animation IDs.
local EMOTES={dance="dance",dance2="dance2",dance3="dance3",wave="wave",cheer="cheer",laugh="laugh",point="point"}
local function playBuiltInEmote(p,em)
    local hum=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local ok,res=pcall(function() return hum:PlayEmote(em) end)
    if ok and res~=false then p:SetAttribute("BBYALastDance",em);return true end
    return false
end
Dance.OnServerEvent:Connect(function(p,key)
    key=string.lower(tostring(key or ""));local em=EMOTES[key];if not em then return end
    if not playBuiltInEmote(p,em) then Notice:FireClient(p,"Emote tidak tersedia pada avatar ini") end
end)
SyncDance.OnServerEvent:Connect(function(p,targetId)
    local target=Players:GetPlayerByUserId(tonumber(targetId) or 0);if not target then return end
    local a=p.Character and p.Character:FindFirstChild("HumanoidRootPart");local b=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if a and b and (a.Position-b.Position).Magnitude<=35 then
        local em=target:GetAttribute("BBYALastDance");if em and playBuiltInEmote(p,em) then Notice:FireClient(p,"Synced with "..target.DisplayName) end
    end
end)

-- Hybrid Auto-DJ: preserve verified BBYA audio vault.
local QUEUE={
 {id=85427648559465,title="DJ Phut Hon Indo Full Bass",genre="INDO",sub="BREAKBEAT"},{id=100787734732008,title="Aku Suka Jedag Jedug Full Bass",genre="INDO",sub="BREAKBEAT"},
 {id=110691393637838,title="DJ Bahagiamu Sayang Funkot",genre="INDO",sub="FUNKOT"},{id=101399039672234,title="DNA INDO BOUNCE",genre="INDO",sub="INDO_BOUNCE"},
 {id=128622207855102,title="DJ Breakbeat Stadium Jakarta",genre="INDO",sub="STADIUM"},{id=85229747030713,title="DJ Dumes Remix Koplo",genre="INDO",sub="KOPLO"},
 {id=9040442826,title="Pumpin And Bumpin D",genre="INTL",sub="BASS_HOUSE"},{id=9045072146,title="Struck Down D",genre="INTL",sub="PSYTRANCE"},
 {id=1839246840,title="Fast Rave",genre="INTL",sub="TECHNO"},{id=9047436030,title="Ipanema House Beach",genre="INTL",sub="TROPICAL_HOUSE"},
 {id=7023598688,title="Bad Computer - Clarity",genre="INTL",sub="HOUSE"},{id=7023749823,title="Eskai - Mimi",genre="INTL",sub="PROGRESSIVE_HOUSE"},
 {id=7028977687,title="Stonebank - What Are You Waiting For",genre="INTL",sub="EDM"},{id=9042927806,title="We Want Disco",genre="INTL",sub="DISCO"},
 {id=133054925243074,title="Time Chasing",genre="INTL",sub="DNB"},
}
local sound=SoundService:FindFirstChild("BBYA_V6_Music") or Instance.new("Sound")
sound.Name="BBYA_V6_Music";sound.Volume=.58;sound.Looped=false;sound.Parent=SoundService
local idx=0;local current=nil;local bad={};local mode="ALL";local list={}
local function rebuild()
    table.clear(list)
    for _,t in ipairs(QUEUE) do if not bad[t.id] and (mode=="ALL" or t.genre==mode or t.sub==mode) then table.insert(list,t) end end
    idx=0
end
local function publish(err)
    MusicState:FireAllClients({title=current and current.title or "BBYA 24/7",genre=current and current.genre or "",sub=current and current.sub or "",volume=sound.Volume,playing=sound.Playing,mode=mode,error=err or ""})
end
local nextTrack
local function play(t)
    current=t;sound:Stop();sound.SoundId="rbxassetid://"..t.id;sound.TimePosition=0
    local ok=pcall(function() sound:Play() end)
    if not ok then bad[t.id]=true;current=nil;task.defer(nextTrack);return end
    publish("")
    task.delay(5,function() if current==t and #Players:GetPlayers()>0 and not (sound.IsLoaded and sound.TimeLength>0) then bad[t.id]=true;current=nil;nextTrack() end end)
end
nextTrack=function()
    if #Players:GetPlayers()==0 then sound:Stop();current=nil;publish("WAITING FOR PLAYERS");return end
    if #list==0 or idx>=#list then rebuild() end
    if #list==0 then publish("NO PLAYABLE AUDIO");return end
    idx+=1;play(list[idx])
end
sound.Ended:Connect(function() task.defer(nextTrack) end)
local function nearDJ(p)
    if p.UserId==QUEEN_ID or p:GetAttribute("BBYAAllAccess")==true then return true end
    local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if not hrp then return false end
    local a=workspace:FindFirstChild("A4 DJ BOOTH",true);local b=workspace:FindFirstChild("D2 POOL DJ DESK",true)
    return (a and (hrp.Position-a.Position).Magnitude<=20) or (b and (hrp.Position-b.Position).Magnitude<=20) or false
end
Music.OnServerEvent:Connect(function(p,action,value)
    action=string.upper(tostring(action or ""))
    if action=="STATE" then publish("");return end
    if not nearDJ(p) then Notice:FireClient(p,"Use the A4 or rooftop DJ booth for DJ controls");return end
    if action=="NEXT" then nextTrack()
    elseif action=="PLAY" then if current then sound:Resume();publish("") else nextTrack() end
    elseif action=="PAUSE" then sound:Pause();publish("")
    elseif action=="VOLUME" then sound.Volume=math.clamp(tonumber(value) or .58,0,1);publish("")
    elseif action=="MODE" then mode=string.upper(tostring(value or "ALL"));rebuild();nextTrack() end
end)
Players.PlayerAdded:Connect(function() task.delay(1,function() if not sound.Playing then nextTrack() end end) end)
rebuild();if #Players:GetPlayers()>0 then task.delay(1,nextTrack) else publish("WAITING FOR PLAYERS") end

-- PHYSICAL LIFT -------------------------------------------------------------
-- Architecture owns shaft/cab/landing doors. This runtime only animates them.
local v6=workspace:WaitForChild("BBYA V6 CLEANROOM",10)
local b3=v6 and v6:FindFirstChild("ZONES") and v6.ZONES:FindFirstChild("[B3] LIFT CORE")
local levels={G=0,VIP=20,ROOF=40}
local currentLevel="G"
local busy=false

local function find(name)
    return b3 and b3:FindFirstChild(name,true) or nil
end
local landing={
    G={find("B3 G LANDING DOOR L"),find("B3 G LANDING DOOR R")},
    VIP={find("B3 VIP LANDING DOOR L"),find("B3 VIP LANDING DOOR R")},
    ROOF={find("B3 ROOF LANDING DOOR L"),find("B3 ROOF LANDING DOOR R")},
}
local cabDoors={find("B3 LIFT CAB DOOR L"),find("B3 LIFT CAB DOOR R")}
local cabBody={}
if b3 then
    for _,o in ipairs(b3:GetDescendants()) do
        if o:IsA("BasePart") and o.Name:find("B3 LIFT CAB",1,true) then table.insert(cabBody,o) end
    end
end

local landingBase={}
for _,pair in pairs(landing) do for _,d in ipairs(pair) do if d then landingBase[d]=d.CFrame end end end
local cabDoorBase={}
for _,d in ipairs(cabDoors) do if d then cabDoorBase[d]=d.CFrame end end

local function tweenCF(p,cf,time)
    if not p then return nil end
    local tw=TweenService:Create(p,TweenInfo.new(time or .45,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=cf})
    tw:Play();return tw
end
local function setDoorPair(pair,baseMap,open,instant)
    if not pair or not pair[1] or not pair[2] then return end
    local l,r=pair[1],pair[2]
    local lc=baseMap[l]*CFrame.new(open and -4.5 or 0,0,0)
    local rc=baseMap[r]*CFrame.new(open and 4.5 or 0,0,0)
    if instant then l.CFrame=lc;r.CFrame=rc else tweenCF(l,lc,.45);tweenCF(r,rc,.45) end
end
local function insideCab(p)
    local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local y=levels[currentLevel]
    local pos=hrp.Position
    return pos.X>=52.2 and pos.X<=65.8 and pos.Z>=119 and pos.Z<=130.8 and pos.Y>=y+.5 and pos.Y<=y+10.5
end
local function getOccupants()
    local result={}
    for _,p in ipairs(Players:GetPlayers()) do if insideCab(p) then table.insert(result,p) end end
    return result
end

-- Simple physical call panels at each landing; no floating giant text.
local function makePanel(level,y)
    if not b3 then return end
    local panel=Instance.new("Part")
    panel.Name="B3 "..level.." CALL PANEL";panel.Size=Vector3.new(1.2,2.4,.45);panel.CFrame=CFrame.new(66.8,y+5.2,117.8)
    panel.Anchored=true;panel.CanCollide=false;panel.CanTouch=false;panel.Material=Enum.Material.Metal;panel.Color=Color3.fromRGB(32,32,38);panel.Parent=b3
    panel:SetAttribute("BBYAZoneCode","B3")
    local prompt=Instance.new("ProximityPrompt")
    prompt.ActionText="CALL LIFT";prompt.ObjectText=level;prompt.HoldDuration=0;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=panel
    prompt.Triggered:Connect(function() if not busy then task.spawn(function() moveLift(level) end) end end)
end

-- Forward declaration because landing prompts call it.
local moveLift

-- Cab destination buttons move with the cab.
local cabButtons={}
local function makeCabButton(dest,yOffset)
    if not b3 then return end
    local p=Instance.new("Part")
    p.Name="B3 LIFT CAB BUTTON "..dest;p.Size=Vector3.new(.45,1.2,1.2);p.CFrame=CFrame.new(64.48,4.2+yOffset,124.8)
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.Material=Enum.Material.Neon;p.Color=dest=="ROOF" and Color3.fromRGB(255,196,75) or Color3.fromRGB(31,221,255);p.Parent=b3
    p:SetAttribute("BBYAZoneCode","B3")
    table.insert(cabBody,p);table.insert(cabButtons,p)
    local pr=Instance.new("ProximityPrompt")
    pr.ActionText="GO "..dest;pr.ObjectText="LIFT";pr.HoldDuration=0;pr.MaxActivationDistance=6;pr.RequiresLineOfSight=false;pr.Parent=p
    pr.Triggered:Connect(function(player) if insideCab(player) then task.spawn(function() moveLift(dest) end) end end)
end

moveLift=function(dest)
    dest=string.upper(tostring(dest or ""))
    if busy or levels[dest]==nil or not b3 then return end
    if dest==currentLevel then
        setDoorPair(landing[currentLevel],landingBase,true,false)
        setDoorPair(cabDoors,cabDoorBase,true,false)
        return
    end
    busy=true
    setDoorPair(landing[currentLevel],landingBase,false,false)
    setDoorPair(cabDoors,cabDoorBase,false,false)
    task.wait(.58)

    local delta=levels[dest]-levels[currentLevel]
    local occupants=getOccupants()
    local hrpStates={}
    for _,plr in ipairs(occupants) do
        local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrpStates[hrp]=hrp.Anchored;hrp.Anchored=true
            tweenCF(hrp,hrp.CFrame*CFrame.new(0,delta,0),3.2)
        end
    end
    for _,p in ipairs(cabBody) do tweenCF(p,p.CFrame*CFrame.new(0,delta,0),3.2) end
    task.wait(3.28)
    for d,cf in pairs(cabDoorBase) do cabDoorBase[d]=cf*CFrame.new(0,delta,0) end
    currentLevel=dest
    for hrp,wasAnchored in pairs(hrpStates) do if hrp.Parent then hrp.Anchored=wasAnchored end end
    setDoorPair(landing[currentLevel],landingBase,true,false)
    setDoorPair(cabDoors,cabDoorBase,true,false)
    busy=false
end

if b3 and landing.G[1] and landing.G[2] and cabDoors[1] and cabDoors[2] then
    setDoorPair(landing.G,landingBase,true,true)
    setDoorPair(cabDoors,cabDoorBase,true,true)
    makeCabButton("G",0)
    makeCabButton("VIP",1.6)
    makeCabButton("ROOF",3.2)
    makePanel("G",0)
    makePanel("VIP",20)
    makePanel("ROOF",40)
    workspace:SetAttribute("BBYAV6LiftRuntime","READY")
else
    workspace:SetAttribute("BBYAV6LiftRuntime","MISSING_GEOMETRY")
end

Lift.OnServerEvent:Connect(function(p,dest)
    dest=string.upper(tostring(dest or ""))
    if levels[dest]==nil then return end
    if not insideCab(p) then Notice:FireClient(p,"Enter the lift cab first") return end
    task.spawn(function() moveLift(dest) end)
end)

workspace:SetAttribute("BBYAV6Systems","ACTIVE")