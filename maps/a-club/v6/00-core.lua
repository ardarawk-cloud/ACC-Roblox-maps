-- BBYA SOCIAL HUB V6 — CLEAN-ROOM PHYSICAL CORE
-- No V5 geometry/runtime names. This file must run first in the V6 architecture assembly.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local ROOT_NAME = "BBYA V6 CLEANROOM"

-- V6 owns only its own root during development. Do not wipe unrelated live geometry here.
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace
root:SetAttribute("BBYABuildFamily","V6")
root:SetAttribute("BBYAProductIdentity","SOCIAL_HUB_FIRST")

local zones = Instance.new("Folder")
zones.Name = "ZONES"
zones.Parent = root

local components = Instance.new("Folder")
components.Name = "COMPONENTS"
components.Parent = root

local P = {
    black=Color3.fromRGB(10,10,14), charcoal=Color3.fromRGB(24,24,30), graphite=Color3.fromRGB(38,38,45),
    stone=Color3.fromRGB(65,63,66), stone2=Color3.fromRGB(83,80,82), concrete=Color3.fromRGB(106,103,105),
    pink=Color3.fromRGB(255,38,182), cyan=Color3.fromRGB(28,218,255), violet=Color3.fromRGB(130,65,245),
    gold=Color3.fromRGB(255,197,82), warm=Color3.fromRGB(255,174,106), cream=Color3.fromRGB(231,222,208),
    wood=Color3.fromRGB(111,76,50), leaf=Color3.fromRGB(39,92,59), water=Color3.fromRGB(35,151,193),
    glass=Color3.fromRGB(128,184,199), white=Color3.fromRGB(246,243,246),
}

local function zone(code,name,level,center,size)
    local f=Instance.new("Folder")
    f.Name=string.format("[%s] %s",code,name)
    f:SetAttribute("BBYAZoneCode",code)
    f:SetAttribute("BBYAZoneName",name)
    f:SetAttribute("BBYALevel",level)
    f:SetAttribute("BBYACenterX",center.X);f:SetAttribute("BBYACenterY",center.Y);f:SetAttribute("BBYACenterZ",center.Z)
    f:SetAttribute("BBYASizeX",size.X);f:SetAttribute("BBYASizeY",size.Y);f:SetAttribute("BBYASizeZ",size.Z)
    f.Parent=zones
    return f
end

local function component(parent,code,name,center,size)
    local f=Instance.new("Folder")
    f.Name=string.format("[%s] %s",code,name)
    f:SetAttribute("BBYAComponentCode",code)
    f:SetAttribute("BBYAComponentName",name)
    f:SetAttribute("BBYAZoneCode",parent:GetAttribute("BBYAZoneCode"))
    f:SetAttribute("BBYAZoneName",parent:GetAttribute("BBYAZoneName"))
    f:SetAttribute("BBYACenterX",center.X);f:SetAttribute("BBYACenterY",center.Y);f:SetAttribute("BBYACenterZ",center.Z)
    f:SetAttribute("BBYASizeX",size.X);f:SetAttribute("BBYASizeY",size.Y);f:SetAttribute("BBYASizeZ",size.Z)
    f.Parent=components
    return f
end

local function tag(obj,parent,componentCode)
    if parent then
        obj:SetAttribute("BBYAZoneCode",parent:GetAttribute("BBYAZoneCode"))
        obj:SetAttribute("BBYAZoneName",parent:GetAttribute("BBYAZoneName"))
    end
    if componentCode then obj:SetAttribute("BBYAComponentCode",componentCode) end
    return obj
end

local function part(parent,name,size,cf,color,material,transparency,collide,componentCode)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size;p.CFrame=cf;p.Anchored=true
    p.CanCollide=collide~=false;p.CanTouch=false;p.CanQuery=true
    p.Color=color or P.stone;p.Material=material or Enum.Material.SmoothPlastic
    p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return tag(p,parent,componentCode)
end

local function floor(parent,name,size,center,color,material,componentCode)
    return part(parent,name,size,CFrame.new(center),color or P.stone,material or Enum.Material.Concrete,0,true,componentCode)
end

local function wallX(parent,name,z,x1,x2,y,h,t,color,componentCode)
    return part(parent,name,Vector3.new(math.abs(x2-x1),h,t or 2),CFrame.new((x1+x2)/2,y,z),color or P.charcoal,Enum.Material.Concrete,0,true,componentCode)
end

local function wallZ(parent,name,x,z1,z2,y,h,t,color,componentCode)
    return part(parent,name,Vector3.new(t or 2,h,math.abs(z2-z1)),CFrame.new(x,y,(z1+z2)/2),color or P.charcoal,Enum.Material.Concrete,0,true,componentCode)
end

local function glass(parent,name,size,cf,componentCode)
    local p=part(parent,name,size,cf,P.glass,Enum.Material.Glass,.48,true,componentCode)
    p.Reflectance=.04
    return p
end

local function neon(parent,name,size,cf,color,componentCode)
    local p=part(parent,name,size,cf,color or P.pink,Enum.Material.Neon,0,false,componentCode)
    p.CanQuery=false
    return p
end

local function light(parent,name,pos,color,brightness,range,componentCode)
    local anchor=part(parent,name.." ANCHOR",Vector3.new(.35,.35,.35),CFrame.new(pos),color or P.warm,Enum.Material.SmoothPlastic,1,false,componentCode)
    local l=Instance.new("PointLight")
    l.Name=name;l.Color=color or P.warm;l.Brightness=brightness or 1.2;l.Range=range or 18;l.Shadows=false;l.Parent=anchor
    return l
end

local function sign(parent,name,text,cf,size,color,face,componentCode)
    local board=part(parent,name,size,cf,P.black,Enum.Material.SmoothPlastic,0,false,componentCode)
    local gui=Instance.new("SurfaceGui")
    gui.Face=face or Enum.NormalId.Front;gui.LightInfluence=0
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=28;gui.Parent=board
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text
    t.TextColor3=color or P.white;t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.TextWrapped=true;t.Parent=gui
    return board
end

local function twoFaceSign(parent,name,frontText,backText,cf,size,color,componentCode)
    local board=sign(parent,name,frontText,cf,size,color,Enum.NormalId.Front,componentCode)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Back;gui.LightInfluence=0;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=28;gui.Parent=board
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=backText
    t.TextColor3=color or P.white;t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.TextWrapped=true;t.Parent=gui
    board:SetAttribute("BBYADoubleSidedSign",true)
    return board
end

local function doorwayWallX(parent,name,z,x1,x2,doorCenter,doorWidth,y,h,t,color,componentCode)
    local leftEnd=doorCenter-doorWidth/2
    local rightStart=doorCenter+doorWidth/2
    if leftEnd>x1 then wallX(parent,name.." LEFT",z,x1,leftEnd,y,h,t,color,componentCode) end
    if rightStart<x2 then wallX(parent,name.." RIGHT",z,rightStart,x2,y,h,t,color,componentCode) end
    local lintelH=math.max(1.5,h-9)
    part(parent,name.." LINTEL",Vector3.new(doorWidth,lintelH,t or 2),CFrame.new(doorCenter,y+(h-lintelH)/2,z),color or P.charcoal,Enum.Material.Concrete,0,true,componentCode)
end

local function doorwayWallZ(parent,name,x,z1,z2,doorCenter,doorWidth,y,h,t,color,componentCode)
    local a=doorCenter-doorWidth/2;local b=doorCenter+doorWidth/2
    if a>z1 then wallZ(parent,name.." A",x,z1,a,y,h,t,color,componentCode) end
    if b<z2 then wallZ(parent,name.." B",x,b,z2,y,h,t,color,componentCode) end
    local lintelH=math.max(1.5,h-9)
    part(parent,name.." LINTEL",Vector3.new(t or 2,lintelH,doorWidth),CFrame.new(x,y+(h-lintelH)/2,doorCenter),color or P.charcoal,Enum.Material.Concrete,0,true,componentCode)
end

local function sofa(parent,name,center,width,yaw,color,componentCode)
    local cf=CFrame.new(center)*CFrame.Angles(0,math.rad(yaw or 0),0)
    part(parent,name.." SEAT",Vector3.new(width,1.15,4),cf,color or P.graphite,Enum.Material.Fabric,0,true,componentCode)
    part(parent,name.." BACK",Vector3.new(width,3,1),cf*CFrame.new(0,1.65,1.5),color or P.graphite,Enum.Material.Fabric,0,true,componentCode)
    part(parent,name.." ARM L",Vector3.new(1,2,4),cf*CFrame.new(-width/2+.5,.5,0),color or P.graphite,Enum.Material.Fabric,0,true,componentCode)
    part(parent,name.." ARM R",Vector3.new(1,2,4),cf*CFrame.new(width/2-.5,.5,0),color or P.graphite,Enum.Material.Fabric,0,true,componentCode)
end

local function tableLow(parent,name,center,size,color,componentCode)
    part(parent,name.." TOP",size or Vector3.new(6,.6,4),CFrame.new(center),color or P.black,Enum.Material.SmoothPlastic,0,true,componentCode)
end

local function bar(parent,name,center,size,yaw,componentCode)
    local cf=CFrame.new(center)*CFrame.Angles(0,math.rad(yaw or 0),0)
    part(parent,name.." BODY",size,cf,P.graphite,Enum.Material.Slate,0,true,componentCode)
    part(parent,name.." TOP",Vector3.new(size.X+.5,.35,size.Z+.5),cf*CFrame.new(0,size.Y/2+.18,0),P.wood,Enum.Material.WoodPlanks,0,true,componentCode)
    neon(parent,name.." WARM LINE",Vector3.new(size.X-.6,.14,.14),cf*CFrame.new(0,-.5,-size.Z/2-.1),P.warm,componentCode)
end

local function planter(parent,name,center,size,componentCode)
    local s=size or Vector3.new(5,2,5)
    part(parent,name.." BOX",s,CFrame.new(center),P.charcoal,Enum.Material.Slate,0,true,componentCode)
    part(parent,name.." SOIL",Vector3.new(s.X-.5,.2,s.Z-.5),CFrame.new(center+Vector3.new(0,s.Y/2+.08,0)),Color3.fromRGB(43,31,25),Enum.Material.Ground,0,false,componentCode)
end

local function palm(parent,name,center,height,componentCode)
    height=height or 10
    planter(parent,name.." PLANTER",center,Vector3.new(5,2,5),componentCode)
    local trunk=part(parent,name.." TRUNK",Vector3.new(height,1.1,1.1),CFrame.new(center+Vector3.new(0,height/2+1,0))*CFrame.Angles(0,0,math.rad(90)),P.wood,Enum.Material.Wood,0,true,componentCode)
    trunk.Shape=Enum.PartType.Cylinder
    local crown=center+Vector3.new(0,height+1,0)
    for i=0,5 do
        local a=math.rad(i*60)
        part(parent,name.." LEAF "..i,Vector3.new(7,.35,1.2),CFrame.new(crown)*CFrame.Angles(0,a,math.rad(-8))*CFrame.new(3,0,0),P.leaf,Enum.Material.SmoothPlastic,0,false,componentCode)
    end
end

local function stairFlight(parent,name,startCF,steps,width,rise,run,componentCode)
    for i=0,steps-1 do
        part(parent,name.." STEP "..i,Vector3.new(width,rise+.08,run+.08),startCF*CFrame.new(0,rise*i,-run*i),P.stone2,Enum.Material.Concrete,0,true,componentCode)
    end
end

local function clearPad(parent,name,position,size,componentCode)
    local p=part(parent,name,size or Vector3.new(10,.12,10),CFrame.new(position),Color3.fromRGB(70,190,120),Enum.Material.SmoothPlastic,.72,false,componentCode)
    p:SetAttribute("BBYAClearLanding",true)
    return p
end

-- V6 lighting baseline: readable social venue, not a black void.
Lighting.ClockTime=19.2
Lighting.Brightness=3.2
Lighting.ExposureCompensation=.18
Lighting.Ambient=Color3.fromRGB(105,96,110)
Lighting.OutdoorAmbient=Color3.fromRGB(82,82,94)
Lighting.FogStart=2200;Lighting.FogEnd=5000

workspace:SetAttribute("BBYAV6Status","CLEANROOM_DEVELOPMENT")
workspace:SetAttribute("BBYAV6Root",ROOT_NAME)
