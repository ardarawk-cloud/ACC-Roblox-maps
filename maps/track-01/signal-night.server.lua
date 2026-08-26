local Workspace=game:GetService("Workspace")

-- TRACK 01 v3.3 railway signal + night-atmosphere pass.
-- Physical/visual only. All new parts are non-collidable/non-touching/non-queryable.
local deadline=os.clock()+55
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_INTERACTIVE_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end

local old=world:FindFirstChild("TRACK01_SignalNight_v33")
if old then old:Destroy() end
local folder=Instance.new("Folder")
folder.Name="TRACK01_SignalNight_v33"
folder.Parent=world

local mainSignals=Instance.new("Folder"); mainSignals.Name="MainRailSignals"; mainSignals.Parent=folder
local platformSignals=Instance.new("Folder"); platformSignals.Name="PlatformSignals"; platformSignals.Parent=folder
local restrictedSignals=Instance.new("Folder"); restrictedSignals.Name="RestrictedWarningSignals"; restrictedSignals.Parent=folder
local yardSignals=Instance.new("Folder"); yardSignals.Name="YardSignalPhotoSpot"; yardSignals.Parent=folder

local C={
    black=Color3.fromRGB(16,17,17),
    charcoal=Color3.fromRGB(30,31,31),
    steel=Color3.fromRGB(78,80,78),
    steel2=Color3.fromRGB(112,113,108),
    rust=Color3.fromRGB(74,42,34),
    red=Color3.fromRGB(190,45,38),
    amber=Color3.fromRGB(222,151,67),
    green=Color3.fromRGB(78,135,82),
    redOff=Color3.fromRGB(66,24,22),
    amberOff=Color3.fromRGB(70,48,24),
    greenOff=Color3.fromRGB(28,55,31),
    cream=Color3.fromRGB(184,170,141),
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

local function textSign(parent,name,size,frame,text,textColor)
    local sign=part(parent,name,size,frame,C.black,Enum.Material.Metal,0)
    local gui=Instance.new("SurfaceGui")
    gui.Name="SignalSignage"
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=44
    gui.LightInfluence=0.25
    gui.Parent=sign
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=C.black
    label.BackgroundTransparency=0.08
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=Enum.Font.RobotoMono
    label.Parent=gui
    return sign
end

local function makeLens(parent,name,pos,color,offColor,brightness,range)
    local lens=ball(parent,name,Vector3.new(1.5,1.5,0.62),pos,offColor,Enum.Material.Glass,0.08)
    local light=Instance.new("PointLight")
    light.Name="SignalGlow"
    light.Color=color
    light.Brightness=brightness or 0.38
    light.Range=range or 7
    light.Shadows=false
    light.Enabled=false
    light.Parent=lens
    lens:SetAttribute("ActiveColorR",math.floor(color.R*255+0.5))
    lens:SetAttribute("ActiveColorG",math.floor(color.G*255+0.5))
    lens:SetAttribute("ActiveColorB",math.floor(color.B*255+0.5))
    lens:SetAttribute("OffColorR",math.floor(offColor.R*255+0.5))
    lens:SetAttribute("OffColorG",math.floor(offColor.G*255+0.5))
    lens:SetAttribute("OffColorB",math.floor(offColor.B*255+0.5))
    return lens
end

local function setLens(lens,on)
    local glow=lens:FindFirstChild("SignalGlow")
    local active=Color3.fromRGB(lens:GetAttribute("ActiveColorR"),lens:GetAttribute("ActiveColorG"),lens:GetAttribute("ActiveColorB"))
    local off=Color3.fromRGB(lens:GetAttribute("OffColorR"),lens:GetAttribute("OffColorG"),lens:GetAttribute("OffColorB"))
    lens.Color=on and active or off
    lens.Material=on and Enum.Material.Neon or Enum.Material.Glass
    if glow then glow.Enabled=on end
end

local function makeThreeAspect(parent,name,x,z,height,scale,label)
    local model=Instance.new("Folder")
    model.Name=name
    model.Parent=parent
    local s=scale or 1
    cylinder(model,"SignalMast",Vector3.new(height,0.54*s,0.54*s),cf(x,height/2+0.6,z,0,0,90),C.steel,Enum.Material.CorrodedMetal,0)
    part(model,"SignalBase",Vector3.new(2.4*s,0.45,2.4*s),cf(x,0.72,z),C.rust,Enum.Material.CorrodedMetal,0)
    part(model,"SignalHead",Vector3.new(3.4*s,7.1*s,1.55*s),cf(x,height-1.3*s,z),C.black,Enum.Material.Metal,0)
    for _,dy in ipairs({2.25*s,0,-2.25*s}) do
        part(model,"LensHood",Vector3.new(2.4*s,0.24,1.7*s),cf(x,height-1.3*s+dy+0.55*s,z-0.72*s,72,0,0),C.charcoal,Enum.Material.Metal,0)
    end
    local red=makeLens(model,"RedLens",cf(x,height-1.3*s+2.25*s,z-0.84*s),C.red,C.redOff,0.42,7)
    local amber=makeLens(model,"AmberLens",cf(x,height-1.3*s,z-0.84*s),C.amber,C.amberOff,0.40,7)
    local green=makeLens(model,"GreenLens",cf(x,height-1.3*s-2.25*s,z-0.84*s),C.green,C.greenOff,0.38,7)
    if label then textSign(model,"SignalPlate",Vector3.new(4.0*s,1.35*s,0.16),cf(x,height-5.7*s,z-0.86*s),label,C.cream) end
    model:SetAttribute("SignalRole",name)
    return {model=model,red=red,amber=amber,green=green}
end

-- Main hero signal, kept on the rail-side shoulder outside player circulation.
local main=makeThreeAspect(mainSignals,"MainSignal_T01",35.5,78,15.5,1.0,"T01  /  MAIN")
-- Platform end signals, intentionally slim and non-colliding.
local pNorth=makeThreeAspect(platformSignals,"PlatformSignal_North",9.5,-104,11.5,0.72,"P1  N")
local pSouth=makeThreeAspect(platformSignals,"PlatformSignal_South",9.5,118,11.5,0.72,"P1  S")
-- End-of-line stop signal: red is the permanent hero state.
local endSignal=makeThreeAspect(mainSignals,"EndOfLine_StopSignal",34.8,134.5,12.5,0.80,"STOP  /  EOL")
setLens(endSignal.red,true)

-- Restricted/service warning lamps pair with the existing POLICE LINE treatment.
local restrictedSpecs={
    {name="OpsDoorWarning",x=-51,y=11.4,z=-148.0},
    {name="ToiletServiceWarning",x=-24,y=11.4,z=-148.0},
    {name="TicketCounterWarning",x=-54,y=12.0,z=-132.2},
    {name="SignalPocketWarning",x=35,y=6.4,z=147.0},
}
local warningLamps={}
for _,spec in ipairs(restrictedSpecs) do
    local housing=part(restrictedSignals,spec.name.."Housing",Vector3.new(2.0,2.0,0.55),cf(spec.x,spec.y,spec.z),C.black,Enum.Material.Metal,0)
    local lens=ball(restrictedSignals,spec.name.."RedBeacon",Vector3.new(1.15,1.15,0.40),cf(spec.x,spec.y,spec.z-0.34),C.redOff,Enum.Material.Glass,0.05)
    local light=Instance.new("PointLight")
    light.Name="RestrictedGlow"
    light.Color=C.red
    light.Brightness=0.28
    light.Range=5
    light.Shadows=false
    light.Enabled=false
    light.Parent=lens
    lens:SetAttribute("WarningLens",true)
    table.insert(warningLamps,lens)
    housing:SetAttribute("RestrictedSignal",true)
end

-- The Yard photo-signal: authentic railway silhouette, not a generic neon prop.
local yard=makeThreeAspect(yardSignals,"YardPhotoSignal",-68,88,13.5,0.86,"YARD  01")
setLens(yard.amber,true)
part(yardSignals,"YardSignalSleeper",Vector3.new(12,0.45,2.2),cf(-68,0.42,88),Color3.fromRGB(74,52,39),Enum.Material.WoodPlanks,0)
textSign(yardSignals,"YardPhotoCaption",Vector3.new(13,2.3,0.20),cf(-68,4.5,84.5),"NO DESTINATION  /  SIGNAL 01",C.cream)

-- Rail-side reflective marker plates for extra depth at night.
for _,spec in ipairs({{34.4,62,"S-01"},{34.4,101,"S-02"},{33.8,128,"STOP"}}) do
    local x,z,label=spec[1],spec[2],spec[3]
    local plate=textSign(mainSignals,"ReflectiveMarker_"..label,Vector3.new(3.0,1.4,0.14),cf(x,3.3,z),label,(label=="STOP") and C.red or C.cream)
    plate.Material=Enum.Material.Metal
end

-- Low-frequency state logic: cinematic, not arcade-like.
task.spawn(function()
    local sequence={
        {main="green",north="green",south="amber",duration=16},
        {main="amber",north="amber",south="green",duration=7},
        {main="red",north="green",south="amber",duration=5},
        {main="green",north="amber",south="green",duration=18},
    }
    local function apply(sig,state)
        setLens(sig.red,state=="red")
        setLens(sig.amber,state=="amber")
        setLens(sig.green,state=="green")
    end
    while folder.Parent do
        for _,state in ipairs(sequence) do
            apply(main,state.main)
            apply(pNorth,state.north)
            apply(pSouth,state.south)
            task.wait(state.duration)
            if not folder.Parent then return end
        end
    end
end)

-- Slow red warning pulse for restricted areas.
task.spawn(function()
    local on=false
    while folder.Parent do
        on=not on
        for _,lens in ipairs(warningLamps) do
            if lens.Parent then
                lens.Color=on and C.red or C.redOff
                lens.Material=on and Enum.Material.Neon or Enum.Material.Glass
                local light=lens:FindFirstChild("RestrictedGlow")
                if light then light.Enabled=on end
            end
        end
        task.wait(on and 1.15 or 2.65)
    end
end)

root:SetAttribute("SignalNightVersion","3.3.0")
root:SetAttribute("SignalPointCount",8)
Workspace:SetAttribute("ACC_TRACK01_SIGNAL_NIGHT_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.3.0")
print("[TRACK 01] railway signal + night atmosphere ready v3.3.0")
