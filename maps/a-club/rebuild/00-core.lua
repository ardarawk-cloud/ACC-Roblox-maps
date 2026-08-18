-- BBYA SOCIAL HUB — CLEAN REBUILD CORE
-- Fresh runtime. No legacy BBYA geometry or UI is reused.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

for _,child in ipairs(workspace:GetChildren()) do
    if not child:IsA("Terrain") and not child:IsA("Camera") then
        child:Destroy()
    end
end

local ROOT = Instance.new("Folder")
ROOT.Name = "BBYA CLEAN REBUILD"
ROOT.Parent = workspace
ROOT:SetAttribute("BuildFamily","BBYA_CLEAN_REBUILD")
ROOT:SetAttribute("Reference","OWNER_IMAGE_1")
ROOT:SetAttribute("Status","PHASE_5_REFERENCE_UI_QC")

local Z = {}
local function zone(name)
    local f=Instance.new("Folder")
    f.Name=name
    f.Parent=ROOT
    Z[name]=f
    return f
end

local A1=zone("01 ARRIVAL PLAZA")
local A2=zone("02 SOCIAL ATRIUM")
local A3=zone("03 MAIN CLUB")
local A4=zone("04 LEFT SOCIAL MEZZANINES")
local A5=zone("05 VIP WING")
local A6=zone("06 ROOFTOP POOL")
local A7=zone("07 QUEEN SUPPORT COURT")
local A8=zone("08 CITY BACKDROP")

local C={
    black=Color3.fromRGB(9,10,16),
    charcoal=Color3.fromRGB(23,24,33),
    graphite=Color3.fromRGB(38,40,52),
    stone=Color3.fromRGB(62,61,72),
    pink=Color3.fromRGB(255,42,174),
    magenta=Color3.fromRGB(229,42,255),
    cyan=Color3.fromRGB(35,206,255),
    blue=Color3.fromRGB(41,108,255),
    violet=Color3.fromRGB(117,63,235),
    gold=Color3.fromRGB(255,192,82),
    warm=Color3.fromRGB(255,170,104),
    cream=Color3.fromRGB(235,225,218),
    glass=Color3.fromRGB(83,142,176),
    water=Color3.fromRGB(35,149,210),
    wood=Color3.fromRGB(106,72,50),
    green=Color3.fromRGB(40,105,66),
    white=Color3.fromRGB(245,245,248),
}

local function part(parent,name,size,cf,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Anchored=true
    p.CanCollide=collide~=false
    p.CanTouch=false
    p.CanQuery=true
    p.Color=color or C.stone
    p.Material=material or Enum.Material.SmoothPlastic
    p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function neon(parent,name,size,cf,color)
    local p=part(parent,name,size,cf,color or C.pink,Enum.Material.Neon,0,false)
    p.CanQuery=false
    return p
end

local function glass(parent,name,size,cf,transparency)
    local p=part(parent,name,size,cf,C.glass,Enum.Material.Glass,transparency or .42,true)
    p.Reflectance=.05
    return p
end

local function light(parent,name,pos,color,brightness,range)
    local a=part(parent,name.." ANCHOR",Vector3.new(.3,.3,.3),CFrame.new(pos),color or C.white,Enum.Material.SmoothPlastic,1,false)
    local l=Instance.new("PointLight")
    l.Name=name
    l.Color=color or C.white
    l.Brightness=brightness or 1
    l.Range=range or 18
    l.Shadows=false
    l.Parent=a
    return l
end

local function sign(parent,name,text,cf,size,color,face)
    local b=part(parent,name,size,cf,C.black,Enum.Material.SmoothPlastic,0,false)
    local gui=Instance.new("SurfaceGui")
    gui.Name="DISPLAY"
    gui.Face=face or Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=36
    gui.LightInfluence=0
    gui.Parent=b
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1
    t.Size=UDim2.fromScale(1,1)
    t.Text=text
    t.TextScaled=true
    t.TextWrapped=true
    t.Font=Enum.Font.GothamBlack
    t.TextColor3=color or C.white
    t.TextStrokeTransparency=.5
    t.Parent=gui
    return b
end

local function seat(parent,name,cf,width,color)
    local s=Instance.new("Seat")
    s.Name=name
    s.Size=Vector3.new(width or 5,1.1,4)
    s.CFrame=cf
    s.Anchored=true
    s.Color=color or C.graphite
    s.Material=Enum.Material.Fabric
    s.Parent=parent
    s:SetAttribute("BBYASocialSeat",true)
    part(parent,name.." BACK",Vector3.new(width or 5,3,1),cf*CFrame.new(0,1.5,1.5),color or C.graphite,Enum.Material.Fabric,0,true)
    return s
end

local function tableLow(parent,name,cf,size)
    return part(parent,name,size or Vector3.new(5,.6,4),cf,C.black,Enum.Material.Glass,.08,true)
end

local function rail(parent,name,size,cf)
    return glass(parent,name,size,cf,.5)
end

local function palm(parent,name,pos,height)
    height=height or 12
    local trunk=part(parent,name.." TRUNK",Vector3.new(1.2,height,1.2),CFrame.new(pos+Vector3.new(0,height/2,0)),Color3.fromRGB(89,59,39),Enum.Material.Wood,0,true)
    for i=0,5 do
        local a=math.rad(i*60)
        part(parent,name.." LEAF "..i,Vector3.new(1,.35,9),CFrame.new(pos+Vector3.new(0,height,0))*CFrame.Angles(0,a,math.rad(-18))*CFrame.new(0,0,-3.5),C.green,Enum.Material.SmoothPlastic,0,false)
    end
    return trunk
end

local function stair(parent,name,startPos,steps,width,rise,run,yaw,color)
    local base=CFrame.new(startPos)*CFrame.Angles(0,math.rad(yaw or 0),0)
    for i=0,steps-1 do
        part(parent,name.." STEP "..i,Vector3.new(width,rise+.08,run+.08),base*CFrame.new(0,rise*i,-run*i),color or C.stone,Enum.Material.Slate,0,true)
    end
end

Lighting.ClockTime=0.1
Lighting.Brightness=2.7
Lighting.ExposureCompensation=.22
Lighting.Ambient=Color3.fromRGB(72,70,92)
Lighting.OutdoorAmbient=Color3.fromRGB(40,46,72)
Lighting.FogColor=Color3.fromRGB(16,20,39)
Lighting.FogStart=450
Lighting.FogEnd=1800
Lighting.ShadowSoftness=.35
pcall(function() Lighting.Technology=Enum.Technology.Future end)

for _,o in ipairs(Lighting:GetChildren()) do
    if o.Name:match("^BBYA ") then o:Destroy() end
end
local atmosphere=Instance.new("Atmosphere")
atmosphere.Name="BBYA ATMOSPHERE"
atmosphere.Density=.28
atmosphere.Offset=.08
atmosphere.Color=Color3.fromRGB(92,104,152)
atmosphere.Decay=Color3.fromRGB(28,18,54)
atmosphere.Glare=.08
atmosphere.Haze=1.4
atmosphere.Parent=Lighting
local bloom=Instance.new("BloomEffect")
bloom.Name="BBYA BLOOM"
bloom.Intensity=.72
bloom.Size=32
bloom.Threshold=1.15
bloom.Parent=Lighting
local grade=Instance.new("ColorCorrectionEffect")
grade.Name="BBYA GRADE"
grade.Brightness=.02
grade.Contrast=.08
grade.Saturation=.08
grade.TintColor=Color3.fromRGB(232,225,255)
grade.Parent=Lighting

workspace:SetAttribute("BBYACleanRebuild",true)
workspace:SetAttribute("BBYAReferenceImage1",true)
workspace:SetAttribute("BBYABuildPhase","PHASE_5_REFERENCE_UI_QC")
