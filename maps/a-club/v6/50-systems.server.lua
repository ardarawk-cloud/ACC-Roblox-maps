-- BBYA V6 — FUNCTIONAL SYSTEMS CORE
-- Server-authoritative remotes, music, lift, inspection teleport, profile badge.

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

-- Dance uses Roblox built-in emotes only.
local EMOTES={dance="dance",dance2="dance2",dance3="dance3",wave="wave",cheer="cheer",laugh="laugh",point="point"}
Dance.OnServerEvent:Connect(function(p,key)
    key=string.lower(tostring(key or ""));local em=EMOTES[key];if not em then return end
    local hum=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        local ok,desc=pcall(function() return Players:GetHumanoidDescriptionFromUserId(p.UserId) end)
        if ok then p:SetAttribute("BBYALastDance",em) end
    end
end)
SyncDance.OnServerEvent:Connect(function(p,targetId)
    local target=Players:GetPlayerByUserId(tonumber(targetId) or 0);if not target then return end
    local a=p.Character and p.Character:FindFirstChild("HumanoidRootPart");local b=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if a and b and (a.Position-b.Position).Magnitude<=35 then
        local em=target:GetAttribute("BBYALastDance");if em then p:SetAttribute("BBYALastDance",em);Notice:FireClient(p,"Synced with "..target.DisplayName) end
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
    current=t;sound:Stop();sound.SoundId="rbxassetid://"..t.id;sound.TimePosition=0;sound:Play();publish("")
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
    if not nearDJ(p) and action~="VOLUME_LOCAL" then Notice:FireClient(p,"Use the A4 or rooftop DJ booth for DJ controls");return end
    if action=="NEXT" then nextTrack()
    elseif action=="PLAY" then if current then sound:Resume();publish("") else nextTrack() end
    elseif action=="PAUSE" then sound:Pause();publish("")
    elseif action=="VOLUME" then sound.Volume=math.clamp(tonumber(value) or .58,0,1);publish("")
    elseif action=="MODE" then mode=string.upper(tostring(value or "ALL"));rebuild();nextTrack() end
end)
Players.PlayerAdded:Connect(function() task.delay(1,function() if not sound.Playing then nextTrack() end end) end)
rebuild();if #Players:GetPlayers()>0 then task.delay(1,nextTrack) else publish("WAITING FOR PLAYERS") end

-- Physical lift system. Cab moves between G/VIP/ROOF and opens matching landing doors.
local v6=workspace:FindFirstChild("BBYA V6 CLEANROOM")
local b3=v6 and v6:FindFirstChild("ZONES") and v6.ZONES:FindFirstChild("[B3] LIFT CORE")
local levels={G=0,VIP=20,ROOF=40};local currentLevel="G";local busy=false
local cabParts={};if b3 then for _,o in ipairs(b3:GetChildren()) do if o:IsA("BasePart") and o.Name:find("B3 LIFT CAB",1,true) then table.insert(cabParts,o) end end end
local function landingDoors(level,y)
    if not b3 then return nil,nil end
    local l=part(b3,"B3 "..level.." LANDING DOOR L",Vector3.new(5,9,.5),CFrame.new(56.5,y+5.2,119.15),P.black,Enum.Material.Metal,0,true,nil)
    local r=part(b3,"B3 "..level.." LANDING DOOR R",Vector3.new(5,9,.5),CFrame.new(61.5,y+5.2,119.15),P.black,Enum.Material.Metal,0,true,nil)
    return l,r
end
local landing={G={landingDoors("G",0)},VIP={landingDoors("VIP",20)},ROOF={landingDoors("ROOF",40)}}
local function tweenPart(p,cf,time) local tw=TweenService:Create(p,TweenInfo.new(time,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=cf});tw:Play();return tw end
local function openPair(pair,open)
    if not pair or not pair[1] then return end
    local l,r=pair[1],pair[2];local dx=open and 4.5 or -4.5
    tweenPart(l,l.CFrame*CFrame.new(-dx,0,0),.45);tweenPart(r,r.CFrame*CFrame.new(dx,0,0),.45)
end
local cabBase={};for _,p in ipairs(cabParts) do cabBase[p]=p.CFrame end
local function moveLift(dest)
    if busy or not levels[dest] then return end;busy=true
    local fromY=levels[currentLevel];local toY=levels[dest];openPair(landing[currentLevel],false)
    task.wait(.6)
    local delta=toY-fromY
    for _,p in ipairs(cabParts) do tweenPart(p,p.CFrame*CFrame.new(0,delta,0),3.2) end
    task.wait(3.35);currentLevel=dest;openPair(landing[currentLevel],true);busy=false
end
Lift.OnServerEvent:Connect(function(p,dest)
    dest=string.upper(tostring(dest or ""));if levels[dest] then moveLift(dest) end
end)

workspace:SetAttribute("BBYAV6Systems","ACTIVE")
