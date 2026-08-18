-- BBYA SOCIAL HUB — ENTRANCE SOCIAL LOBBY POLISH v1.0
-- Premium social arrival layer. Does not modify rooftop systems.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA Entrance Social Lobby Polish v1"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end
local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
    black=Color3.fromRGB(8,8,14),
    graphite=Color3.fromRGB(19,20,28),
    pink=Color3.fromRGB(255,42,178),
    magenta=Color3.fromRGB(218,48,255),
    cyan=Color3.fromRGB(47,221,255),
    purple=Color3.fromRGB(103,60,190),
    gold=Color3.fromRGB(255,190,86),
    glass=Color3.fromRGB(61,78,103),
    warm=Color3.fromRGB(255,154,91),
    green=Color3.fromRGB(50,112,73),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false
    p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or C.graphite;p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root
    return p
end

local function neon(name,size,cf,color,parent,range,brightness)
    local p=part(name,size,cf,color,Enum.Material.Neon,0,false,parent)
    local l=Instance.new("PointLight")
    l.Color=color;l.Range=range or 16;l.Brightness=brightness or 1.3;l.Shadows=false;l.Parent=p
    return p
end

local function textSign(name,text,cf,size,color,parent)
    local p=part(name,size,cf,C.black,Enum.Material.SmoothPlastic,0,false,parent)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=32;gui.LightInfluence=0;gui.Parent=p
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text=text;t.TextScaled=true;t.Font=Enum.Font.GothamBlack;t.TextColor3=color or C.pink;t.TextStrokeTransparency=.28;t.Parent=gui
    return p
end

local lobby=Instance.new("Folder");lobby.Name="Main Entrance Social Lobby";lobby.Parent=root

-- Architectural shell focused around the existing front-lobby zone.
part("Lobby Premium Floor",Vector3.new(116,1.2,50),CFrame.new(0,2,58),C.graphite,Enum.Material.Marble,0,true,lobby)
part("Lobby Ceiling",Vector3.new(116,1,50),CFrame.new(0,23,58),C.black,Enum.Material.Metal,0,true,lobby)
for _,x in ipairs({-55,55}) do
    part("Lobby Side Wall "..x,Vector3.new(2,22,48),CFrame.new(x,12,58),C.black,Enum.Material.Slate,0,true,lobby)
end

-- Hero entrance signage inspired by approved reference.
textSign("Hero BBYA Sign","BBYA",CFrame.new(0,19,81.6),Vector3.new(62,10,.8),C.pink,lobby)
textSign("Hero Social Hub Sign","SOCIAL HUB",CFrame.new(0,12,81.4),Vector3.new(42,4,.7),Color3.fromRGB(255,145,221),lobby)
for _,x in ipairs({-17,-8.5,0,8.5,17}) do
    neon("Crown Spike "..x,Vector3.new(1,5,1),CFrame.new(x,27,81.2)*CFrame.Angles(0,0,math.rad(x/2.7)),C.pink,lobby,22,1.8)
end
neon("Crown Base",Vector3.new(35,.7,.7),CFrame.new(0,24.6,81.2),C.pink,lobby,26,2)

-- Bar as first social destination.
part("Social Bar Counter",Vector3.new(42,4,7),CFrame.new(-25,4.2,54),C.black,Enum.Material.Marble,0,true,lobby)
part("Social Bar Back",Vector3.new(42,12,2),CFrame.new(-25,9,47.5),C.graphite,Enum.Material.Slate,0,true,lobby)
neon("Bar Header Neon",Vector3.new(38,.35,.35),CFrame.new(-25,15.4,48.4),C.pink,lobby,20,1.5)
textSign("Bar Sign","SOCIAL BAR",CFrame.new(-25,12.2,48.4),Vector3.new(25,4,.4),C.pink,lobby)
for i=1,7 do
    local seat=Instance.new("Seat")
    seat.Name="Bar Stool "..i;seat.Size=Vector3.new(2.5,1.2,2.5);seat.CFrame=CFrame.new(-42+(i-1)*5.6,3.1,60);seat.Anchored=true
    seat.Material=Enum.Material.Fabric;seat.Color=Color3.fromRGB(57,38,68);seat.Parent=lobby
end

-- Lounge islands.
for i,center in ipairs({Vector3.new(22,3,53),Vector3.new(38,3,65),Vector3.new(12,3,69)}) do
    local yaw=(i-1)*35
    local cf=CFrame.new(center)*CFrame.Angles(0,math.rad(yaw),0)
    local a=Instance.new("Seat");a.Name="Lounge A "..i;a.Size=Vector3.new(7,1.4,4);a.CFrame=cf*CFrame.new(-5,0,0);a.Anchored=true;a.Material=Enum.Material.Fabric;a.Color=C.purple;a.Parent=lobby
    local b=a:Clone();b.Name="Lounge B "..i;b.CFrame=cf*CFrame.new(5,0,0);b.Parent=lobby
    part("Lounge Table "..i,Vector3.new(6,1,4),cf*CFrame.new(0,.4,-4.2),C.black,Enum.Material.Glass,.12,true,lobby)
    neon("Lounge Underlight "..i,Vector3.new(14,.15,.35),cf*CFrame.new(0,.8,2.5),i%2==0 and C.cyan or C.pink,lobby,11,1.1)
end

-- Decorative planters, giving depth and luxury nightclub feel.
for i,pos in ipairs({Vector3.new(-49,3,69),Vector3.new(49,3,69),Vector3.new(-49,3,50),Vector3.new(49,3,50)}) do
    part("Planter "..i,Vector3.new(8,2.6,8),CFrame.new(pos),C.black,Enum.Material.Slate,0,true,lobby)
    for j=1,5 do
        local leaf=part("Plant "..i.."-"..j,Vector3.new(.9,5,.9),CFrame.new(pos+Vector3.new((j-3)*.7,3.5,(j%2==0) and .8 or -.8))*CFrame.Angles(0,0,math.rad((j-3)*12)),C.green,Enum.Material.SmoothPlastic,0,false,lobby)
        leaf.Shape=Enum.PartType.Cylinder
    end
    neon("Planter Glow "..i,Vector3.new(7,.18,7),CFrame.new(pos+Vector3.new(0,1.4,0)),i%2==0 and C.cyan or C.pink,lobby,12,.8)
end

-- Concierge / wayfinding point.
part("Concierge Desk",Vector3.new(20,4,6),CFrame.new(0,4.2,44),C.black,Enum.Material.Marble,0,true,lobby)
textSign("Concierge Sign","WELCOME TO BBYA",CFrame.new(0,10.5,42),Vector3.new(26,4,.5),C.gold,lobby)
local conciergePrompt=Instance.new("ProximityPrompt")
conciergePrompt.ActionText="Venue Guide";conciergePrompt.ObjectText="BBYA Concierge";conciergePrompt.HoldDuration=0;conciergePrompt.MaxActivationDistance=12;conciergePrompt.Parent=workspace[ROOT_NAME]["Main Entrance Social Lobby"]["Concierge Desk"]

-- Clear navigation gate to club.
textSign("Main Club Wayfinding","MAIN CLUB  →",CFrame.new(42,11,38),Vector3.new(24,4,.5),C.cyan,lobby)
textSign("Rooftop Wayfinding","ROOFTOP POOL PARTY  ↗",CFrame.new(-41,11,38),Vector3.new(29,4,.5),C.pink,lobby)

-- Photo moment with crown frame.
local photo=Instance.new("Folder");photo.Name="BBYA Photo Moment";photo.Parent=lobby
part("Photo Backdrop",Vector3.new(26,17,1),CFrame.new(38,10,78),C.black,Enum.Material.SmoothPlastic,0,true,photo)
neon("Photo Frame Top",Vector3.new(27,.5,.5),CFrame.new(38,18,77.3),C.pink,photo,18,1.5)
neon("Photo Frame L",Vector3.new(.5,17,.5),CFrame.new(25,10,77.3),C.pink,photo,16,1.3)
neon("Photo Frame R",Vector3.new(.5,17,.5),CFrame.new(51,10,77.3),C.cyan,photo,16,1.3)
textSign("Photo Text","BBYA NIGHTS",CFrame.new(38,13.5,77.2),Vector3.new(19,4,.4),C.pink,photo)

-- Premium warm pools of light, balanced against neon.
for _,pos in ipairs({Vector3.new(-40,15,62),Vector3.new(-10,15,62),Vector3.new(18,15,60),Vector3.new(45,15,55)}) do
    local lamp=part("Warm Pendant",Vector3.new(1,1,1),CFrame.new(pos),C.warm,Enum.Material.Neon,0,false,lobby)
    lamp.Shape=Enum.PartType.Ball
    local pl=Instance.new("PointLight");pl.Color=C.warm;pl.Brightness=1.2;pl.Range=15;pl.Shadows=true;pl.Parent=lamp
end

-- Concierge response uses temporary BillboardGui; no disruptive modal UI.
conciergePrompt.Triggered:Connect(function(player)
    local char=player.Character
    local head=char and char:FindFirstChild("Head")
    if not head then return end
    local oldGui=head:FindFirstChild("BBYAGuide")
    if oldGui then oldGui:Destroy() end
    local gui=Instance.new("BillboardGui");gui.Name="BBYAGuide";gui.Size=UDim2.fromOffset(430,110);gui.StudsOffset=Vector3.new(0,3.4,0);gui.AlwaysOnTop=true;gui.Parent=head
    local txt=Instance.new("TextLabel");txt.Size=UDim2.fromScale(1,1);txt.BackgroundColor3=C.black;txt.BackgroundTransparency=.15;txt.TextColor3=Color3.new(1,1,1);txt.TextWrapped=true;txt.Font=Enum.Font.GothamBold;txt.TextScaled=true;txt.Text="MAIN CLUB →   |   ROOFTOP ↗   |   VIP ↑";txt.Parent=gui
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,14);corner.Parent=txt
    task.delay(5,function() if gui and gui.Parent then gui:Destroy() end end)
end)

-- Soft lobby breathing neon animation.
task.spawn(function()
    while root.Parent do
        for _,o in ipairs(root:GetDescendants()) do
            if o:IsA("PointLight") and (o.Parent:IsA("BasePart") and o.Parent.Material==Enum.Material.Neon) then
                TweenService:Create(o,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Brightness=math.max(.5,o.Brightness*.72)}):Play()
            end
        end
        task.wait(1.9)
        for _,o in ipairs(root:GetDescendants()) do
            if o:IsA("PointLight") and (o.Parent:IsA("BasePart") and o.Parent.Material==Enum.Material.Neon) then
                TweenService:Create(o,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Brightness=math.min(2.2,o.Brightness*1.35)}):Play()
            end
        end
        task.wait(1.9)
    end
end)

print("[BBYA] Entrance Social Lobby Polish v1 loaded")
