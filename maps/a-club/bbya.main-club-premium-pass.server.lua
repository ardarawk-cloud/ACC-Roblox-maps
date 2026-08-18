-- BBYA SOCIAL HUB — MAIN CLUB PREMIUM PASS v1
-- Premium density and dance-floor experience layer.
local TweenService = game:GetService("TweenService")

local ROOT = "BBYA Main Club Premium Pass v1"
local old = workspace:FindFirstChild(ROOT)
if old then old:Destroy() end
local root = Instance.new("Folder")
root.Name = ROOT
root.Parent = workspace

local C = {
    black = Color3.fromRGB(10,10,16),
    charcoal = Color3.fromRGB(24,24,34),
    blue = Color3.fromRGB(30,145,255),
    cyan = Color3.fromRGB(40,235,255),
    pink = Color3.fromRGB(255,45,165),
    purple = Color3.fromRGB(115,65,220),
    gold = Color3.fromRGB(255,190,75),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
    local p=Instance.new("Part")
    p.Name=name; p.Size=size; p.CFrame=cf; p.Anchored=true; p.CanCollide=collide~=false
    p.Color=color or C.charcoal; p.Material=material or Enum.Material.SmoothPlastic; p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent or root
    return p
end

local function neon(name,size,cf,color,parent)
    local p=part(name,size,cf,color,Enum.Material.Neon,0,false,parent)
    local l=Instance.new("PointLight"); l.Color=color; l.Brightness=1.4; l.Range=16; l.Shadows=false; l.Parent=p
    return p
end

local function sign(name,text,cf,size,color,parent)
    local b=part(name,size,cf,C.black,Enum.Material.SmoothPlastic,0,false,parent)
    local sg=Instance.new("SurfaceGui"); sg.Face=Enum.NormalId.Front; sg.PixelsPerStud=30; sg.Parent=b
    local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Font=Enum.Font.GothamBlack
    t.Text=text; t.TextScaled=true; t.TextColor3=color or C.pink; t.TextStrokeTransparency=.3; t.Parent=sg
    return b
end

local main=Instance.new("Folder"); main.Name="Premium Main Club"; main.Parent=root

-- Dance floor: large, open, readable, premium frame
part("Dance Floor Base",Vector3.new(104,1.2,62),CFrame.new(0,1,-13),C.black,Enum.Material.Marble,0,true,main)
for x=-42,42,14 do
    for z=-34,8,14 do
        neon("Floor Pixel "..x.." "..z,Vector3.new(8,.12,8),CFrame.new(x,1.7,z),((x+z)/14)%2==0 and C.pink or C.blue,main)
    end
end

-- perimeter strips keep center clear
for _,x in ipairs({-51,51}) do
    neon("Floor Edge "..x,Vector3.new(.4,.25,60),CFrame.new(x,2,-13),x<0 and C.blue or C.pink,main)
end
neon("Floor Front Edge",Vector3.new(102,.25,.4),CFrame.new(0,2,17),C.cyan,main)

-- first-impact stage reveal
part("Stage Premium Deck",Vector3.new(82,3,18),CFrame.new(0,3,-56),C.charcoal,Enum.Material.Metal,0,true,main)
sign("Stage Hero Sign","BBYA • NIGHT SYSTEM",CFrame.new(0,19,-65),Vector3.new(60,7,.7),C.pink,main)
part("DJ Booth Premium",Vector3.new(28,5,8),CFrame.new(0,6,-50),C.black,Enum.Material.Metal,0,true,main)
neon("DJ Booth Front",Vector3.new(22,.7,.4),CFrame.new(0,7.5,-45.8),C.cyan,main)

-- stage side towers / pixel bars
for _,x in ipairs({-42,42}) do
    part("Stage Tower "..x,Vector3.new(10,23,10),CFrame.new(x,12,-58),C.black,Enum.Material.Metal,0,true,main)
    for y=4,20,4 do
        neon("Stage Tower Pixel "..x.." "..y,Vector3.new(7,.55,.4),CFrame.new(x,y,-52.8),y%8==0 and C.pink or C.cyan,main)
    end
end

-- overhead truss with animated moving beams
for _,z in ipairs({-40,-24,-8,8}) do
    part("Premium Truss "..z,Vector3.new(104,.65,.65),CFrame.new(0,25,z),C.black,Enum.Material.Metal,0,false,main)
    for _,x in ipairs({-40,-20,0,20,40}) do
        local lamp=neon("Beam Head "..x.." "..z,Vector3.new(1.8,1.3,1.8),CFrame.new(x,24,z),((x+z)%40==0) and C.pink or C.blue,main)
        local s=Instance.new("SpotLight"); s.Face=Enum.NormalId.Bottom; s.Angle=38; s.Range=62; s.Brightness=3.6; s.Color=lamp.Color; s.Shadows=false; s.Parent=lamp
        task.spawn(function()
            while lamp.Parent do
                TweenService:Create(lamp,TweenInfo.new(2.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Orientation=Vector3.new(0,0,15)}):Play()
                task.wait(2.8)
                TweenService:Create(lamp,TweenInfo.new(2.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Orientation=Vector3.new(0,0,-15)}):Play()
                task.wait(2.8)
            end
        end)
    end
end

-- side lounges: premium but do not choke dance floor
for side=-1,1,2 do
    local x=side*66
    for _,z in ipairs({-34,-12,10}) do
        local pod=Instance.new("Folder"); pod.Name=(side<0 and "West" or "East").." Lounge "..z; pod.Parent=main
        part("Deck",Vector3.new(22,1.4,16),CFrame.new(x,3,z),C.charcoal,Enum.Material.WoodPlanks,0,true,pod)
        local s1=Instance.new("Seat"); s1.Name="Sofa A"; s1.Size=Vector3.new(7,1.4,4); s1.CFrame=CFrame.new(x-side*5,4,z); s1.Anchored=true; s1.Color=C.purple; s1.Material=Enum.Material.Fabric; s1.Parent=pod
        local s2=s1:Clone(); s2.Name="Sofa B"; s2.CFrame=CFrame.new(x+side*5,4,z); s2.Parent=pod
        part("Table",Vector3.new(5,1,5),CFrame.new(x,4,z-4),C.black,Enum.Material.Glass,.15,true,pod)
        neon("Pod Accent",Vector3.new(18,.18,.3),CFrame.new(x,5.3,z+6.8),side<0 and C.blue or C.pink,pod)
    end
end

-- VIP split: raised premium rails, keeps public path separate
for _,x in ipairs({-74,74}) do
    part("VIP Raised Deck "..x,Vector3.new(18,2,54),CFrame.new(x,10,-14),C.charcoal,Enum.Material.Slate,0,true,main)
    part("VIP Glass "..x,Vector3.new(1,6,52),CFrame.new(x-(x>0 and 9 or -9),14,-14),Color3.fromRGB(65,90,120),Enum.Material.Glass,.5,true,main)
    sign("VIP Sign "..x,"VIP",CFrame.new(x,17,13),Vector3.new(12,4,.5),C.gold,main)
end

-- focal social ring behind the dance floor
local ring=Instance.new("Folder"); ring.Name="Social Ring"; ring.Parent=main
for i=0,7 do
    local a=math.rad(i*45)
    local x=math.cos(a)*43
    local z=math.sin(a)*18+21
    local table=part("Social Table "..i,Vector3.new(4,2,4),CFrame.new(x,3,z),C.black,Enum.Material.Glass,.1,true,ring)
    neon("Table Glow "..i,Vector3.new(3.4,.12,3.4),table.CFrame*CFrame.new(0,1.05,0),i%2==0 and C.pink or C.blue,ring)
end

-- stage approach runway: centered visual guide
for z=-40,-4,6 do
    neon("Stage Guide "..z,Vector3.new(1.2,.15,4),CFrame.new(0,1.75,z),z%12==0 and C.pink or C.cyan,main)
end

print("[BBYA] Main Club Premium Pass v1 loaded")
