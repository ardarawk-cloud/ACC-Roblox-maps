local Workspace=game:GetService("Workspace")

-- TRACK 01 v3.5 END OF LINE hero-room pass.
-- Visual-only railway control-room detailing. No uploaded assets/audio; all geometry non-collidable.
local deadline=os.clock()+55
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_STEAM_FOG_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_EndOfLineHero_v35")
if old then old:Destroy() end
local hero=Instance.new("Folder")
hero.Name="TRACK01_EndOfLineHero_v35"
hero.Parent=world

local C={
    black=Color3.fromRGB(14,15,15),
    charcoal=Color3.fromRGB(27,28,28),
    steel=Color3.fromRGB(80,82,80),
    steel2=Color3.fromRGB(122,121,114),
    red=Color3.fromRGB(181,40,36),
    redDark=Color3.fromRGB(72,22,22),
    amber=Color3.fromRGB(211,143,69),
    green=Color3.fromRGB(77,132,83),
    cream=Color3.fromRGB(192,177,146),
    glass=Color3.fromRGB(45,52,53),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end

local function part(parent,name,size,frame,color,material,transparency,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.steel
    p.Material=material or Enum.Material.Metal
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function cylinder(parent,name,size,frame,color,material,transparency)
    return part(parent,name,size,frame,color,material,transparency,Enum.PartType.Cylinder)
end

local function ball(parent,name,size,frame,color,material,transparency)
    return part(parent,name,size,frame,color,material,transparency,Enum.PartType.Ball)
end

local function surfaceText(target,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="EndLineSignage"
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=52
    gui.LightInfluence=0.18
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bgColor or C.black
    label.BackgroundTransparency=0.05
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=font or Enum.Font.GothamBlack
    label.Parent=gui
    return label
end

-- Rear-wall hero sign: large enough to read from the dance floor but still inside railway language.
local backplate=part(hero,"EndOfLineHeroBackplate",Vector3.new(13.2,4.4,0.26),cf(22,12.15,122.7),C.black,Enum.Material.Metal,0)
surfaceText(backplate,"END OF LINE\nNO FURTHER SERVICE",C.red,C.black,Enum.Font.GothamBlack)
part(hero,"HeroSignTopRail",Vector3.new(14.2,0.18,0.30),cf(22,14.5,122.62),C.steel2,Enum.Material.Metal,0)
part(hero,"HeroSignBottomRail",Vector3.new(14.2,0.18,0.30),cf(22,9.80,122.62),C.steel2,Enum.Material.Metal,0)

-- Booth edge lighting: restrained red/amber railway-control glow, never crossing the aisle.
part(hero,"DJBoothEdgeGlow",Vector3.new(10.8,0.10,0.20),cf(22,7.0,115.45),C.red,Enum.Material.Neon,0.18)
part(hero,"DJBoothFootGlow",Vector3.new(9.8,0.08,0.18),cf(22,5.25,115.62),C.amber,Enum.Material.Neon,0.34)
for _,x in ipairs({16.5,27.5}) do
    part(hero,"BoothSideMarker",Vector3.new(0.12,2.2,0.22),cf(x,6.25,115.5),C.red,Enum.Material.Neon,0.24)
end

-- Analog gauge cluster inspired by old railway electrical/control panels.
local gaugeCenters={18.5,20.8,23.2,25.5}
for i,x in ipairs(gaugeCenters) do
    cylinder(hero,"AnalogGaugeBezel",Vector3.new(0.22,2.15,2.15),cf(x,11.0,119.45,0,90,0),C.steel2,Enum.Material.Metal,0)
    cylinder(hero,"AnalogGaugeFace",Vector3.new(0.13,1.72,1.72),cf(x,11.0,119.31,0,90,0),C.glass,Enum.Material.Glass,0.12)
    local angle=(-55)+(i-1)*31
    part(hero,"GaugeNeedle",Vector3.new(0.08,0.10,0.72),cf(x,11.0,119.19,0,0,angle),C.red,Enum.Material.Neon,0.10)
    local tickColor=(i%2==0) and C.amber or C.cream
    part(hero,"GaugeTick",Vector3.new(0.08,0.12,0.32),cf(x,11.62,119.18,0,0,0),tickColor,Enum.Material.Neon,0.25)
end

-- Horizontal switch banks and old-style relay modules.
for row=0,1 do
    for col=0,5 do
        local x=17.4+col*1.85
        local y=8.6-row*1.35
        part(hero,"RelayModule",Vector3.new(1.25,0.85,0.24),cf(x,y,119.22),C.charcoal,Enum.Material.Metal,0)
        local colr=((col+row)%3==0) and C.red or (((col+row)%3==1) and C.amber or C.green)
        local lamp=ball(hero,"RelayLamp",Vector3.new(0.30,0.30,0.20),cf(x,y+0.16,119.03),colr,Enum.Material.Neon,0.14)
        local light=Instance.new("PointLight")
        light.Name="HeroPanelGlow"
        light.Color=colr
        light.Brightness=0.08
        light.Range=2.2
        light.Shadows=false
        light.Parent=lamp
    end
end

-- Overhead signal bar, visually connecting the DJ with the railway control-room theme.
part(hero,"OverheadSignalBar",Vector3.new(11.5,0.30,0.40),cf(22,14.25,116.6),C.charcoal,Enum.Material.Metal,0)
local overheadLamps={}
for i,x in ipairs({18.2,20.1,22.0,23.9,25.8}) do
    local color=({C.red,C.amber,C.green,C.amber,C.red})[i]
    local lens=ball(hero,"OverheadSignalLens",Vector3.new(0.72,0.72,0.32),cf(x,14.10,116.35),color,Enum.Material.Neon,0.12)
    local l=Instance.new("PointLight")
    l.Name="OverheadSignalGlow"
    l.Color=color
    l.Brightness=0.12
    l.Range=3.5
    l.Shadows=false
    l.Parent=lens
    table.insert(overheadLamps,{lens=lens,light=l})
end

-- Cable trays and small control-room construction detail against the side/rear wall.
for _,x in ipairs({16.2,27.8}) do
    part(hero,"HeroCableTray",Vector3.new(0.28,0.42,8.2),cf(x,12.8,118.6),C.black,Enum.Material.Metal,0)
    for z=116.0,121.0,1.25 do
        cylinder(hero,"ControlCable",Vector3.new(2.2,0.10,0.10),cf(x,12.2,z,0,0,90),C.black,Enum.Material.SmoothPlastic,0)
    end
end

-- Slow staged pulse: hero ambience, not a strobe.
task.spawn(function()
    local index=1
    while hero.Parent do
        for i,item in ipairs(overheadLamps) do
            local active=(i==index) or (i==6-index)
            item.lens.Transparency=active and 0.02 or 0.38
            item.light.Brightness=active and 0.20 or 0.05
        end
        index=index+1
        if index>5 then index=1 end
        task.wait(2.4)
    end
end)

root:SetAttribute("EndOfLineHeroVersion","3.5.0")
Workspace:SetAttribute("ACC_TRACK01_ENDLINE_HERO_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.5.0")
print("[TRACK 01] END OF LINE hero room ready v3.5.0")
